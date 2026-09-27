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

  test('maybeRestore imports the file when eligible and sets the attempted flag', () async {
    final backupFile = File(p.join(tempDir.path, 'thiruppugazh_auto_backup.json'));
    await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

    final statusProvider = AutoBackupStatusProvider();
    await Future.delayed(Duration.zero);

    Map<String, dynamic>? importedMap;
    final service = AutoBackupService(
      backupJsonBuilder: () async => {'version': 1},
      applyImport: (map) async {
        importedMap = map;
        return null;
      },
      statusProvider: statusProvider,
      backupDirectory: tempDir,
    );

    await service.maybeRestore(isFreshDatabase: true);

    expect(importedMap, isNotNull);
    expect(importedMap!['favorites'], [7]);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('auto_restore_attempted'), true);
  });

  test('maybeRestore does nothing on an ordinary reopen', () async {
    final backupFile = File(p.join(tempDir.path, 'thiruppugazh_auto_backup.json'));
    await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

    final statusProvider = AutoBackupStatusProvider();
    await Future.delayed(Duration.zero);

    var importCalled = false;
    final service = AutoBackupService(
      backupJsonBuilder: () async => {'version': 1},
      applyImport: (map) async {
        importCalled = true;
        return null;
      },
      statusProvider: statusProvider,
      backupDirectory: tempDir,
    );

    await service.maybeRestore(isFreshDatabase: false);

    expect(importCalled, false);
  });

  test('maybeRestore never runs twice even if called again on a fresh DB', () async {
    final backupFile = File(p.join(tempDir.path, 'thiruppugazh_auto_backup.json'));
    await backupFile.writeAsString(jsonEncode({'version': 1, 'favorites': [7]}));

    SharedPreferences.setMockInitialValues({'auto_restore_attempted': true});
    final statusProvider = AutoBackupStatusProvider();
    await Future.delayed(Duration.zero);

    var importCalled = false;
    final service = AutoBackupService(
      backupJsonBuilder: () async => {'version': 1},
      applyImport: (map) async {
        importCalled = true;
        return null;
      },
      statusProvider: statusProvider,
      backupDirectory: tempDir,
    );

    await service.maybeRestore(isFreshDatabase: true);

    expect(importCalled, false);
  });
}
