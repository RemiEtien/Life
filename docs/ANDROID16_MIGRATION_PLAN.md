# Android 16 Migration Plan

## Overview

This document outlines the migration plan for upgrading from targetSdk 35 (Android 15) to targetSdk 36 (Android 16), required by **August 2026** for Google Play Store submissions.

## Current Status (October 2025)

- ✅ **Current targetSdk**: 35 (Android 15)
- ✅ **Edge-to-Edge**: Enabled via `windowOptOutEdgeToEdgeEnforcement=false`
- ✅ **16KB Page Size**: Supported via isar_community
- ✅ **PopScope Migration**: Already using PopScope (not deprecated WillPopScope)
- ⏳ **Deadline**: August 2026 (10 months remaining)

## Android 16 Breaking Changes Analysis

### 1. Edge-to-Edge Enforcement (CRITICAL)

**Status**: ⚠️ Requires changes

**Current Implementation**:
```xml
<!-- values-v35/styles.xml -->
<item name="android:windowOptOutEdgeToEdgeEnforcement">false</item>
```

**Impact**:
- Flag `windowOptOutEdgeToEdgeEnforcement` deprecated in Android 16
- App MUST properly handle system bars (status bar, navigation bar)
- All UI must work with insets

**Required Changes**:
1. Remove `windowOptOutEdgeToEdgeEnforcement` flag
2. Ensure all screens handle WindowInsets properly
3. Wrap UI in SafeArea widgets where needed
4. Test on devices with different screen configurations

**Priority**: HIGH
**Effort**: Medium (2-3 days)
**Risk**: Medium (UI layout issues)

---

### 2. Predictive Back Gesture

**Status**: ✅ Already compatible

**Current Implementation**:
```dart
// memory_edit_screen.dart:1023
return PopScope(
  canPop: false,
  onPopInvokedWithResult: (didPop, dynamic result) async {
    // Handle unsaved changes confirmation
  },
);
```

**Analysis**:
- ✅ Using PopScope (modern API)
- ✅ NOT using deprecated WillPopScope
- ✅ Handles back navigation properly
- ✅ Shows confirmation dialogs for unsaved changes

**Files Using PopScope**:
- `lib/screens/premium_screen.dart:244`
- `lib/screens/memory_edit_screen.dart:1023`
- `lib/screens/memory_view_screen.dart:1014`

**Required Changes**: ⚠️ None (already compatible)

**Priority**: LOW (monitoring only)
**Effort**: None
**Risk**: None

---

### 3. Screen Orientation Changes

**Status**: ⚠️ Needs testing

**Impact**:
- Android 16 enforces orientation changes more strictly
- Apps must handle orientation changes gracefully
- Configuration changes must preserve state

**Current Handling**: Unknown (needs audit)

**Required Changes**:
1. Audit all screens for orientation handling
2. Test rotation on tablets and foldables
3. Ensure state preservation during rotation
4. Add orientation locks where appropriate (e.g., camera)

**Priority**: MEDIUM
**Effort**: Medium (3-4 days testing)
**Risk**: Medium (UX degradation)

---

### 4. Foreground Service Restrictions

**Status**: ✅ Not affected

**Analysis**:
- App doesn't use foreground services
- Sync happens in background (WorkManager)
- No changes required

**Priority**: N/A
**Effort**: None
**Risk**: None

---

### 5. Notification Permissions

**Status**: ✅ Already handling

**Current Implementation**:
- Using notification_service.dart
- Requesting permissions at runtime
- Graceful degradation if denied

**Priority**: LOW
**Effort**: None (verify only)
**Risk**: None

---

## Migration Checklist

### Phase 1: Preparation (Q1 2026)

- [ ] **Update Flutter SDK** to version with Android 16 support
  - Wait for Flutter stable with Android 16 compatibility
  - Expected: Flutter 3.30+ (check flutter.dev)

- [ ] **Update Dependencies**
  - [ ] Update gradle to 8.8+
  - [ ] Update AGP to 8.8+
  - [ ] Update Kotlin to 2.0+
  - [ ] Check all plugins for Android 16 compatibility

- [ ] **Create Android 16 Test Environment**
  - [ ] Install Android 16 SDK
  - [ ] Create Android 16 AVD emulator
  - [ ] Test on real Android 16 device (if available)

### Phase 2: Edge-to-Edge Migration (Q2 2026)

- [ ] **Remove Opt-Out Flag**
  - [ ] Delete `windowOptOutEdgeToEdgeEnforcement` from values-v35/styles.xml
  - [ ] Update MainActivity.kt comments

- [ ] **Audit UI Components**
  - [ ] Identify screens that need SafeArea wrapping
  - [ ] Check all dialogs for proper positioning
  - [ ] Verify bottom sheets don't overlap navigation bar
  - [ ] Test floating action buttons positioning

- [ ] **Implement WindowInsets Handling**
  - [ ] Wrap main scaffold in SafeArea
  - [ ] Handle camera/fullscreen views specially
  - [ ] Ensure keyboard doesn't overlap input fields
  - [ ] Test on devices with notches/camera cutouts

- [ ] **Update Large Screens**
  - [ ] `memory_view_screen.dart` (2770 lines) - Priority HIGH
  - [ ] `lifeline_widget.dart` (2682 lines) - Priority HIGH
  - [ ] `memory_edit_screen.dart` (1811 lines) - Priority HIGH
  - [ ] `profile_screen.dart` (1275 lines) - Priority MEDIUM

### Phase 3: Testing (Q3 2026)

- [ ] **Emulator Testing**
  - [ ] Test on phone emulator (Android 16)
  - [ ] Test on tablet emulator (10" and 12")
  - [ ] Test on foldable emulator (open/closed states)
  - [ ] Test different screen densities (mdpi, hdpi, xxhdpi)

- [ ] **Orientation Testing**
  - [ ] Test all screens in portrait mode
  - [ ] Test all screens in landscape mode
  - [ ] Test rotation during various operations
  - [ ] Verify state preservation

- [ ] **Edge Cases**
  - [ ] Test with system gesture navigation
  - [ ] Test with 3-button navigation
  - [ ] Test on devices with camera notches
  - [ ] Test on devices with rounded corners

- [ ] **Automated Tests**
  - [ ] Add widget tests for SafeArea
  - [ ] Add integration tests for orientation changes
  - [ ] Update existing tests for Android 16

### Phase 4: Deployment (August 2026)

- [ ] **Update targetSdk**
  ```gradle
  android {
      compileSdk 36
      defaultConfig {
          targetSdkVersion 36
      }
  }
  ```

- [ ] **Update Documentation**
  - [ ] Update ANDROID15_MIGRATION.md → ANDROID16_MIGRATION.md
  - [ ] Update README.md with new SDK version
  - [ ] Update ARCHITECTURE.md
  - [ ] Create release notes

- [ ] **Build and Test**
  - [ ] Build release AAB
  - [ ] Test on internal testing track
  - [ ] Run 14-day closed testing
  - [ ] Monitor Pre-launch reports

- [ ] **Production Release**
  - [ ] Submit to Google Play
  - [ ] Monitor Crashlytics for errors
  - [ ] Monitor user reviews
  - [ ] Prepare rollback plan

---

## Screen Audit Results

### Screens Requiring SafeArea Review

Based on file size and complexity, prioritize these screens:

1. **memory_view_screen.dart** (2770 lines)
   - Complex media gallery
   - Video/audio players
   - Action buttons
   - **Risk**: HIGH
   - **Effort**: 2 days

2. **lifeline_widget.dart** (2682 lines)
   - Timeline visualization
   - Custom painter
   - Gesture handling
   - **Risk**: HIGH
   - **Effort**: 2 days

3. **memory_edit_screen.dart** (1811 lines)
   - Rich text editor
   - Media pickers
   - Bottom action bar
   - **Risk**: HIGH
   - **Effort**: 1.5 days

4. **profile_screen.dart** (1275 lines)
   - Settings list
   - Account management
   - **Risk**: MEDIUM
   - **Effort**: 1 day

5. **auth_gate.dart** (894 lines)
   - Login/signup forms
   - Keyboard handling
   - **Risk**: MEDIUM
   - **Effort**: 0.5 day

### Low-Risk Screens
- Splash screen (minimal UI)
- Dialog widgets (already centered)
- Simple list views (standard Material widgets)

---

## Risk Assessment

### High Risk Items

1. **Edge-to-Edge Layout Issues** (Likelihood: HIGH, Impact: HIGH)
   - Mitigation: Thorough testing on multiple device types
   - Fallback: Can revert targetSdk if critical issues found

2. **Performance Regression** (Likelihood: MEDIUM, Impact: MEDIUM)
   - Mitigation: Profile app before/after migration
   - Monitor: Frame rendering times, jank metrics

3. **Third-Party Plugin Incompatibility** (Likelihood: MEDIUM, Impact: HIGH)
   - Mitigation: Check plugin changelogs before migration
   - Test: Each plugin on Android 16 emulator
   - Fallback: Fork and patch plugins if needed

### Medium Risk Items

1. **Orientation Handling** (Likelihood: MEDIUM, Impact: MEDIUM)
   - Mitigation: Add rotation tests to test suite
   - Test: All critical user flows in both orientations

2. **Keyboard/Input Issues** (Likelihood: LOW, Impact: MEDIUM)
   - Mitigation: Test all text input fields thoroughly
   - Focus: Memory edit screen, search, auth forms

### Low Risk Items

1. **PopScope Migration** - Already done ✅
2. **Foreground Services** - Not used ✅
3. **Notification Permissions** - Already handled ✅

---

## Timeline

```
Q1 2026 (Jan-Mar)
├─ January: Monitor Flutter releases for Android 16 support
├─ February: Update dependencies, create test environment
└─ March: Begin edge-to-edge code audit

Q2 2026 (Apr-Jun)
├─ April: Implement SafeArea wrapping in high-priority screens
├─ May: Complete all screen updates, internal testing
└─ June: Fix issues, optimize performance

Q3 2026 (Jul-Aug)
├─ July: Final testing, documentation updates
└─ August: Production release (DEADLINE)
```

---

## Testing Strategy

### Automated Testing
```bash
# Run all tests on Android 16
flutter test --device-id=emulator-android-16

# Generate coverage
flutter test --coverage

# Widget tests for SafeArea
flutter test test/widgets/ --name SafeArea
```

### Manual Testing Matrix

| Device Type | Screen Size | API Level | Test Status |
|-------------|-------------|-----------|-------------|
| Phone       | 5.5"        | 36        | ⏳ Pending  |
| Phone       | 6.7"        | 36        | ⏳ Pending  |
| Tablet      | 10"         | 36        | ⏳ Pending  |
| Tablet      | 12"         | 36        | ⏳ Pending  |
| Foldable    | Variable    | 36        | ⏳ Pending  |

### Test Scenarios

1. **Memory Creation Flow**
   - Create memory with text only
   - Add photos (1, 5, 10+)
   - Add videos
   - Add audio recordings
   - Save and verify

2. **Memory Viewing**
   - View memory with media
   - Play video/audio
   - Swipe through photos
   - Rotate device during playback

3. **Timeline Interaction**
   - Scroll timeline
   - Zoom in/out
   - Select memories
   - Rotate device

4. **Authentication**
   - Sign in with Google
   - Sign in with Email
   - Biometric unlock
   - Password reset

5. **Settings & Profile**
   - Change language
   - Toggle premium features
   - Export data
   - Delete account

---

## Rollback Plan

If critical issues are discovered after targetSdk 36 release:

1. **Immediate Actions**
   - Halt production rollout (if staged)
   - Revert to targetSdk 35
   - Submit hotfix build to Google Play

2. **Communication**
   - Notify users via in-app message
   - Post to support channels
   - Update store listing

3. **Investigation**
   - Collect crash logs from Crashlytics
   - Analyze Pre-launch reports
   - Identify root cause

4. **Fix & Redeploy**
   - Fix issues in development
   - Re-test thoroughly
   - Gradual rollout (1% → 10% → 100%)

---

## Resources

### Official Documentation
- [Android 16 Behavior Changes](https://developer.android.com/about/versions/16/behavior-changes-all)
- [Edge-to-Edge Guide](https://developer.android.com/develop/ui/views/layout/edge-to-edge)
- [Predictive Back Gesture](https://developer.android.com/guide/navigation/custom-back/predictive-back-gesture)

### Flutter Resources
- [Flutter Android 16 Support](https://docs.flutter.dev/release/breaking-changes)
- [Platform Views on Android](https://docs.flutter.dev/platform-integration/android/platform-views)

### Community
- Flutter GitHub Issues: Search for "android 16"
- Stack Overflow: Tag `flutter` + `android-16`

---

## Success Criteria

- [ ] App builds successfully with targetSdk 36
- [ ] All 161 unit tests pass on Android 16
- [ ] No critical crashes in Crashlytics (7 days post-release)
- [ ] No UI layout issues reported by users
- [ ] Performance metrics within 5% of targetSdk 35 baseline
- [ ] Google Play Pre-launch report shows no blockers
- [ ] User rating remains ≥ 4.0 stars

---

**Last Updated**: October 2025
**Next Review**: January 2026
**Owner**: Development Team
**Status**: Planning Phase
