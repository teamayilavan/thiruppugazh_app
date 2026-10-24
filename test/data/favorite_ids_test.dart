import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

void main() {
  test('getFavoriteSongIds returns exactly the favorited ids, ordered by title', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('favids');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.insert('songs', {'id': 1, 'title': 'c', 'is_favorite': 1});
    await seed.insert('songs', {'id': 2, 'title': 'b', 'is_favorite': 0});
    await seed.insert('songs', {'id': 3, 'title': 'a', 'is_favorite': 1});
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final helper = DatabaseHelper();
    expect(await helper.getFavoriteSongIds(), [3, 1]);

    final db = await helper.database;
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
