import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/data/database/search_text.dart';

void main() {
  test('tamilVariations adds the ன/ந counterpart', () {
    expect(SearchText.tamilVariations('பழனி').toSet(), {'பழனி', 'பழநி'});
    expect(SearchText.tamilVariations('abc'), ['abc']);
  });

  test('normalizeTanglish folds scholarly spellings toward casual ones', () {
    expect(
      SearchText.normalizeTanglish('thiruchchendhUr'),
      SearchText.normalizeTanglish('thiruchendur'),
    );
  });

  test('tanglishNormalizedSql applies the same rules as normalizeTanglish', () {
    final sql = SearchText.tanglishNormalizedSql('english_venue');
    expect(sql, startsWith('REPLACE('));
    expect(sql, contains('LOWER(english_venue)'));
  });

  test('sanitizeQuery trims and caps the length', () {
    expect(SearchText.sanitizeQuery('  murugan  '), 'murugan');
    final long = 'a' * (AppConstants.maxSearchQueryLength + 50);
    expect(
      SearchText.sanitizeQuery(long).length,
      AppConstants.maxSearchQueryLength,
    );
  });
}
