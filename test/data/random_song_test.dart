import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

void main() {
  test('getRandomSong returns a song from the table', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('random');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    for (final id in [4, 9, 12]) {
      await seed.insert('songs', {'id': id, 'title': 't$id'});
    }
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final helper = DatabaseHelper();
    final seen = <int>{};
    for (var i = 0; i < 40; i++) {
      final song = await helper.getRandomSong();
      expect(song, isNotNull);
      seen.add(song!.id);
    }
    expect(seen.difference({4, 9, 12}), isEmpty);
    expect(seen.length, greaterThan(1), reason: 'offsets should vary');

    final db = await helper.database;
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
