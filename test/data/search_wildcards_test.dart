import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/data/database/search_text.dart';
import 'package:thiruppugazh/data/models/search_filter.dart';

void main() {
  test('escapeLike makes %, _ and backslash literal', () {
    expect(SearchText.escapeLike('50%_a'), r'50\%\_a');
    expect(SearchText.escapeLike(r'a\b'), r'a\\b');
    expect(SearchText.escapeLike('plain'), 'plain');
  });

  test('a typed underscore or percent matches only itself', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final dir = Directory.systemTemp.createTempSync('wild');
    await databaseFactoryFfi.setDatabasesPath(dir.path);

    final seed = await databaseFactoryFfi.openDatabase('${dir.path}/thiruppugazh.db');
    await seed.execute('CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL, english_title TEXT, lyrics TEXT, english_lyrics_list TEXT, words TEXT, english_words TEXT, place TEXT, english_venue TEXT, tune TEXT, kaumaram_id TEXT, pathavurai TEXT, english_pathavurai TEXT, is_favorite INTEGER DEFAULT 0)');
    await seed.insert('songs', {'id': 1, 'title': 'a_b'});
    await seed.insert('songs', {'id': 2, 'title': 'axb'});
    await seed.insert('songs', {'id': 3, 'title': '100% sure'});
    await seed.insert('songs', {'id': 4, 'title': '100 sure'});
    await seed.execute('PRAGMA user_version = 6');
    await seed.close();

    final helper = DatabaseHelper();
    final under = await helper.searchSongsWithFilter(const SearchFilter(query: 'a_b'));
    expect(under.map((s) => s.id), [1]);
    final percent = await helper.searchSongsWithFilter(const SearchFilter(query: '0% s'));
    expect(percent.map((s) => s.id), [3]);
    // Ordinary substring search still works.
    final plain = await helper.searchSongsWithFilter(const SearchFilter(query: 'sure'));
    expect(plain.map((s) => s.id).toSet(), {3, 4});

    final db = await helper.database;
    await db.close();
    dir.deleteSync(recursive: true);
  });
}
