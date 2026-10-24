import 'dart:io' show Platform;
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

/// Keeps the screen on while the user is chanting, so it doesn't dim or lock
/// in the middle of a verse. The native side is a window flag set in
/// MainActivity; elsewhere this is a no-op.
class ScreenAwakeService {
  ScreenAwakeService._();

  static const MethodChannel _channel = MethodChannel(
    'org.ayilavan.thiruppugazh/screen',
  );

  static Future<void> setKeepAwake(bool keepAwake) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', keepAwake);
    } on MissingPluginException {
      // Native side not present (e.g. in tests); nothing to do.
    } catch (e, st) {
      AppLogger.error('Setting keep-screen-on failed', error: e, stackTrace: st);
    }
  }
}
