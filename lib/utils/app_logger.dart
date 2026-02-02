import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

/// Centralized logging utility to replace print() statements
/// Supports different log levels and automatically filters in release builds
class AppLogger {
  static const bool _enableLogging = !kReleaseMode || kDebugMode;

  /// Log debug messages (only in debug mode)
  static void debug(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (_enableLogging) {
      developer.log(
        message,
        name: tag ?? 'AppLogger',
        error: error,
        stackTrace: stackTrace,
        level: 900, // DEBUG level
      );
    }
  }

  /// Log info messages
  static void info(String message, [String? tag]) {
    if (_enableLogging) {
      developer.log(
        message,
        name: tag ?? 'AppLogger',
        level: 800, // INFO level
      );
    }
  }

  /// Log warning messages
  static void warning(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      error: error,
      stackTrace: stackTrace,
      level: 900, // WARNING level
    );
  }

  /// Log error messages (always logged, even in release)
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? additionalData,
  }) {
    developer.log(
      message,
      name: tag ?? 'AppLogger',
      error: error,
      stackTrace: stackTrace,
      level: 1000, // ERROR level
    );

    // In production, you might want to send this to a crash reporting service
    // e.g., Firebase Crashlytics, Sentry, etc.
    if (kReleaseMode && error != null && stackTrace != null) {
      // TODO: Integrate with crash reporting service
      // FirebaseCrashlytics.instance.recordError(error, stackTrace);
    }

    if (additionalData != null && _enableLogging) {
      developer.log(
        'Additional data: $additionalData',
        name: tag ?? 'AppLogger',
        level: 1000,
      );
    }
  }

  /// Log critical errors that need immediate attention
  static void critical(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    AppLogger.error(message, tag: tag, error: error, stackTrace: stackTrace);
    
    // Critical errors should always be reported
    if (kReleaseMode && error != null && stackTrace != null) {
      // TODO: Send to crash reporting service
    }
  }
}
