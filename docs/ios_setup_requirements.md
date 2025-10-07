# iOS Setup Requirements - Critical Issues

**Current Status:** iOS build is NOT ready for deployment. The following critical issues must be resolved before compiling for iOS.

---

## ❌ CRITICAL ISSUE 1: Firebase Configuration Missing

**Problem:** `GoogleService-Info.plist` file is missing from the iOS project.

**Location:** Should be at `ios/Runner/GoogleService-Info.plist`

**Impact:**
- Firebase Auth will NOT work on iOS
- Crashlytics will NOT work
- Firebase Storage will NOT work
- Analytics will NOT work
- App will crash on startup when trying to initialize Firebase

**Solution:**
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings (gear icon)
4. Click "Add app" → iOS
5. Enter Bundle ID: `com.momentic.lifeline`
6. Download `GoogleService-Info.plist`
7. Add it to `ios/Runner/` directory in Xcode
8. Make sure "Copy items if needed" and "Add to targets: Runner" are checked

---

## ❌ CRITICAL ISSUE 2: Google Sign-In URL Scheme Missing

**Problem:** Info.plist does not contain the required URL scheme for Google Sign-In OAuth callback.

**Impact:**
- Google Sign-In will FAIL on iOS
- Users will not be able to login with Google
- Auth flow will hang or crash

**Solution:**

1. Open the downloaded `GoogleService-Info.plist` from Issue #1
2. Find the value for `REVERSED_CLIENT_ID` (looks like `com.googleusercontent.apps.123456789-xxxxx`)
3. Add this to `ios/Runner/Info.plist` BEFORE the closing `</dict>` tag:

```xml
<!-- GOOGLE SIGN-IN URL SCHEME -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>YOUR_REVERSED_CLIENT_ID_HERE</string>
        </array>
    </dict>
</array>
```

Replace `YOUR_REVERSED_CLIENT_ID_HERE` with the actual value from GoogleService-Info.plist.

**Example:**
```xml
<array>
    <string>com.googleusercontent.apps.123456789-abcdefg</string>
</array>
```

---

## ⚠️ ISSUE 3: Bundle ID Still Default

**Problem:** iOS project still uses example bundle ID `com.example.lifeline`

**Current:** `com.example.lifeline`
**Should be:** `com.momentic.lifeline` (matching Android)

**Impact:**
- Cannot publish to App Store (bundle ID mismatch)
- Firebase configuration mismatch
- Apple Sign-In configuration issues
- In-App Purchase issues

**Solution:**

### Method 1: Via Xcode (Recommended)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" project in navigator
3. Select "Runner" target
4. Go to "Signing & Capabilities" tab
5. Change Bundle Identifier to `com.momentic.lifeline`
6. Ensure "Automatically manage signing" is checked
7. Select your Team

### Method 2: Manual Edit
Edit `ios/Runner.xcodeproj/project.pbxproj`:
Find all instances of:
```
PRODUCT_BUNDLE_IDENTIFIER = com.example.lifeline;
```
Replace with:
```
PRODUCT_BUNDLE_IDENTIFIER = com.momentic.lifeline;
```

---

## ⚠️ ISSUE 4: Apple Sign-In Capability May Need Setup

**Status:** Code is ready, but Xcode project capability may not be configured

**Solution:**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Runner" project → "Runner" target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Add "Sign in with Apple"

---

## ⚠️ ISSUE 5: In-App Purchase Capability May Need Setup

**Status:** Code is ready, but Xcode project capability may not be configured

**Solution:**
1. In Xcode, "Signing & Capabilities" tab
2. Click "+ Capability"
3. Add "In-App Purchase"

---

## ✅ What's Already Correct

### Permissions in Info.plist ✅
All required permissions are properly configured:
- ✅ `NSCameraUsageDescription` - Camera access for photos/videos
- ✅ `NSPhotoLibraryUsageDescription` - Photo library read access
- ✅ `NSPhotoLibraryAddUsageDescription` - Photo library write access
- ✅ `NSMicrophoneUsageDescription` - Microphone for audio notes
- ✅ `NSFaceIDUsageDescription` - Face ID for biometric unlock

### Localization ✅
All 9 languages are configured:
- en, ru, de, es, fr, he, pt, ar, zh

### iOS Deployment Target ✅
- Minimum iOS version: 13.0
- This is compatible with all major Firebase packages

### Code Platform Handling ✅
- Platform-specific code properly uses `Platform.isIOS` checks
- iOS-specific implementations exist for device detection
- Biometric service properly handles iOS Face ID

### Dependencies ✅
All packages support iOS:
- ✅ firebase_core, firebase_auth, firebase_storage
- ✅ google_sign_in (requires URL scheme fix above)
- ✅ sign_in_with_apple
- ✅ in_app_purchase
- ✅ local_auth (Face ID/Touch ID)

---

## Step-by-Step Setup Checklist

Before compiling iOS version:

1. ☐ Download `GoogleService-Info.plist` from Firebase Console
2. ☐ Add `GoogleService-Info.plist` to `ios/Runner/` via Xcode
3. ☐ Extract `REVERSED_CLIENT_ID` from GoogleService-Info.plist
4. ☐ Add `CFBundleURLTypes` with REVERSED_CLIENT_ID to Info.plist
5. ☐ Change Bundle ID from `com.example.lifeline` to `com.momentic.lifeline`
6. ☐ Add "Sign in with Apple" capability in Xcode
7. ☐ Add "In-App Purchase" capability in Xcode
8. ☐ Configure code signing with your Apple Developer account
9. ☐ Create App ID in Apple Developer Portal: `com.momentic.lifeline`
10. ☐ Enable "Sign in with Apple" for App ID in Apple Developer Portal
11. ☐ Enable "In-App Purchase" for App ID in Apple Developer Portal
12. ☐ Create provisional profile for development
13. ☐ Run `flutter pub get`
14. ☐ Run `cd ios && pod install` (if Podfile exists)
15. ☐ Test build: `flutter build ios --debug`
16. ☐ Test on physical device (simulator won't test auth properly)

---

## Testing Authentication on iOS

After setup, test these critical flows:

1. **Google Sign-In**
   - Tap "Continue with Google"
   - Should open Google consent screen
   - Should return to app after consent
   - Should NOT crash or hang

2. **Apple Sign-In**
   - Tap "Continue with Apple"
   - Should show Apple ID authentication
   - Should handle user name and email properly

3. **Biometric Authentication**
   - Enable encryption in settings
   - Lock app
   - Should show Face ID prompt on iPhone X+
   - Should show Touch ID prompt on older devices

4. **In-App Purchase**
   - Navigate to Premium screen
   - Tap subscription option
   - Should show iOS purchase sheet
   - Test sandbox account purchase

---

## Common iOS Build Errors After Setup

### Error: "No such module 'Firebase'"
- **Solution:** Run `cd ios && pod install && cd ..`

### Error: "Code signing failed"
- **Solution:** Configure team in Xcode Signing & Capabilities

### Error: "GoogleService-Info.plist not found"
- **Solution:** Add file via Xcode (not Finder) and check target membership

### Error: "Undefined symbols for architecture arm64"
- **Solution:** Clean build folder in Xcode (Cmd+Shift+K) and rebuild

---

## Additional Notes

- iOS requires a Mac with Xcode for compilation
- Physical device required for proper auth testing (simulator limitations)
- TestFlight required for testing In-App Purchases with sandbox
- Apple Developer account required ($99/year)

---

**Last Updated:** October 7, 2025
**Checked by:** Claude (Automated iOS Compatibility Analysis)
