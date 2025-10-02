import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Secure error handling utility to prevent information disclosure
class ErrorHandler {
  /// Logs error securely without exposing sensitive information to users
  static void logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? context,
  }) {
    // Log to console only in debug mode
    if (kDebugMode) {
      debugPrint('Error: $error');
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
      if (context != null) {
        debugPrint('Context: $context');
      }
    }

    // Always report to Crashlytics in production for monitoring
    try {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: reason,
        information: context?.entries.map((e) => '${e.key}: ${e.value}').toList() ?? [],
        fatal: false,
      );
    } catch (e) {
      // Fail silently if crashlytics fails
      if (kDebugMode) {
        debugPrint('Failed to report to Crashlytics: $e');
      }
    }
  }

  /// Returns user-friendly error message without exposing internal details
  static String getUserFriendlyMessage(dynamic error, {String? fallback}) {
    // Never expose actual exception details to users
    if (error is SecurityException) {
      return error.userMessage;
    }

    if (error is UserFriendlyException) {
      return error.userMessage;
    }

    // Return generic messages for common error types
    if (error.toString().toLowerCase().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (error.toString().toLowerCase().contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (error.toString().toLowerCase().contains('permission')) {
      return 'Permission denied. Please check your device settings.';
    }

    if (error.toString().toLowerCase().contains('authentication')) {
      return 'Authentication failed. Please sign in again.';
    }

    if (error.toString().toLowerCase().contains('storage')) {
      return 'Storage error. Please check available space.';
    }

    // Default generic message
    return fallback ?? 'An unexpected error occurred. Please try again.';
  }

  /// Handles errors in async operations safely
  static Future<T?> handleAsync<T>(
    Future<T> operation, {
    String? errorContext,
    T? fallbackValue,
  }) async {
    try {
      return await operation;
    } catch (error, stackTrace) {
      logError(
        error,
        stackTrace,
        reason: errorContext,
        context: {'operation': T.toString()},
      );
      return fallbackValue;
    }
  }

  /// Handles synchronous operations safely
  static T? handleSync<T>(
    T Function() operation, {
    String? errorContext,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      logError(
        error,
        stackTrace,
        reason: errorContext,
        context: {'operation': T.toString()},
      );
      return fallbackValue;
    }
  }
}

/// Exception that can safely expose user-friendly messages
class UserFriendlyException implements Exception {
  final String userMessage;
  final dynamic originalError;

  const UserFriendlyException(this.userMessage, [this.originalError]);

  @override
  String toString() => userMessage;
}

/// Security-related exception with safe user message
class SecurityException extends UserFriendlyException {
  const SecurityException(super.userMessage, [super.originalError]);
}

/// Network-related exception with safe user message
class NetworkException extends UserFriendlyException {
  const NetworkException(super.userMessage, [super.originalError]);
}

/// Storage-related exception with safe user message
class StorageException extends UserFriendlyException {
  const StorageException(super.userMessage, [super.originalError]);
}