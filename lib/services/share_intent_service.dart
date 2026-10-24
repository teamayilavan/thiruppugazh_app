import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

/// Receives text shared into the app from other apps (Android's share sheet).
///
/// The native side lives in MainActivity. [getInitialSharedText] covers the
/// app being launched by a share; [sharedText] covers a share arriving while
/// the app is already running. On platforms without the native side both are
/// quietly empty.
class ShareIntentService {
  ShareIntentService._();

  static const MethodChannel _channel = MethodChannel(
    'org.ayilavan.thiruppugazh/share',
  );

  static final StreamController<String> _controller =
      StreamController<String>.broadcast();
  static bool _listening = false;

  static bool get _supported => Platform.isAndroid;

  /// Text that launched the app, or null. Returns it only once.
  static Future<String?> getInitialSharedText() async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<String>('getInitialSharedText');
    } on MissingPluginException {
      return null;
    } catch (e, st) {
      AppLogger.error('Reading initial shared text failed', error: e, stackTrace: st);
      return null;
    }
  }

  /// Text shared while the app is running.
  static Stream<String> get sharedText {
    if (_supported && !_listening) {
      _listening = true;
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onSharedText' && call.arguments is String) {
          _controller.add(call.arguments as String);
        }
      });
    }
    return _controller.stream;
  }
}
