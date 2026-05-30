import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

enum LyricsLanguage {
  tamil('ta', 'தமிழ்'),
  english('en', 'English');

  final String code;
  final String displayName;

  const LyricsLanguage(this.code, this.displayName);
}

class LyricsLanguageProvider with ChangeNotifier {
  LyricsLanguage _lyricsLanguage = LyricsLanguage.tamil;

  LyricsLanguage get lyricsLanguage => _lyricsLanguage;

  LyricsLanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(AppConstants.lyricsLanguagePrefsKey);
    if (code != null) {
      _lyricsLanguage = LyricsLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => LyricsLanguage.tamil,
      );
    }
    notifyListeners();
  }

  Future<void> setLyricsLanguage(LyricsLanguage language) async {
    if (_lyricsLanguage == language) return;
    _lyricsLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.lyricsLanguagePrefsKey, language.code);
    notifyListeners();
  }
}
