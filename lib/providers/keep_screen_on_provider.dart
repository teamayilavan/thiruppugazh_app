import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// The user's choice to keep the screen from dimming while they read a song.
/// Off unless they turn it on; chanting mode always keeps the screen on.
class KeepScreenOnProvider with ChangeNotifier {
  KeepScreenOnProvider() {
    ready = _load();
  }

  bool _enabled = false;
  bool get enabled => _enabled;

  /// Completes when the saved choice has been read.
  late final Future<void> ready;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled =
          prefs.getBool(AppConstants.keepScreenOnReadingPrefsKey) ?? false;
      notifyListeners();
    } catch (e, st) {
      AppLogger.error(
        'Reading keep-screen-on setting failed',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<void> setEnabled(bool value) async {
    if (value == _enabled) return;
    _enabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keepScreenOnReadingPrefsKey, value);
    } catch (e, st) {
      AppLogger.error(
        'Saving keep-screen-on setting failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
