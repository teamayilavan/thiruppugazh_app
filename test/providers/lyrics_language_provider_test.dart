import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/lyrics_language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LyricsLanguageProvider', () {
    test('defaults to tamil when no preference is stored', () async {
      final provider = LyricsLanguageProvider();
      await Future.delayed(Duration.zero);
      expect(provider.lyricsLanguage, LyricsLanguage.tamil);
    });

    test('loads saved preference on construction', () async {
      SharedPreferences.setMockInitialValues({'lyrics_language': 'en'});
      final provider = LyricsLanguageProvider();
      await Future.delayed(Duration.zero);
      expect(provider.lyricsLanguage, LyricsLanguage.english);
    });

    test('setLyricsLanguage updates value and persists', () async {
      final provider = LyricsLanguageProvider();
      await Future.delayed(Duration.zero);

      await provider.setLyricsLanguage(LyricsLanguage.english);

      expect(provider.lyricsLanguage, LyricsLanguage.english);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lyrics_language'), 'en');
    });

    test('setLyricsLanguage is a no-op when value is unchanged', () async {
      final provider = LyricsLanguageProvider();
      await Future.delayed(Duration.zero);

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);
      await provider.setLyricsLanguage(LyricsLanguage.tamil); // already tamil

      expect(notifyCount, 0);
    });
  });
}
