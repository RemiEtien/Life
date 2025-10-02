import 'dart:io';

/// Comprehensive input validation utility for security
class InputValidator {
  // Content length limits
  static const int maxMemoryTitleLength = 200;
  static const int maxMemoryContentLength = 10000;
  static const int maxUserNameLength = 100;
  static const int maxEmailLength = 320; // RFC 5321 limit
  static const int maxReflectionLength = 5000;
  static const int maxLocationLength = 300;

  // File validation limits
  static const int maxFileNameLength = 255;
  static const int maxFilePathLength = 4096;
  static const Set<String> allowedImageExtensions = {
    '.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'
  };
  static const Set<String> allowedVideoExtensions = {
    '.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp'
  };
  static const Set<String> allowedAudioExtensions = {
    '.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac'
  };

  // Dangerous patterns to filter
  static final RegExp _scriptPattern = RegExp(
    r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>',
    caseSensitive: false,
  );
  static final RegExp _sqlInjectionPattern = RegExp(
    r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER|EXEC|UNION)\b)',
    caseSensitive: false,
  );
  static final RegExp _pathTraversalPattern = RegExp(r'\.\.[\\/]');
  static final RegExp _nullBytePattern = RegExp(r'\x00');

  /// Validates memory title
  static ValidationResult validateMemoryTitle(String? title) {
    if (title == null || title.trim().isEmpty) {
      return ValidationResult.invalid('Memory title cannot be empty');
    }

    final sanitized = _sanitizeText(title);
    if (sanitized.length > maxMemoryTitleLength) {
      return ValidationResult.invalid('Memory title too long (max $maxMemoryTitleLength characters)');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('Memory title contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates memory content
  static ValidationResult validateMemoryContent(String? content) {
    if (content == null) {
      return ValidationResult.valid('');
    }

    final sanitized = _sanitizeText(content);
    if (sanitized.length > maxMemoryContentLength) {
      return ValidationResult.invalid('Memory content too long (max $maxMemoryContentLength characters)');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('Memory content contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates user profile name
  static ValidationResult validateUserName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return ValidationResult.invalid('User name cannot be empty');
    }

    final sanitized = _sanitizeText(name);
    if (sanitized.length > maxUserNameLength) {
      return ValidationResult.invalid('User name too long (max $maxUserNameLength characters)');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('User name contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates email address
  static ValidationResult validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return ValidationResult.invalid('Email cannot be empty');
    }

    final sanitized = email.trim().toLowerCase();
    if (sanitized.length > maxEmailLength) {
      return ValidationResult.invalid('Email too long (max $maxEmailLength characters)');
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(sanitized)) {
      return ValidationResult.invalid('Invalid email format');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('Email contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates reflection/impact text
  static ValidationResult validateReflection(String? reflection) {
    if (reflection == null) {
      return ValidationResult.valid('');
    }

    final sanitized = _sanitizeText(reflection);
    if (sanitized.length > maxReflectionLength) {
      return ValidationResult.invalid('Reflection too long (max $maxReflectionLength characters)');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('Reflection contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates location string
  static ValidationResult validateLocation(String? location) {
    if (location == null) {
      return ValidationResult.valid('');
    }

    final sanitized = _sanitizeText(location);
    if (sanitized.length > maxLocationLength) {
      return ValidationResult.invalid('Location too long (max $maxLocationLength characters)');
    }

    if (_containsDangerousContent(sanitized)) {
      return ValidationResult.invalid('Location contains invalid content');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates file path for security
  static ValidationResult validateFilePath(String? path) {
    if (path == null || path.trim().isEmpty) {
      return ValidationResult.invalid('File path cannot be empty');
    }

    final sanitized = path.trim();

    // Check for path traversal attacks
    if (_pathTraversalPattern.hasMatch(sanitized)) {
      return ValidationResult.invalid('File path contains directory traversal');
    }

    // Check for null bytes
    if (_nullBytePattern.hasMatch(sanitized)) {
      return ValidationResult.invalid('File path contains null bytes');
    }

    // Check length
    if (sanitized.length > maxFilePathLength) {
      return ValidationResult.invalid('File path too long (max $maxFilePathLength characters)');
    }

    // Extract filename for validation
    final fileName = sanitized.split(Platform.pathSeparator).last;
    if (fileName.length > maxFileNameLength) {
      return ValidationResult.invalid('File name too long (max $maxFileNameLength characters)');
    }

    return ValidationResult.valid(sanitized);
  }

  /// Validates file extension for media files
  static ValidationResult validateMediaFile(String? path, MediaType type) {
    final pathResult = validateFilePath(path);
    if (!pathResult.isValid) {
      return pathResult;
    }

    final extension = _getFileExtension(pathResult.value!).toLowerCase();

    switch (type) {
      case MediaType.image:
        if (!allowedImageExtensions.contains(extension)) {
          return ValidationResult.invalid('Invalid image file extension');
        }
        break;
      case MediaType.video:
        if (!allowedVideoExtensions.contains(extension)) {
          return ValidationResult.invalid('Invalid video file extension');
        }
        break;
      case MediaType.audio:
        if (!allowedAudioExtensions.contains(extension)) {
          return ValidationResult.invalid('Invalid audio file extension');
        }
        break;
    }

    return pathResult;
  }

  /// Sanitizes text by removing dangerous content
  static String _sanitizeText(String input) {
    String sanitized = input.trim();

    // Remove script tags
    sanitized = sanitized.replaceAll(_scriptPattern, '');

    // Remove null bytes
    sanitized = sanitized.replaceAll(_nullBytePattern, '');

    // Normalize whitespace
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    return sanitized;
  }

  /// Checks for dangerous content patterns
  static bool _containsDangerousContent(String input) {
    return _scriptPattern.hasMatch(input) ||
           _sqlInjectionPattern.hasMatch(input) ||
           _pathTraversalPattern.hasMatch(input) ||
           _nullBytePattern.hasMatch(input);
  }

  /// Gets file extension from path
  static String _getFileExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot);
  }
}

/// Result of input validation
class ValidationResult {
  final bool isValid;
  final String? value;
  final String? error;

  const ValidationResult._(this.isValid, this.value, this.error);

  factory ValidationResult.valid(String value) {
    return ValidationResult._(true, value, null);
  }

  factory ValidationResult.invalid(String error) {
    return ValidationResult._(false, null, error);
  }
}

/// Media file types for validation
enum MediaType {
  image,
  video,
  audio,
}