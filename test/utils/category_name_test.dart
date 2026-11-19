import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/utils/category_name.dart';

void main() {
  group('hasValidCategoryNameChars', () {
    test('accepts purely Tamil names', () {
      expect(hasValidCategoryNameChars('முருகன்'), isTrue);
      expect(hasValidCategoryNameChars('தினசரி'), isTrue);
      expect(hasValidCategoryNameChars('  கந்தர் அலங்காரம்  '), isTrue);
    });

    test('accepts English, digits and mixed scripts', () {
      expect(hasValidCategoryNameChars('Daily'), isTrue);
      expect(hasValidCategoryNameChars('12'), isTrue);
      expect(hasValidCategoryNameChars('Arupadai வீடு'), isTrue);
    });

    test('rejects names with no letters or digits', () {
      expect(hasValidCategoryNameChars('!!'), isFalse);
      expect(hasValidCategoryNameChars('  - .  '), isFalse);
      expect(hasValidCategoryNameChars(''), isFalse);
    });
  });
}
