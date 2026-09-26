import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import '../l10n/app_localizations_ta.dart';
import '../services/reminder_notification_service.dart';

/// Offline, opt-in daily reminder: a toggle plus a time. Entirely local --
/// no network is ever involved, and the devotee can turn it off at any
/// time. Persists to [SharedPreferences] and owns scheduling/cancelling
/// the underlying OS notification via [ReminderNotificationService].
class ReminderSettingsProvider with ChangeNotifier {
  ReminderSettingsProvider({ReminderNotificationService? notificationService})
    : _notifications = notificationService ?? ReminderNotificationService() {
    _load();
  }

  final ReminderNotificationService _notifications;

  // 08:00 -- a plain, unremarkable default time until the devotee picks
  // their own.
  static const int _defaultReminderMinutes = 8 * 60;

  bool _enabled = false; // default OFF -- never opt a devotee in silently
  // Stored as minutes since midnight (0-1439) rather than a `TimeOfDay` --
  // `TimeOfDay` has no built-in prefs codec, and a plain int is the
  // simplest stable encoding.
  int _reminderMinutesSinceMidnight = _defaultReminderMinutes;

  bool get enabled => _enabled;

  TimeOfDay get reminderTime => TimeOfDay(
    hour: _reminderMinutesSinceMidnight ~/ 60,
    minute: _reminderMinutesSinceMidnight % 60,
  );

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(AppConstants.reminderEnabledPrefsKey) ?? false;

    final savedMinutes = prefs.getInt(AppConstants.reminderTimePrefsKey);
    if (savedMinutes != null && savedMinutes >= 0 && savedMinutes < 24 * 60) {
      _reminderMinutesSinceMidnight = savedMinutes;
    }

    notifyListeners();

    if (_enabled) {
      await _scheduleWithLocalizedText(reminderTime);
    }
  }

  /// Attempts to turn the reminder on: requests the OS notification
  /// permission and, only if granted, persists [enabled] as true and
  /// schedules the notification. Returns false (and leaves [enabled]
  /// false) if permission was denied, so the caller can explain why the
  /// toggle didn't turn on.
  Future<bool> enable() async {
    final granted = await _notifications.requestPermission();
    if (!granted) return false;

    _enabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.reminderEnabledPrefsKey, true);
    notifyListeners();

    await _scheduleWithLocalizedText(reminderTime);
    return true;
  }

  Future<void> disable() async {
    _enabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.reminderEnabledPrefsKey, false);
    notifyListeners();

    await _notifications.cancel();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderMinutesSinceMidnight = time.hour * 60 + time.minute;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      AppConstants.reminderTimePrefsKey,
      _reminderMinutesSinceMidnight,
    );
    notifyListeners();

    if (_enabled) {
      await _scheduleWithLocalizedText(time);
    }
  }

  /// Resolves the devotee's UI language (the same preference
  /// [LanguageProvider] persists to and loads from) and schedules the
  /// notification with that language's title/body. There is no
  /// [BuildContext] here -- scheduling can happen outside a widget tree
  /// -- so the language pref is read directly from [SharedPreferences]
  /// and the matching generated localization class is constructed
  /// directly rather than resolved via `AppLocalizations.of(context)`.
  Future<void> _scheduleWithLocalizedText(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languagePrefsKey);
    final AppLocalizations l10n = languageCode == 'en'
        ? AppLocalizationsEn()
        : AppLocalizationsTa();

    await _notifications.scheduleDaily(
      time,
      title: l10n.reminderNotificationTitle,
      body: l10n.reminderNotificationBody,
    );
  }
}
