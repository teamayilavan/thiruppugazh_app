import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class LyricsFontSizeProvider with ChangeNotifier {
  static const List<double> steps = [14.0, 17.0, 20.0, 23.0, 26.0];
  static const double defaultFontSize = 17.0;

  double _fontSize = defaultFontSize;

  double get fontSize => _fontSize;

  bool get canIncrease => _fontSize < steps.last;

  bool get canDecrease => _fontSize > steps.first;

  LyricsFontSizeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(AppConstants.lyricsFontSizePrefsKey);
    if (saved != null && steps.contains(saved)) {
      _fontSize = saved;
    }
    notifyListeners();
  }

  Future<void> increase() async {
    final index = steps.indexOf(_fontSize);
    if (index == -1 || index >= steps.length - 1) return;
    await _setFontSize(steps[index + 1]);
  }

  Future<void> decrease() async {
    final index = steps.indexOf(_fontSize);
    if (index <= 0) return;
    await _setFontSize(steps[index - 1]);
  }

  Future<void> _setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.lyricsFontSizePrefsKey, size);
    notifyListeners();
  }
}
