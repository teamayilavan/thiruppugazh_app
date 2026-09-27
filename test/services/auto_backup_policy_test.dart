import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/auto_backup_policy.dart';

void main() {
  group('isAutoBackupStale', () {
    test('is stale when there has never been a backup', () {
      expect(isAutoBackupStale(null, DateTime(2026, 1, 2)), true);
    });

    test('is not stale within the window', () {
      final now = DateTime(2026, 1, 2, 10, 0);
      final last = now.subtract(const Duration(hours: 1));
      expect(isAutoBackupStale(last, now), false);
    });

    test('is stale once past the window', () {
      final now = DateTime(2026, 1, 3, 10, 0);
      final last = now.subtract(const Duration(hours: 25));
      expect(isAutoBackupStale(last, now), true);
    });
  });

  group('shouldAttemptAutoRestore', () {
    test('true only when fresh DB, file exists, and not already attempted', () {
      expect(
        shouldAttemptAutoRestore(
          isFreshDatabase: true,
          backupFileExists: true,
          alreadyAttempted: false,
        ),
        true,
      );
    });

    test('false on an ordinary reopen even if a backup file is present', () {
      expect(
        shouldAttemptAutoRestore(
          isFreshDatabase: false,
          backupFileExists: true,
          alreadyAttempted: false,
        ),
        false,
      );
    });

    test('false if no backup file was restored by the OS', () {
      expect(
        shouldAttemptAutoRestore(
          isFreshDatabase: true,
          backupFileExists: false,
          alreadyAttempted: false,
        ),
        false,
      );
    });

    test('false once already attempted, even on a fresh DB with a file present', () {
      expect(
        shouldAttemptAutoRestore(
          isFreshDatabase: true,
          backupFileExists: true,
          alreadyAttempted: true,
        ),
        false,
      );
    });
  });
}
