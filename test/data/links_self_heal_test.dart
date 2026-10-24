import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/data/models/link_model.dart';

/// The v6 migration is non-fatal, so if creating `links` ever failed the
/// database would still be marked v6 and never retried. Opening the database
/// must put the table back.
void main() {
  test('opening a v6 database that is missing the links table recreates it', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('selfheal');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    // A "v6" database as left behind by a failed migration: songs and
    // user data present, version stamped 6, no links table.
    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.insert('songs', {'id': 7, 'title': 'one', 'is_favorite': 1});
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final db = await DatabaseHelper().database;

    final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table' AND name='links'");
    expect(tables, hasLength(1), reason: 'links table should have been recreated');
    expect(await db.getVersion(), 6);

    // User data untouched, and the new table is usable.
    expect(await db.query('songs'), hasLength(1));
    final helper = DatabaseHelper();
    expect(await helper.getAllLinks(), isEmpty);
    expect(
      await helper.addLinkIfAbsent(SongLink(songId: 7, url: 'https://youtu.be/x', createdAt: DateTime(2026, 10, 1))),
      isTrue,
    );
    expect((await helper.getLinksForSong(7)).single.url, 'https://youtu.be/x');
    // Backups read this table; it must not throw.
    expect(await helper.getAllLinks(), hasLength(1));

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
