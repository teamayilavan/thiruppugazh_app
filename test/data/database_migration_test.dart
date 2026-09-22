import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// Builds a v3-shaped schema (post-v3 English columns, no mayuragiri
/// columns, no practice tables) -- what a real pre-mayuragiri install
/// looked like.
Future<void> _createV3Schema(Database db) async {
  await db.execute('''
    CREATE TABLE songs(
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
      english_pathavurai    TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE
    )
  ''');
  await db.execute('''
    CREATE TABLE song_categories(
      song_id INTEGER,
      category_id INTEGER,
      PRIMARY KEY (song_id, category_id)
    )
  ''');
  await db.execute('''
    CREATE TABLE temples(
      id           INTEGER PRIMARY KEY AUTOINCREMENT,
      name         TEXT NOT NULL UNIQUE,
      song_count   INTEGER DEFAULT 0,
      english_name TEXT
    )
  ''');
  await db.execute('''
    CREATE TABLE highlights(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id INTEGER NOT NULL,
      verse_index INTEGER NOT NULL,
      text_content TEXT,
      created_at TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE notes(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id INTEGER NOT NULL,
      content TEXT NOT NULL,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL
    )
  ''');
}

Future<void> _expectTablesExist(Database db, List<String> tables) async {
  for (final table in tables) {
    final rows = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    expect(rows, isNotEmpty, reason: '$table should exist');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('thiruppugazh_db_test_');
  });

  tearDown(() async {
    DatabaseHelper().resetDatabaseForTesting();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Best-effort cleanup; a lingering open handle on some platforms
      // shouldn't fail the test.
    }
  });

  group('database migration', () {
    test('fresh install (no prior file) creates all v5 tables', () async {
      final path = p.join(tempDir.path, 'fresh.db');
      final db = await DatabaseHelper().openDatabaseAtPathForTesting(path);

      await _expectTablesExist(db, [
        'songs',
        'categories',
        'song_categories',
        'temples',
        'highlights',
        'notes',
        'reading_log',
        'practice_days',
        'milestones',
      ]);

      await db.close();
    });

    test(
      'upgrade from v3 creates v5 tables and preserves existing rows',
      () async {
        final path = p.join(tempDir.path, 'v3.db');
        final seed = await databaseFactory.openDatabase(path);
        await _createV3Schema(seed);
        await seed.insert('songs', {'id': 1, 'title': 'Seed Song'});
        await seed.insert('categories', {'id': 2, 'name': 'My Category'});
        await seed.insert('notes', {
          'id': 1,
          'song_id': 1,
          'content': 'a note',
          'created_at': '2020-01-01T00:00:00.000',
          'updated_at': '2020-01-01T00:00:00.000',
        });
        await seed.insert('highlights', {
          'id': 1,
          'song_id': 1,
          'verse_index': 0,
          'text_content': 'a highlight',
          'created_at': '2020-01-01T00:00:00.000',
        });
        await seed.execute('PRAGMA user_version = 3');
        await seed.close();

        final db = await DatabaseHelper().openDatabaseAtPathForTesting(path);

        await _expectTablesExist(db, [
          'reading_log',
          'practice_days',
          'milestones',
        ]);

        final notes = await db.query('notes');
        expect(notes, hasLength(1));
        expect(notes.first['content'], 'a note');

        final highlights = await db.query('highlights');
        expect(highlights, hasLength(1));

        final categories = await db.query(
          'categories',
          where: 'id = ?',
          whereArgs: [2],
        );
        expect(categories, hasLength(1));
        expect(categories.first['name'], 'My Category');

        await db.close();
      },
    );

    test(
      'upgrade from v4 creates v5 tables and preserves mayuragiri data',
      () async {
        final path = p.join(tempDir.path, 'v4.db');
        final seed = await databaseFactory.openDatabase(path);
        await _createV3Schema(seed);
        await seed.execute(
          'ALTER TABLE songs ADD COLUMN mayuragiri_lyrics_separated TEXT',
        );
        await seed.execute(
          'ALTER TABLE songs ADD COLUMN mayuragiri_english_lyrics_separated TEXT',
        );
        await seed.insert('songs', {
          'id': 1,
          'title': 'Seed Song',
          'mayuragiri_lyrics_separated': '["a","b"]',
        });
        await seed.execute('PRAGMA user_version = 4');
        await seed.close();

        final db = await DatabaseHelper().openDatabaseAtPathForTesting(path);

        await _expectTablesExist(db, [
          'reading_log',
          'practice_days',
          'milestones',
        ]);

        final songs = await db.query('songs', where: 'id = ?', whereArgs: [1]);
        expect(songs, hasLength(1));
        expect(songs.first['mayuragiri_lyrics_separated'], '["a","b"]');

        await db.close();
      },
    );
  });

  group('recordDwell upsert', () {
    test(
      'two calls in a day yield one row with max dwell, never downgrading completed',
      () async {
        final path = p.join(tempDir.path, 'dwell.db');
        final db = await DatabaseHelper().openDatabaseAtPathForTesting(path);
        await db.insert('songs', {'id': 1, 'title': 'Test Song'});
        DatabaseHelper().setDatabaseForTesting(db);

        await DatabaseHelper().recordDwell(1, '2026-09-22', 30, false);
        // A shorter dwell in the same day must not downgrade the max.
        await DatabaseHelper().recordDwell(1, '2026-09-22', 10, false);
        await DatabaseHelper().recordDwell(1, '2026-09-22', 20, true);

        final rows = await db.query(
          'reading_log',
          where: 'song_id = ? AND read_on = ?',
          whereArgs: [1, '2026-09-22'],
        );
        expect(rows, hasLength(1));
        expect(rows.first['dwell_seconds'], 30);
        expect(rows.first['completed'], 1);

        // completed=false afterwards must not downgrade completed back to 0.
        await DatabaseHelper().recordDwell(1, '2026-09-22', 5, false);
        final after = await db.query(
          'reading_log',
          where: 'song_id = ? AND read_on = ?',
          whereArgs: [1, '2026-09-22'],
        );
        expect(after, hasLength(1));
        expect(after.first['completed'], 1);
        expect(after.first['dwell_seconds'], 30);

        expect(await DatabaseHelper().getCompletedSongCount(), 1);
        expect(await DatabaseHelper().isSongCompleted(1), isTrue);

        final practiceDays = await db.query(
          'practice_days',
          where: 'day = ?',
          whereArgs: ['2026-09-22'],
        );
        expect(practiceDays, hasLength(1));
        expect(practiceDays.first['songs_completed'], 1);

        await db.close();
      },
    );
  });

  group('corpus assertion', () {
    test(
      'AppConstants.corpusSize matches the bundled asset song count',
      () async {
        final assetPath = p.join(
          Directory.current.path,
          'assets',
          'thiruppugazh.db',
        );
        expect(
          File(assetPath).existsSync(),
          isTrue,
          reason: 'bundled asset db not found at $assetPath',
        );

        final db = await databaseFactory.openDatabase(
          assetPath,
          options: OpenDatabaseOptions(readOnly: true),
        );
        final result = await db.rawQuery('SELECT COUNT(*) as count FROM songs');
        final count = result.first['count'] as int;
        await db.close();

        expect(count, AppConstants.corpusSize);
      },
    );
  });
}
