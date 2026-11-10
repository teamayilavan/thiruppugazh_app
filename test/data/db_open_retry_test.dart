import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';

/// One failed open of the song database must not stick. The helper caches the
/// opening Future so concurrent callers share it; a cached failure would make
/// every later query fail until the app was restarted.
void main() {
  test('a failed open is retried by the next caller', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    DatabaseHelper.resetForTesting();

    final dir = Directory.systemTemp.createTempSync('retry');
    addTearDown(() {
      DatabaseHelper.resetForTesting();
      dir.deleteSync(recursive: true);
    });

    // A folder cannot be created underneath a plain file, so the first open
    // fails for real.
    final blocker = File('${dir.path}/blocker')..writeAsStringSync('x');
    await databaseFactoryFfi.setDatabasesPath('${blocker.path}/db');

    final helper = DatabaseHelper();
    await expectLater(helper.database, throwsA(anything));

    // The trouble clears (the folder is now usable).
    await databaseFactoryFfi.setDatabasesPath('${dir.path}/good');
    final db = await helper.database;
    expect(await helper.getSongsCount(), greaterThan(1000));
    await db.close();
  });
}
