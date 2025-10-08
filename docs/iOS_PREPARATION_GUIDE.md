# iOS Development Preparation Guide

## Overview

This document prepares for iOS development when MacBook arrives. It identifies platform differences, lists required tasks, and highlights potential issues.

**Current Status**: Android app complete (v1.0.142), iOS pending MacBook acquisition

---

## iOS vs Android Key Differences

### 1. Authentication

#### Sign in with Apple (iOS-exclusive)

**Dependency**: Already included ✅
```yaml
sign_in_with_apple: ^7.0.1
```

**Implementation**: [lib/services/auth_service.dart](lib/services/auth_service.dart)
```dart
// Platform check exists
if (Platform.isIOS) {
  // Apple Sign-In flow
}
```

**Required Setup on MacBook**:
- [ ] Enable "Sign in with Apple" capability in Xcode
- [ ] Add Apple as auth provider in Firebase Console
- [ ] Test on real iOS device (Simulator has limitations)

#### Google Sign-In (Platform-specific config)

**Android**: Uses `google-services.json` ✅
**iOS**: Requires `GoogleService-Info.plist` + URL Scheme

**Info.plist Status**: URL Scheme already configured ✅
```xml
<!-- Line 84-94: ios/Runner/Info.plist -->
<key>CFBundleURLSchemes</key>
<array>
  <string>com.googleusercontent.apps.325668503094-1k0lilps9c224oi4udb957dbl1rqid11</string>
</array>
```

**Pending**:
- [ ] Add `GoogleService-Info.plist` (see [ios/Runner/README_FIREBASE.md](ios/Runner/README_FIREBASE.md))
- [ ] Verify REVERSED_CLIENT_ID matches Info.plist

### 2. Permissions

#### Permissions Already Configured in Info.plist ✅

| Permission | Key | Description | Line |
|------------|-----|-------------|------|
| Camera | NSCameraUsageDescription | Photo/video capture | 50-51 |
| Photo Library | NSPhotoLibraryUsageDescription | Select photos | 54-55 |
| Save Photos | NSPhotoLibraryAddUsageDescription | Export memories | 56-57 |
| Microphone | NSMicrophoneUsageDescription | Audio recording | 60-61 |
| Face ID | NSFaceIDUsageDescription | Biometric unlock | 64-65 |

**Runtime Permission Handling**:
```dart
// lib/services/permission_service.dart (needs creation)
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestCamera() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotos() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophone() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}
```

**Action Items**:
- [ ] Create PermissionService
- [ ] Add permission checks before media access
- [ ] Handle permission denial gracefully
- [ ] Test on iOS 13+ (different permission flow)

### 3. Biometric Authentication

**Package**: `local_auth: ^2.2.0` ✅ Already included

**iOS-Specific**:
- Touch ID (iPhone 5s - iPhone 8)
- Face ID (iPhone X+)
- Requires `NSFaceIDUsageDescription` in Info.plist ✅ (line 64-65)

**Testing Needs**:
- [ ] Test on Face ID device (iPhone X+)
- [ ] Test on Touch ID device (iPhone 8 or Simulator)
- [ ] Handle LAError codes (iOS-specific errors)

**iOS Error Codes**:
```dart
// iOS-specific error handling
try {
  final authenticated = await localAuth.authenticate(...);
} on PlatformException catch (e) {
  if (e.code == 'NotAvailable') {
    // No biometric hardware
  } else if (e.code == 'LockedOut') {
    // Too many failed attempts
  } else if (e.code == 'PasscodeNotSet') {
    // User hasn't set up passcode
  }
}
```

### 4. In-App Purchases

**Package**: `in_app_purchase: ^3.1.13` ✅ Already included

**iOS-Specific Requirements**:
- [ ] Create products in App Store Connect
- [ ] Set up test users in App Store Connect
- [ ] Configure Sandbox testing
- [ ] Handle subscription groups
- [ ] Test restore purchases (mandatory on iOS)

**Product IDs** (must match across platforms):
```dart
// Android: com.momentic.lifeline.premium_monthly
// iOS:     com.momentic.lifeline.premium_monthly (same)
```

**StoreKit 2 Considerations**:
- iOS 15+ uses StoreKit 2
- `in_app_purchase` package handles both versions
- Test on iOS 14 and iOS 15+ separately

### 5. Media Handling

#### Image Picker

**Package**: `image_picker: ^1.1.2` ✅

**iOS-Specific**:
- [ ] Test PHPicker (iOS 14+) vs UIImagePickerController
- [ ] Verify HEIC image format handling
- [ ] Test Live Photos (convert to video)
- [ ] Check file size limits (different from Android)

#### Video Player

**Package**: `video_player: ^2.8.3` ✅

**iOS-Specific**:
- AVPlayer backend (different from Android's ExoPlayer)
- Test codec support (H.264, HEVC)
- Verify background audio handling
- Test PiP (Picture-in-Picture) on iPad

#### Audio Recording

**Package**: `record: ^6.1.1` ✅

**iOS-Specific**:
- AVAudioRecorder backend
- Test audio formats (AAC, ALAC)
- Verify audio session handling
- Test recording during phone calls

### 6. Push Notifications

**Package**: `flutter_local_notifications: ^19.4.2` ✅

**iOS-Specific Setup**:
- [ ] Enable Push Notifications capability in Xcode
- [ ] Generate APNs certificates/keys
- [ ] Upload APNs key to Firebase Console
- [ ] Test notification permissions (iOS 12+)
- [ ] Handle notification actions (deep links)

**Critical Difference**:
- Android: Notifications work out-of-box
- iOS: Requires APNs setup + user permission

### 7. Deep Linking

**Package**: `url_launcher: ^6.3.0` ✅

**iOS URL Scheme**: Already configured in Info.plist ✅ (lines 84-94)

**Universal Links** (not yet configured):
- [ ] Create `apple-app-site-association` file
- [ ] Host on lifeline.com/.well-known/
- [ ] Add Associated Domains capability
- [ ] Test deep links from Safari/Messages

### 8. Background Tasks

**Android**: WorkManager (FlutterBackgroundService)
**iOS**: BackgroundTasks framework (limited)

**Limitations on iOS**:
- No guaranteed background sync
- App can't run indefinitely in background
- Use Background Fetch (15-minute intervals minimum)
- Consider CloudKit for silent push

**Current Sync Strategy**: Eventual consistency ✅ (works for iOS)

### 9. File Storage

**Package**: `path_provider: ^2.1.4` ✅

**iOS Paths**:
```dart
// Application Documents Directory (backed up to iCloud)
final docsDir = await getApplicationDocumentsDirectory();

// Application Support Directory (NOT backed up)
final supportDir = await getApplicationSupportDirectory();
```

**Recommendation**: Use Application Support for database to avoid iCloud backup

**Action Items**:
- [ ] Move Isar database to Application Support directory on iOS
- [ ] Exclude large media from iCloud backup
- [ ] Test iCloud backup/restore flow

### 10. Security

#### Keychain (iOS) vs Keystore (Android)

**Package**: `flutter_secure_storage: ^9.0.0` ✅

**iOS Specifics**:
- Uses iOS Keychain
- Survives app uninstall (unlike Android)
- Can require biometric for access
- Syncs across devices via iCloud Keychain (can disable)

**Configuration**:
```dart
// Disable iCloud sync for encryption keys
const secureStorage = FlutterSecureStorage(
  iOptions: IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
    accountName: 'lifeline_keys',
    synchronizable: false, // Don't sync to iCloud
  ),
);
```

---

## iOS-Specific Dependencies

### All Dependencies Support iOS ✅

Verified in `pubspec.yaml`:

| Package | iOS Support | Notes |
|---------|-------------|-------|
| firebase_* | ✅ | All Firebase packages support iOS |
| sign_in_with_apple | ✅ | iOS-exclusive |
| isar_community | ✅ | Cross-platform |
| image_picker | ✅ | Uses PHPicker on iOS 14+ |
| audioplayers | ✅ | AVPlayer backend |
| record | ✅ | AVAudioRecorder backend |
| video_player | ✅ | AVPlayer backend |
| local_auth | ✅ | Touch ID / Face ID |
| in_app_purchase | ✅ | StoreKit integration |
| google_fonts | ✅ | Works on all platforms |
| cached_network_image | ✅ | Cross-platform |
| flutter_secure_storage | ✅ | iOS Keychain backend |

**No incompatible dependencies found** ✅

---

## MacBook Setup Checklist

### Day 1: Initial Setup

**Development Environment**:
- [ ] Install Xcode from Mac App Store (latest stable)
- [ ] Install Xcode Command Line Tools: `xcode-select --install`
- [ ] Accept Xcode license: `sudo xcodebuild -license accept`
- [ ] Install CocoaPods: `sudo gem install cocoapods`
- [ ] Install Flutter SDK (same version: 3.35.5)
- [ ] Run `flutter doctor` and fix all issues
- [ ] Install VS Code / Android Studio

**Apple Developer Account**:
- [ ] Sign up for Apple Developer Program ($99/year)
- [ ] Wait for approval (can take 24-48 hours)
- [ ] Add Apple ID to Xcode (Preferences → Accounts)

**Certificates & Provisioning**:
- [ ] Create iOS Development Certificate
- [ ] Create iOS Distribution Certificate
- [ ] Create App ID: `com.momentic.lifeline`
- [ ] Create Provisioning Profiles (Development + Distribution)

### Day 2: Project Setup

**Firebase Configuration**:
- [ ] Download `GoogleService-Info.plist` from Firebase Console
- [ ] Add to `ios/Runner/` via Xcode (see [README_FIREBASE.md](ios/Runner/README_FIREBASE.md))
- [ ] Verify REVERSED_CLIENT_ID in Info.plist
- [ ] Enable Sign in with Apple in Firebase Console
- [ ] Upload APNs key for push notifications

**Xcode Project Configuration**:
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Set Bundle Identifier: `com.momentic.lifeline`
- [ ] Set Team (your Apple Developer account)
- [ ] Set Deployment Target: iOS 13.0 (matches pubspec.yaml)
- [ ] Enable capabilities:
  - [ ] Push Notifications
  - [ ] Sign in with Apple
  - [ ] Associated Domains (for Universal Links)
  - [ ] Background Modes (if needed)

**CocoaPods Setup**:
```bash
cd ios
pod install
cd ..
```

### Day 3: First Build

**Build & Run**:
```bash
# Clean build
flutter clean
flutter pub get
cd ios && pod install && cd ..

# Run on simulator
flutter run -d "iPhone 15 Pro"

# Run on real device (requires Apple Developer account)
flutter run -d <device-id>
```

**Expected Issues**:
1. Provisioning profile errors → Fix in Xcode Signing & Capabilities
2. CocoaPods version mismatch → Update CocoaPods
3. Firebase initialization errors → Check GoogleService-Info.plist
4. Permission crashes → Verify Info.plist entries

### Day 4-5: Testing

**Test Matrix**:

| Feature | Simulator | Real Device | iPad | Notes |
|---------|-----------|-------------|------|-------|
| Google Sign-In | ❌ | ✅ | ✅ | Simulator doesn't support |
| Apple Sign-In | ⚠️ | ✅ | ✅ | Simulator uses sandbox |
| Camera | ❌ | ✅ | ✅ | Simulator has no camera |
| Photo Library | ✅ | ✅ | ✅ | Simulator uses sample photos |
| Audio Recording | ⚠️ | ✅ | ✅ | Simulator uses Mac mic |
| Face ID | ✅ | ✅ | ⚠️ | iPad uses different UI |
| Push Notifications | ⚠️ | ✅ | ✅ | Simulator supports iOS 16+ |
| In-App Purchase | ✅ | ✅ | ✅ | Sandbox mode |
| Video Playback | ✅ | ✅ | ✅ | Works everywhere |
| Encryption | ✅ | ✅ | ✅ | Works everywhere |

**Device Recommendations**:
- iPhone 13+ (Face ID testing)
- iPad (tablet layout testing)
- iOS 15+ device (latest features)
- iOS 13 device (minimum OS testing)

---

## Known iOS-Specific Issues

### 1. isar_community on iOS

**Status**: Should work (Rust-based, cross-platform)

**Potential Issues**:
- Bitcode (deprecated in Xcode 14, shouldn't be issue)
- ARM64 architecture (check M1 Mac compatibility)

**Testing Needed**:
- [ ] Test database creation on iOS
- [ ] Test CRUD operations
- [ ] Verify file paths (Application Support vs Documents)
- [ ] Test migration from empty state

### 2. Spotify API

**Package**: `spotify: ^0.13.7`

**iOS Considerations**:
- Spotify SDK may require additional setup
- Test OAuth flow on iOS (different from Android)
- Verify deep linking from Spotify app

### 3. Markdown Rendering

**Package**: `markdown_widget: ^2.3.2+8`

**iOS Considerations**:
- May use different fonts
- Test RTL languages (Arabic/Hebrew)
- Verify emoji rendering

### 4. Country Picker

**Package**: `country_picker: ^2.0.20`

**iOS Considerations**:
- Test Cupertino-style picker
- Verify localization
- Test on iPad (different modal presentation)

---

## iOS Build Configuration

### Debug Build

```bash
flutter build ios --debug
# Creates: build/ios/iphoneos/Runner.app
```

### Release Build

```bash
flutter build ios --release
# Creates: build/ios/iphoneos/Runner.app

# Or build IPA for distribution
flutter build ipa --release
# Creates: build/ios/ipa/lifeline.ipa
```

### Build Modes Comparison

| Mode | Optimization | Size | Use Case |
|------|--------------|------|----------|
| Debug | Low | Large | Development, debugging |
| Profile | Medium | Medium | Performance testing |
| Release | High | Small | App Store, TestFlight |

---

## App Store Submission Checklist

### Required Assets

**App Icon**:
- [ ] 1024x1024 px (App Store)
- [ ] Various sizes (generated by `flutter_launcher_icons`) ✅

**Screenshots** (per device size):
- [ ] 6.7" (iPhone 14 Pro Max) - 1 required
- [ ] 5.5" (iPhone 8 Plus) - 1 required
- [ ] 12.9" (iPad Pro) - 1 required
- [ ] 10.5" (iPad Pro) - Optional

**App Store Metadata**:
- [ ] App name (Lifeline)
- [ ] Subtitle (30 chars max)
- [ ] Description (4000 chars max)
- [ ] Keywords (100 chars max, comma-separated)
- [ ] Privacy Policy URL
- [ ] Support URL
- [ ] Marketing URL (optional)

**Age Rating**:
- [ ] Complete questionnaire in App Store Connect
- [ ] Likely 4+ (no objectionable content)

**Pricing**:
- [ ] Free with In-App Purchases
- [ ] Configure in-app product prices

### TestFlight Testing

**Before App Store Submission**:
- [ ] Upload build to TestFlight
- [ ] Add internal testers (up to 100)
- [ ] Test for 1-2 weeks
- [ ] Gather feedback
- [ ] Fix critical bugs
- [ ] Upload final build

**External Testing** (optional):
- [ ] Add up to 10,000 external testers
- [ ] Requires Beta App Review (1-2 days)

### App Review Preparation

**Common Rejection Reasons**:
1. Missing functionality (ensure all features work)
2. Broken links (test all URLs)
3. Privacy policy issues (must have URL)
4. In-app purchase issues (test thoroughly)
5. Sign in with Apple (must offer if using social login)

**Review Notes**:
- [ ] Provide test account (if login required)
- [ ] Explain encryption features (may need export compliance)
- [ ] Describe in-app purchases clearly

**Export Compliance**:
- App uses encryption (AES-256-GCM)
- May need to complete export compliance questionnaire
- Usually exempt if using standard iOS encryption APIs

---

## Timeline Estimate

### Optimistic (All Goes Well)

| Phase | Duration | Tasks |
|-------|----------|-------|
| MacBook Setup | 1 day | Xcode, Flutter, certificates |
| Project Config | 1 day | Firebase, Xcode project |
| First Build | 1 day | Fix build errors, run on simulator |
| Feature Testing | 3 days | Test all features on device |
| Bug Fixes | 2 days | Fix iOS-specific issues |
| UI Polish | 2 days | iPad layout, iOS styling |
| TestFlight | 3 days | Upload, internal testing |
| App Review | 1-3 days | Apple review process |
| **Total** | **14-16 days** | **2-3 weeks** |

### Realistic (With Issues)

| Phase | Duration | Tasks |
|-------|----------|-------|
| MacBook Setup | 1-2 days | Xcode issues, certificate problems |
| Project Config | 2 days | Firebase, signing issues |
| First Build | 2-3 days | Build errors, dependency issues |
| Feature Testing | 5 days | Test all features, find bugs |
| Bug Fixes | 5 days | Fix iOS-specific bugs |
| UI Polish | 3 days | iPad, iPhone layouts |
| TestFlight | 5 days | Upload, testing, fixes |
| App Review | 1-7 days | Possible rejection, resubmit |
| **Total** | **24-32 days** | **4-5 weeks** |

---

## Proactive TODO List

### Before MacBook Arrives

- [x] Document iOS vs Android differences
- [x] Review Info.plist configuration
- [x] Verify all dependencies support iOS
- [x] Create iOS preparation guide
- [ ] Research App Store guidelines
- [ ] Prepare app screenshots (use Android as reference)
- [ ] Write App Store description
- [ ] Create Privacy Policy page

### Week 1 (MacBook Arrives)

- [ ] Complete MacBook setup checklist (Day 1)
- [ ] Complete project setup (Day 2)
- [ ] First successful build (Day 3)
- [ ] Test core features (Day 4-5)
- [ ] Fix critical bugs

### Week 2

- [ ] Test all features on real device
- [ ] iPad layout optimization
- [ ] iOS UI polish (SF Symbols, haptics)
- [ ] TestFlight submission
- [ ] Internal testing

### Week 3

- [ ] Fix bugs from TestFlight
- [ ] Final testing
- [ ] Prepare App Store assets
- [ ] Submit for App Review

### Week 4+

- [ ] Respond to App Review feedback
- [ ] Release on App Store
- [ ] Monitor Crashlytics for iOS crashes
- [ ] Gather user feedback

---

## Resources

### Official Documentation

- [Flutter iOS Setup](https://docs.flutter.dev/get-started/install/macos)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)

### Firebase

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [Firebase Cloud Messaging (iOS)](https://firebase.google.com/docs/cloud-messaging/ios/client)

### Community

- [Flutter iOS Issues](https://github.com/flutter/flutter/issues?q=is%3Aissue+is%3Aopen+label%3Aplatform-ios)
- [r/FlutterDev](https://reddit.com/r/FlutterDev)
- [Stack Overflow: flutter+ios](https://stackoverflow.com/questions/tagged/flutter+ios)

---

## Success Criteria

- [ ] App builds successfully on iOS
- [ ] All 161 unit tests pass on iOS
- [ ] All features work identically to Android
- [ ] No iOS-specific crashes
- [ ] Passed App Store review
- [ ] Published on App Store
- [ ] 4+ star rating maintained
- [ ] < 1% crash rate on iOS

---

**Last Updated**: October 2025
**Status**: Preparation Complete, Awaiting MacBook
**Next Steps**: Order MacBook, execute Day 1 checklist
