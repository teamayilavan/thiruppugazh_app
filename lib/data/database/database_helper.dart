import 'dart:io';
import 'dart:math' show Random;
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
import 'database_schema.dart';
import 'search_text.dart';

/// A singleton class to manage the SQLite database connection and queries.
class DatabaseHelper {
  // Singleton pattern setup
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Future<Database>? _databaseFuture;

  /// Forgets the cached connection so a test can open a different database
  /// file through the normal startup path.
  @visibleForTesting
  static void resetForTesting() {
    _databaseFuture = null;
    _instance._wasFreshlyCreated = false;
    _instance._wasRecovered = false;
  }
  static const int _dbVersion = AppConstants.dbVersion;

  /// True if this run's [_initDatabase] had to (re)copy the database from
  /// the bundled asset -- i.e. there was no usable database on disk before
  /// this launch. Used by the auto-backup restore check to distinguish a
  /// genuinely fresh install from an ordinary reopen; only meaningful after
  /// [database] has been awaited at least once.
  bool _wasFreshlyCreated = false;
  bool get wasFreshlyCreated => _wasFreshlyCreated;

  /// True if an existing but unusable database file was set aside and
  /// replaced this run. The auto-backup restore uses it to run again even
  /// though it may already have run once on this device.
  bool _wasRecovered = false;
  bool get wasRecovered => _wasRecovered;

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
    final path = join(dbPath, AppConstants.dbName);

    // Check if the database exists
    final exists = await databaseExists(path);
    String? setAside;

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
      // Keep the old file rather than deleting it: it may still hold the
      // user's notes, highlights, categories and links.
      setAside = await _setAsideUnusableDatabase(path);
      await _copyDatabaseFromAssets(path);
      _wasFreshlyCreated = true;
      _wasRecovered = true;
    }

    final db = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        // Enable foreign keys
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Since we copied the asset, 'songs' table should exist.
        // We need to ensure other tables exist and populate temples.
        await DatabaseSchema.initializeSchema(db);
        await DatabaseSchema.addIndexes(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await DatabaseSchema.migrateToV2(db);
        }
        if (oldVersion < 3) {
          await DatabaseSchema.migrateToV3(db);
        }
        if (oldVersion < 4) {
          await DatabaseSchema.migrateToV4(db);
        }
        if (oldVersion < 5) {
          await DatabaseSchema.migrateToV5(db);
        }
        if (oldVersion < 6) {
          await DatabaseSchema.migrateToV6(db);
        }
      },
      onOpen: (db) async {
        // Safety net for the v6 migration, which is deliberately non-fatal:
        // if creating `links` ever failed once, the database would still be
        // marked v6 and never retried, leaving backups (which read links)
        // failing. Re-creating it is idempotent and costs next to nothing, so
        // do it on every open and the table can't stay missing.
        try {
          await DatabaseSchema.createLinksTable(db);
        } catch (e, st) {
          AppLogger.error(
            'Could not ensure the links table on open',
            error: e,
            stackTrace: st,
          );
        }
      },
    );

    if (setAside != null) {
      final rescued = await _rescueUserData(db, setAside);
      if (rescued) {
        await _deleteQuietly(setAside);
      }
    }
    return db;
  }

  /// Prefix of the name an unusable database is renamed to.
  static const String _setAsideInfix = '.corrupt-';

  /// Renames the unusable database at [path] out of the way (keeping at most
  /// one such file) and returns its new path, or null if that wasn't
  /// possible -- in which case the caller's copy simply overwrites it, as
  /// before.
  Future<String?> _setAsideUnusableDatabase(String path) async {
    try {
      final dir = Directory(dirname(path));
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is File &&
            basename(entity.path).startsWith('${basename(path)}$_setAsideInfix')) {
          await _deleteQuietly(entity.path);
        }
      }
      final target =
          '$path$_setAsideInfix${DateTime.now().millisecondsSinceEpoch}';
      await File(path).rename(target);
      return target;
    } catch (e, st) {
      AppLogger.error(
        'Could not set the unusable database aside',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<void> _deleteQuietly(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {
      // Best-effort.
    }
  }

  /// Best-effort copy of the user's own tables from the set-aside database
  /// [oldPath] into the freshly copied [db]. Each table is tried on its own,
  /// so one unreadable table doesn't lose the others. Returns true only if
  /// every table copied cleanly (so the old file can then be deleted).
  Future<bool> _rescueUserData(Database db, String oldPath) async {
    var allOk = true;
    try {
      await db.execute('ATTACH DATABASE ? AS old', [oldPath]);
    } catch (e, st) {
      AppLogger.error(
        'Could not open the set-aside database for rescue',
        error: e,
        stackTrace: st,
      );
      return false;
    }
    const statements = <String, String>{
      'categories':
          'INSERT OR IGNORE INTO main.categories(id, name) '
          'SELECT id, name FROM old.categories',
      'song_categories':
          'INSERT OR IGNORE INTO main.song_categories(song_id, category_id) '
          'SELECT song_id, category_id FROM old.song_categories '
          'WHERE song_id IN (SELECT id FROM main.songs) '
          'AND category_id IN (SELECT id FROM main.categories)',
      'notes':
          'INSERT INTO main.notes(song_id, content, created_at, updated_at) '
          'SELECT song_id, content, created_at, updated_at FROM old.notes '
          'WHERE song_id IN (SELECT id FROM main.songs)',
      'highlights':
          'INSERT INTO main.highlights'
          '(song_id, verse_index, text_content, created_at) '
          'SELECT song_id, verse_index, text_content, created_at '
          'FROM old.highlights WHERE song_id IN (SELECT id FROM main.songs)',
      'links':
          'INSERT INTO main.links(song_id, url, title, created_at) '
          'SELECT song_id, url, title, created_at FROM old.links '
          'WHERE song_id IN (SELECT id FROM main.songs)',
      'favorites':
          'UPDATE main.songs SET is_favorite = 1 WHERE id IN '
          '(SELECT id FROM old.songs WHERE is_favorite = 1)',
    };
    for (final entry in statements.entries) {
      try {
        await db.execute(entry.value);
      } catch (e, st) {
        allOk = false;
        AppLogger.error(
          'Rescuing ${entry.key} from the set-aside database failed',
          error: e,
          stackTrace: st,
        );
      }
    }
    try {
      await db.execute('DETACH DATABASE old');
    } catch (_) {
      allOk = false;
    }
    return allOk;
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

  /// Kept on the helper for tests; see [DatabaseSchema.migrateToV5].
  @visibleForTesting
  Future<void> migrateToV5(
    Database db, {
    Future<String> Function()? loadPatch,
    Future<String> Function()? loadRestore,
  }) => DatabaseSchema.migrateToV5(
    db,
    loadPatch: loadPatch,
    loadRestore: loadRestore,
  );

  /// Kept on the helper for tests; see [DatabaseSchema.migrateToV6].
  @visibleForTesting
  Future<void> migrateToV6(Database db) => DatabaseSchema.migrateToV6(db);

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
    // A random offset into an id-ordered scan; ORDER BY RANDOM() would sort
    // every (wide) song row just to keep one.
    final count = Sqflite.firstIntValue(
      await (await database).rawQuery('SELECT COUNT(*) FROM songs'),
    );
    if (count == null || count == 0) return null;
    return getSongByIndex(Random().nextInt(count));
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

  /// Rows for the in-memory ranking index: titles plus only the first few
  /// hundred characters of the lyric lists, so building it never loads the
  /// full text of every song.
  Future<List<Map<String, Object?>>> getSearchIndexRows() async {
    final db = await database;
    return db.rawQuery('''
      SELECT id, kaumaram_id, title, english_title,
             substr(lyrics_list, 1, 400) AS lyrics_list_head,
             substr(english_lyrics_list, 1, 400) AS english_lyrics_list_head
      FROM songs
    ''');
  }

  /// Songs for [ids], in the order given. Ids with no song are skipped.
  Future<List<Song>> getSongsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final rows = await db.rawQuery(
      'SELECT * FROM songs WHERE id IN ($placeholders)',
      ids,
    );
    final byId = {for (final r in rows) r['id'] as int: Song.fromMap(r)};
    return [
      for (final id in ids)
        if (byId[id] != null) byId[id]!,
    ];
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
    final sanitizedQuery = SearchText.sanitizeQuery(filter.query);

    if (sanitizedQuery.isEmpty) {
      return [];
    }

    // Build dynamic WHERE clause based on filter flags
    final List<String> conditions = [];
    final List<dynamic> args = [];
    final exactQuery = sanitizedQuery;

    // Generate variations for Tamil spelling tolerance (e.g. ன vs ந)
    final variations = SearchText.tamilVariations(sanitizedQuery);

    void addLikeConditions(String tamilField, [String? englishField]) {
      if (variations.isEmpty) return;
      final fieldConditions = <String>[];
      for (var _ in variations) {
        fieldConditions.add("$tamilField LIKE ? ESCAPE '\\'");
      }
      args.addAll(variations.map((v) => '%${SearchText.escapeLike(v)}%'));

      if (englishField != null) {
        fieldConditions.add("$englishField LIKE ? ESCAPE '\\'");
        args.add('%${SearchText.escapeLike(sanitizedQuery)}%');
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
      final normalizedQuery = SearchText.normalizeTanglish(sanitizedQuery);
      if (normalizedQuery.isNotEmpty) {
        conditions.add(
          "${SearchText.tanglishNormalizedSql('english_venue')} LIKE ? ESCAPE '\\'",
        );
        args.add('%${SearchText.escapeLike(normalizedQuery)}%');
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

  /// Ids of the favorite songs, without loading their (large) text columns.
  Future<List<int>> getFavoriteSongIds() async {
    final db = await database;
    final maps = await db.query(
      'songs',
      columns: ['id'],
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'title',
    );
    return maps.map((m) => m['id'] as int).toList();
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
