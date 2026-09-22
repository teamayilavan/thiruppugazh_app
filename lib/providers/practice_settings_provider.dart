import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// The devotee's stated intent, chosen once during onboarding (T1.9).
/// `justLooking` is the one choice that turns the whole practice layer off.
enum Sankalpam { dailyPractice, meanings, temples, justLooking }

/// Master switch and onboarding state for the optional daily-practice layer.
/// Every practice feature (T1.4 onward) must check [enabled] and render
/// nothing when it is false — this provider is the single source of truth
/// for that opt-out (standing rule 7).
class PracticeSettingsProvider with ChangeNotifier {
  bool _enabled = false; // default OFF — never opt a user in silently
  Sankalpam? _sankalpam; // null = onboarding not completed
  DateTime? _firstRun;

  bool get enabled => _enabled;

  bool get onboardingComplete => _sankalpam != null;

  Sankalpam? get sankalpam => _sankalpam;

  /// Whole days since first run, gating the notification ask (T2.2).
  /// 0 when first run hasn't been recorded yet.
  int get daysSinceFirstRun {
    final firstRun = _firstRun;
    if (firstRun == null) return 0;
    final start = DateTime(firstRun.year, firstRun.month, firstRun.day);
    final today = DateTime.now();
    final now = DateTime(today.year, today.month, today.day);
    return now.difference(start).inDays;
  }

  PracticeSettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(AppConstants.practiceEnabledPrefsKey) ?? false;

    final savedSankalpam = prefs.getString(
      AppConstants.practiceSankalpamPrefsKey,
    );
    if (savedSankalpam != null) {
      try {
        _sankalpam = Sankalpam.values.byName(savedSankalpam);
      } catch (_) {
        _sankalpam = null;
      }
    }

    final savedFirstRun = prefs.getString(
      AppConstants.practiceFirstRunPrefsKey,
    );
    if (savedFirstRun != null) {
      _firstRun = DateTime.tryParse(savedFirstRun);
    }

    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    _enabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.practiceEnabledPrefsKey, value);
    notifyListeners();
  }

  /// Records the devotee's onboarding choice. `justLooking` forces
  /// [enabled] to false; every other choice is itself an opt-in, so it
  /// turns the layer on.
  Future<void> setSankalpam(Sankalpam value) async {
    _sankalpam = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.practiceSankalpamPrefsKey, value.name);
    notifyListeners();

    await setEnabled(value != Sankalpam.justLooking);
  }

  /// Stamps first run exactly once. Later calls are no-ops so the
  /// day-3 notification gate (T2.2) has a stable anchor date.
  Future<void> markFirstRunIfUnset() async {
    if (_firstRun != null) return;
    _firstRun = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.practiceFirstRunPrefsKey,
      _firstRun!.toIso8601String(),
    );
    notifyListeners();
  }
}
