import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/lyrics_font_size_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LyricsFontSizeProvider', () {
    test('defaults to 17.0 when no preference is stored', () async {
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);
      expect(provider.fontSize, 17.0);
    });

    test('loads saved preference on construction', () async {
      SharedPreferences.setMockInitialValues({'lyrics_font_size': 23.0});
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);
      expect(provider.fontSize, 23.0);
    });

    test(
      'falls back to default when saved preference is not a valid step',
      () async {
        SharedPreferences.setMockInitialValues({'lyrics_font_size': 99.0});
        final provider = LyricsFontSizeProvider();
        await Future.delayed(Duration.zero);
        expect(provider.fontSize, 17.0);
      },
    );

    test('increase steps to the next size and persists', () async {
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);

      await provider.increase();

      expect(provider.fontSize, 20.0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('lyrics_font_size'), 20.0);
    });

    test('decrease steps to the previous size and persists', () async {
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);

      await provider.decrease();

      expect(provider.fontSize, 14.0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getDouble('lyrics_font_size'), 14.0);
    });

    test('increase is a no-op at the maximum step', () async {
      SharedPreferences.setMockInitialValues({'lyrics_font_size': 26.0});
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.increase();

      expect(provider.fontSize, 26.0);
      expect(notifyCount, 0);
    });

    test('decrease is a no-op at the minimum step', () async {
      SharedPreferences.setMockInitialValues({'lyrics_font_size': 14.0});
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.decrease();

      expect(provider.fontSize, 14.0);
      expect(notifyCount, 0);
    });

    test('canIncrease and canDecrease reflect boundaries', () async {
      SharedPreferences.setMockInitialValues({'lyrics_font_size': 14.0});
      final provider = LyricsFontSizeProvider();
      await Future.delayed(Duration.zero);

      expect(provider.canDecrease, false);
      expect(provider.canIncrease, true);

      await provider.increase(); // 17.0
      expect(provider.canDecrease, true);
      expect(provider.canIncrease, true);
    });
  });
}
