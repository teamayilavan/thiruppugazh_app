import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/practice_settings_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('PracticeSettingsProvider', () {
    test('enabled defaults to false on a fresh profile', () async {
      final provider = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);
      expect(provider.enabled, isFalse);
      expect(provider.onboardingComplete, isFalse);
      expect(provider.sankalpam, isNull);
    });

    test('setEnabled persists across reload', () async {
      final provider = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);

      await provider.setEnabled(true);
      expect(provider.enabled, isTrue);

      final reloaded = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);
      expect(reloaded.enabled, isTrue);
    });

    test('choosing justLooking forces enabled false', () async {
      final provider = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);

      await provider.setSankalpam(Sankalpam.justLooking);

      expect(provider.enabled, isFalse);
      expect(provider.onboardingComplete, isTrue);
      expect(provider.sankalpam, Sankalpam.justLooking);
    });

    test('choosing a non-justLooking sankalpam enables the layer', () async {
      final provider = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);

      await provider.setSankalpam(Sankalpam.dailyPractice);

      expect(provider.enabled, isTrue);
      expect(provider.sankalpam, Sankalpam.dailyPractice);
    });

    test('markFirstRunIfUnset stamps once and never overwrites', () async {
      final provider = PracticeSettingsProvider();
      await Future.delayed(Duration.zero);

      expect(provider.daysSinceFirstRun, 0);
      await provider.markFirstRunIfUnset();
      final prefs = await SharedPreferences.getInstance();
      final firstStamp = prefs.getString('practice_first_run_date');
      expect(firstStamp, isNotNull);

      await provider.markFirstRunIfUnset();
      expect(prefs.getString('practice_first_run_date'), firstStamp);
    });

    test(
      'an invalid stored sankalpam falls back to null, not a crash',
      () async {
        SharedPreferences.setMockInitialValues({
          'practice_sankalpam': 'not_a_real_value',
        });
        final provider = PracticeSettingsProvider();
        await Future.delayed(Duration.zero);
        expect(provider.sankalpam, isNull);
        expect(provider.onboardingComplete, isFalse);
      },
    );
  });
}
