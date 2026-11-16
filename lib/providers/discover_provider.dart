import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// Whether the user has closed the Home card that points to the Discover page.
/// A device-side flag only (preferences): no database or backup data.
class DiscoverProvider with ChangeNotifier {
  DiscoverProvider() {
    ready = _load();
  }

  bool _cardDismissed = false;
  bool _loaded = false;

  /// True once the card has been closed. False until the saved value is read.
  bool get cardDismissed => _cardDismissed;

  /// True once the saved value has been read (or reading failed).
  bool get loaded => _loaded;

  /// Completes when the saved choice has been read.
  late final Future<void> ready;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.get(AppConstants.discoverCardDismissedPrefsKey);
      _cardDismissed = saved is bool ? saved : false;
    } catch (e, st) {
      AppLogger.error(
        'Reading discover card setting failed',
        error: e,
        stackTrace: st,
      );
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> dismissCard() async {
    if (_cardDismissed) return;
    _cardDismissed = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.discoverCardDismissedPrefsKey, true);
    } catch (e, st) {
      AppLogger.error(
        'Saving discover card setting failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
