import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/reminder_notification_service.dart';
import 'package:timezone/data/latest_10y.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  const eight = TimeOfDay(hour: 8, minute: 0);

  test('later today when the time has not passed yet', () {
    final kolkata = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime(kolkata, 2026, 10, 24, 6, 30);
    final next = ReminderNotificationService.nextFireTime(kolkata, eight, now);
    expect(next, tz.TZDateTime(kolkata, 2026, 10, 24, 8, 0));
  });

  test('tomorrow when the time has passed', () {
    final kolkata = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime(kolkata, 2026, 10, 24, 9, 15);
    final next = ReminderNotificationService.nextFireTime(kolkata, eight, now);
    expect(next, tz.TZDateTime(kolkata, 2026, 10, 25, 8, 0));
  });

  test('stays at 08:00 on the wall clock across a daylight-saving change', () {
    final ny = tz.getLocation('America/New_York');
    // US clocks go back on 1 Nov 2026; asking on the evening before, the
    // next 08:00 is 25 hours away in real time but still 08:00 locally.
    final now = tz.TZDateTime(ny, 2026, 10, 31, 20, 0);
    final next = ReminderNotificationService.nextFireTime(ny, eight, now);
    expect(next.hour, 8);
    expect(next.day, 1);
    expect(next.timeZoneOffset, const Duration(hours: -5));
    expect(next.difference(now), const Duration(hours: 13));
  });

  test('rolls over the end of the month', () {
    final kolkata = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime(kolkata, 2026, 10, 31, 23, 0);
    final next = ReminderNotificationService.nextFireTime(kolkata, eight, now);
    expect(next, tz.TZDateTime(kolkata, 2026, 11, 1, 8, 0));
  });
}
