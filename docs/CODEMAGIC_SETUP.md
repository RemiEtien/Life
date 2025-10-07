# Codemagic Setup Guide for Lifeline

## Prerequisites

Before starting:
1. ✅ Codemagic account connected to GitHub (Done!)
2. ⏳ Apple Developer Account ($99/year) - needed for code signing
3. ⏳ GoogleService-Info.plist from Firebase Console

---

## Step 1: Add codemagic.yaml to Repository

The file `codemagic.yaml` is already created in the project root.

**Commit and push it:**
```bash
git add codemagic.yaml
git commit -m "Add Codemagic CI/CD configuration"
git push
```

After push, Codemagic will detect it automatically.

---

## Step 2: Add GoogleService-Info.plist

### Option A: Add to Repository (Quick Test)
**For testing only!** Don't use for production.

```bash
# Download GoogleService-Info.plist from Firebase Console
# Copy it to ios/Runner/
cp ~/Downloads/GoogleService-Info.plist ios/Runner/

# Temporarily remove from .gitignore (ONLY FOR TESTING)
# Or use environment variables (see Option B)
```

### Option B: Use Environment Variables (Production - Recommended)

In Codemagic dashboard:
1. Go to your app → Settings
2. Click "Environment variables"
3. Add variable:
   - **Key:** `GOOGLE_SERVICES_PLIST`
   - **Value:** (paste entire GoogleService-Info.plist content)
   - ✅ Check "Secure"

Then update script in `codemagic.yaml`:
```yaml
- name: Create GoogleService-Info.plist
  script: |
    echo "$GOOGLE_SERVICES_PLIST" > ios/Runner/GoogleService-Info.plist
```

---

## Step 3: Set Up iOS Code Signing

### Automatic (Recommended for Beginners)

In Codemagic:
1. Go to your app → Settings
2. Click "Code signing identities"
3. Click "iOS code signing"
4. Click "Generate certificate"
5. Select "App Store" distribution type
6. Enter Bundle ID: `com.momentic.lifeline`
7. Sign in with Apple Developer account
8. Codemagic will:
   - ✅ Generate certificate
   - ✅ Generate provisioning profile
   - ✅ Upload to Apple Developer Portal
   - ✅ Store in Codemagic

**This is the easiest way!**

### Manual (Advanced)

If you already have certificates:
1. Export from Keychain as `.p12` file
2. Download provisioning profile from Apple Developer Portal
3. Upload both to Codemagic → Code signing identities

---

## Step 4: Configure App Store Connect Integration (Optional)

For automatic TestFlight distribution:

1. In Codemagic → Teams → Integrations
2. Click "Connect" next to App Store Connect
3. Follow the setup wizard:
   - Generate App Store Connect API key
   - Upload to Codemagic

Then in `codemagic.yaml`, uncomment:
```yaml
app_store_connect:
  auth: integration
  submit_to_testflight: true
```

---

## Step 5: Start First Build

### In Codemagic UI:

1. Go to "Builds" tab
2. Click "Start new build"
3. Select branch (usually `main` or `master`)
4. Select workflow: **ios-workflow**
5. Click "Start new build"

### Or via Git:

Just push to the repository:
```bash
git push
```

Codemagic will auto-trigger build on push.

---

## Step 6: Monitor Build

Build process (~10-15 minutes):
1. ✅ Checkout code
2. ✅ Setup Flutter environment
3. ✅ Install dependencies (`flutter pub get`)
4. ✅ Generate localization (`flutter gen-l10n`)
5. ✅ Analyze code (`flutter analyze`)
6. ✅ Install CocoaPods
7. ✅ Setup code signing
8. ✅ Build IPA (`flutter build ipa`)
9. ✅ Upload artifacts

**Watch the logs in real-time!**

---

## Step 7: Download IPA

After successful build:
1. Go to build details page
2. Scroll to "Artifacts" section
3. Download `.ipa` file
4. Or it will be sent to your email

---

## Common Issues & Solutions

### ❌ "GoogleService-Info.plist not found"
**Solution:** Add it via environment variable (Step 2, Option B)

### ❌ "Code signing failed"
**Solution:**
- Make sure you completed Step 3
- Verify Apple Developer account is active
- Check Bundle ID matches: `com.momentic.lifeline`

### ❌ "Pod install failed"
**Solution:** Usually auto-resolved by Codemagic. If persists:
- Check Podfile.lock is committed
- Try `cd ios && pod install` locally first

### ❌ "Build timeout"
**Solution:**
- 60 min should be enough
- If timeout, check for infinite loops or network issues
- Contact Codemagic support

### ❌ "Flutter command not found"
**Solution:** Already handled in `codemagic.yaml` with `flutter: stable`

---

## Build Configuration Details

### iOS Workflow

**What it does:**
- Builds for iOS devices (ARM64)
- Creates `.ipa` file for App Store/TestFlight
- Uses release mode (optimized)
- Applies code signing
- Increments build number automatically

**Build time:** ~10-15 minutes
**Output:** `build/ios/ipa/lifeline.ipa`

### Android Workflow

**What it does:**
- Builds both APK and App Bundle
- Uses release mode
- Signs with keystore (if configured)
- Increments build number

**Build time:** ~8-12 minutes
**Output:**
- `build/app/outputs/bundle/release/app-release.aab`
- `build/app/outputs/apk/release/app-release.apk`

---

## Environment Variables Reference

| Variable | Description | Required |
|----------|-------------|----------|
| `GOOGLE_SERVICES_PLIST` | iOS Firebase config | Yes |
| `APP_STORE_APPLE_ID` | App Store Connect app ID | No (for publishing) |
| `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` | For Google Play | No (for publishing) |

---

## Cost Estimation

**Free tier:** 500 minutes/month

**Typical build times:**
- iOS build: ~12 minutes
- Android build: ~10 minutes
- Both: ~22 minutes

**Builds per month:** ~22 builds (500 min ÷ 22 min)

**If you exceed free tier:**
- First overflow: Warning email
- Cost: $0.038/minute after 500 minutes
- Example: 1000 minutes = $19/month

---

## Tips for Saving Build Minutes

1. **Use build caching** (enabled by default)
2. **Don't trigger builds on every commit**
   - Use draft PRs
   - Commit to feature branches
   - Only build on PR merge
3. **Use conditional builds:**
   ```yaml
   triggering:
     events:
       - push
     branch_patterns:
       - pattern: 'main'
       - pattern: 'release/*'
   ```
4. **Cancel failed builds quickly** (don't wait for timeout)

---

## Next Steps After First Successful Build

1. ✅ Test IPA on real device via Xcode
2. ✅ Setup App Store Connect integration
3. ✅ Configure TestFlight auto-distribution
4. ✅ Add Android keystore for signing
5. ✅ Setup automated tests (optional)

---

## Troubleshooting Commands

If build fails, try locally:

```bash
# Test Flutter build
flutter build ios --release --no-codesign

# Test pod install
cd ios
pod install
cd ..

# Test Xcode build
open ios/Runner.xcworkspace
# Then build in Xcode
```

---

## Support

- **Codemagic Docs:** https://docs.codemagic.io/
- **Codemagic Slack:** https://slack.codemagic.io/
- **Flutter iOS Docs:** https://docs.flutter.dev/deployment/ios

---

## Security Notes

⚠️ **Never commit these files:**
- GoogleService-Info.plist (use environment variables)
- Certificates (.p12 files)
- Provisioning profiles
- API keys

All handled securely by Codemagic! ✅
