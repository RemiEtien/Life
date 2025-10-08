# Lifeline Architecture

## Overview

Lifeline is a Flutter-based personal memory journal with end-to-end encryption, cloud sync, and rich media support. The architecture follows clean architecture principles with clear separation between UI, business logic, and data layers.

## Architecture Layers

```
┌─────────────────────────────────────────┐
│           UI Layer (Screens)            │
│  - memory_view_screen.dart (2770 lines) │
│  - lifeline_widget.dart (2682 lines)    │
│  - memory_edit_screen.dart (1811 lines) │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│     State Management (Riverpod)         │
│  - application_providers.dart           │
│  - Declarative state with providers     │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│      Business Logic (Services)          │
│  - auth_service.dart                    │
│  - sync_service.dart                    │
│  - encryption_service.dart (665 lines)  │
│  - firestore_service.dart               │
└─────────────────┬───────────────────────┘
                  │
┌─────────────────▼───────────────────────┐
│         Data Layer (Models)             │
│  - memory.dart (core data model)        │
│  - Isar local database                  │
│  - Firebase Firestore (cloud)           │
└─────────────────────────────────────────┘
```

## Key Architectural Decisions

### 1. Database: Isar Community Edition

**Decision**: Use `isar_community` instead of official `isar` package

**Rationale**:
- Android 15 introduced mandatory 16KB page size support
- Official Isar package doesn't support 16KB pages
- Community fork provides necessary compatibility
- Migration path: `916824b` commit (December 2024)

**Impact**:
- ✅ Full Android 15/16 compatibility
- ✅ Future-proof until August 2026
- ⚠️ Community-maintained (requires monitoring)

**Technical Details**:
```yaml
# pubspec.yaml
dependencies:
  isar_community: ^4.0.3
  isar_community_flutter_libs: ^4.0.3

dev_dependencies:
  isar_community_generator: ^4.0.3
```

**Build Configuration**:
```gradle
// android/app/build.gradle
defaultConfig {
    ndk {
        abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
    }
    externalNativeBuild {
        cmake {
            arguments "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
        }
    }
}

packaging {
    jniLibs {
        useLegacyPackaging = false
    }
}
```

### 2. State Management: Riverpod

**Decision**: Use Riverpod for state management

**Rationale**:
- Compile-time safety (no runtime Provider errors)
- Improved testability
- Better performance than traditional Provider
- Type-safe dependency injection

**Key Providers**:
- `localeProvider` - App localization state
- `authProvider` - Authentication state
- `syncProvider` - Cloud sync state
- `memoryProvider` - Memory CRUD operations

### 3. Encryption: AES-GCM

**Decision**: Use AES-256-GCM for end-to-end encryption

**Implementation**: `lib/services/encryption_service.dart` (665 lines)

**Format**:
```
gcm_v1:IV:CIPHER
```

**Rationale**:
- Authenticated encryption (prevents tampering)
- Industry standard (NIST approved)
- Built-in integrity checking
- Efficient performance

**Security Features**:
- Random IV for each encryption
- 256-bit keys
- Authenticated data
- Base64 encoding for storage

**Testing**: 9 comprehensive unit tests covering edge cases

### 4. Sync Architecture

**Model**: Eventual consistency with conflict resolution

**Flow**:
```
1. Local change → Isar database
2. Create sync job → Queue
3. Upload to Firestore when online
4. Download remote changes
5. Merge with last-write-wins
```

**Sync State Machine**:
```
idle → queued → syncing → (success|paused|failed)
                   ↓
            progress: 0.0 - 1.0
```

**Implementation**: `lib/services/sync_service.dart`

**Testing**: 20 unit tests for SyncState and workflows

### 5. Media Handling

**Strategy**: Local-first with cloud backup

**Workflow**:
1. Capture media → Local storage
2. Generate thumbnail (images/videos)
3. Upload original + thumbnail to Firebase Storage
4. Store references in Firestore
5. Lazy load on demand

**Ordering**:
- Media: `mediaKeysOrder` (user-defined)
- Videos: `videoKeysOrder`
- Audio: `audioKeysOrder`

**Path Resolution**:
```dart
displayableMediaPaths → Ordered, displayable media
displayableThumbPaths → Thumbnails with fallbacks
```

### 6. Localization

**Approach**: ARB-based with lazy loading

**Supported Languages**: 9 (EN, RU, DE, ES, FR, HE, PT, AR, ZH)

**Strategy**:
- Only English locale initialized at startup
- Other locales loaded on-demand
- Reduces startup time by ~200ms

**Files**:
```
lib/l10n/
├── app_en.arb (source)
├── app_ru.arb (1281 lines)
├── app_de.arb (1293 lines)
└── ... (7 total translations)
```

### 7. Authentication

**Providers**:
- Google Sign-In (Android + iOS)
- Apple Sign-In (iOS only)
- Email/Password

**Security**:
- Firebase Authentication
- App Check for anti-abuse (Play Integrity/App Attest)
- Biometric unlock (local_auth)

**Platform Differences**:
- iOS: Requires REVERSED_CLIENT_ID in Info.plist
- Android: Configured via google-services.json

### 8. Error Handling

**Strategy**: Defensive with Crashlytics logging

**Layers**:
1. **UI Layer**: User-friendly error messages
2. **Business Logic**: Try-catch with specific errors
3. **Global**: Zone-based error catching

**Crashlytics Integration**:
```dart
// Debug mode: Print to console
FlutterError.onError = (details) {
  debugPrint('Flutter error: $details');
};

// Production: Send to Crashlytics
FlutterError.onError = (details) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
};
```

**Custom Keys** (isar_community migration):
```dart
Crashlytics.instance.setCustomKey('database_type', 'isar_community');
Crashlytics.instance.setCustomKey('migration_version', '4.0.3');
```

### 9. Testing Strategy

**Coverage**: 161 unit tests

**Test Pyramid**:
- **Unit Tests**: 161 (business logic, models, services)
- **Integration Tests**: 12 (end-to-end workflows)
- **Widget Tests**: 20 (UI components)

**Key Test Suites**:
- `memory_test.dart` - 84 tests (core model)
- `encryption_service_test.dart` - 9 tests
- `sync_service_test.dart` - 20 tests
- `ios_specific_test.dart` - 25 tests
- `lifeline_insights_test.dart` - 23 tests

**CI/CD**: Automated via Codemagic

## Android 15/16 Migration

### Edge-to-Edge Implementation

**Current State** (as of v1.0.142):

**MainActivity.kt**:
```kotlin
override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    WindowCompat.setDecorFitsSystemWindows(window, false)
}
```

**values-v35/styles.xml**:
```xml
<item name="android:windowOptOutEdgeToEdgeEnforcement">false</item>
```

**main.dart**:
```dart
await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
```

**Status**:
- ✅ Edge-to-edge enabled for Android 15/16
- ✅ Backward compatible with older Android versions
- ⚠️ Google Play Console warnings expected (from Flutter SDK, not user code)
- ✅ Won't block publication

**Timeline**:
- **Now - August 2026**: Safe on targetSdk 35
- **August 2026**: Must upgrade to targetSdk 36
- **Future Work**: Full edge-to-edge migration (remove opt-out flag)

See: [docs/ANDROID15_MIGRATION.md](ANDROID15_MIGRATION.md)

## Performance Optimizations

### 1. Shared Media Processing
**Optimization**: Parallel processing (v1.0.140)
```dart
// Before: Sequential
for (var path in paths) await processSingleMedia(path);

// After: Parallel
await Future.wait(paths.map((path) => processSingleMedia(path)));
```
**Impact**: ~60% faster for 10+ media items

### 2. Date Formatting
**Optimization**: Lazy locale initialization
```dart
// Only initialize English at startup
await initializeDateFormatting('en', null);

// Other locales loaded on-demand
```
**Impact**: ~200ms faster startup

### 3. Build Configuration
**Production**:
```gradle
minifyEnabled true
shrinkResources true
proguardFiles ...
```
**Result**: ~40% smaller APK/AAB

## Known Technical Debt

### Large Files (Refactoring Candidates)

1. **memory_view_screen.dart** (2770 lines)
   - Could split into smaller widgets
   - Separate media gallery component
   - Extract reflection/emotion sections

2. **lifeline_widget.dart** (2682 lines)
   - Complex timeline visualization
   - Could extract painter to separate file
   - Simplify gesture handling

3. **memory_edit_screen.dart** (1811 lines)
   - Rich text editor integration
   - Media picker abstraction
   - Form validation logic

4. **profile_screen.dart** (1275 lines)
   - Settings management
   - Account operations
   - Could split into tabs

### Dependency Updates Available

From `flutter pub outdated` (34 packages):
- `flutter_riverpod` 2.6.1 → 3.0.2 (breaking changes)
- `pointycastle` 3.9.1 → 4.0.0 (breaking changes)
- Others: Minor version bumps

**Decision**: Delay major updates until iOS development phase

## Security Considerations

### Encryption Key Management
- Keys stored in Flutter Secure Storage
- Platform-specific secure enclaves (Keychain/Keystore)
- Never transmitted over network
- Wiped on app uninstall

### Network Security
- HTTPS only (Firebase enforced)
- Certificate pinning via Firebase
- App Check anti-abuse
- No cleartext traffic

### Data Privacy
- End-to-end encryption for sensitive memories
- Local-first architecture (offline-capable)
- User controls sync (can disable)
- GDPR-compliant data deletion

## Deployment

### Android
- **Target SDK**: 35 (Android 15)
- **Min SDK**: 26 (Android 8.0)
- **Build**: `flutter build appbundle`
- **Release**: Google Play Console

### iOS
- **Min Version**: 13.0
- **Build**: `flutter build ios --release`
- **Release**: App Store Connect
- **Status**: Pending MacBook acquisition

### CI/CD
- **Platform**: Codemagic
- **Triggers**: Git push to main/branches
- **Artifacts**: APK, AAB, IPA
- **Tests**: Automated unit/integration tests

## Future Roadmap

### Q1 2026
- [ ] iOS development and testing
- [ ] App Store submission
- [ ] Cross-platform sync testing

### Q2 2026
- [ ] Refactor large screen files
- [ ] Dependency updates (Riverpod 3.x)
- [ ] Performance profiling

### Q3 2026
- [ ] targetSdk 36 migration
- [ ] Full edge-to-edge implementation
- [ ] Predictive back gesture
- [ ] WillPopScope → PopScope migration

---

**Last Updated**: October 2025
**Version**: 1.0.142
