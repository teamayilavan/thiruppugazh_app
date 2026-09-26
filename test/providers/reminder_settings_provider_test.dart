import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiruppugazh/providers/reminder_settings_provider.dart';
import 'package:thiruppugazh/services/reminder_notification_service.dart';

/// Records calls instead of touching the real
/// flutter_local_notifications platform channel, which isn't available
/// in a plain widget-test environment.
class _FakeReminderNotificationService extends ReminderNotificationService {
  _FakeReminderNotificationService({this.permissionGranted = true});

  final bool permissionGranted;
  int scheduleCalls = 0;
  int cancelCalls = 0;
  TimeOfDay? lastScheduledTime;

  @override
  Future<bool> requestPermission() async => permissionGranted;

  @override
  Future<void> scheduleDaily(
    TimeOfDay time, {
    required String title,
    required String body,
  }) async {
    scheduleCalls++;
    lastScheduledTime = time;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ReminderSettingsProvider', () {
    test('defaults to disabled with an 8:00 AM reminder time', () async {
      final provider = ReminderSettingsProvider(
        notificationService: _FakeReminderNotificationService(),
      );
      await Future.delayed(Duration.zero);

      expect(provider.enabled, false);
      expect(provider.reminderTime, const TimeOfDay(hour: 8, minute: 0));
    });

    test('loads saved enabled/time preference on construction', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_enabled': true,
        'reminder_time_minutes': 19 * 60 + 30,
      });
      final provider = ReminderSettingsProvider(
        notificationService: _FakeReminderNotificationService(),
      );
      await Future.delayed(Duration.zero);

      expect(provider.enabled, true);
      expect(provider.reminderTime, const TimeOfDay(hour: 19, minute: 30));
    });

    test('enable() turns on and schedules when permission is granted', () async {
      final service = _FakeReminderNotificationService(
        permissionGranted: true,
      );
      final provider = ReminderSettingsProvider(notificationService: service);
      await Future.delayed(Duration.zero);

      final result = await provider.enable();

      expect(result, true);
      expect(provider.enabled, true);
      expect(service.scheduleCalls, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), true);
    });

    test('enable() stays off and does not schedule when permission is denied', () async {
      final service = _FakeReminderNotificationService(
        permissionGranted: false,
      );
      final provider = ReminderSettingsProvider(notificationService: service);
      await Future.delayed(Duration.zero);

      final result = await provider.enable();

      expect(result, false);
      expect(provider.enabled, false);
      expect(service.scheduleCalls, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), isNot(true));
    });

    test('disable() turns off and cancels the schedule', () async {
      final service = _FakeReminderNotificationService();
      final provider = ReminderSettingsProvider(notificationService: service);
      await Future.delayed(Duration.zero);
      await provider.enable();

      await provider.disable();

      expect(provider.enabled, false);
      expect(service.cancelCalls, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('reminder_enabled'), false);
    });

    test('setReminderTime persists and reschedules only while enabled', () async {
      final service = _FakeReminderNotificationService();
      final provider = ReminderSettingsProvider(notificationService: service);
      await Future.delayed(Duration.zero);

      // Disabled: persists the time but does not schedule anything.
      await provider.setReminderTime(const TimeOfDay(hour: 6, minute: 15));
      expect(provider.reminderTime, const TimeOfDay(hour: 6, minute: 15));
      expect(service.scheduleCalls, 0);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('reminder_time_minutes'), 6 * 60 + 15);

      // Enabled: changing the time reschedules with the new time.
      await provider.enable();
      service.scheduleCalls = 0;
      await provider.setReminderTime(const TimeOfDay(hour: 21, minute: 0));
      expect(service.scheduleCalls, 1);
      expect(service.lastScheduledTime, const TimeOfDay(hour: 21, minute: 0));
    });
  });
}
