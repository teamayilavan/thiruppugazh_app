import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import '../../constants/app_constants.dart';
import '../../utils/app_logger.dart';

/// Table/index creation and the versioned migrations for the app database.
///
/// Everything here is additive and idempotent -- see `docs/database.md` and
/// the "User data is sacred" rules. [DatabaseHelper] owns opening, copying
/// and recovering the file and calls into this class.
class DatabaseSchema {
  DatabaseSchema._();

  static Future<void> initializeSchema(Database db) async {
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
    await createLinksTable(db);

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
  static Future<void> _addColumnIfMissing(
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

  static Future<void> addIndexes(Database db) async {
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

  static Future<void> createLinksTable(DatabaseExecutor db) async {
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
  static Future<void> migrateToV6(Database db) async {
    AppLogger.info('Running v6 migration: adding links table');
    try {
      await createLinksTable(db);
    } catch (e, st) {
      AppLogger.error(
        'v6 migration: failed to create links table',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// v2: adds the indexes. A v1 database (1.0.0) predates `is_favorite` and
  /// the notes/highlights tables the indexes refer to, so the idempotent
  /// schema setup runs first; without it opening such a database threw
  /// "no such column: is_favorite". Purely additive and non-fatal.
  static Future<void> migrateToV2(Database db) async {
    AppLogger.info('Running v2 migration: completing the v1 schema, adding indexes');
    try {
      await initializeSchema(db);
      await addIndexes(db);
    } catch (e, st) {
      AppLogger.error(
        'v2 migration failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  static Future<void> migrateToV3(Database db) async {
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
  static Future<void> migrateToV5(
    Database db, {
    Future<String> Function()? loadPatch,
    Future<String> Function()? loadRestore,
  }) async {
    await _applySongFixesV5(db, loadPatch);
    await _restoreMissingSongsV5(db, loadRestore);
  }

  static Future<void> _applySongFixesV5(
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
  static Future<void> _restoreMissingSongsV5(
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

  static Future<void> migrateToV4(Database db) async {
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
}
