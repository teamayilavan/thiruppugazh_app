import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// Upgrades from every earlier bundled database to the current schema, with
/// user data present, and checks that none of it is lost or changed.
///
/// The old databases are the real bundled assets from git history, so this
/// needs the history (CI checks out with fetch-depth 0); without it the
/// cases are skipped rather than failed.
const _eras = <({int version, String commit, String label})>[
  (version: 1, commit: 'e032220', label: 'first bundled DB'),
  (version: 2, commit: '794be54', label: 'English columns added'),
  (version: 3, commit: '501f9b4', label: 'English data regenerated'),
  (version: 4, commit: '62df613', label: 'Mayuragiri columns added'),
  (version: 5, commit: '4430bf3', label: '1.3-era DB (songs 1-6 absent)'),
];

const _userTables = [
  'categories',
  'song_categories',
  'notes',
  'highlights',
  'links',
];

Future<List<int>?> _assetAt(String commit) async {
  try {
    final r = await Process.run('git', [
      'show',
      '$commit:assets/thiruppugazh.db',
    ], stdoutEncoding: null);
    if (r.exitCode != 0) return null;
    final bytes = r.stdout as List<int>;
    return bytes.isEmpty ? null : bytes;
  } catch (_) {
    return null;
  }
}

Future<Set<String>> _tables(Database db) async => {
  for (final r in await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table'",
  ))
    r['name'] as String,
};

/// Everything the user owns, as comparable values. Row ids are included:
/// they must survive an upgrade unchanged.
Future<Map<String, Object?>> _userData(Database db) async {
  final tables = await _tables(db);
  final snapshot = <String, Object?>{};
  for (final t in _userTables) {
    if (tables.contains(t)) {
      snapshot[t] = await db.query(t, orderBy: 'rowid');
    }
  }
  final cols = {
    for (final r in await db.rawQuery('PRAGMA table_info(songs)'))
      r['name'] as String,
  };
  if (cols.contains('is_favorite')) {
    snapshot['favorites'] = await db.rawQuery(
      'SELECT id FROM songs WHERE is_favorite = 1 ORDER BY id',
    );
  }
  return snapshot;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  for (final era in _eras) {
    test(
      'upgrade from v${era.version} (${era.label}) keeps all user data',
      () async {
        final bytes = await _assetAt(era.commit);
        if (bytes == null) {
          markTestSkipped('git history for ${era.commit} not available');
          return;
        }

        final dir = Directory.systemTemp.createTempSync('matrix${era.version}');
        addTearDown(() => dir.deleteSync(recursive: true));
        final path = '${dir.path}/thiruppugazh.db';
        File(path).writeAsBytesSync(bytes);

        // Make it look like an install at this version, with user data in
        // every user table that version had.
        final seed = await databaseFactoryFfi.openDatabase(path);
        final tables = await _tables(seed);
        final songIds = (await seed.query(
          'songs',
          columns: ['id'],
          orderBy: 'id',
          limit: 40,
        )).map((r) => r['id'] as int).toList();
        final cols = {
          for (final r in await seed.rawQuery('PRAGMA table_info(songs)'))
            r['name'] as String,
        };
        if (cols.contains('is_favorite')) {
          await seed.rawUpdate(
            'UPDATE songs SET is_favorite = 1 WHERE id IN (?, ?, ?)',
            [songIds[10], songIds[11], songIds[30]],
          );
        }
        await seed.insert('categories', {'name': 'My chants'});
        final catId =
            (await seed.query(
                  'categories',
                  where: "name = 'My chants'",
                )).single['id']
                as int;
        await seed.insert('song_categories', {
          'song_id': songIds[12],
          'category_id': catId,
        });
        await seed.insert('song_categories', {
          'song_id': songIds[13],
          'category_id': catId,
        });
        if (tables.contains('notes')) {
          await seed.insert('notes', {
            'song_id': songIds[12],
            'content': 'திருப்புகழ் note',
            'created_at': '2026-01-01T00:00:00.000',
            'updated_at': '2026-01-02T00:00:00.000',
          });
        }
        if (tables.contains('highlights')) {
          await seed.insert('highlights', {
            'song_id': songIds[13],
            'verse_index': 2,
            'text_content': 'verse',
            'created_at': '2026-01-03T00:00:00.000',
          });
        }
        await seed.execute('PRAGMA user_version = ${era.version}');
        final before = await _userData(seed);
        await seed.close();

        DatabaseHelper.resetForTesting();
        await databaseFactoryFfi.setDatabasesPath(dir.path);
        final db = await DatabaseHelper().database;
        addTearDown(() => db.close());

        expect(await db.getVersion(), AppConstants.dbVersion);
        final after = await _userData(db);
        for (final entry in before.entries) {
          expect(
            after[entry.key],
            entry.value,
            reason: '${entry.key} changed in the upgrade',
          );
        }

        // And the upgraded database is complete and usable.
        final cols2 = {
          for (final r in await db.rawQuery('PRAGMA table_info(songs)'))
            r['name'] as String,
        };
        expect(
          cols2,
          containsAll([
            'is_favorite',
            'english_title',
            'mayuragiri_lyrics_separated',
          ]),
        );
        expect(
          await _tables(db),
          containsAll(['notes', 'highlights', 'links', 'temples']),
        );
        expect(await DatabaseHelper().getSongsCount(), greaterThan(1300));
      },
    );
  }
}
