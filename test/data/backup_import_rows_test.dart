import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/services/backup_service.dart';

/// One malformed row in a backup must be skipped, not abort the whole import.
void main() {
  test('applyImport skips bad notes, highlights and category names', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('importrows');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.insert('songs', {'id': 7, 'title': 'one'});
    await seed.execute('CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)');
    await seed.execute('CREATE TABLE song_categories(song_id INTEGER, category_id INTEGER, PRIMARY KEY(song_id, category_id))');
    await seed.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE highlights(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, verse_index INTEGER NOT NULL, text_content TEXT, created_at TEXT NOT NULL)');
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final map = <String, dynamic>{
      'version': 1,
      'favorites': [7],
      'categories': [
        {'name': 'Good', 'songs': [7]},
        {'name': 'x', 'songs': [7]}, // too short
        {'name': 'y' * 80, 'songs': [7]}, // too long
      ],
      'notes': [
        {'song_id': 7, 'content': 'ok', 'created_at': '2026-01-01T00:00:00.000', 'updated_at': '2026-01-01T00:00:00.000'},
        {'song_id': 7, 'content': null, 'created_at': 'not a date', 'updated_at': 'x'},
        'garbage',
      ],
      'highlights': [
        {'song_id': 7, 'verse_index': 0, 'text_content': 'v', 'created_at': '2026-01-01T00:00:00.000'},
        {'song_id': 'seven', 'verse_index': 0, 'created_at': 'bad'},
        42,
      ],
      'links': [],
    };
    validateBackupMap(map);

    final result = await BackupService().applyImport(map);

    expect(result.notesImported, 1);
    expect(result.notesSkipped, 2);
    expect(result.highlightsImported, 1);
    expect(result.highlightsSkipped, 2);
    expect(result.categorySongsImported, 1);
    expect(result.categorySongsSkipped, 2);
    final helper = DatabaseHelper();
    expect((await helper.getAllNotes()).single.content, 'ok');
    expect(await helper.getCategoryByName('x'), isNull);

    final db = await helper.database;
    await db.close();
    dir.deleteSync(recursive: true);
  });

  group('validateBackupMap limits', () {
    test('rejects oversized lists', () {
      final big = List<int>.filled(maxBackupListLength + 1, 1);
      expect(
        () => validateBackupMap({'version': 1, 'favorites': big, 'categories': []}),
        throwsA(isA<FormatException>()),
      );
      expect(
        () => validateBackupMap({
          'version': 1,
          'favorites': [],
          'categories': [],
          'notes': List<Object>.filled(maxBackupListLength + 1, 0),
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('accepts a minimal valid backup', () {
      expect(
        () => validateBackupMap({'version': 1, 'favorites': [], 'categories': []}),
        returnsNormally,
      );
    });
  });
}
