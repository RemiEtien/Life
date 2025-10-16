# Lifeline - Personal Memory Journal

A Flutter-based personal digital journal application that helps you preserve, organize, and visualize your life's memories.

## Features

- 📝 Create rich memories with text, photos, videos, and audio
- 🎨 Beautiful timeline visualization of your life events
- 🔐 End-to-end encryption for sensitive memories
- 🎵 Spotify music integration
- 🔄 Cloud sync across devices
- 🌍 Localized in 9 languages (EN, RU, DE, ES, FR, HE, PT, AR, ZH)
- 💎 Premium features with in-app purchases

## Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio (for Android builds)
- Xcode (for iOS builds, macOS only)
- Firebase project configured

### Installation

1. Clone the repository
```bash
git clone <repository-url>
cd lifeline
```

2. Install dependencies
```bash
flutter pub get
```

3. Generate localization files
```bash
flutter gen-l10n
```

### Building for Android

Android build is ready to compile:

```bash
flutter build appbundle --release
```

The app bundle will be in `build/app/outputs/bundle/release/`.

### Building for iOS

**⚠️ IMPORTANT:** iOS requires additional setup before building.

#### Quick Check
Run the setup verification script:
```bash
./scripts/check_ios_setup.sh
```

#### Required Steps

1. **Add Firebase Configuration**
   - Download `GoogleService-Info.plist` from Firebase Console
   - See: `ios/Runner/README_FIREBASE.md`

2. **Configure Google Sign-In URL Scheme**
   - Extract `REVERSED_CLIENT_ID` from GoogleService-Info.plist
   - Update `ios/Runner/Info.plist`

3. **Full Setup Guide**
   - Read: `docs/ios_setup_requirements.md`

After setup:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── memory.dart              # Core data model
├── screens/                 # UI screens
│   ├── splash_screen.dart
│   ├── auth_gate.dart
│   ├── home_screen.dart
│   ├── memory_edit_screen.dart
│   └── ...
├── services/                # Business logic
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   ├── encryption_service.dart
│   ├── sync_service.dart
│   └── ...
├── providers/               # Riverpod state management
└── widgets/                 # Reusable widgets

ios/
├── Runner/
│   ├── Info.plist
│   └── README_FIREBASE.md   # Firebase setup instructions

android/
├── app/
│   ├── build.gradle
│   └── google-services.json # Already configured

docs/
└── ios_setup_requirements.md # Detailed iOS setup guide

scripts/
└── check_ios_setup.sh        # iOS verification script
```

## Configuration

### Firebase

The app uses Firebase for:
- Authentication (Google, Apple, Email/Password)
- Cloud Firestore (data storage)
- Firebase Storage (media files)
- Crashlytics (error reporting)
- Analytics

**Android:** Already configured with `google-services.json`
**iOS:** Requires manual setup (see above)

### Environment

Current configuration:
- **Bundle ID:** `com.momentic.lifeline`
- **Version:** 1.0.142+142
- **Min Android SDK:** 26 (Android 8.0)
- **Target Android SDK:** 35 (Android 15)
- **Min iOS:** 13.0
- **Android 15 Support:** ✅ 16KB page size support with isar_community
- **Edge-to-Edge:** ✅ Android 15/16 compatible

## Development

### Run in debug mode
```bash
flutter run
```

### Run tests
```bash
flutter test
```

### Analyze code
```bash
flutter analyze
```

### Generate app icon
```bash
flutter pub run flutter_launcher_icons
```

## Coding Standards

### Logging

**Always use SafeLogger** instead of `debugPrint()` or `print()`:

```dart
import '../utils/safe_logger.dart';

// ✅ Correct - Production-safe logging
SafeLogger.debug('User logged in', tag: 'AuthService');
SafeLogger.warning('Cache miss, loading from network', tag: 'DataService');
SafeLogger.error('Failed to sync', error: e, stackTrace: st, tag: 'SyncService');

// ❌ Wrong - Not production-safe
debugPrint('User logged in');
print('Some debug info');
```

**SafeLogger features:**
- `debug()` - Only logs in debug mode, silent in release
- `warning()` - Always logs, sends to Crashlytics in release
- `error()` - Always logs, sends to Crashlytics with full stack traces
- `sensitive()` - ONLY in debug mode, never in release (for auth/encryption data)

**Exception:** In isolates (background workers), use `print()` with tag prefix since SafeLogger isn't available.

See [Safe Logging Guidelines](docs/SAFE_LOGGING_GUIDELINES.md) for details.

### Memory Management

**Always clean up resources:**

```dart
// ✅ Correct - Proper cleanup
class MyService {
  StreamSubscription? _subscription;

  void init() {
    _subscription = stream.listen(...);
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

// ❌ Wrong - Memory leak
class MyService {
  void init() {
    stream.listen(...); // No way to cancel!
  }
}
```

**Use Riverpod's `ref.onDispose()` for cleanup:**

```dart
final myProvider = Provider((ref) {
  final controller = StreamController();
  ref.onDispose(() => controller.close());
  return MyService(controller);
});
```

### Async Operations

**Always handle unawaited futures explicitly:**

```dart
// ✅ Correct - Explicit unawaited
unawaited(analytics.logEvent('user_action'));

// ✅ Correct - Awaited when needed
await criticalOperation();

// ❌ Wrong - Silent failure
someAsyncMethod(); // Analyzer warning!
```

**Use `unawaited()` only for:**
- Analytics/logging (non-critical)
- Fire-and-forget operations
- Background tasks where errors are handled internally

### Null Safety

**Avoid unsafe collection access:**

```dart
// ✅ Correct - Safe access
final first = list.firstOrNull;
if (first != null) {
  use(first);
}

// ❌ Wrong - Can crash
final first = list.first; // Throws if empty!
```

**Minimize `!` operator usage:**

```dart
// ✅ Correct - Explicit null check
if (value != null) {
  use(value);
}

// ⚠️ Use sparingly - Only when 100% sure
final guaranteed = value!; // Can crash!
```

### Error Handling

**Always log errors to Crashlytics in production:**

```dart
try {
  await riskyOperation();
} catch (e, stackTrace) {
  SafeLogger.error('Operation failed', error: e, stackTrace: stackTrace, tag: 'ServiceName');
  // Handle gracefully
}
```

**For critical user-facing operations**, show user-friendly error messages:

```dart
try {
  await userAction();
} catch (e, stackTrace) {
  SafeLogger.error('User action failed', error: e, stackTrace: stackTrace, tag: 'UI');
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.errorGeneric)),
  );
}
```

### State Management (Riverpod)

**Never use `ref.read()` in build methods:**

```dart
// ✅ Correct - Use ref.watch
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.watch(userProvider);
  return Text(user.name);
}

// ❌ Wrong - Won't rebuild on changes
@override
Widget build(BuildContext context, WidgetRef ref) {
  final user = ref.read(userProvider);
  return Text(user.name);
}
```

**Use `ref.read()` only in event handlers:**

```dart
onPressed: () {
  ref.read(counterProvider.notifier).increment();
}
```

### Security

**Never log sensitive data:**

```dart
// ✅ Correct
SafeLogger.debug('User authenticated', tag: 'Auth');

// ❌ Wrong - Exposes credentials
debugPrint('Password: $password');
debugPrint('Auth token: $token');
debugPrint('Encryption key: $key');
```

**Use `SafeLogger.sensitive()` for debugging encryption/auth** (debug-only):

```dart
SafeLogger.sensitive('Decryption successful for key: $keyId', tag: 'Encryption');
// This log is COMPLETELY REMOVED in release builds
```

### Code Quality

**Keep methods focused and testable:**
- Max 50 lines per method (prefer 20-30)
- One responsibility per method
- Extract complex logic into helper methods

**Remove commented-out code:**
```dart
// ❌ Wrong - Dead code
// final oldLogic = something();
// return oldValue;

// ✅ Use version control instead
final newLogic = somethingBetter();
return newValue;
```

**Replace magic numbers with named constants:**

```dart
// ✅ Correct
const maxRetries = 3;
const cacheExpiryMinutes = 30;
const thumbnailSize = 200;

// ❌ Wrong
for (int i = 0; i < 3; i++) { ... }
if (elapsed > 30) { ... }
final size = 200;
```

## Common Mistakes to Avoid

Learn from past issues we've fixed:

### 1. **Forgetting to use `unawaited()` for async calls**

```dart
// ❌ Wrong - Warning about unawaited Future
void handlePurchase(PurchaseDetails details) {
  _verifyPurchase(details);  // Analyzer warning!
  _completePurchase(details); // Analyzer warning!
}

// ✅ Correct - Explicit intent
void handlePurchase(PurchaseDetails details) {
  unawaited(_verifyPurchase(details));
  unawaited(_completePurchase(details));
}
```

**We fixed this in:** `purchase_service.dart:154, 158`

### 2. **Using variables but never reading them**

```dart
// ❌ Wrong - Unused variable
final result = await callable.call({...});
// 'result' is never used!

// ✅ Correct - Don't store if not needed
await callable.call({...});

// ✅ Or use it
final result = await callable.call({...});
return result.data;
```

**We fixed this in:** `purchase_service.dart:181`

### 3. **Not cleaning up StreamControllers**

```dart
// ❌ Wrong - Memory leak
class NotificationService {
  final _controller = StreamController.broadcast();
  // No dispose method!
}

// ✅ Correct - Proper cleanup
class NotificationService {
  StreamController? _controller;

  Stream get stream {
    _controller ??= StreamController.broadcast();
    return _controller!.stream;
  }

  void dispose() {
    _controller?.close();
    _controller = null;
  }
}
```

**We fixed this in:** `notification_service.dart:13-28`

### 4. **Debug logging in release builds**

```dart
// ❌ Wrong - Logs sensitive info in production
if (kDebugMode) {
  debugPrint('User token: $token');
}
// Still appears in production logs!

// ✅ Correct - Never reaches production
SafeLogger.sensitive('User token: $token', tag: 'Auth');
// Completely removed in release builds
```

**We fixed this across:** 7+ service files during SafeLogger migration

### 5. **Hardcoded strings instead of localization**

```dart
// ❌ Wrong - English-only
Text('Failed to Create Profile')

// ✅ Correct - Localized
Text(l10n.profileCreationErrorTitle)
```

**We fixed this in:** `auth_gate.dart:769-848`

### 6. **Race conditions in sync operations**

```dart
// ❌ Wrong - Can queue same item twice
Future<void> queueSync(int id) async {
  if (!_syncQueue.contains(id)) {
    // Another call can reach here before we add!
    _syncQueue.add(id);
  }
}

// ✅ Correct - Use proper locking
final _queueLock = Lock();

Future<void> queueSync(int id) async {
  await _queueLock.synchronized(() {
    if (!_syncQueue.contains(id)) {
      _syncQueue.add(id);
    }
  });
}
```

**This was identified in:** AUDIT_REPORT.md Issue #3

### 7. **Missing error handling for async operations**

```dart
// ❌ Wrong - Silent failures
void initService() {
  loadData(); // If this fails, nobody knows!
}

// ✅ Correct - Handle errors
void initService() {
  unawaited(loadData().catchError((e, st) {
    SafeLogger.error('Failed to load data', error: e, stackTrace: st, tag: 'Service');
  }));
}

// ✅ Better - Await critical operations
Future<void> initService() async {
  try {
    await loadData();
  } catch (e, st) {
    SafeLogger.error('Failed to load data', error: e, stackTrace: st, tag: 'Service');
  }
}
```

### 8. **Unsafe collection access**

```dart
// ❌ Wrong - Crashes if list is empty
final firstItem = items.first;
final lastItem = items.last;

// ✅ Correct - Safe access
final firstItem = items.firstOrNull;
if (firstItem != null) {
  use(firstItem);
}
```

**This pattern appears in:** `lifeline_widget.dart:766, 1023, 1051` and 20+ other locations

### 9. **Not handling Firebase transaction retries**

```dart
// ❌ Wrong - Single attempt, can lose data
await db.runTransaction((transaction) async {
  // ... updates
});

// ✅ Correct - Retry on conflicts
for (int attempt = 0; attempt < maxRetries; attempt++) {
  try {
    await db.runTransaction((transaction) async {
      // ... updates
    });
    break; // Success
  } on FirebaseException catch (e) {
    if (e.code == 'aborted' && attempt < maxRetries - 1) {
      await Future.delayed(Duration(milliseconds: 100 * attempt));
      continue;
    }
    rethrow;
  }
}
```

**Identified in:** AUDIT_REPORT.md Issue #4

### 10. **Expensive operations on main thread**

```dart
// ❌ Wrong - Blocks UI
Future<void> processImages(List<String> paths) async {
  for (final path in paths) {
    final file = File(path);
    final bytes = file.readAsBytesSync(); // BLOCKS!
    await uploadImage(bytes);
  }
}

// ✅ Correct - Use async I/O
Future<void> processImages(List<String> paths) async {
  for (final path in paths) {
    final file = File(path);
    final bytes = await file.readAsBytes(); // Non-blocking
    await uploadImage(bytes);
  }
}

// ✅ Even better - Use isolate for large batches
if (paths.length > 10) {
  await compute(processImagesInIsolate, paths);
}
```

**Identified in:** AUDIT_REPORT.md Issue #5

---

**Rule of thumb:** If you're thinking "I'll fix this later" - don't ship it. Technical debt compounds quickly.

## Localization

To add/update translations:

1. Edit `.arb` files in `lib/l10n/`
2. Run: `flutter gen-l10n`
3. Restart app

Supported languages:
- English (en)
- Russian (ru)
- German (de)
- Spanish (es)
- French (fr)
- Hebrew (he)
- Portuguese (pt)
- Arabic (ar)
- Chinese (zh)

## Troubleshooting

### Android
- **Build fails:** Run `flutter clean && flutter pub get`
- **Google Sign-In fails:** Check `google-services.json` is present

### iOS
- **App crashes on startup:** Missing `GoogleService-Info.plist`
- **Google Sign-In fails:** URL Scheme not configured in Info.plist
- **Build fails:** Run `cd ios && pod install && cd ..`

See `docs/ios_setup_requirements.md` for detailed iOS troubleshooting.

## Documentation

- [Architecture Guide](docs/ARCHITECTURE.md) - System design and technical decisions
- [iOS Setup Requirements](docs/ios_setup_requirements.md) - Critical iOS setup guide
- [Firebase Setup](ios/Runner/README_FIREBASE.md) - Firebase configuration for iOS
- [Android 15 Migration Guide](docs/ANDROID15_MIGRATION.md) - Android 15/16 edge-to-edge migration
- [Release Notes](RELEASE_NOTES_139.md) - Latest release information

## Testing

The project includes comprehensive test coverage:
- **161 unit tests** covering core business logic
- **Integration tests** for critical workflows
- Run tests: `flutter test --exclude-tags=integration`
- Generate coverage: `flutter test --coverage --exclude-tags=integration`

## License

[Your License]

## Contact

Email: founder@theplacewelive.org

---

**Note:** This is a production application. Make sure all Firebase credentials and API keys are properly secured and not committed to version control.
