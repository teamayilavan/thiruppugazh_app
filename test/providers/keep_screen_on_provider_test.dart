import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/constants/app_constants.dart';
import 'package:thiruppugazh/providers/keep_screen_on_provider.dart';

void main() {
  test('is off until the user turns it on', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = KeepScreenOnProvider();
    await provider.ready;
    expect(provider.enabled, isFalse);
  });

  test('remembers the choice across launches', () async {
    SharedPreferences.setMockInitialValues({});
    final first = KeepScreenOnProvider();
    await first.ready;
    await first.setEnabled(true);

    final second = KeepScreenOnProvider();
    await second.ready;
    expect(second.enabled, isTrue);
  });

  test('reads a saved value', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keepScreenOnReadingPrefsKey: true,
    });
    final provider = KeepScreenOnProvider();
    await provider.ready;
    expect(provider.enabled, isTrue);
  });

  test('an unreadable saved value falls back to off', () async {
    SharedPreferences.setMockInitialValues({
      AppConstants.keepScreenOnReadingPrefsKey: 'not a bool',
    });
    final provider = KeepScreenOnProvider();
    await provider.ready;
    expect(provider.enabled, isFalse);
  });

  test('tells listeners only when the value changes', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = KeepScreenOnProvider();
    await provider.ready;
    var calls = 0;
    provider.addListener(() => calls++);

    await provider.setEnabled(true);
    await provider.setEnabled(true);
    await provider.setEnabled(false);
    expect(calls, 2);
  });
}
