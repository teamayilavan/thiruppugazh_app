// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';

/// Log levels for application logging.
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Utility class for consistent logging throughout the application.
/// In debug mode, logs are printed to console.
/// In release mode, logs can be sent to remote logging service.
class AppLogger {
  AppLogger._();

  static const bool _debugMode = kDebugMode;
  static LogLevel _minLogLevel = _debugMode ? LogLevel.debug : LogLevel.info;

  /// Sets the minimum log level.
  /// Logs below this level will be ignored.
  static void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Logs a debug message.
  /// Only shown in debug builds.
  static void debug(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an informational message.
  /// Shown in debug and release builds.
  static void info(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// Logs a warning message.
  /// Shown in debug and release builds.
  static void warning(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// Logs an error message.
  /// Shown in debug and release builds.
  static void error(String message, {dynamic error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method.
  static void _log(
    LogLevel level,
    String message, {
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (level.index < _minLogLevel.index) {
      return;
    }

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = _getLevelString(level);

    final logMessage = '[$timestamp] $levelStr: $message';

    if (_debugMode) {
      print(logMessage);

      if (error != null) {
        print('Error details: $error');
      }

      if (stackTrace != null) {
        print('Stack trace:\n$stackTrace');
      }
    } else {
      // In release mode, send logs to crash reporting/analytics service
      // e.g., Firebase Crashlytics, Sentry, etc.
      // AnalyticsService.logError(logMessage, error: error);
    }
  }

  /// Converts log level to string.
  static String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }
}

/// Extension to simplify logging on objects.
extension LoggerExtension on Object {
  void logDebug([String? message]) {
    AppLogger.debug(message ?? toString());
  }

  void logInfo([String? message]) {
    AppLogger.info(message ?? toString());
  }

  void logWarning([String? message]) {
    AppLogger.warning(message ?? toString());
  }

  void logError([String? message]) {
    AppLogger.error(message ?? toString());
  }
}
