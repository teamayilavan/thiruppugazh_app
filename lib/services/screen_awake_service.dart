import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

/// Keeps the screen on while the user is chanting or, if they asked for it,
/// reading, so it doesn't dim or lock in the middle of a verse. The native
/// side is a window flag set in MainActivity; elsewhere this is a no-op.
///
/// Several screens can ask at once (a song page and chanting mode on top of
/// it, or the reading pane swapping one song for the next while the old page
/// is still being disposed), so it counts holders: the screen is kept on
/// while at least one holds it.
class ScreenAwakeService {
  ScreenAwakeService._();

  static const MethodChannel _channel = MethodChannel(
    'org.ayilavan.thiruppugazh/screen',
  );

  static int _holders = 0;

  /// Sends the flag to the native side. Replaceable in tests.
  @visibleForTesting
  static Future<void> Function(bool keepAwake) sender = _sendToNative;

  @visibleForTesting
  static int get holders => _holders;

  @visibleForTesting
  static void resetForTesting() {
    _holders = 0;
    sender = _sendToNative;
  }

  /// Start holding the screen on. Pair every call with [release].
  static Future<void> acquire() async {
    _holders++;
    if (_holders == 1) await sender(true);
  }

  /// Stop holding it. The screen is allowed to sleep again once nobody holds
  /// it.
  static Future<void> release() async {
    if (_holders == 0) return;
    _holders--;
    if (_holders == 0) await sender(false);
  }

  static Future<void> _sendToNative(bool keepAwake) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('setKeepScreenOn', keepAwake);
    } on MissingPluginException {
      // Native side not present (e.g. in tests); nothing to do.
    } catch (e, st) {
      AppLogger.error(
        'Setting keep-screen-on failed',
        error: e,
        stackTrace: st,
      );
    }
  }
}
