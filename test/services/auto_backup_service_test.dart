import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';
import 'package:thiruppugazh/services/auto_backup_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('auto_backup_test');
  });

  tearDown(() async {
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('writeNow writes buildBackupJson output to the fixed file path and records the time', () async {
    final statusProvider = AutoBackupStatusProvider();
    await Future.delayed(Duration.zero);

    final service = AutoBackupService(
      backupJsonBuilder: () async => {'version': 1, 'favorites': [1, 2]},
      applyImport: (_) async => throw UnimplementedError(),
      statusProvider: statusProvider,
      backupDirectory: tempDir,
    );

    await service.writeNow();

    final file = File(p.join(tempDir.path, 'thiruppugazh_auto_backup.json'));
    expect(await file.exists(), true);
    final content = jsonDecode(await file.readAsString());
    expect(content['favorites'], [1, 2]);
    expect(statusProvider.lastBackupAt, isNotNull);
  });

  test('a mutation debounces to a single write after the configured delay', () async {
    final statusProvider = AutoBackupStatusProvider();
    await Future.delayed(Duration.zero);
    var buildCalls = 0;

    final service = AutoBackupService(
      backupJsonBuilder: () async {
        buildCalls++;
        return {'version': 1};
      },
      applyImport: (_) async => throw UnimplementedError(),
      statusProvider: statusProvider,
      backupDirectory: tempDir,
      debounceDuration: const Duration(milliseconds: 20),
    );

    service.onMutation();
    service.onMutation();
    service.onMutation();
    expect(buildCalls, 0); // not yet -- still debouncing

    await Future.delayed(const Duration(milliseconds: 60));
    expect(buildCalls, 1);

    service.dispose();
  });

  group('maybeRestore', () {
    // Mirrors the production layout: tempDir plays the role of the base
    // (application support) directory, backups go in tempDir/auto_backup,
    // and the one-shot marker sits directly in tempDir.
    late Directory backupDir;
    late File backupFile;
    late File markerFile;

    setUp(() async {
      backupDir = Directory(p.join(tempDir.path, 'auto_backup'));
      await backupDir.create(recursive: true);
      backupFile = File(p.join(backupDir.path, 'thiruppugazh_auto_backup.json'));
      markerFile = File(p.join(tempDir.path, 'auto_restore_attempted.marker'));
    });

    AutoBackupService buildService(
      Future<dynamic> Function(Map<String, dynamic>) applyImport,
    ) {
      return AutoBackupService(
        backupJsonBuilder: () async => {'version': 1},
        applyImport: applyImport,
        statusProvider: AutoBackupStatusProvider(),
        backupDirectory: backupDir,
        attemptedMarkerDirectory: tempDir,
      );
    }

    test('imports the file when eligible and creates the attempted marker', () async {
      await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

      Map<String, dynamic>? importedMap;
      final service = buildService((map) async {
        importedMap = map;
        return null;
      });

      await service.maybeRestore(isFreshDatabase: true);

      expect(importedMap, isNotNull);
      expect(importedMap!['favorites'], [7]);
      expect(await markerFile.exists(), true);
    });

    test('does nothing on an ordinary reopen', () async {
      await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

      var importCalled = false;
      final service = buildService((map) async {
        importCalled = true;
        return null;
      });

      await service.maybeRestore(isFreshDatabase: false);

      expect(importCalled, false);
      expect(await markerFile.exists(), false);
    });

    test('never runs twice even if called again on a fresh DB', () async {
      await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));
      await markerFile.writeAsString('');

      var importCalled = false;
      final service = buildService((map) async {
        importCalled = true;
        return null;
      });

      await service.maybeRestore(isFreshDatabase: true);

      expect(importCalled, false);
    });

    test('ignores a restore-attempted flag in SharedPreferences (it is backed up, so must not gate restore)', () async {
      SharedPreferences.setMockInitialValues({'auto_restore_attempted': true});
      await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

      var importCalled = false;
      final service = buildService((map) async {
        importCalled = true;
        return null;
      });

      await service.maybeRestore(isFreshDatabase: true);

      expect(importCalled, true);
    });

    test('the marker is a sibling of the backup directory, not inside it', () async {
      await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));
      final service = buildService((_) async => null);

      await service.maybeRestore(isFreshDatabase: true);

      expect(await markerFile.exists(), true);
      expect(p.isWithin(backupDir.path, markerFile.path), false);
      expect(p.equals(markerFile.parent.path, backupDir.parent.path), true);
      // Nothing other than the backup file itself ends up in auto_backup/.
      final backupDirContents = await backupDir
          .list()
          .map((e) => p.basename(e.path))
          .toList();
      expect(backupDirContents, ['thiruppugazh_auto_backup.json']);
    });

    test('rejects an unsupported backup version without importing, but still marks attempted', () async {
      await backupFile.writeAsString(jsonEncode({'version': 2, 'favorites': [7]}));

      var importCalled = false;
      final service = buildService((map) async {
        importCalled = true;
        return null;
      });

      await service.maybeRestore(isFreshDatabase: true);

      expect(importCalled, false);
      expect(await markerFile.exists(), true);
    });
  });
}
