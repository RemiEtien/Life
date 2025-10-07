# iOS Quick Start Guide

**Before you can build Lifeline for iOS, complete these steps:**

## ✅ Step 1: Get Firebase Config (2 minutes)

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select "Lifeline" project
3. Click ⚙️ → Project Settings
4. Scroll to "Your apps" section
5. Click iOS app (or "Add app" → iOS)
6. Bundle ID: `com.momentic.lifeline`
7. **Download GoogleService-Info.plist**

## ✅ Step 2: Add Firebase Config to Xcode (1 minute)

```bash
# Open project in Xcode
open ios/Runner.xcworkspace
```

In Xcode:
1. Drag `GoogleService-Info.plist` to `Runner` folder
2. ✅ Check "Copy items if needed"
3. ✅ Check "Add to targets: Runner"
4. Click "Finish"

## ✅ Step 3: Configure Google Sign-In (2 minutes)

1. Open `GoogleService-Info.plist` in text editor
2. Find this line:
   ```xml
   <key>REVERSED_CLIENT_ID</key>
   <string>com.googleusercontent.apps.123456789-xxxxx</string>
   ```
3. Copy the value (the `com.googleusercontent.apps...` string)
4. Open `ios/Runner/Info.plist`
5. Find the commented section near the bottom:
   ```xml
   <!-- GOOGLE SIGN-IN CONFIGURATION -->
   ```
6. **Uncomment** the `CFBundleURLTypes` block
7. Replace `YOUR_REVERSED_CLIENT_ID` with the value you copied

## ✅ Step 4: Add Capabilities in Xcode (1 minute)

In Xcode (Runner.xcworkspace):
1. Select Runner project → Runner target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Add "Sign in with Apple"
5. Click "+ Capability" again
6. Add "In-App Purchase"

## ✅ Step 5: Verify Setup (30 seconds)

Run verification script:
```bash
./scripts/check_ios_setup.sh
```

Should show: ✅ All checks passed!

## ✅ Step 6: Build!

```bash
flutter build ios --release
```

Or open in Xcode:
```bash
open ios/Runner.xcworkspace
```

---

## 🆘 Troubleshooting

**Script shows errors?**
→ Read: [docs/ios_setup_requirements.md](ios_setup_requirements.md)

**Build fails in Xcode?**
→ Try: `cd ios && pod install && cd ..`

**App crashes on device?**
→ Check GoogleService-Info.plist is in Bundle Resources (Xcode → Build Phases)

**Google Sign-In doesn't work?**
→ Verify URL Scheme is uncommented and has correct REVERSED_CLIENT_ID

---

**Total setup time: ~6 minutes** ⏱️
