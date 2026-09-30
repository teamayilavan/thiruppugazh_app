import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// Guards the invariant that an upgraded install ends up with exactly the
/// same song rows as a fresh install of the bundled database.
void main() {
  setUpAll(() => sqfliteFfiInit());

  test('patching a copy of the bundled DB is a no-op (fresh == upgraded)',
      () async {
    final bundled = await databaseFactoryFfi.openDatabase(
      File('assets/thiruppugazh.db').absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final before = await bundled.query('songs', orderBy: 'id');
    await bundled.close();

    final tmp = Directory.systemTemp.createTempSync('v5');
    final copy = File('${tmp.path}/t.db')
      ..writeAsBytesSync(File('assets/thiruppugazh.db').readAsBytesSync());
    final db = await databaseFactoryFfi.openDatabase(copy.path);
    await DatabaseHelper().migrateToV5(
      db,
      loadPatch: () async => File('assets/song_fixes_v5.json').readAsString(),
      loadRestore: () async =>
          File('assets/song_restore_v5.json').readAsString(),
    );
    expect(await db.query('songs', orderBy: 'id'), before);
    await db.close();
    tmp.deleteSync(recursive: true);
  });

  test('a 1.2.0-era install (songs 1-6 absent) ends up identical to a fresh one',
      () async {
    final bundled = await databaseFactoryFfi.openDatabase(
      File('assets/thiruppugazh.db').absolute.path,
      options: OpenDatabaseOptions(readOnly: true),
    );
    final freshSongs = await bundled.query('songs', orderBy: 'id');
    const tq = 'SELECT name, song_count, english_name FROM temples ORDER BY name';
    final freshTemples = await bundled.rawQuery(tq);
    await bundled.close();

    final tmp = Directory.systemTemp.createTempSync('v5b');
    final copy = File('${tmp.path}/t.db')
      ..writeAsBytesSync(File('assets/thiruppugazh.db').readAsBytesSync());
    final db = await databaseFactoryFfi.openDatabase(copy.path);
    // Recreate what a 1.2.0-1.3.0 install looks like: no songs 1-6, and the
    // temples table as it was built then.
    await db.delete('songs', where: 'id <= 6');
    await db.delete('temples', where: "name = 'விநாயகர்'");
    await db.rawUpdate(
        "UPDATE temples SET song_count = song_count - 1 WHERE name = 'திருவருணை'");
    expect((await db.query('songs')).length, 1334);

    await DatabaseHelper().migrateToV5(
      db,
      loadPatch: () async => File('assets/song_fixes_v5.json').readAsString(),
      loadRestore: () async =>
          File('assets/song_restore_v5.json').readAsString(),
    );
    expect(await db.query('songs', orderBy: 'id'), freshSongs);
    expect(await db.rawQuery(tq), freshTemples);
    await db.close();
    tmp.deleteSync(recursive: true);
  });
}
