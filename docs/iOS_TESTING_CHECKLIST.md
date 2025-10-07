# iOS Testing Checklist - Lifeline App

Comprehensive checklist for testing iOS-specific features when you get access to an iOS build.

## 📋 Prerequisites

- ✅ iOS device with iOS 12.0 or higher
- ✅ Apple Developer account (for TestFlight or device installation)
- ✅ Stable internet connection
- ✅ Test Firebase account
- ✅ Test Apple ID

---

## 🔐 Authentication Testing

### Email/Password Authentication
- [ ] **Sign Up**
  - [ ] Create new account with email/password
  - [ ] Verify email verification email is sent
  - [ ] App shows "Please verify email" message
  - [ ] After verification, can login successfully

- [ ] **Sign In**
  - [ ] Login with correct credentials
  - [ ] Error message for incorrect password
  - [ ] Error message for non-existent email
  - [ ] "Remember me" functionality works

- [ ] **Password Reset**
  - [ ] Reset password link sent to email
  - [ ] Can reset password successfully
  - [ ] Can login with new password

### Google Sign-In (iOS Specific)
- [ ] **First Time Sign In**
  - [ ] Google Sign-In button appears
  - [ ] Tapping shows Google account picker
  - [ ] Can select Google account
  - [ ] Redirects back to app correctly (URL Scheme working)
  - [ ] User profile created in Firestore

- [ ] **Subsequent Sign Ins**
  - [ ] Shows last used Google account
  - [ ] Can switch accounts
  - [ ] Sign out and sign back in works

- [ ] **Error Handling**
  - [ ] Canceling sign-in doesn't crash app
  - [ ] Network error shows appropriate message
  - [ ] Handles "account already exists" scenario

### Sign in with Apple (iOS Exclusive)
- [ ] **First Time Sign In**
  - [ ] "Sign in with Apple" button visible
  - [ ] Face ID/Touch ID prompt appears
  - [ ] Can complete authentication
  - [ ] Email sharing option works (Hide My Email)
  - [ ] User profile created correctly

- [ ] **Subsequent Sign Ins**
  - [ ] Quick sign-in with Face ID/Touch ID
  - [ ] No re-authentication required (unless expired)

- [ ] **Error Handling**
  - [ ] Canceling doesn't crash app
  - [ ] Handles revoked credentials gracefully

---

## 🔒 Biometric Authentication (Face ID / Touch ID)

### Initial Setup
- [ ] **Enable Biometric Lock**
  - [ ] Settings > Security > Enable biometric lock option
  - [ ] Face ID/Touch ID prompt appears
  - [ ] NSFaceIDUsageDescription shown correctly
  - [ ] Biometric lock enabled successfully

### Lock Screen
- [ ] **App Lock Behavior**
  - [ ] App locks when going to background
  - [ ] Face ID/Touch ID required on return
  - [ ] Fallback to passcode works
  - [ ] Correct number of attempts allowed

- [ ] **Biometric Failures**
  - [ ] Multiple failed Face ID attempts → Passcode required
  - [ ] "Cancel" button works
  - [ ] Can logout from lock screen

### Memory Encryption
- [ ] **Encrypted Memories**
  - [ ] Create encrypted memory
  - [ ] Face ID/Touch ID required to view
  - [ ] Viewing works after authentication
  - [ ] Encryption persists after app restart

---

## 📸 Camera & Photo Library Permissions

### Camera Access
- [ ] **First Time Access**
  - [ ] Permission dialog appears when tapping "Add Photo"
  - [ ] NSCameraUsageDescription text is clear and correct
  - [ ] "Allow" grants camera access
  - [ ] "Don't Allow" shows error message with settings link

- [ ] **Photo Capture**
  - [ ] Camera opens correctly
  - [ ] Can capture photo
  - [ ] Photo saves to memory
  - [ ] Can capture multiple photos
  - [ ] Portrait and landscape modes work

### Photo Library Access
- [ ] **First Time Access**
  - [ ] Permission dialog for photo library access
  - [ ] NSPhotoLibraryUsageDescription shown correctly
  - [ ] "Allow Access to All Photos" works
  - [ ] "Select Photos" works (iOS 14+)
  - [ ] "Don't Allow" handled gracefully

- [ ] **Photo Selection**
  - [ ] Can browse photo library
  - [ ] Can select single photo
  - [ ] Can select multiple photos
  - [ ] Selected photos display correctly
  - [ ] Can remove selected photos

### Photo Export
- [ ] **Save to Library**
  - [ ] Can export memory as image
  - [ ] NSPhotoLibraryAddUsageDescription shown
  - [ ] Photo saved to Camera Roll
  - [ ] Success message appears

---

## 🎤 Microphone & Audio Recording

### Microphone Permission
- [ ] **First Time Access**
  - [ ] Tapping record button shows permission dialog
  - [ ] NSMicrophoneUsageDescription text is correct
  - [ ] "Allow" grants microphone access
  - [ ] "Don't Allow" shows error message

### Audio Recording
- [ ] **Recording Flow**
  - [ ] Can start recording
  - [ ] Recording indicator shows
  - [ ] Can stop recording
  - [ ] Recording saves correctly
  - [ ] Can play back recording

- [ ] **Recording Quality**
  - [ ] Audio quality is acceptable
  - [ ] File size is reasonable (check for 25MB limit)
  - [ ] Works with headphones
  - [ ] Works with AirPods

### Audio Playback
- [ ] **Playback Controls**
  - [ ] Play button works
  - [ ] Pause button works
  - [ ] Scrubbing/seeking works
  - [ ] Volume controls work
  - [ ] Playback continues in background

---

## 🎵 Media Integration

### Video Recording/Selection
- [ ] **Video from Camera**
  - [ ] Can record video
  - [ ] Video quality settings work
  - [ ] Video saves correctly
  - [ ] 100MB limit enforced (Firebase rule)

- [ ] **Video from Library**
  - [ ] Can select video from library
  - [ ] Video thumbnail generates
  - [ ] Video plays in app

### Spotify Integration (if applicable)
- [ ] **Spotify OAuth**
  - [ ] Spotify login works
  - [ ] Redirects back to app correctly
  - [ ] Can select tracks
  - [ ] Tracks save to memory

---

## 💰 In-App Purchases (iOS Specific)

### Product Loading
- [ ] **Premium Screen**
  - [ ] Monthly subscription shows correct price (in local currency)
  - [ ] Yearly subscription shows correct price
  - [ ] Subscription details visible
  - [ ] "Restore Purchases" button visible

### Purchase Flow
- [ ] **Subscription Purchase**
  - [ ] Tapping subscribe shows iOS payment dialog
  - [ ] Face ID/Touch ID authentication for payment
  - [ ] Can enter password if biometrics fail
  - [ ] Purchase completes successfully
  - [ ] Receipt verification works (Cloud Function)
  - [ ] Premium status updates immediately

- [ ] **Purchase Errors**
  - [ ] Canceling purchase doesn't crash app
  - [ ] Network error handled gracefully
  - [ ] Shows error message for failed verification
  - [ ] Payment declined handled correctly

### Subscription Management
- [ ] **Restore Purchases**
  - [ ] "Restore Purchases" button works
  - [ ] Previous purchases detected
  - [ ] Premium status restored
  - [ ] Shows success message

- [ ] **Subscription Status**
  - [ ] Premium features unlocked after purchase
  - [ ] Premium badge shows on profile
  - [ ] Free tier limits removed

### Sandbox Testing
- [ ] **Test Environment**
  - [ ] Using Sandbox Apple ID
  - [ ] Test purchases don't charge real money
  - [ ] Can complete purchase flow
  - [ ] Can cancel subscriptions

---

## 🔔 Notifications (if implemented)

### Permission Request
- [ ] **Notification Permission**
  - [ ] Permission dialog appears at appropriate time
  - [ ] "Allow" enables notifications
  - [ ] "Don't Allow" disables notifications

### Notification Delivery
- [ ] **Local Notifications**
  - [ ] Scheduled notifications appear
  - [ ] Tapping notification opens app
  - [ ] Notification content is correct

---

## 🌐 Network & Connectivity

### Online Behavior
- [ ] **With Internet**
  - [ ] Firebase sync works
  - [ ] Images load from Firebase Storage
  - [ ] Real-time updates work

### Offline Behavior
- [ ] **Without Internet**
  - [ ] App doesn't crash
  - [ ] Shows offline indicator
  - [ ] Local data accessible
  - [ ] Can create memories offline
  - [ ] Sync happens when back online

---

## 🔄 App Lifecycle

### Background/Foreground
- [ ] **App Backgrounding**
  - [ ] App state saves when backgrounded
  - [ ] Returns to same screen when foregrounded
  - [ ] Biometric lock triggers (if enabled)
  - [ ] Network reconnects automatically

### App Updates
- [ ] **Version Updates**
  - [ ] App updates through TestFlight
  - [ ] Data persists after update
  - [ ] No migration errors

---

## 📱 Device-Specific Testing

### iPhone Models
- [ ] **iPhone with Face ID** (X, 11, 12, 13, 14, 15)
  - [ ] Face ID authentication works
  - [ ] Notch doesn't obscure UI
  - [ ] Safe area respected

- [ ] **iPhone with Touch ID** (8, SE 2nd/3rd gen)
  - [ ] Touch ID authentication works
  - [ ] Home button doesn't conflict with UI

- [ ] **iPhone with Home Button** (6, 7, 8)
  - [ ] UI layout correct
  - [ ] No UI clipping

### iPad Support (if applicable)
- [ ] **iPad Layouts**
  - [ ] App scales correctly
  - [ ] No stretched UI elements
  - [ ] Landscape mode works
  - [ ] Multitasking works

### iOS Versions
- [ ] **iOS 12** (minimum supported)
  - [ ] App launches
  - [ ] Core features work

- [ ] **Latest iOS** (17+)
  - [ ] All features work
  - [ ] No deprecation warnings
  - [ ] New iOS features utilized

---

## 🐛 Error Scenarios

### Authentication Errors
- [ ] **Session Expiration**
  - [ ] Expired token handled
  - [ ] Redirects to login
  - [ ] Shows appropriate message

### Storage Errors
- [ ] **Full Device Storage**
  - [ ] App handles low storage
  - [ ] Shows error message
  - [ ] Doesn't crash

### Firebase Errors
- [ ] **Firebase Offline**
  - [ ] Graceful degradation
  - [ ] Error message shown
  - [ ] Retry mechanism works

---

## 🎨 UI/UX Testing

### Dark Mode
- [ ] **System Dark Mode**
  - [ ] App respects system dark mode
  - [ ] Colors readable in both modes
  - [ ] Images/icons adapt correctly

### Accessibility
- [ ] **VoiceOver**
  - [ ] VoiceOver describes elements
  - [ ] Navigation works with VoiceOver
  - [ ] Buttons have accessibility labels

- [ ] **Dynamic Type**
  - [ ] Text scales with system settings
  - [ ] UI doesn't break with large text

### Localization
- [ ] **Multi-language Support**
  - [ ] App supports configured languages
  - [ ] RTL languages work (Arabic, Hebrew)
  - [ ] Date/time formatting correct

---

## ⚡ Performance Testing

### App Launch
- [ ] **Cold Start**
  - [ ] App launches in < 3 seconds
  - [ ] Splash screen shows
  - [ ] No crash on launch

- [ ] **Warm Start**
  - [ ] Resumes quickly from background
  - [ ] State restored correctly

### Memory Usage
- [ ] **Memory Leaks**
  - [ ] No memory warnings
  - [ ] App doesn't crash after extended use
  - [ ] Images release properly

### Battery Usage
- [ ] **Battery Drain**
  - [ ] Reasonable battery consumption
  - [ ] Background tasks don't drain battery
  - [ ] Location services (if used) optimized

---

## 🔒 Security Testing

### Data Protection
- [ ] **Encrypted Storage**
  - [ ] Sensitive data encrypted at rest
  - [ ] Keychain used for credentials
  - [ ] Biometric keys secure

### Network Security
- [ ] **HTTPS**
  - [ ] All API calls use HTTPS
  - [ ] Certificate pinning (if implemented)
  - [ ] No man-in-the-middle vulnerabilities

---

## 📊 Analytics & Crash Reporting

### Firebase Analytics
- [ ] **Event Tracking**
  - [ ] Events logged to Firebase
  - [ ] User properties set correctly
  - [ ] Screen tracking works

### Crashlytics
- [ ] **Crash Reporting**
  - [ ] Force crash for testing
  - [ ] Crash appears in Crashlytics dashboard
  - [ ] Stack traces complete

---

## ✅ Final Checks

### Pre-Release Checklist
- [ ] All critical bugs fixed
- [ ] Performance acceptable
- [ ] No console errors/warnings
- [ ] TestFlight build validated
- [ ] Screenshots prepared
- [ ] App Store metadata ready

### App Store Submission
- [ ] Privacy policy URL correct
- [ ] Support URL accessible
- [ ] App complies with Apple guidelines
- [ ] No private APIs used
- [ ] Age rating appropriate

---

## 🚨 Known Issues / Expected Failures

### Without Apple Developer Account
- ⚠️ **Code Signing**: Builds will fail without proper provisioning profiles
- ⚠️ **In-App Purchases**: Need active paid Apple Developer account to test
- ⚠️ **Push Notifications**: Require APNs certificate from Apple Developer

### Development Limitations
- ⚠️ **TestFlight**: 90-day testing limit per build
- ⚠️ **Sandbox**: Sandbox purchases behave differently than production
- ⚠️ **Background Modes**: Some require additional entitlements

---

## 📝 Testing Notes Template

```
Date: __________
iOS Version: __________
Device Model: __________
Build Number: __________

Test Results:
- Authentication: ☐ Pass ☐ Fail
- Biometrics: ☐ Pass ☐ Fail
- Camera/Photos: ☐ Pass ☐ Fail
- Audio Recording: ☐ Pass ☐ Fail
- In-App Purchases: ☐ Pass ☐ Fail
- Overall Performance: ☐ Good ☐ Acceptable ☐ Poor

Issues Found:
1. _____________________________________
2. _____________________________________
3. _____________________________________

Notes:
_________________________________________
_________________________________________
```

---

## 🎯 Priority Testing Order

1. **Critical Path** (Must work):
   - Sign in with Apple
   - Create/view memories
   - Biometric authentication
   - Camera/photo access

2. **High Priority**:
   - Google Sign-In
   - Audio recording
   - In-App Purchases
   - Data sync

3. **Medium Priority**:
   - Spotify integration
   - Export features
   - Dark mode
   - Notifications

4. **Low Priority**:
   - Accessibility
   - Localization edge cases
   - Performance optimization

---

**Last Updated:** 2025-10-07
**Version:** 1.0.0
**Maintained by:** Claude Code iOS Audit
