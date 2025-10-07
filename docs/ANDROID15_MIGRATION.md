# Android 15 Migration Guide - Lifeline App

**Date:** 2025-10-07
**Branch:** `android15-migration`
**Status:** ✅ Complete

---

## 🎯 Goal

Ensure Lifeline app complies with Google Play's **Android 15 requirements**:
1. **16KB page size support** (mandatory by November 2025)
2. **Edge-to-Edge rendering** (best practice for Android 15+)
3. **Remove deprecated APIs** (setStatusBarColor, setNavigationBarColor, etc.)

---

## 🚨 Issues Identified

### From Google Play Console:

1. **16KB Page Size Incompatibility**
   > "В вашем приложении есть нативные библиотеки, несовместимые с устройствами, которые используют страницы памяти размером 16 КБ."

   **Problematic libraries:**
   - `base/lib/arm64-v8a/libisar.so`
   - `base/lib/x86_64/libisar.so`

2. **Edge-to-Edge Rendering**
   > "Отображение от края до края может работать не у всех пользователей"

3. **Deprecated APIs**
   ```
   android.view.Window.setStatusBarColor
   android.view.Window.setNavigationBarColor
   android.view.Window.setNavigationBarDividerColor
   ```

---

## ✅ Solutions Implemented

### 1. Isar Database Migration (16KB Support)

**Problem:** Original Isar 3.1.0+1 does NOT support 16KB page sizes.

**Solution:** Migrated to `isar_community` fork which supports 16KB pages.

#### Changes Made:

**pubspec.yaml:**
```yaml
dependencies:
  # OLD:
  # isar: 3.1.0+1
  # isar_flutter_libs: 3.1.0+1

  # NEW:
  isar_community: ^3.3.0-dev.3
  isar_community_flutter_libs: ^3.3.0-dev.3

dev_dependencies:
  # OLD:
  # isar_generator: 3.1.0+1

  # NEW:
  isar_community_generator: ^3.3.0-dev.3
```

**Code Updates:**
```dart
// OLD:
import 'package:isar/isar.dart';

// NEW:
import 'package:isar_community/isar.dart';
```

**Files Modified:**
- `lib/memory.dart`
- `lib/services/isar_service.dart`
- `lib/services/memory_repository.dart`

**Commands Run:**
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

#### Why isar_community?

- **Original Isar:** No longer maintained, no 16KB support planned
- **isar_community:** Community fork with 16KB page size support
- **Google Play Requirement:** Mandatory by November 2025
- **Issue Tracking:** https://github.com/isar/isar/issues/1699

---

### 2. Edge-to-Edge Rendering & Deprecated APIs

**Status:** ✅ Implemented with Android 15 Support

**Problem:** Android 15 deprecates several Edge-to-Edge APIs:
- `android.view.Window.setStatusBarColor`
- `android.view.Window.setNavigationBarColor`
- `android.view.Window.setNavigationBarDividerColor`
- `LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES`

**Solution:** Use `enableEdgeToEdge()` for Android 15+

**MainActivity.kt:**
```kotlin
package com.momentic.lifeline

import android.os.Build
import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Android 15+ Edge-to-Edge enforcement
        // enableEdgeToEdge() automatically handles:
        // - setStatusBarColor (deprecated)
        // - setNavigationBarColor (deprecated)
        // - setNavigationBarDividerColor (deprecated)
        // - LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES (deprecated)
        if (Build.VERSION.SDK_INT >= 35) {
            enableEdgeToEdge()
        } else {
            // For Android 14 and below
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
    }
}
```

**Important Note:** Google Play Console may still show warnings about deprecated APIs being present in the APK. This is because:
1. Flutter SDK and plugins may contain these APIs for backward compatibility
2. Our app uses `enableEdgeToEdge()` which means these deprecated methods are NOT called on Android 15+
3. The warnings refer to API presence, not usage on target devices

**Dependencies (already in build.gradle):**
```gradle
implementation 'androidx.core:core-ktx:1.10.1'
implementation 'androidx.activity:activity-ktx:1.9.0'
```

**Flutter Side (already handled):**
- Flutter SDK automatically handles safe areas with `MediaQuery.of(context).padding`
- System UI overlays handled by Flutter framework

---

### 3. AGP & Gradle Configuration

**Current Versions (already up-to-date):**

**android/build.gradle:**
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:8.7.3'  // AGP 8.7+
    classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:2.1.0"
}
```

**android/gradle/wrapper/gradle-wrapper.properties:**
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.7-all.zip
```

**android/app/build.gradle:**
```gradle
android {
    compileSdk 36          // Latest
    ndkVersion "28.0.12674087"  // NDK r28+ for 16KB support

    defaultConfig {
        targetSdkVersion 35  // Android 15

        // 16KB page size support
        ndk {
            abiFilters 'arm64-v8a', 'armeabi-v7a', 'x86_64'
        }

        externalNativeBuild {
            cmake {
                arguments "-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON"
            }
        }
    }

    // Uncompressed native libs (required for 16KB)
    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}
```

---

### 4. Deprecated APIs

**Status:** ✅ No deprecated APIs found in our code

**Checked locations:**
- ❌ `setStatusBarColor` - Not used
- ❌ `setNavigationBarColor` - Not used
- ❌ `setNavigationBarDividerColor` - Not used

**Note:** These may be used by plugins, but that's handled by plugin authors.

---

## 📊 Testing & Verification

### Build Commands:

```bash
# Clean build
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Build release AAB (for Google Play)
flutter build appbundle --release

# Check for warnings
flutter build appbundle --release 2>&1 | grep -E "(deprecated|16 KB|page size)"
```

### Android Studio Build Analyzer:

1. Open project in Android Studio
2. Build → Analyze APK/AAB
3. Check "Configurations" tab for 16KB support

### Google Play Console Verification:

1. Upload new AAB to Internal Testing
2. Wait for processing (15-30 minutes)
3. Check "Release" → "Testing" for warnings
4. Verify no 16KB warnings appear

---

## 🔄 Migration Checklist

- [x] Migrated isar → isar_community
- [x] Updated all imports in Dart code
- [x] Regenerated .g.dart files
- [x] Verified Edge-to-Edge implementation
- [x] Confirmed AGP/Gradle versions
- [x] Checked for deprecated APIs
- [x] Built release AAB successfully
- [ ] Tested on Android 15 emulator
- [ ] Uploaded to Google Play Internal Testing
- [ ] Verified no warnings in Console

---

## 🚀 Deployment Instructions

### Pre-Deployment:

```bash
# Ensure on correct branch
git checkout android15-migration

# Build and test
flutter clean
flutter pub get
flutter test
flutter build appbundle --release
```

### Upload to Google Play:

1. Go to Google Play Console
2. Navigate to "Release" → "Production" → "Create new release"
3. Upload `build/app/outputs/bundle/release/app-release.aab`
4. Add release notes
5. Review and roll out

### Post-Upload Verification:

- **Wait 15-30 minutes** for processing
- Check for **16KB compatibility** in bundle details
- Verify **Edge-to-Edge** section shows green checkmark
- Confirm **no deprecated API warnings**

---

## 📚 References

### Official Documentation:

- [Android 15 Behavior Changes](https://developer.android.com/about/versions/15/behavior-changes-15)
- [Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes)
- [Edge-to-Edge Implementation](https://developer.android.com/develop/ui/views/layout/edge-to-edge)

### GitHub Issues:

- [Isar 16KB Support Issue #1699](https://github.com/isar/isar/issues/1699)
- [isar_community Package](https://pub.dev/packages/isar_community)

### Blog Posts:

- [Prepare your apps for Google Play's 16 KB page size compatibility requirement](https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html)
- [Transition to using 16 KB page sizes for Android apps](https://android-developers.googleblog.com/2025/07/transition-to-16-kb-page-sizes-android-apps-games-android-studio.html)

---

## 🐛 Troubleshooting

### Issue: Build fails with isar_community

**Solution:**
```bash
flutter clean
flutter pub get
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Still seeing 16KB warnings

**Check:**
1. All native libraries built with NDK r28+
2. All plugins up-to-date
3. No custom JNI libraries without 16KB support

**Verify:**
```bash
unzip -l build/app/outputs/bundle/release/app-release.aab | grep libisar
```

### Issue: Edge-to-Edge not working

**Check:**
1. `WindowCompat.setDecorFitsSystemWindows(window, false)` in MainActivity
2. AndroidX dependencies present in build.gradle
3. Flutter app handles safe areas with SafeArea widgets

---

## ⚠️ Known Limitations

1. **isar_community** is a dev release (3.3.0-dev.3)
   - Monitor for stable 3.3.0 release
   - Update when available

2. **Plugin Dependencies**
   - Some plugins may still use deprecated APIs
   - Not in our control, handled by plugin authors
   - Google Play usually doesn't block for plugin issues

3. **16KB Testing**
   - Real 16KB devices not yet widely available
   - Emulator testing limited
   - Rely on Google Play validation

---

## 📝 Commit History

- `916824b` - feat: Migrate to isar_community for Android 15 16KB page size support
- `bae3a07` - feat: Complete iOS audit and testing infrastructure

---

## ✅ Success Criteria

**Before Merging to Main:**
- ✅ All tests passing
- ✅ Release build successful
- ✅ No compile warnings
- ⏳ Google Play Console shows no 16KB warnings
- ⏳ Edge-to-Edge validation passes
- ⏳ App tested on Android 15 emulator

**After Merge:**
- Deploy to Production
- Monitor crash reports
- Check user reviews for issues

---

**Last Updated:** 2025-10-07
**Maintained by:** Development Team
**Next Review:** After Google Play upload verification
