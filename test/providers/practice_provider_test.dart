import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:thiruppugazh/data/database/database_helper.dart';
import 'package:thiruppugazh/providers/practice_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync(
      'thiruppugazh_provider_test_',
    );
  });

  tearDown(() async {
    DatabaseHelper().resetDatabaseForTesting();
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {
      // Best-effort cleanup.
    }
  });

  group('PracticeProvider.resolveTodaysHymnId', () {
    test('stays pinned for the day even after the hymn is completed', () async {
      SharedPreferences.setMockInitialValues({});
      final db = await DatabaseHelper().openDatabaseAtPathForTesting(
        p.join(tempDir.path, 'pinned.db'),
      );
      await db.insert('songs', {'id': 1, 'title': 'One'});
      await db.insert('songs', {'id': 2, 'title': 'Two'});
      DatabaseHelper().setDatabaseForTesting(db);

      final provider = PracticeProvider(databaseHelper: DatabaseHelper());
      // Settle the constructor's own fire-and-forget refresh() fully --
      // a single microtask yield isn't enough for its four sequential
      // awaited queries, and letting it dangle risks it still being
      // in-flight when a later test's database is torn down.
      await provider.ready;

      final first = await provider.resolveTodaysHymnId();
      expect(first, 1);

      // Completing today's hymn must not advance the pick.
      await provider.recordCompletion(1, 90, true);

      final second = await provider.resolveTodaysHymnId();
      expect(
        second,
        1,
        reason: 'should stay pinned for the day even after completion',
      );

      await db.close();
    });

    test(
      'rolls over to a fresh pick on a new day, skipping already-completed songs',
      () async {
        // A pin from a prior day, whose song was completed that same day.
        SharedPreferences.setMockInitialValues({
          'practice_todays_hymn_date': '2000-01-01',
          'practice_todays_hymn_id': 1,
        });
        final db = await DatabaseHelper().openDatabaseAtPathForTesting(
          p.join(tempDir.path, 'rollover.db'),
        );
        await db.insert('songs', {'id': 1, 'title': 'One'});
        await db.insert('songs', {'id': 2, 'title': 'Two'});
        await db.insert('reading_log', {
          'song_id': 1,
          'read_on': '2000-01-01',
          'dwell_seconds': 90,
          'completed': 1,
        });
        DatabaseHelper().setDatabaseForTesting(db);

        final provider = PracticeProvider(databaseHelper: DatabaseHelper());
        await provider.ready;

        final hymnId = await provider.resolveTodaysHymnId();
        expect(
          hymnId,
          2,
          reason:
              'song 1 was completed on a prior day -- today should pick the next uncompleted one, not reuse the stale pin',
        );

        await db.close();
      },
    );
  });
}
