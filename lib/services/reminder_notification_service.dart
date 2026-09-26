import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../utils/app_logger.dart';

/// Schedules the single opt-in daily reminder notification. Entirely
/// on-device: no network, no server. A single [zonedSchedule] call with
/// [DateTimeComponents.time] is enough for a true daily-repeating
/// notification -- unlike a per-day-unique-content reminder, this one's
/// text never changes, so there is no rolling window to maintain; the OS
/// itself repeats it every day at the chosen wall-clock time.
class ReminderNotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'daily_reminder';
  static const String _channelName = 'Daily reminder';
  static const String _channelDescription =
      'A daily reminder to open Thiruppugazh, generated entirely on this '
      'device.';
  static const int _notificationId = 8000;

  bool _pluginInitialized = false;

  Future<void> _ensureInitialized() async {
    if (_pluginInitialized) return;
    // Not the launcher mipmap: Android ignores color on status-bar icons
    // and renders anything but a plain alpha silhouette as a solid blob,
    // so this points at a dedicated white-on-transparent drawable instead
    // (cropped from the app's own vel emblem).
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_reminder',
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(settings: initSettings);
    _pluginInitialized = true;
  }

  /// Requests the OS notification permission. Must be called right after
  /// the devotee switches the reminder toggle on.
  Future<bool> requestPermission() async {
    await _ensureInitialized();
    try {
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidImpl != null) {
        return await androidImpl.requestNotificationsPermission() ?? false;
      }
      final iosImpl = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (iosImpl != null) {
        return await iosImpl.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
      return true; // desktop/other platforms: nothing to request
    } catch (e, st) {
      AppLogger.error(
        'Failed to request notification permission',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  /// Schedules the reminder to repeat every day at [time]. Cancels any
  /// previous schedule first, so this is safe to call again whenever the
  /// devotee changes the time.
  Future<void> scheduleDaily(TimeOfDay time, {required String title, required String body}) async {
    await _ensureInitialized();
    await cancel();

    final now = DateTime.now();
    var fireAt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (!fireAt.isAfter(now)) {
      fireAt = fireAt.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id: _notificationId,
        title: title,
        body: body,
        // TZDateTime.from() converts using fireAt.toUtc() -- Dart's own,
        // always-correct local-to-UTC conversion -- so the *instant* is
        // right no matter which Location is attached; the Location only
        // controls what zone name gets sent to the native side. tz.UTC
        // ('Etc/UTC') is used deliberately: it is the one zone name
        // guaranteed to resolve on both Android and iOS without needing a
        // device timezone-name lookup package, which isn't in this app's
        // dependency set.
        scheduledDate: tz.TZDateTime.from(fireAt, tz.UTC),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Exact alarms need a separate, sensitive Android permission this
        // app doesn't request; a few minutes' slack for a daily reminder
        // is not worth asking for it.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to schedule daily reminder notification',
        error: e,
        stackTrace: st,
      );
    }
  }

  /// Cancels the reminder notification, if scheduled.
  Future<void> cancel() async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(id: _notificationId);
    } catch (e, st) {
      AppLogger.error(
        'Failed to cancel daily reminder notification',
        error: e,
        stackTrace: st,
      );
    }
  }
}
