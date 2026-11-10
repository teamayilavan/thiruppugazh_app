import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

/// The last few things the user searched for, kept on the device only so the
/// search screen can offer them again. A search counts once the user opens one
/// of its results, not on every keystroke. Stored as one small list in
/// preferences, so no database or backup change.
class RecentSearches {
  RecentSearches._();

  static const int maxItems = 8;

  static Future<List<String>> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(AppConstants.recentSearchesPrefsKey);
      if (raw == null) return [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return [
        for (final item in decoded)
          if (item is String && item.trim().isNotEmpty) item.trim(),
      ].take(maxItems).toList();
    } catch (e, st) {
      AppLogger.error('Recent searches unreadable', error: e, stackTrace: st);
      return [];
    }
  }

  /// Remembers [query] as the most recent search and returns the new list.
  /// Very short queries are ignored, and a repeat moves to the front.
  static Future<List<String>> add(String query) async {
    final q = query.trim();
    final current = await load();
    if (q.length < 2) return current;
    final updated = [
      q,
      ...current.where((s) => s.toLowerCase() != q.toLowerCase()),
    ].take(maxItems).toList();
    await _save(updated);
    return updated;
  }

  static Future<void> clear() => _save(const []);

  static Future<void> _save(List<String> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.recentSearchesPrefsKey,
        jsonEncode(items),
      );
    } catch (e, st) {
      AppLogger.error(
        'Saving recent searches failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
