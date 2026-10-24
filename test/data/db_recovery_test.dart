import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// An unusable database file must not take the user's own tables with it:
/// it is set aside, and what can be read from it is copied into the fresh one.
void main() {
  test('an unusable database is set aside and its user data carried over', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('recover');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    // A database with user data but an empty songs table: opens fine, fails
    // the "has songs" usability check.
    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, is_favorite INTEGER DEFAULT 0)');
    await seed.execute('CREATE TABLE categories(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE)');
    await seed.execute('CREATE TABLE song_categories(song_id INTEGER, category_id INTEGER, PRIMARY KEY(song_id, category_id))');
    await seed.execute('CREATE TABLE notes(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, content TEXT NOT NULL, created_at TEXT NOT NULL, updated_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE highlights(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, verse_index INTEGER NOT NULL, text_content TEXT, created_at TEXT NOT NULL)');
    await seed.execute('CREATE TABLE links(id INTEGER PRIMARY KEY AUTOINCREMENT, song_id INTEGER NOT NULL, url TEXT NOT NULL, title TEXT, created_at TEXT NOT NULL)');
    await seed.insert('categories', {'id': 1, 'name': 'Favorites'});
    await seed.insert('categories', {'id': 2, 'name': 'Morning'});
    await seed.insert('song_categories', {'song_id': 7, 'category_id': 2});
    await seed.insert('notes', {'song_id': 7, 'content': 'my note', 'created_at': '2026-01-01T00:00:00.000', 'updated_at': '2026-01-02T00:00:00.000'});
    await seed.insert('highlights', {'song_id': 7, 'verse_index': 1, 'text_content': 'v', 'created_at': '2026-01-01T00:00:00.000'});
    await seed.insert('links', {'song_id': 7, 'url': 'https://a.com', 'title': 'A', 'created_at': '2026-01-01T00:00:00.000'});
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final helper = DatabaseHelper();
    final db = await helper.database;

    expect(helper.wasRecovered, true);
    expect(helper.wasFreshlyCreated, true);
    expect((await helper.getAllNotes()).single.content, 'my note');
    expect(await helper.getHighlightsForSong(7), hasLength(1));
    expect((await helper.getLinksForSong(7)).single.url, 'https://a.com');
    expect(await helper.getCategoryIdsForSong(7), [2]);
    expect(await helper.getSongsCount(), greaterThan(1000));

    // A clean rescue leaves no copy of the old file behind.
    final leftovers = dir.listSync().where((e) => e.path.contains('.corrupt-'));
    expect(leftovers, isEmpty);

    await db.close();
    dir.deleteSync(recursive: true);
  });
}
