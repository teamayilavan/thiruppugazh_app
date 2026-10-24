import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/services/backup_service.dart';

/// Importing many rows must trigger one auto-backup rewrite, not one per row,
/// and must leave the hook installed afterwards.
void main() {
  test('applyImport fires the mutation hook once and restores it', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('hook');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    for (var id = 1; id <= 5; id++) {
      await seed.insert('songs', {'id': id, 'title': 't$id'});
    }
    await seed.execute('CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)');
    await seed.execute('CREATE TABLE song_categories(song_id INTEGER, category_id INTEGER, PRIMARY KEY(song_id, category_id))');
    await seed.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE highlights(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, verse_index INTEGER NOT NULL, text_content TEXT, created_at TEXT NOT NULL)');
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    var calls = 0;
    void hook() => calls++;
    DatabaseHelper.onMutation = hook;
    addTearDown(() => DatabaseHelper.onMutation = null);

    final result = await BackupService().applyImport({
      'version': 1,
      'favorites': [1, 2, 3, 4, 5],
      'categories': [
        {'name': 'Morning', 'songs': [1, 2, 3]},
      ],
      'notes': [],
      'highlights': [],
      'links': [],
    });

    expect(result.favoritesImported, 5);
    expect(calls, 1);
    expect(identical(DatabaseHelper.onMutation, hook), isTrue);

    final db = await DatabaseHelper().database;
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
