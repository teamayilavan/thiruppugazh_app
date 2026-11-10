import 'package:flutter_test/flutter_test.dart';
import 'package:thiruppugazh/services/screen_awake_service.dart';

void main() {
  late List<bool> sent;

  setUp(() {
    ScreenAwakeService.resetForTesting();
    sent = [];
    ScreenAwakeService.sender = (keepAwake) async => sent.add(keepAwake);
  });

  tearDown(ScreenAwakeService.resetForTesting);

  test(
    'the first holder turns the screen on, the last one turns it off',
    () async {
      await ScreenAwakeService.acquire();
      await ScreenAwakeService.acquire();
      expect(sent, [true]); // not sent twice

      await ScreenAwakeService.release();
      expect(sent, [true]); // one holder is left

      await ScreenAwakeService.release();
      expect(sent, [true, false]);
      expect(ScreenAwakeService.holders, 0);
    },
  );

  test(
    'a new holder arriving before the old one leaves never lets it sleep',
    () async {
      // The reading pane starts the next song's page before the previous
      // page has been disposed.
      await ScreenAwakeService.acquire();
      await ScreenAwakeService.acquire();
      await ScreenAwakeService.release();
      expect(sent, [true]);
      expect(ScreenAwakeService.holders, 1);
    },
  );

  test('releasing without holding does nothing', () async {
    await ScreenAwakeService.release();
    expect(sent, isEmpty);
    expect(ScreenAwakeService.holders, 0);
  });
}
