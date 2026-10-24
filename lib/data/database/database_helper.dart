import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/song_model.dart';
import '../models/category_model.dart';
import '../models/search_filter.dart';
import '../models/highlight_model.dart';
import '../models/note_model.dart';
import '../models/link_model.dart';
import '../../utils/app_logger.dart';
import '../../constants/app_constants.dart';

/// A singleton class to manage the SQLite database connection and queries.
class DatabaseHelper {
  // Singleton pattern setup
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Future<Database>? _databaseFuture;
  static const String _dbName = "thiruppugazh.db";
  static const int _dbVersion = AppConstants.dbVersion;

  /// True if this run's [_initDatabase] had to (re)copy the database from
  /// the bundled asset -- i.e. there was no usable database on disk before
  /// this launch. Used by the auto-backup restore check to distinguish a
  /// genuinely fresh install from an ordinary reopen; only meaningful after
  /// [database] has been awaited at least once.
  bool _wasFreshlyCreated = false;
  bool get wasFreshlyCreated => _wasFreshlyCreated;

  /// Called after any write that changes backup-relevant data (favorites,
  /// categories, notes, highlights). Set by [AutoBackupService] at startup
  /// to schedule a debounced re-write of the auto-backup snapshot.
  static void Function()? onMutation;

  /// Returns the singleton database instance, initializing it if necessary.
  /// Caches the Future itself so concurrent callers all await the same init.
  Future<Database> get database => _databaseFuture ??= _initDatabase();

  /// Runs [action] inside a single sqflite transaction. Pass the given
  /// [Transaction] as the `executor` argument to the executor-aware helper
  /// methods below so their writes participate in the same transaction and
  /// roll back together on failure.
  Future<T> runInTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return db.transaction(action);
  }

  /// How many times [_copyDatabaseFromAssets] will (re)try a fresh copy if
  /// the result doesn't verify. A second attempt is cheap insurance against
  /// a one-off partial write (e.g. a device briefly out of storage); it's
  /// not expected to help if the device is persistently out of space, but
  /// in that case the final attempt's exception still surfaces instead of
  /// silently leaving every screen empty.
  static const int _copyVerifyMaxAttempts = 2;

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // Check if the database exists
    final exists = await databaseExists(path);

    if (!exists) {
      await _copyDatabaseFromAssets(path);
      _wasFreshlyCreated = true;
    } else if (await _isDatabaseUsable(path)) {
      AppLogger.info("Opening existing database");
    } else {
      // A file is there, but it's not a usable songs database (corrupted,
      // truncated, or otherwise broken -- e.g. from an interrupted copy
      // on some past launch). databaseExists() only checks that *some*
      // file is present at this path, not that it's valid, so without
      // this check a bad file here would be silently trusted forever:
      // every future launch would open it, find no data, and show every
      // screen empty with no error and no way to recover short of
      // clearing app data. Re-copy from the bundled asset instead.
      AppLogger.error(
        "Existing database failed verification; re-copying from assets",
      );
      await _copyDatabaseFromAssets(path);
      _wasFreshlyCreated = true;
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enable foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Since we copied the asset, 'songs' table should exist.
        // We need to ensure other tables exist and populate temples.
        await _initializeSchema(db);
        await _addIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _addIndexes(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          await _migrateToV4(db);
        }
        if (oldVersion < 5) {
          await migrateToV5(db);
        }
        if (oldVersion < 6) {
          await migrateToV6(db);
        }
      },
      onOpen: (db) async {
        // Ensure schema is up to date even on open if needed
        // (Optional, but safe for dev environments where asset might be replaced)
        // For now, we rely on onCreate/onUpgrade
      },
    );
  }

  /// Copies the bundled database asset to [path] and verifies the result
  /// is actually readable and non-empty before trusting it. A silently
  /// partial/corrupted copy (device low on storage, process killed
  /// mid-write, etc.) would otherwise leave every screen looking empty
  /// with no error anywhere -- this makes that failure mode loud (and
  /// gives it one retry) instead of silent.
  Future<void> _copyDatabaseFromAssets(String path) async {
    Object? lastError;
    StackTrace? lastStackTrace;

    for (
      var attempt = 1;
      attempt <= _copyVerifyMaxAttempts;
      attempt++
    ) {
      try {
        AppLogger.info("Creating new copy from asset (attempt $attempt)");
        await Directory(dirname(path)).create(recursive: true);

        ByteData data = await rootBundle.load('assets/thiruppugazh.db');
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await File(path).writeAsBytes(bytes, flush: true);

        final count = await _countSongs(path);
        if (count == 0) {
          throw StateError(
            'Copied database has no songs -- likely a partial/corrupt copy',
          );
        }
        AppLogger.info("Database copied from assets ($count songs)");
        return;
      } catch (e, stackTrace) {
        lastError = e;
        lastStackTrace = stackTrace;
        AppLogger.error(
          "Failed to copy/verify bundled database (attempt $attempt)",
          error: e,
          stackTrace: stackTrace,
        );
        // Don't leave a partial/corrupt file behind for the next attempt
        // (or for a future launch, if this was the last attempt) to
        // mistake for a valid, already-copied database.
        final partialFile = File(path);
        if (await partialFile.exists()) {
          try {
            await partialFile.delete();
          } catch (_) {
            // Best-effort cleanup; the rethrow below still surfaces the
            // original failure either way.
          }
        }
      }
    }

    AppLogger.error(
      "Fatal: failed to copy bundled database after "
      "$_copyVerifyMaxAttempts attempts",
      error: lastError,
      stackTrace: lastStackTrace,
    );
    // ignore: only_throw_errors
    throw lastError ?? StateError('Failed to copy bundled database');
  }

  /// Opens the sqlite file at [path] read-only and returns how many rows
  /// are in `songs`. Throws if the file can't be opened at all (not a
  /// valid sqlite file, corrupted header, etc.) or doesn't have a `songs`
  /// table -- callers decide whether that should be fatal or just mean
  /// "not usable, try recopying".
  Future<int> _countSongs(String path) async {
    final db = await openReadOnlyDatabase(path);
    try {
      return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM songs'),
          ) ??
          0;
    } finally {
      await db.close();
    }
  }

  /// Whether the sqlite file already at [path] is a valid, non-empty
  /// songs database -- i.e. safe to open and use as-is. `databaseExists`
  /// only checks that *some* file is present at this path, not that it's
  /// usable, so a corrupted/truncated file left over from some past
  /// launch (e.g. an interrupted copy, before [_copyDatabaseFromAssets]
  /// grew its own verification) would otherwise be trusted forever: every
  /// future launch would open it, find no data, and show every screen
  /// empty with no error and no way to recover short of clearing app
  /// data.
  Future<bool> _isDatabaseUsable(String path) async {
    try {
      return await _countSongs(path) > 0;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Existing database failed usability check',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> _initializeSchema(Database db) async {
    AppLogger.info("Initializing database schema");

    // 1. Ensure 'songs' table exists (it should from asset)
    // If not, we have a problem, but let's define it just in case of empty db creation
    await db.execute('''
      CREATE TABLE IF NOT EXISTS songs(
        id                    INTEGER PRIMARY KEY,
        title                 TEXT NOT NULL,
        lyrics                TEXT,
        tune                  TEXT,
        place                 TEXT,
        kaumaram_id           TEXT,
        tune_list             TEXT,
        lyrics_list           TEXT,
        words                 TEXT,
        meanings              TEXT,
        pathavurai            TEXT,
        patham                TEXT,
        search_content        TEXT,
        is_favorite           INTEGER DEFAULT 0,
        english_title         TEXT,
        english_venue         TEXT,
        english_tune_list     TEXT,
        english_lyrics_list   TEXT,
        english_words         TEXT,
        english_meanings_list TEXT,
        english_pathavurai    TEXT,
        mayuragiri_lyrics_separated         TEXT,
        mayuragiri_english_lyrics_separated TEXT
      )
    ''');

    // 2. Create Categories table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    // Insert default 'Favorites' category if it doesn't exist
    await db.execute('''
      INSERT OR IGNORE INTO categories (id, name) VALUES (1, 'Favorites')
    ''');

    // 3. Create Song Categories mapping table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS song_categories(
        song_id INTEGER,
        category_id INTEGER,
        PRIMARY KEY (song_id, category_id),
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE,
        FOREIGN KEY(category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 4. Create Temples table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS temples(
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        name         TEXT NOT NULL UNIQUE,
        song_count   INTEGER DEFAULT 0,
        english_name TEXT
      )
    ''');

    // 5. Create Highlights table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS highlights(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        verse_index INTEGER NOT NULL,
        text_content TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // 6. Create Notes table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    // 6b. Create Links table
    await _createLinksTable(db);

    // 7. Populate Temples Table
    // We only want to populate if it's empty to avoid re-calculating on every open/upgrade unnecessarily,
    // unless we want to ensure sync.
    // Let's check count first.
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM temples'),
    );

    if (count == 0) {
      AppLogger.info('Populating temples table');
      final List<Map<String, dynamic>> places = await db.rawQuery('''
        SELECT place, COUNT(*) as count
        FROM songs
        WHERE place IS NOT NULL AND place != ''
        GROUP BY place
      ''');

      final batch = db.batch();
      for (final place in places) {
        batch.insert('temples', {
          'name': place['place'],
          'song_count': place['count'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    }

    // 8. Ensure is_favorite column exists in songs (if asset didn't have it)
    await _addColumnIfMissing(
      db,
      table: 'songs',
      column: 'is_favorite',
      definition: 'INTEGER DEFAULT 0',
    );
  }

  /// Adds `$column` to `$table` only if it isn't already there.
  ///
  /// Every migration below ships a bundled asset database that, by the
  /// time a given app version reaches most devices, may *already* have
  /// gone through this migration once -- either because a fresh install's
  /// onCreate path uses the current, already-up-to-date bundled schema
  /// (fresh installs never run these migrations, see [_initDatabase]'s
  /// version-0-vs-onCreate handling), or because a future migration is
  /// added that overlaps one already applied. A bare `ALTER TABLE ADD
  /// COLUMN` throws "duplicate column name" in that case, and since these
  /// calls sit outside any try/catch, that exception used to propagate
  /// all the way up through the single cached `database` Future --
  /// poisoning every future call to it and leaving every screen silently
  /// empty with no visible error. Checking first makes this idempotent.
  Future<void> _addColumnIfMissing(
    Database db, {
    required String table,
    required String column,
    required String definition,
  }) async {
    try {
      await db.rawQuery('SELECT $column FROM $table LIMIT 1');
      // Column already exists -- nothing to do.
    } catch (_) {
      AppLogger.info('Adding $column column to $table');
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }

  Future<void> _addIndexes(Database db) async {
    // Index for fast favorite lookups (WHERE is_favorite = 1)
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_songs_is_favorite
      ON songs(is_favorite)
    ''');

    // Index for fast category-based song lookups
    // (composite PK covers song_id first; this covers category_id queries)
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_song_categories_category_id
      ON song_categories(category_id)
    ''');

    // Index for fast highlight lookups by song
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_highlights_song_id
      ON highlights(song_id)
    ''');

    // Index for fast note lookups by song
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_notes_song_id
      ON notes(song_id)
    ''');
  }

  Future<void> _createLinksTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS links(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        url TEXT NOT NULL,
        title TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE INDEX IF NOT EXISTS idx_links_song_id
      ON links(song_id)
    ''');
  }

  /// v6: adds the user-owned `links` table. Purely additive; existing data is
  /// untouched. Idempotent, and non-fatal so a failure here can't block the
  /// app from opening (links would simply be unavailable).
  @visibleForTesting
  Future<void> migrateToV6(Database db) async {
    AppLogger.info('Running v6 migration: adding links table');
    try {
      await _createLinksTable(db);
    } catch (e, st) {
      AppLogger.error(
        'v6 migration: failed to create links table',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> _migrateToV3(Database db) async {
    AppLogger.info('Running v3 migration: adding English content columns');

    // Step 1: Add English columns to songs (all nullable)
    for (final col in [
      'english_title',
      'english_venue',
      'english_tune_list',
      'english_lyrics_list',
      'english_words',
      'english_meanings_list',
      'english_pathavurai',
    ]) {
      await _addColumnIfMissing(
        db,
        table: 'songs',
        column: col,
        definition: 'TEXT',
      );
    }

    // Step 2: Add english_name to temples
    await _addColumnIfMissing(
      db,
      table: 'temples',
      column: 'english_name',
      definition: 'TEXT',
    );

    // Step 3: Populate songs English columns from bundled JSON asset
    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.englishDataAsset,
      );
      final Map<String, dynamic> patch = jsonDecode(jsonString);

      final batch = db.batch();
      for (final entry in patch.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final fields = entry.value as Map<String, dynamic>;
        batch.update(
          'songs',
          {
            'english_title': fields['english_title'],
            'english_venue': fields['english_venue'],
            'english_tune_list': fields['english_tune_list'],
            'english_lyrics_list': fields['english_lyrics_list'],
            'english_words': fields['english_words'],
            'english_meanings_list': fields['english_meanings_list'],
            'english_pathavurai': fields['english_pathavurai'],
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
      AppLogger.info(
        'v3 migration: populated English data for ${patch.length} songs',
      );
    } catch (e, st) {
      AppLogger.error(
        'v3 migration: failed to populate English data',
        error: e,
        stackTrace: st,
      );
      // Non-fatal: English columns remain NULL, app falls back to Tamil
    }

    // Step 4: Populate temples.english_name from songs (runs after Step 3)
    await db.execute('''
      UPDATE temples
      SET english_name = (
        SELECT english_venue FROM songs
        WHERE songs.place = temples.name
          AND songs.english_venue IS NOT NULL
        LIMIT 1
      )
    ''');

    AppLogger.info('v3 migration complete');
  }

  /// Columns a v5 song-fix patch is allowed to touch. Deliberately excludes
  /// `is_favorite` (user data) and identity columns.
  static const List<String> _v5PatchableColumns = [
    'lyrics',
    'tune',
    'tune_list',
    'lyrics_list',
    'pathavurai',
    'search_content',
    'mayuragiri_lyrics_separated',
  ];

  /// v5: corrects songs whose source data was mis-parsed at release (lyrics
  /// stored in the tune column, etc.). Patches rows in place with UPDATE
  /// only -- never delete/replace, since notes, highlights and category
  /// links cascade-delete with the song row. Idempotent.
  ///
  /// [loadPatch] exists so tests can supply the patch without an asset bundle.
  @visibleForTesting
  Future<void> migrateToV5(
    Database db, {
    Future<String> Function()? loadPatch,
    Future<String> Function()? loadRestore,
  }) async {
    await _applySongFixesV5(db, loadPatch);
    await _restoreMissingSongsV5(db, loadRestore);
  }

  Future<void> _applySongFixesV5(
    Database db,
    Future<String> Function()? loadPatch,
  ) async {
    AppLogger.info('Running v5 migration: correcting mis-parsed songs');
    try {
      final jsonString = await (loadPatch ??
          () => rootBundle.loadString(AppConstants.songFixesV5Asset))();
      final Map<String, dynamic> patch = jsonDecode(jsonString);

      // Devices upgrading from very old releases may lack some columns
      // (e.g. `search_content`); patch only what actually exists so one
      // missing column can't make the whole batch fail.
      final existing = {
        for (final row in await db.rawQuery('PRAGMA table_info(songs)'))
          row['name'] as String,
      };

      final batch = db.batch();
      for (final entry in patch.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final fields = entry.value as Map<String, dynamic>;
        final values = {
          for (final col in _v5PatchableColumns)
            if (fields.containsKey(col) && existing.contains(col))
              col: fields[col],
        };
        if (values.isEmpty) continue;
        batch.update('songs', values, where: 'id = ?', whereArgs: [id]);
      }
      await batch.commit(noResult: true);
      AppLogger.info('v5 migration: corrected ${patch.length} songs');
    } catch (e, st) {
      AppLogger.error(
        'v5 migration: failed to apply song fixes',
        error: e,
        stackTrace: st,
      );
      // Non-fatal: songs keep their previous (flawed) content.
    }
  }

  /// v5: songs 1-6 were dropped from the bundled DB at the 1.2.0 rebuild, so
  /// installs since then lack them. Re-insert them with INSERT OR IGNORE:
  /// devices that already have a row (upgraders from 1.1.0) are left exactly
  /// as they are, and a restored song always starts unfavorited. Temples are
  /// brought in line afterwards. Idempotent and non-fatal.
  Future<void> _restoreMissingSongsV5(
    Database db,
    Future<String> Function()? loadRestore,
  ) async {
    AppLogger.info('Running v5 migration: restoring songs dropped in 1.2.0');
    try {
      final jsonString = await (loadRestore ??
          () => rootBundle.loadString(AppConstants.songRestoreV5Asset))();
      final Map<String, dynamic> restore = jsonDecode(jsonString);

      final existing = {
        for (final row in await db.rawQuery('PRAGMA table_info(songs)'))
          row['name'] as String,
      };

      final places = <String>{};
      final batch = db.batch();
      for (final entry in restore.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final fields = entry.value as Map<String, dynamic>;
        final values = <String, Object?>{
          for (final e in fields.entries)
            if (existing.contains(e.key) && e.key != 'is_favorite')
              e.key: e.value,
          'id': id,
        };
        batch.insert(
          'songs',
          values,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        final place = fields['place'];
        if (place is String && place.isNotEmpty) places.add(place);
      }
      await batch.commit(noResult: true);

      // Keep the temples list in step with the songs table.
      for (final place in places) {
        await db.insert(
          'temples',
          {'name': place},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
        await db.rawUpdate(
          'UPDATE temples SET song_count = '
          '(SELECT COUNT(*) FROM songs WHERE place = ?) WHERE name = ?',
          [place, place],
        );
      }
      AppLogger.info('v5 migration: processed ${restore.length} restored songs');
    } catch (e, st) {
      AppLogger.error(
        'v5 migration: failed to restore songs',
        error: e,
        stackTrace: st,
      );
      // Non-fatal: the songs stay absent, as before.
    }
  }

  Future<void> _migrateToV4(Database db) async {
    AppLogger.info(
      'Running v4 migration: adding Mayuragiri word-separated lyrics columns',
    );

    for (final col in [
      'mayuragiri_lyrics_separated',
      'mayuragiri_english_lyrics_separated',
    ]) {
      await _addColumnIfMissing(
        db,
        table: 'songs',
        column: col,
        definition: 'TEXT',
      );
    }

    try {
      final jsonString = await rootBundle.loadString(
        AppConstants.mayuragiriDataAsset,
      );
      final Map<String, dynamic> patch = jsonDecode(jsonString);

      final batch = db.batch();
      for (final entry in patch.entries) {
        final id = int.tryParse(entry.key);
        if (id == null) continue;
        final fields = entry.value as Map<String, dynamic>;
        batch.update(
          'songs',
          {
            'mayuragiri_lyrics_separated':
                fields['mayuragiri_lyrics_separated'],
            'mayuragiri_english_lyrics_separated':
                fields['mayuragiri_english_lyrics_separated'],
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      await batch.commit(noResult: true);
      AppLogger.info(
        'v4 migration: populated Mayuragiri data for ${patch.length} songs',
      );
    } catch (e, st) {
      AppLogger.error(
        'v4 migration: failed to populate Mayuragiri data',
        error: e,
        stackTrace: st,
      );
      // Non-fatal: Mayuragiri columns remain NULL, section stays hidden
    }
  }

  // --- Highlights Methods ---

  Future<int> addHighlight(Highlight highlight, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final rows = await db.insert('highlights', highlight.toMap());
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<int> removeHighlight(
    int songId,
    int verseIndex, {
    DatabaseExecutor? executor,
  }) async {
    final DatabaseExecutor db = executor ?? await database;
    final rows = await db.delete(
      'highlights',
      where: 'song_id = ? AND verse_index = ?',
      whereArgs: [songId, verseIndex],
    );
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<List<Highlight>> getHighlightsForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'highlights',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    return List.generate(maps.length, (i) => Highlight.fromMap(maps[i]));
  }

  Future<List<Highlight>> getAllHighlights() async {
    final db = await database;
    final maps = await db.query('highlights', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => Highlight.fromMap(maps[i]));
  }

  /// Returns all highlights joined with their song titles in one query.
  /// Each map contains all highlight columns plus `song_title`.
  Future<List<Map<String, dynamic>>> getHighlightsWithSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT h.id, h.song_id, h.verse_index, h.text_content, h.created_at,
             s.title AS song_title
      FROM highlights h
      INNER JOIN songs s ON h.song_id = s.id
      ORDER BY h.created_at DESC
    ''');
  }

  // --- Notes Methods ---

  Future<int> saveNote(Note note, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final existing = await db.query(
      'notes',
      where: 'song_id = ?',
      whereArgs: [note.songId],
    );

    late int rows;
    if (existing.isNotEmpty) {
      rows = await db.update(
        'notes',
        {
          'content': note.content,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'song_id = ?',
        whereArgs: [note.songId],
      );
    } else {
      rows = await db.insert('notes', note.toMap());
    }
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<Note?> getNoteForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    if (maps.isEmpty) return null;
    return Note.fromMap(maps.first);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => Note.fromMap(maps[i]));
  }

  /// Returns all notes joined with their song titles in one query.
  /// Each map contains all note columns plus `song_title`.
  Future<List<Map<String, dynamic>>> getNotesWithSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT n.id, n.song_id, n.content, n.created_at, n.updated_at,
             s.title AS song_title
      FROM notes n
      INNER JOIN songs s ON n.song_id = s.id
      ORDER BY n.updated_at DESC
    ''');
  }

  Future<void> deleteNote(int songId) async {
    final db = await database;
    await db.delete('notes', where: 'song_id = ?', whereArgs: [songId]);
    DatabaseHelper.onMutation?.call();
  }

  // --- Links Methods ---

  Future<int> addLink(SongLink link, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final id = await db.insert('links', link.toMap()..remove('id'));
    DatabaseHelper.onMutation?.call();
    return id;
  }

  /// Inserts [link] unless this song already has the same URL. Returns true
  /// if a row was added. Used by backup import so re-importing a backup never
  /// duplicates links.
  Future<bool> addLinkIfAbsent(
    SongLink link, {
    DatabaseExecutor? executor,
  }) async {
    final DatabaseExecutor db = executor ?? await database;
    final existing = await db.query(
      'links',
      columns: ['id'],
      where: 'song_id = ? AND url = ?',
      whereArgs: [link.songId, link.url],
      limit: 1,
    );
    if (existing.isNotEmpty) return false;
    await addLink(link, executor: db);
    return true;
  }

  Future<void> deleteLink(int id) async {
    final db = await database;
    await db.delete('links', where: 'id = ?', whereArgs: [id]);
    DatabaseHelper.onMutation?.call();
  }

  Future<List<SongLink>> getLinksForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'links',
      where: 'song_id = ?',
      whereArgs: [songId],
      orderBy: 'created_at ASC',
    );
    return List.generate(maps.length, (i) => SongLink.fromMap(maps[i]));
  }

  Future<List<SongLink>> getAllLinks() async {
    final db = await database;
    final maps = await db.query('links', orderBy: 'created_at DESC');
    return List.generate(maps.length, (i) => SongLink.fromMap(maps[i]));
  }

  /// Returns all links joined with their song titles in one query.
  /// Each map contains all link columns plus `song_title`.
  Future<List<Map<String, dynamic>>> getLinksWithSongs() async {
    final db = await database;
    return await db.rawQuery('''
      SELECT l.id, l.song_id, l.url, l.title, l.created_at,
             s.title AS song_title
      FROM links l
      INNER JOIN songs s ON l.song_id = s.id
      ORDER BY l.created_at DESC
    ''');
  }

  // --- Query Methods ---

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<Song?> getSongById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  Future<Song?> getRandomSong() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT * FROM songs ORDER BY RANDOM() LIMIT 1',
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  /// Fetches the song at [index] in a stable id-ordered sequence -- used by
  /// the date-seeded "song of the day" pick, which needs an actual song for
  /// an index in `[0, getSongsCount())` without loading every song into
  /// memory.
  Future<Song?> getSongByIndex(int index) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      orderBy: 'id',
      limit: 1,
      offset: index,
    );
    if (maps.isEmpty) return null;
    return Song.fromMap(maps.first);
  }

  Future<List<Song>> getSongsPaginated({
    int page = 0,
    int pageSize = 20,
  }) async {
    try {
      final db = await database;
      final offset = page * pageSize;
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        orderBy: 'title',
        limit: pageSize,
        offset: offset,
      );
      AppLogger.info(
        'Retrieved ${maps.length} songs (page $page, pageSize $pageSize)',
      );
      return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error fetching paginated songs: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<int> getSongsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
      final count = Sqflite.firstIntValue(result) ?? 0;
      AppLogger.info('Total songs in database: $count');
      return count;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error getting songs count: $e',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<List<Song>> searchSongs(String query) async {
    final filter = SearchFilter(query: query);
    return searchSongsWithFilter(filter);
  }

  Future<List<Song>> searchSongsWithFilter(SearchFilter filter) async {
    final db = await database;

    if (filter.query.isEmpty) {
      return [];
    }

    // Validate and sanitize search query
    final sanitizedQuery = _sanitizeSearchQuery(filter.query);

    if (sanitizedQuery.isEmpty) {
      return [];
    }

    // Build dynamic WHERE clause based on filter flags
    final List<String> conditions = [];
    final List<dynamic> args = [];
    final exactQuery = sanitizedQuery;

    // Generate variations for Tamil spelling tolerance (e.g. ன vs ந)
    final variations = _getTamilVariations(sanitizedQuery);

    void addLikeConditions(String tamilField, [String? englishField]) {
      if (variations.isEmpty) return;
      final fieldConditions = <String>[];
      for (var _ in variations) {
        fieldConditions.add('$tamilField LIKE ?');
      }
      args.addAll(variations.map((v) => '%$v%'));

      if (englishField != null) {
        fieldConditions.add('$englishField LIKE ?');
        args.add('%$sanitizedQuery%');
      }
      conditions.add('(${fieldConditions.join(' OR ')})');
    }

    if (filter.searchTitle) {
      addLikeConditions('title', 'english_title');
    }

    // For lyrics, we also check 'words' as it often contains the segmented words useful for search
    if (filter.searchLyrics) {
      addLikeConditions('lyrics', 'english_lyrics_list');
      addLikeConditions('words', 'english_words');
    }

    if (filter.searchPlace) {
      addLikeConditions('place', 'english_venue');

      // Temple names are stored in english_venue using a formal scholarly
      // transliteration (e.g. "thiruchchendhUr" for திருச்செந்தூர்), which
      // rarely matches a casual "Tanglish" spelling like "thiruchendur"
      // via plain substring LIKE. Add a second, additive condition that
      // compares a simplified/normalized form of both sides instead --
      // this only widens matches (the exact-substring condition above
      // still applies), so it can't cause an existing search to lose
      // results.
      final normalizedQuery = _normalizeTanglish(sanitizedQuery);
      if (normalizedQuery.isNotEmpty) {
        conditions.add('${_tanglishNormalizedSql('english_venue')} LIKE ?');
        args.add('%$normalizedQuery%');
      }
    }

    if (filter.searchTune) {
      addLikeConditions('tune'); // no English tune search
    }

    if (filter.searchKaumaramId) {
      // Exact match for Kaumaram ID as requested
      conditions.add('kaumaram_id = ?');
      args.add(exactQuery);
    }

    if (filter.searchPathavurai) {
      addLikeConditions('pathavurai', 'english_pathavurai');
    }

    // If no specific filter is selected, fallback... (handled by returning empty above if conditions empty)

    if (conditions.isEmpty) {
      return [];
    }

    final whereClause = conditions.join(' OR ');

    // AppLogger.info('Searching with Clause: $whereClause');
    // AppLogger.info('Args: $args');

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT * FROM songs
      WHERE $whereClause
      ORDER BY title
      LIMIT 50
    ''', args);

    return results.map((songMap) => Song.fromMap(songMap)).toList();
  }

  /// Generates variations for common Tamil spelling differences.
  /// Currently handles:
  /// - ன (U+0BA9) <-> ந (U+0BA8)
  List<String> _getTamilVariations(String query) {
    final Set<String> variations = {query};

    // Handle ன (Nna - Alveolar) vs ந (Na - Dental) mismatch
    // These are often confused in spelling (e.g., Palani: பழனி vs பழநி)
    if (query.contains('ன')) {
      variations.add(query.replaceAll('ன', 'ந'));
    }
    if (query.contains('ந')) {
      variations.add(query.replaceAll('ந', 'ன'));
    }

    // We could add more here (ra/Ra, la/La/zha) if needed later.

    return variations.toList();
  }

  /// Ordered find/replace pairs collapsing the formal scholarly
  /// transliteration scheme used throughout `english_venue` (and
  /// elsewhere) toward a casual "Tanglish" spelling -- e.g.
  /// "thiruchchendhUr" -> "tiruchendur", matching how most people would
  /// actually type Thiruchendur. Order matters: digraph-doubling and
  /// single-letter-doubling collapse first, so a later single-letter rule
  /// (like th -> t) doesn't interfere with an earlier digraph rule (like
  /// thth -> th). Verified against every temple name currently in the
  /// bundled database (see PR description / commit message for the check
  /// script) -- every entry's own casually-simplified spelling matches
  /// itself after normalization.
  static const List<List<String>> _tanglishNormalizationRules = [
    ['chch', 'ch'],
    ['thth', 'th'],
    ['dhdh', 'dh'],
    ['shsh', 'sh'],
    ['aa', 'a'],
    ['ee', 'e'],
    ['kk', 'k'],
    ['ll', 'l'],
    ['mm', 'm'],
    ['nn', 'n'],
    ['pp', 'p'],
    ['tt', 't'],
    ['uu', 'u'],
    ['dh', 'd'],
    // zh (ழ) is very commonly typed as a plain "l" rather than "zh"/"z"
    // (e.g. Palani for பழநி, "pazhani"), so both collapse to the same
    // letter for matching purposes.
    ['zh', 'l'],
    ['th', 't'],
    ['ngk', 'nk'],
    ['ng', 'n'],
  ];

  /// Applies [_tanglishNormalizationRules] to a Dart string -- used to
  /// normalize the incoming search query. See [_tanglishNormalizedSql]
  /// for the equivalent transformation applied to a database column.
  String _normalizeTanglish(String s) {
    var result = s.toLowerCase();
    for (final rule in _tanglishNormalizationRules) {
      result = result.replaceAll(rule[0], rule[1]);
    }
    return result;
  }

  /// Builds a SQL expression that applies [_tanglishNormalizationRules]
  /// to [column] via chained `REPLACE()` calls, so it can be compared
  /// against a query already normalized by [_normalizeTanglish]. SQLite
  /// has no regex support, but every rule here is a plain substring
  /// replacement, so a REPLACE() chain is exact.
  String _tanglishNormalizedSql(String column) {
    var expr = 'LOWER($column)';
    for (final rule in _tanglishNormalizationRules) {
      expr = "REPLACE($expr, '${rule[0]}', '${rule[1]}')";
    }
    return expr;
  }

  /// Trims and length-limits the search query.
  /// SQL injection is prevented by parameterised queries (whereArgs),
  /// not by character removal.
  String _sanitizeSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed.length > AppConstants.maxSearchQueryLength) {
      return trimmed.substring(0, AppConstants.maxSearchQueryLength);
    }
    return trimmed;
  }

  Future<List<Category>> getCategoriesWithSongCounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.id, c.name, 
        CASE 
          WHEN c.id = 1 THEN (SELECT COUNT(*) FROM songs WHERE is_favorite = 1)
          ELSE COUNT(sc.song_id)
        END AS song_count
      FROM categories c
      LEFT JOIN song_categories sc ON c.id = sc.category_id
      GROUP BY c.id, c.name ORDER BY c.id
    ''');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  Future<int> createCategory(String name, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final rows = await db.insert('categories', {
      'name': name,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<int> updateCategory(int id, String name) async {
    final db = await database;
    final rows = await db.update(
      'categories',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<void> deleteCategory(int id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
    DatabaseHelper.onMutation?.call();
  }

  Future<int> addSongToCategory(
    int songId,
    int categoryId, {
    DatabaseExecutor? executor,
  }) async {
    final DatabaseExecutor db = executor ?? await database;
    final rows = await db.insert('song_categories', {
      'song_id': songId,
      'category_id': categoryId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    DatabaseHelper.onMutation?.call();
    return rows;
  }

  Future<void> removeSongFromCategory(int songId, int categoryId) async {
    final db = await database;
    await db.delete(
      'song_categories',
      where: 'song_id = ? AND category_id = ?',
      whereArgs: [songId, categoryId],
    );
    DatabaseHelper.onMutation?.call();
  }

  Future<List<int>> getCategoryIdsForSong(int songId) async {
    final db = await database;
    final maps = await db.query(
      'song_categories',
      columns: ['category_id'],
      where: 'song_id = ?',
      whereArgs: [songId],
    );
    return maps.map((map) => map['category_id'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getAllSongCategories() async {
    final db = await database;
    return await db.query('song_categories');
  }

  Future<Category?> getCategoryByName(String name, {DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final maps = await db.query(
      'categories',
      where: 'name = ?',
      whereArgs: [name],
    );
    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  Future<List<Song>> getSongsByCategoryId(int categoryId) async {
    final db = await database;

    if (categoryId == 1) {
      final List<Map<String, dynamic>> maps = await db.query(
        'songs',
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'title',
      );
      return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
    }

    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT s.* FROM songs s
      INNER JOIN song_categories sc ON s.id = sc.song_id
      WHERE sc.category_id = ? ORDER BY s.title
    ''',
      [categoryId],
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getFavoriteSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  /// All song IDs currently in the (read-only, bundled) songs table. Used
  /// by import to skip backup entries that reference a song no longer
  /// present in this install, instead of letting a foreign-key violation
  /// abort the whole import.
  Future<Set<int>> getAllSongIds({DatabaseExecutor? executor}) async {
    final DatabaseExecutor db = executor ?? await database;
    final maps = await db.query('songs', columns: ['id']);
    return maps.map((m) => m['id'] as int).toSet();
  }

  // --- Temples Methods ---

  Future<List<Map<String, dynamic>>> getAllTemples() async {
    final db = await database;
    return await db.query('temples', orderBy: 'name');
  }

  Future<List<Song>> getSongsByTemple(String templeName) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'songs',
      where: 'place = ?',
      whereArgs: [templeName],
      orderBy: 'title',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<int> toggleFavorite(
    int songId,
    bool isFavorite, {
    DatabaseExecutor? executor,
  }) async {
    final DatabaseExecutor db = executor ?? await database;
    final rows = await db.update(
      'songs',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [songId],
    );
    DatabaseHelper.onMutation?.call();
    return rows;
  }
}
