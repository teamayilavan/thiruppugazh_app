import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/auto_backup_status_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AutoBackupStatusProvider', () {
    test('starts with no last-backup time when nothing is saved', () async {
      final provider = AutoBackupStatusProvider();
      await Future.delayed(Duration.zero);
      expect(provider.lastBackupAt, isNull);
    });

    test('loads a previously saved last-backup time', () async {
      final saved = DateTime(2026, 9, 1, 12, 30);
      SharedPreferences.setMockInitialValues({
        'auto_backup_last_write_at': saved.toIso8601String(),
      });
      final provider = AutoBackupStatusProvider();
      await Future.delayed(Duration.zero);
      expect(provider.lastBackupAt, saved);
    });

    test('ready completes only after the saved time is loaded', () async {
      final saved = DateTime(2026, 9, 1, 12, 30);
      SharedPreferences.setMockInitialValues({
        'auto_backup_last_write_at': saved.toIso8601String(),
      });
      final provider = AutoBackupStatusProvider();
      await provider.ready;
      expect(provider.lastBackupAt, saved);
    });

    test('recordBackup persists and notifies listeners', () async {
      final provider = AutoBackupStatusProvider();
      await Future.delayed(Duration.zero);

      var notified = false;
      provider.addListener(() => notified = true);

      final now = DateTime(2026, 9, 27, 8, 0);
      await provider.recordBackup(now);

      expect(provider.lastBackupAt, now);
      expect(notified, true);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getString('auto_backup_last_write_at'),
        now.toIso8601String(),
      );
    });
  });
}
