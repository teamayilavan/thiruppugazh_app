import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

enum AppLanguage {
  tamil('ta', 'தமிழ்'),
  english('en', 'English');

  final String code;
  final String displayName;

  const AppLanguage(this.code, this.displayName);
}

class LanguageProvider with ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.tamil;

  AppLanguage get currentLanguage => _currentLanguage;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languagePrefsKey);

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
    await prefs.setString(AppConstants.languagePrefsKey, language.code);

    notifyListeners();
  }
}
