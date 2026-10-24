import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// Re-creating the links table on every open must never touch links the user
/// already has.
void main() {
  test('opening a database that already has links leaves them untouched', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('keeplinks');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.insert('songs', {'id': 7, 'title': 'one'});
    await seed.execute('''CREATE TABLE links(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      song_id INTEGER NOT NULL,
      url TEXT NOT NULL,
      title TEXT,
      created_at TEXT NOT NULL,
      FOREIGN KEY(song_id) REFERENCES songs(id) ON DELETE CASCADE)''');
    await seed.insert('links', {'song_id': 7, 'url': 'https://a.com', 'title': 'A', 'created_at': '2026-01-01T00:00:00.000'});
    await seed.insert('links', {'song_id': 7, 'url': 'https://b.com', 'created_at': '2026-01-02T00:00:00.000'});
    final before = await seed.query('links', orderBy: 'id');
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final db = await DatabaseHelper().database;
    expect(await db.query('links', orderBy: 'id'), before);

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
