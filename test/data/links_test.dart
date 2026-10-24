import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/data/models/link_model.dart';
import 'package:thiruppugazh/services/backup_service.dart';

/// A database shaped like a released v5 device: songs plus a user table,
/// with a note attached so we can prove the migration leaves it alone.
Future<Database> _openV5Fixture() async {
  final db = await databaseFactoryFfi.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    ),
  );
  await db.execute(
    'CREATE TABLE songs(id INTEGER PRIMARY KEY, title TEXT NOT NULL)',
  );
  await db.execute('''CREATE TABLE notes(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    song_id INTEGER NOT NULL REFERENCES songs(id) ON DELETE CASCADE,
    content TEXT NOT NULL)''');
  await db.insert('songs', {'id': 1, 'title': 'one'});
  await db.insert('songs', {'id': 2, 'title': 'two'});
  await db.insert('notes', {'song_id': 1, 'content': 'keep me'});
  return db;
}

SongLink _link(int songId, String url, {String? title}) => SongLink(
  songId: songId,
  url: url,
  title: title,
  createdAt: DateTime(2026, 1, 1),
);

Map<String, dynamic> _row(int songId, String url, {String created = '2026-01-01T00:00:00.000'}) => {
  'song_id': songId,
  'url': url,
  'created_at': created,
};

void main() {
  setUpAll(() => sqfliteFfiInit());

  group('SongLink', () {
    test('round-trips through a map', () {
      final link = SongLink(
        id: 3,
        songId: 9,
        url: 'https://youtu.be/a',
        title: 'Talk',
        createdAt: DateTime(2026, 2, 3),
      );
      final back = SongLink.fromMap(link.toMap());
      expect(back.id, 3);
      expect(back.songId, 9);
      expect(back.url, 'https://youtu.be/a');
      expect(back.title, 'Talk');
      expect(back.createdAt, DateTime(2026, 2, 3));
    });

    test('displayTitle prefers the label, then the domain, then the url', () {
      expect(_link(1, 'https://youtu.be/a', title: ' Talk ').displayTitle, 'Talk');
      expect(_link(1, 'https://youtu.be/a').displayTitle, 'youtu.be');
      expect(_link(1, 'https://youtu.be/a', title: '  ').displayTitle, 'youtu.be');
      expect(_link(1, 'nonsense').displayTitle, 'nonsense');
    });
  });

  group('migrateToV6', () {
    test('adds the links table without touching existing data', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='links'",
      );
      expect(tables, hasLength(1));
      expect(await db.query('notes'), hasLength(1));
      expect(await db.query('songs'), hasLength(2));
      await db.close();
    });

    test('is idempotent', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);
      await DatabaseHelper().migrateToV6(db);
      await DatabaseHelper().addLinkIfAbsent(
        _link(1, 'https://a.com'),
        executor: db,
      );
      await DatabaseHelper().migrateToV6(db);
      expect(await db.query('links'), hasLength(1));
      await db.close();
    });

    test('links cascade-delete with their song', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);
      await DatabaseHelper().addLinkIfAbsent(
        _link(1, 'https://a.com'),
        executor: db,
      );
      await db.delete('songs', where: 'id = 1');
      expect(await db.query('links'), isEmpty);
      await db.close();
    });
  });

  group('addLinkIfAbsent', () {
    test('adds once per song+url, but allows the url on another song', () async {
      final db = await _openV5Fixture();
      final helper = DatabaseHelper();
      await helper.migrateToV6(db);

      expect(
        await helper.addLinkIfAbsent(_link(1, 'https://a.com'), executor: db),
        isTrue,
      );
      expect(
        await helper.addLinkIfAbsent(_link(1, 'https://a.com'), executor: db),
        isFalse,
      );
      expect(
        await helper.addLinkIfAbsent(_link(2, 'https://a.com'), executor: db),
        isTrue,
      );
      expect(await db.query('links'), hasLength(2));
      await db.close();
    });
  });

  group('BackupService.importLinks', () {
    test('imports valid links and skips bad rows without aborting', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);

      final result = await BackupService().importLinks(
        [
          {..._row(1, 'https://a.com'), 'id': 9, 'title': 'A'},
          _row(1, 'javascript:alert(1)'),
          _row(99, 'https://gone.com'),
          _row(2, 'https://b.com', created: 'not a date'),
          'garbage',
          _row(2, 'https://b.com'),
        ],
        {1, 2},
        executor: db,
      );

      expect(result.imported, 2);
      expect(result.skipped, 4);
      final rows = await db.query('links', orderBy: 'url');
      expect(rows.map((r) => r['url']), ['https://a.com', 'https://b.com']);
      // The backup's row id is dropped; the local DB assigns its own.
      expect(rows.first['id'], isNot(9));
      await db.close();
    });

    test('re-importing the same backup does not duplicate links', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);
      final rows = [_row(1, 'https://a.com')];

      await BackupService().importLinks(rows, {1}, executor: db);
      final second = await BackupService().importLinks(rows, {1}, executor: db);

      expect(second.skipped, 0);
      expect(await db.query('links'), hasLength(1));
      await db.close();
    });

    test('an old backup with no links imports nothing and skips nothing', () async {
      final db = await _openV5Fixture();
      await DatabaseHelper().migrateToV6(db);
      final result = await BackupService().importLinks(
        const [],
        {1, 2},
        executor: db,
      );
      expect(result.imported, 0);
      expect(result.skipped, 0);
      await db.close();
    });
  });

  group('ImportResult', () {
    test('counts links in the totals', () {
      const result = ImportResult(
        favoritesImported: 0,
        favoritesSkipped: 0,
        categoriesImported: 0,
        categorySongsImported: 0,
        categorySongsSkipped: 0,
        notesImported: 0,
        notesSkipped: 0,
        highlightsImported: 0,
        highlightsSkipped: 0,
        linksImported: 3,
        linksSkipped: 1,
      );
      expect(result.totalImported, 3);
      expect(result.totalSkipped, 1);
    });
  });
}
