import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  tamil('ta', 'தமிழ்'),
  english('en', 'English');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);
}

class LanguageProvider with ChangeNotifier {
  static const String _languageKey = 'app_language';

  AppLanguage _currentLanguage = AppLanguage.tamil;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      _currentLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.code == languageCode,
        orElse: () => AppLanguage.tamil,
      );
    }
    
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
    
    notifyListeners();
  }
}
