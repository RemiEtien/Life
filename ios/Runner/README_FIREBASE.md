# 🚨 IMPORTANT: Firebase Configuration Required

## Missing File: GoogleService-Info.plist

This file is **REQUIRED** for the iOS app to work. Without it, the app will crash on startup.

### Where to Get It

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your "Lifeline" project
3. Click the gear icon ⚙️ → Project Settings
4. Scroll down to "Your apps"
5. Click the iOS app icon (if exists) OR click "Add app" → iOS
6. Enter Bundle ID: **com.momentic.lifeline**
7. Download **GoogleService-Info.plist**

### How to Add It

**Option 1: Via Xcode (Recommended)**
1. Open `ios/Runner.xcworkspace` in Xcode
2. Drag `GoogleService-Info.plist` into the `Runner` folder in Xcode navigator
3. Make sure these checkboxes are selected:
   - ✅ Copy items if needed
   - ✅ Add to targets: Runner
4. Click "Finish"

**Option 2: Manual**
1. Copy `GoogleService-Info.plist` to this directory (`ios/Runner/`)
2. Open `ios/Runner.xcodeproj/project.pbxproj` in text editor
3. Add the file reference (not recommended, use Xcode instead)

### After Adding

The file should be in the same directory as this README:
```
ios/Runner/
├── AppDelegate.swift
├── Info.plist
├── GoogleService-Info.plist  ← This file
└── README_FIREBASE.md         ← You are here
```

### Next Steps

After adding `GoogleService-Info.plist`:

1. Open it in a text editor
2. Find the `REVERSED_CLIENT_ID` key (looks like `com.googleusercontent.apps.123456789-xxxxx`)
3. Copy that value
4. Open `Info.plist` in this directory
5. Find the commented-out `CFBundleURLTypes` section
6. Uncomment it and replace `YOUR_REVERSED_CLIENT_ID` with the actual value

### Verification

To verify the file is correctly added:
1. Open `ios/Runner.xcodeproj` in Xcode
2. Select the `Runner` target
3. Go to "Build Phases" tab
4. Expand "Copy Bundle Resources"
5. You should see `GoogleService-Info.plist` in the list

---

**DO NOT commit GoogleService-Info.plist to version control!**
Add it to `.gitignore` if not already there.
