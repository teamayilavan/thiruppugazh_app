import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/reminder_notification_service.dart';

NotificationResponse _response(int? id) => NotificationResponse(
  notificationResponseType: NotificationResponseType.selectedNotification,
  id: id,
);

void main() {
  group('isReminderResponse', () {
    test('recognises the daily reminder by its id', () {
      expect(
        ReminderNotificationService.isReminderResponse(_response(8000)),
        isTrue,
      );
    });

    test(
      'a reminder scheduled by an earlier version (no payload) still counts',
      () {
        // Earlier versions set no payload, so only the id can identify it.
        const old = NotificationResponse(
          notificationResponseType:
              NotificationResponseType.selectedNotification,
          id: 8000,
          payload: null,
        );
        expect(ReminderNotificationService.isReminderResponse(old), isTrue);
      },
    );

    test('ignores other notifications and missing responses', () {
      expect(
        ReminderNotificationService.isReminderResponse(_response(1)),
        isFalse,
      );
      expect(
        ReminderNotificationService.isReminderResponse(_response(null)),
        isFalse,
      );
      expect(ReminderNotificationService.isReminderResponse(null), isFalse);
    });
  });

  test('a tap is announced to listeners', () async {
    var taps = 0;
    final sub = ReminderNotificationService.taps.listen((_) => taps++);
    ReminderNotificationService.emitTapForTesting();
    await Future<void>.delayed(Duration.zero);
    expect(taps, 1);
    await sub.cancel();
  });
}
