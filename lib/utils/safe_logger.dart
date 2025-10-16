import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// SafeLogger provides production-safe logging utilities
/// that automatically disable or sanitize logs in release builds.
class SafeLogger {
  /// Log general debug information (disabled in release mode)
  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  /// Log warning messages (always logged, sent to Crashlytics in release)
  static void warning(String message, {String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    final fullMessage = '$prefix$message';

    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $fullMessage');
    } else {
      // In release, send warnings to Crashlytics for monitoring
      FirebaseCrashlytics.instance.log(fullMessage);
    }
  }

  /// Log error messages (always logged, sent to Crashlytics)
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final prefix = tag != null ? '[$tag] ' : '';
    final fullMessage = '$prefix$message';

    if (kDebugMode) {
      debugPrint('❌ ERROR: $fullMessage');
      if (error != null) debugPrint('  Error: $error');
      if (stackTrace != null) debugPrint('  StackTrace: $stackTrace');
    }

    // Always log errors to Crashlytics
    if (error != null && stackTrace != null) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace, reason: fullMessage);
    } else {
      FirebaseCrashlytics.instance.log('ERROR: $fullMessage');
    }
  }

  /// Log sensitive information (ONLY in debug mode, completely disabled in release)
  /// Use this for authentication, encryption, or user data that should NEVER
  /// appear in production logs.
  static void sensitive(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🔒 SENSITIVE: $prefix$message');
    }
    // Completely silent in release mode
  }

  /// Log performance metrics (disabled in release unless explicitly enabled)
  static void performance(String message, {String? tag, Map<String, dynamic>? metrics}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚡ PERF: $prefix$message');
      if (metrics != null) {
        metrics.forEach((key, value) {
          debugPrint('  $key: $value');
        });
      }
    }
  }

  /// Log network requests (sanitized in release mode)
  static void network(String message, {String? tag, bool includeDetails = true}) {
    final prefix = tag != null ? '[$tag] ' : '';

    if (kDebugMode && includeDetails) {
      debugPrint('🌐 NETWORK: $prefix$message');
    } else if (!kDebugMode) {
      // In release, only log basic network info without sensitive details
      final sanitized = _sanitizeUrl(message);
      FirebaseCrashlytics.instance.log('NETWORK: $prefix$sanitized');
    }
  }

  /// Sanitize URLs by removing query parameters and sensitive paths
  static String _sanitizeUrl(String message) {
    // Remove query parameters
    final withoutQuery = message.split('?').first;
    // Remove user IDs and other sensitive path components
    return withoutQuery.replaceAllMapped(
      RegExp(r'/users/[^/]+'),
      (match) => '/users/***',
    ).replaceAllMapped(
      RegExp(r'/memories/[^/]+'),
      (match) => '/memories/***',
    );
  }
}
