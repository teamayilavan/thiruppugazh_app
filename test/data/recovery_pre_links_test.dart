import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// A set-aside database from before the links table existed must still be
/// rescued cleanly: a missing table is nothing to copy, not a failure, so the
/// (37 MB) old file is not stranded on the device.
void main() {
  test('rescuing a database without a links table succeeds and cleans up', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('recover_pre_links');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.execute('CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)');
    await seed.execute('CREATE TABLE song_categories(song_id INTEGER, category_id INTEGER, PRIMARY KEY(song_id, category_id))');
    await seed.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE highlights(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, verse_index INTEGER NOT NULL, text_content TEXT, created_at TEXT NOT NULL)');
    await seed.insert('categories', {'id': 1, 'name': 'Favorites'});
    await seed.insert('notes', {'song_id': 7, 'content': 'kept', 'created_at': '2026-01-01T00:00:00.000', 'updated_at': '2026-01-02T00:00:00.000'});
    await seed.execute('PRAGMA user_version = 5');
    await seed.close();

    final helper = DatabaseHelper();
    final db = await helper.database;

    expect(helper.wasRecovered, true);
    expect(helper.userDataRescued, true);
    expect((await helper.getNoteForSong(7))!.content, 'kept');
    expect(dir.listSync().where((e) => e.path.contains('.corrupt-')), isEmpty);

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
