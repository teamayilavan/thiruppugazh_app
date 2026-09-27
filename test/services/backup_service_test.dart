import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/backup_service.dart';

void main() {
  group('validateBackupVersion', () {
    test('accepts version 1', () {
      expect(validateBackupVersion({'version': 1, 'favorites': [], 'categories': []}), 1);
    });

    test('rejects a missing version', () {
      expect(
        () => validateBackupVersion({'favorites': [], 'categories': []}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects an unsupported version', () {
      expect(
        () => validateBackupVersion({'version': 2, 'favorites': [], 'categories': []}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('_songIdsPresentIn (via filterExistingIds)', () {
    test('splits requested IDs into present and missing', () {
      final present = filterExistingIds([1, 2, 3, 99], {1, 2, 3});
      expect(present, [1, 2, 3]);
    });

    test('returns an empty list when none exist', () {
      expect(filterExistingIds([5, 6], {1, 2, 3}), isEmpty);
    });
  });
}
