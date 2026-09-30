import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// Builds a database shaped like a released v4 device: the two mis-parsed
/// songs plus a healthy song, with user data attached to each.
Future<Database> _openV4Fixture() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    ),
  );
  await db.execute('''CREATE TABLE songs(
    id INTEGER PRIMARY KEY, title TEXT NOT NULL, lyrics TEXT, tune TEXT,
    tune_list TEXT, lyrics_list TEXT, pathavurai TEXT, search_content TEXT,
    is_favorite INTEGER DEFAULT 0, mayuragiri_lyrics_separated TEXT)''');
  await db.execute('''CREATE TABLE notes(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    content TEXT NOT NULL)''');
  await db.execute('''CREATE TABLE highlights(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    verse_index INTEGER NOT NULL, text_content TEXT)''');
  await db.execute('''CREATE TABLE song_categories(
    song_id INTEGER REFERENCES songs(id) ON DELETE CASCADE,
    category_id INTEGER, PRIMARY KEY(song_id, category_id))''');

  await db.insert('songs', {
    'id': 1338, 'title': 'polluted', 'lyrics': 'L\n ', 'tune': 'tune\nL\nsep',
    'tune_list': '["tune"]', 'lyrics_list': '["L"]', 'is_favorite': 1,
  });
  await db.insert('songs', {
    'id': 1328, 'title': 'empty-lyrics', 'lyrics': '', 'tune': 'l1\nl2\nmeaning',
    'tune_list': '["l1","l2","meaning"]', 'lyrics_list': '[]', 'is_favorite': 1,
  });
  await db.insert('songs', {
    'id': 7, 'title': 'healthy', 'lyrics': 'keep', 'is_favorite': 1,
  });
  for (final id in [1338, 1328, 7]) {
    await db.insert('notes', {'song_id': id, 'content': 'note $id'});
    await db.insert('highlights',
        {'song_id': id, 'verse_index': 0, 'text_content': 'hl $id'});
    await db.insert('song_categories', {'song_id': id, 'category_id': 1});
  }
  return db;
}

String _patch() => jsonEncode({
      '1338': {
        'lyrics': 'L', 'tune': 'tune', 'tune_list': '["tune"]',
        'lyrics_list': '["L"]', 'pathavurai': '', 'search_content': 's',
        'mayuragiri_lyrics_separated': '["l"]',
        'is_favorite': 0, // must be ignored: not a patchable column
      },
      '1328': {
        'lyrics': 'l1\nl2', 'tune': '', 'tune_list': '[]',
        'lyrics_list': '["l1","l2"]', 'pathavurai': 'meaning',
        'search_content': 's2', 'mayuragiri_lyrics_separated': null,
      },
    });

void main() {
  setUpAll(() => sqfliteFfiInit());

  test('fixes the listed songs and leaves user data intact', () async {
    final db = await _openV4Fixture();
    await DatabaseHelper().migrateToV5(db, loadPatch: () async => _patch());

    final s1338 = (await db.query('songs', where: 'id = 1338')).single;
    expect(s1338['lyrics'], 'L');
    expect(s1338['tune'], 'tune');
    expect(s1338['mayuragiri_lyrics_separated'], '["l"]');

    final s1328 = (await db.query('songs', where: 'id = 1328')).single;
    expect(s1328['lyrics'], 'l1\nl2');
    expect(s1328['tune'], '');
    expect(s1328['pathavurai'], 'meaning');

    // Untouched song is unchanged.
    final s7 = (await db.query('songs', where: 'id = 7')).single;
    expect(s7['lyrics'], 'keep');

    // Favorites survive, even where the patch tried to reset the flag.
    final favs = await db.rawQuery('SELECT id FROM songs WHERE is_favorite = 1');
    expect(favs.length, 3);

    // Notes, highlights and category links all survive (no cascade delete).
    expect((await db.query('notes')).length, 3);
    expect((await db.query('highlights')).length, 3);
    expect((await db.query('song_categories')).length, 3);
    await db.close();
  });

  test('is idempotent', () async {
    final db = await _openV4Fixture();
    final helper = DatabaseHelper();
    await helper.migrateToV5(db, loadPatch: () async => _patch());
    final once = await db.query('songs', orderBy: 'id');
    await helper.migrateToV5(db, loadPatch: () async => _patch());
    expect(await db.query('songs', orderBy: 'id'), once);
    await db.close();
  });

  test('a broken patch is non-fatal and changes nothing', () async {
    final db = await _openV4Fixture();
    final before = await db.query('songs', orderBy: 'id');
    await DatabaseHelper().migrateToV5(db, loadPatch: () async => 'not json');
    expect(await db.query('songs', orderBy: 'id'), before);
    await db.close();
  });

  test('bundled patch covers exactly the corrected songs', () {
    final patch = jsonDecode(File('assets/song_fixes_v5.json').readAsStringSync())
        as Map<String, dynamic>;
    expect(patch.keys.toSet(), {'1328', '1338'});
    expect((patch['1338'] as Map)['lyrics'], isNot(contains('சொற்பிரிவு')));
    expect((patch['1338'] as Map)['tune'], isNot(contains('\n\n')));
    expect((patch['1328'] as Map)['lyrics'], isNotEmpty);
  });
}
