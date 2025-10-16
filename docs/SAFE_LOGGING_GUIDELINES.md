# Safe Logging Guidelines

## Overview

Lifeline uses `SafeLogger` to ensure sensitive information is never exposed in production logs. This document outlines best practices for logging throughout the application.

## When to Use Each Log Level

### 1. `SafeLogger.debug()` - General Debug Information
Use for general development debugging that's not sensitive but not needed in production.

```dart
SafeLogger.debug('Loading memories from cache', tag: 'MemoryRepository');
SafeLogger.debug('User opened memory edit screen');
```

**Behavior:**
- ✅ Shown in debug mode
- ❌ Completely disabled in release mode

### 2. `SafeLogger.sensitive()` - Sensitive Data (CRITICAL)
Use for ANY information related to:
- Authentication tokens, passwords, or credentials
- Encryption keys or cryptographic operations
- User email addresses or personal information
- Firebase user IDs in sensitive contexts

```dart
// ✅ CORRECT
SafeLogger.sensitive('Decrypting memory content', tag: 'EncryptionService');
SafeLogger.sensitive('User authenticated: ${user.email}', tag: 'AuthService');

// ❌ NEVER DO THIS
debugPrint('Encryption key: $key'); // Exposes sensitive data!
print('User token: ${user.token}'); // Security vulnerability!
```

**Behavior:**
- ✅ Shown in debug mode with 🔒 prefix
- ❌ **COMPLETELY SILENT** in release mode (not even sent to Crashlytics)

### 3. `SafeLogger.warning()` - Warning Messages
Use for unexpected but recoverable situations that should be monitored.

```dart
SafeLogger.warning('Failed to load album art, using fallback', tag: 'SpotifyService');
SafeLogger.warning('AutoDispose provider kept alive longer than expected');
```

**Behavior:**
- ✅ Shown in debug mode with ⚠️ prefix
- ✅ Sent to Crashlytics in release mode for monitoring

### 4. `SafeLogger.error()` - Error Messages
Use for actual errors that need investigation.

```dart
SafeLogger.error(
  'Failed to sync memory',
  error: e,
  stackTrace: stackTrace,
  tag: 'SyncService',
);
```

**Behavior:**
- ✅ Shown in debug mode with ❌ prefix
- ✅ **Always** sent to Crashlytics with full stack traces

### 5. `SafeLogger.performance()` - Performance Metrics
Use for performance profiling and optimization tracking.

```dart
SafeLogger.performance(
  'Lifeline render completed',
  tag: 'LifelineWidget',
  metrics: {
    'fps': fps,
    'nodeCount': nodeCount,
    'renderTime': '${duration.inMilliseconds}ms',
  },
);
```

**Behavior:**
- ✅ Shown in debug mode with ⚡ prefix
- ❌ Disabled in release mode

### 6. `SafeLogger.network()` - Network Requests
Use for API calls and network operations (automatically sanitized).

```dart
SafeLogger.network('GET /users/$userId/memories', tag: 'FirestoreService');
SafeLogger.network('Uploading ${files.length} files', tag: 'StorageService');
```

**Behavior:**
- ✅ Full details in debug mode with 🌐 prefix
- ✅ Sanitized version in release mode (user IDs replaced with ***)

## Migration from debugPrint

### Before:
```dart
debugPrint('Loading user data for $userId');  // ❌ Sensitive data in logs
print('Decrypting memory: $memoryId');         // ❌ Exposed in production
if (kDebugMode) debugPrint('Auth error: $e'); // ✅ Safe but verbose
```

### After:
```dart
SafeLogger.sensitive('Loading user data for $userId', tag: 'UserService');
SafeLogger.debug('Decrypting memory: $memoryId', tag: 'EncryptionService');
SafeLogger.error('Auth error', error: e, tag: 'AuthService');
```

## Security Rules

### ❌ NEVER Log:
1. **Passwords or tokens** - Use `SafeLogger.sensitive()` if debugging auth
2. **Encryption keys or salts** - Use `SafeLogger.sensitive()` sparingly
3. **Full user profiles** - Sanitize before logging
4. **Credit card or payment info** - Never log, even in debug mode
5. **Raw API responses** with user data

### ✅ ALWAYS:
1. Wrap sensitive info in `SafeLogger.sensitive()`
2. Use tags to identify log sources
3. Include error context without exposing user data
4. Test in release mode to verify logs are properly filtered

## Examples by Service

### AuthService
```dart
// Sign-in attempt
SafeLogger.debug('Starting Google sign-in', tag: 'AuthService');

// Success (contains email)
SafeLogger.sensitive('User signed in: ${user.email}', tag: 'AuthService');

// Error
SafeLogger.error('Sign-in failed', error: e, stackTrace: st, tag: 'AuthService');
```

### EncryptionService
```dart
// Starting encryption
SafeLogger.debug('Encrypting memory $memoryId', tag: 'EncryptionService');

// Key operation (sensitive!)
SafeLogger.sensitive('Deriving key from password', tag: 'EncryptionService');

// Error
SafeLogger.error('Encryption failed', error: e, tag: 'EncryptionService');
```

### SyncService
```dart
// Sync status
SafeLogger.debug('Queuing ${count} memories for sync', tag: 'SyncService');

// Network call
SafeLogger.network('Uploading memory to Firestore', tag: 'SyncService');

// Warning
SafeLogger.warning('Sync retry attempt ${attempt}/3', tag: 'SyncService');
```

## Testing Your Logs

1. **Debug Mode**: All logs should appear with appropriate prefixes
2. **Release Mode**: Run `flutter build apk --release` and verify:
   - No sensitive logs appear in logcat
   - Only warnings and errors are sent to Crashlytics
   - Performance logs are silent

## Benefits

✅ **Security**: Sensitive data never leaks to production logs
✅ **Performance**: Minimal overhead in release builds
✅ **Debugging**: Rich logs in development
✅ **Monitoring**: Automatic Crashlytics integration for errors
✅ **Compliance**: Meets GDPR/privacy requirements

## Quick Reference

| Method | Debug Mode | Release Mode | Use For |
|--------|------------|--------------|---------|
| `debug()` | ✅ Shown | ❌ Silent | General debugging |
| `sensitive()` | ✅ Shown | ❌ Silent | Auth, encryption, PII |
| `warning()` | ✅ Shown | ✅ Crashlytics | Unexpected situations |
| `error()` | ✅ Shown | ✅ Crashlytics | Actual errors |
| `performance()` | ✅ Shown | ❌ Silent | Performance metrics |
| `network()` | ✅ Full | ✅ Sanitized | API calls |

---

**Last Updated**: 2025-10-16
**Status**: ✅ Implemented
**Priority**: HIGH - Security Critical
