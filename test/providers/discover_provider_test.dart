import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/providers/discover_provider.dart';

void main() {
  test('defaults to not dismissed, and is loaded after ready', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = DiscoverProvider();
    expect(provider.loaded, isFalse);
    await provider.ready;
    expect(provider.loaded, isTrue);
    expect(provider.cardDismissed, isFalse);
  });

  test('reads a saved dismissal', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.discoverCardDismissedPrefsKey: true,
    });
    final provider = DiscoverProvider();
    await provider.ready;
    expect(provider.cardDismissed, isTrue);
  });

  test('dismissCard persists across a new provider', () async {
    SharedPreferences.setMockInitialValues({});
    final first = DiscoverProvider();
    await first.ready;
    await first.dismissCard();

    final second = DiscoverProvider();
    await second.ready;
    expect(second.cardDismissed, isTrue);
  });

  test('a non-bool saved value is treated as not dismissed', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.discoverCardDismissedPrefsKey: 'yes',
    });
    final provider = DiscoverProvider();
    await provider.ready;
    expect(provider.loaded, isTrue);
    expect(provider.cardDismissed, isFalse);
  });

  test('dismissCard notifies once, and a second call does not', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = DiscoverProvider();
    await provider.ready;
    var calls = 0;
    provider.addListener(() => calls++);

    await provider.dismissCard();
    expect(calls, 1);
    await provider.dismissCard();
    expect(calls, 1);
  });
}
