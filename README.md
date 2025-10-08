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
