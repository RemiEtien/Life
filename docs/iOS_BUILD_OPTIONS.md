# iOS Build Options Without Mac

## Free/Trial Options

### 1. ⭐ Codemagic (Recommended)
**URL:** https://codemagic.io

**Free Tier:**
- ✅ 500 free build minutes/month
- ✅ macOS build machines
- ✅ Xcode pre-installed
- ✅ Flutter support out-of-the-box
- ✅ Can build iOS without local Mac

**Setup:**
1. Sign up with GitHub
2. Connect your repository
3. Configure `codemagic.yaml` (see template below)
4. Add Apple certificates (can generate in Codemagic)
5. Build automatically on push or manually

**Pros:**
- Best free tier for Flutter
- Easy setup
- Good documentation
- Can handle code signing

**Cons:**
- Need Apple Developer account ($99/year) for real device testing
- 500 minutes might not be enough for many builds

---

### 2. GitHub Actions (macOS runners)
**URL:** https://github.com/features/actions

**Free Tier:**
- ✅ 2000 minutes/month for private repos (public = unlimited)
- ✅ macOS runners available
- ✅ Xcode pre-installed

**Setup:**
1. Create `.github/workflows/ios.yml`
2. Configure workflow (see template below)
3. Add secrets for certificates
4. Push to GitHub

**Pros:**
- More free minutes than Codemagic
- Integrated with GitHub
- Good for CI/CD

**Cons:**
- More complex setup
- Manual certificate management
- Slower builds (shared runners)

---

### 3. Bitrise
**URL:** https://www.bitrise.io

**Free Tier:**
- ✅ 90 builds/month OR 45 minutes/month (whichever comes first)
- ✅ macOS build machines
- ✅ Xcode support

**Pros:**
- Good Flutter integration
- Visual workflow editor

**Cons:**
- Very limited free tier (45 min/month)
- Slower than Codemagic

---

### 4. App Center (Microsoft)
**URL:** https://appcenter.ms

**Free Tier:**
- ✅ 240 build minutes/month
- ✅ iOS build support

**Pros:**
- Good analytics
- Distribution platform

**Cons:**
- Less Flutter-specific
- Being deprecated (use GitHub Actions instead)

---

### 5. ⚠️ CircleCI
**URL:** https://circleci.com

**Free Tier:**
- ✅ 6000 minutes/month
- ❌ macOS runners NOT included in free tier

**Pros:**
- Lots of free minutes

**Cons:**
- Need paid plan for macOS ($15/month minimum)

---

### 6. ❌ Travis CI
**Status:** No longer free for open source

---

## Paid Options (If Free Isn't Enough)

### Codemagic Pro
- $30/month
- 500 minutes + $0.038/minute
- Best for Flutter/iOS

### GitHub Actions
- $0.08/minute for macOS
- Pay as you go

---

## ⭐ Recommended: Codemagic

**Why:** Best free tier + Flutter-optimized + easiest setup

### Quick Setup for Codemagic

1. **Sign up:** https://codemagic.io/signup
2. **Connect repository:** Link your GitHub
3. **Create codemagic.yaml:**

```yaml
# Save as: codemagic.yaml in project root
workflows:
  ios-workflow:
    name: iOS Workflow
    instance_type: mac_mini_m1
    max_build_duration: 60
    environment:
      flutter: stable
      xcode: latest
      cocoapods: default
      vars:
        BUNDLE_ID: "com.momentic.lifeline"
        XCODE_WORKSPACE: "Runner.xcworkspace"
        XCODE_SCHEME: "Runner"
      ios_signing:
        distribution_type: app_store
        bundle_identifier: com.momentic.lifeline
    scripts:
      - name: Set up code signing settings on Xcode project
        script: |
          xcode-project use-profiles
      - name: Get Flutter packages
        script: |
          flutter packages pub get
      - name: Flutter analyze
        script: |
          flutter analyze
      - name: Install pods
        script: |
          find . -name "Podfile" -execdir pod install \;
      - name: Flutter build ipa
        script: |
          flutter build ipa --release \
            --export-options-plist=/Users/builder/export_options.plist
    artifacts:
      - build/ios/ipa/*.ipa
      - /tmp/xcodebuild_logs/*.log
      - flutter_drive.log
    publishing:
      email:
        recipients:
          - founder@theplacewelive.org
        notify:
          success: true
          failure: true
```

4. **Setup Apple Certificates in Codemagic:**
   - Go to Team settings → Code signing identities
   - Can generate certificates directly in Codemagic
   - Or upload existing ones

5. **Trigger build:**
   - Push to repository, or
   - Click "Start new build" in Codemagic dashboard

---

## Alternative: Rent a Mac in Cloud

### MacStadium / MacinCloud
**Cost:** ~$30-50/month
**Pros:**
- Full macOS access
- Can use Xcode normally
- Good for development

**Cons:**
- Not free
- Overkill for just building

---

## My Recommendation for Lifeline

**Start with Codemagic Free Tier:**

1. 500 minutes/month is enough for ~10-20 builds
2. Easy setup with Flutter
3. Can handle code signing automatically
4. Free trial of Pro features

**Steps:**
1. Sign up: https://codemagic.io/signup
2. Connect GitHub repository
3. I'll help you create the `codemagic.yaml` configuration
4. Add the file to the repository
5. Configure Apple Developer certificates in Codemagic
6. Build!

**When to upgrade:**
- If you need more than 10-20 builds/month
- When closer to production release
- If you need faster builds

---

## What You Still Need

Even with free cloud build:

1. **Apple Developer Account** - $99/year
   - Required to test on real iOS device
   - Required for TestFlight
   - Required for App Store release

2. **GoogleService-Info.plist**
   - Download from Firebase Console (free)
   - Add to repository (already gitignored)

3. **Code Signing Certificates**
   - Can generate in Codemagic (easiest)
   - Or generate manually with Apple Developer account

---

## Next Steps

Want me to:
1. Create the `codemagic.yaml` configuration file?
2. Create GitHub Actions workflow as alternative?
3. Provide detailed Codemagic setup instructions?

Let me know which service you prefer, and I'll help set it up!
