import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Custom error types for the application.
class AppException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  AppException(this.message, {this.details, this.originalError});

  @override
  String toString() {
    if (details != null) {
      return '$message: $details';
    }
    return message;
  }
}

/// Database-related exceptions.
class DatabaseException extends AppException {
  DatabaseException(super.message, {super.details, super.originalError});

  factory DatabaseException.connectionError(dynamic error) {
    return DatabaseException(
      'Database connection error',
      details: error.toString(),
      originalError: error,
    );
  }

  factory DatabaseException.queryError(String query, dynamic error) {
    return DatabaseException(
      'Query execution error',
      details: 'Query: $query, Error: $error',
      originalError: error,
    );
  }

  factory DatabaseException.migrationError(int fromVersion, int toVersion) {
    return DatabaseException(
      'Database migration failed',
      details: 'From $fromVersion to $toVersion',
    );
  }
}

/// Network-related exceptions.
class NetworkException extends AppException {
  NetworkException(super.message, {super.details, super.originalError});

  factory NetworkException.urlLaunchError(String url) {
    return NetworkException(
      'Failed to launch URL',
      details: url,
    );
  }

  factory NetworkException.timeoutError() {
    return NetworkException(
      'Request timed out',
    );
  }
}

/// Validation-related exceptions.
class ValidationException extends AppException {
  ValidationException(super.message, {super.details, super.originalError});

  factory ValidationException.invalidInput(String field) {
    return ValidationException(
      'Invalid input',
      details: field,
    );
  }

  factory ValidationException.duplicateValue(String field) {
    return ValidationException(
      'Duplicate value',
      details: field,
    );
  }

  factory ValidationException.tooShort(String field, int minLength) {
    return ValidationException(
      'Value too short',
      details: '$field must be at least $minLength characters',
    );
  }

  factory ValidationException.tooLong(String field, int maxLength) {
    return ValidationException(
      'Value too long',
      details: '$field must not exceed $maxLength characters',
    );
  }
}

/// Consistent error handler for the application.
class ErrorHandler {
  ErrorHandler._();

  /// Logs an error with appropriate severity.
  static void logError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('ERROR: $error');
      if (stackTrace != null) {
        print('STACK TRACE:\n$stackTrace');
      }
    }
    // In production, this would send to crash reporting service
  }

  /// Logs a warning.
  static void logWarning(String message) {
    if (kDebugMode) {
      print('WARNING: $message');
    }
  }

  /// Logs informational message.
  static void logInfo(String message) {
    if (kDebugMode) {
      print('INFO: $message');
    }
  }

  /// Handles different types of errors and returns a user-friendly message.
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is SocketException) {
      return 'Network error. Please check your internet connection.';
    }

    if (error is FileSystemException) {
      return 'File system error occurred.';
    }

    return 'An unexpected error occurred.';
  }

  /// Shows an error dialog or snackbar with the error message.
  static void showError(
    BuildContext context,
    dynamic error, {
    String? customMessage,
    VoidCallback? onRetry,
  }) {
    final message = customMessage ?? getErrorMessage(error);

    logError(error, StackTrace.current);

    if (onRetry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: onRetry,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  /// Wraps an async operation and handles errors automatically.
  static Future<T?> handleAsyncOperation<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await operation();
    } catch (error) {
      logError(error, StackTrace.current);

      if (onError != null) {
        onError(error);
      }

      if (context != null) {
        showError(context, error);
      }

      return null;
    }
  }
}
