import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/services/recent_searches.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('starts empty', () async {
    expect(await RecentSearches.load(), isEmpty);
  });

  test('remembers searches, newest first', () async {
    await RecentSearches.add('muruga');
    await RecentSearches.add('vel');
    expect(await RecentSearches.load(), ['vel', 'muruga']);
  });

  test('a repeat moves to the front without duplicating', () async {
    await RecentSearches.add('muruga');
    await RecentSearches.add('vel');
    await RecentSearches.add('  MURUGA ');
    expect(await RecentSearches.load(), ['MURUGA', 'vel']);
  });

  test('ignores a single letter and blank text', () async {
    await RecentSearches.add('a');
    await RecentSearches.add('   ');
    expect(await RecentSearches.load(), isEmpty);
  });

  test('keeps only the most recent few', () async {
    for (var i = 0; i < RecentSearches.maxItems + 3; i++) {
      await RecentSearches.add('query $i');
    }
    final items = await RecentSearches.load();
    expect(items, hasLength(RecentSearches.maxItems));
    expect(items.first, 'query ${RecentSearches.maxItems + 2}');
    expect(items, isNot(contains('query 0')));
  });

  test('can be cleared', () async {
    await RecentSearches.add('muruga');
    await RecentSearches.clear();
    expect(await RecentSearches.load(), isEmpty);
  });

  test('an unreadable saved value is treated as empty', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.recentSearchesPrefsKey: '{not a list',
    });
    expect(await RecentSearches.load(), isEmpty);

    SharedPreferences.setMockInitialValues({
      AppConstants.recentSearchesPrefsKey: '{"a": 1}',
    });
    expect(await RecentSearches.load(), isEmpty);
  });

  test('skips non-text entries in a saved list', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.recentSearchesPrefsKey: '["ok", 5, null, "  ", "fine"]',
    });
    expect(await RecentSearches.load(), ['ok', 'fine']);
  });
}
