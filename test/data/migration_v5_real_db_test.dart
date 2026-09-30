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
    );
    expect(await db.query('songs', orderBy: 'id'), before);
    await db.close();
    tmp.deleteSync(recursive: true);
  });
}
