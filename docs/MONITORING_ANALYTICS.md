# Monitoring & Analytics Setup

## Overview

Lifeline uses Firebase Crashlytics and Firebase Analytics for production monitoring, error tracking, and user behavior insights.

## Current Configuration Status

### Firebase Crashlytics ✅

**Status**: Fully configured and active

**Integration Points**:

1. **Global Error Handling** ([lib/main.dart:72-78](lib/main.dart#L72-78))
```dart
// Production mode
FlutterError.onError = (details) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(details);
};

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};
```

2. **Database Operations** ([lib/services/isar_service.dart](lib/services/isar_service.dart))
```dart
// isar_community migration tracking
FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Opening DB instance: $dbName');
FirebaseCrashlytics.instance.setCustomKey('database_type', 'isar_community');
FirebaseCrashlytics.instance.setCustomKey('migration_version', '4.0.3');
```

**Files with Crashlytics Integration** (15 total):
- `lib/main.dart` - Global error handling
- `lib/services/isar_service.dart` - Database operations
- `lib/services/memory_repository.dart` - CRUD operations
- `lib/services/sync_service.dart` - Cloud sync
- `lib/services/firestore_service.dart` - Firestore operations
- `lib/services/auth_service.dart` - Authentication
- `lib/services/purchase_service.dart` - In-app purchases
- `lib/services/spotify_service.dart` - Music integration
- `lib/services/user_service.dart` - User management
- `lib/services/historical_data_service.dart` - Data migration
- `lib/utils/error_handler.dart` - Error utilities
- `lib/screens/splash_screen.dart` - App initialization
- `lib/screens/auth_gate.dart` - Login flow
- `lib/screens/profile_screen.dart` - Settings
- `lib/screens/memory_view_screen.dart` - Memory display

**Build Configuration**:
```gradle
// android/app/build.gradle
buildTypes {
    release {
        firebaseCrashlytics {
            nativeSymbolUploadEnabled true  // Upload native symbols
        }
    }
}
```

### Firebase Analytics ⚠️

**Status**: Initialized but underutilized

**Current Implementation**:
```dart
// lib/main.dart:39
FirebaseAnalytics.instance;  // Just initialized, no custom events
```

**Opportunity**: Add custom event tracking for key user actions

---

## Recommended Analytics Events

### User Journey Tracking

#### 1. Authentication Events
```dart
// lib/services/auth_service.dart
await FirebaseAnalytics.instance.logEvent(
  name: 'sign_up',
  parameters: {
    'method': 'google|apple|email',
    'timestamp': DateTime.now().toIso8601String(),
  },
);

await FirebaseAnalytics.instance.logEvent(
  name: 'login',
  parameters: {
    'method': 'google|apple|email',
    'biometric_enabled': true/false,
  },
);
```

#### 2. Memory Creation Events
```dart
// lib/services/memory_repository.dart
await FirebaseAnalytics.instance.logEvent(
  name: 'memory_created',
  parameters: {
    'has_media': mediaCount > 0,
    'media_count': mediaCount,
    'has_emotions': emotions.isNotEmpty,
    'has_reflection': reflection != null,
    'word_count': content.split(' ').length,
  },
);
```

#### 3. Premium Conversion Events
```dart
// lib/services/purchase_service.dart
await FirebaseAnalytics.instance.logEvent(
  name: 'purchase_initiated',
  parameters: {
    'product_id': productId,
    'price': price,
    'currency': 'USD',
  },
);

await FirebaseAnalytics.instance.logEvent(
  name: 'purchase_completed',
  parameters: {
    'product_id': productId,
    'transaction_id': transactionId,
    'revenue': revenue,
  },
);
```

#### 4. Feature Usage Events
```dart
// Track timeline interactions
await FirebaseAnalytics.instance.logEvent(
  name: 'timeline_viewed',
  parameters: {
    'memory_count': totalMemories,
    'date_range_days': dateRangeDays,
  },
);

// Track media consumption
await FirebaseAnalytics.instance.logEvent(
  name: 'media_viewed',
  parameters: {
    'media_type': 'photo|video|audio',
    'source': 'memory|gallery',
  },
);

// Track search usage
await FirebaseAnalytics.instance.logEvent(
  name: 'search_performed',
  parameters: {
    'query_length': query.length,
    'results_count': results.length,
  },
);
```

#### 5. Engagement Metrics
```dart
// Session duration
await FirebaseAnalytics.instance.logEvent(
  name: 'session_start',
  parameters: {
    'app_version': packageInfo.version,
  },
);

// Feature discovery
await FirebaseAnalytics.instance.logEvent(
  name: 'feature_discovered',
  parameters: {
    'feature_name': 'encryption|spotify|reflections',
  },
);
```

### User Properties

```dart
// Set once after authentication
await FirebaseAnalytics.instance.setUserProperty(
  name: 'premium_status',
  value: isPremium ? 'premium' : 'free',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'language',
  value: currentLocale.languageCode,
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'encryption_enabled',
  value: hasEncryptedMemories ? 'yes' : 'no',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'platform',
  value: Platform.isAndroid ? 'android' : 'ios',
);
```

---

## Custom Crashlytics Keys

### Current Custom Keys

**Database Migration Tracking**:
```dart
// lib/services/isar_service.dart
FirebaseCrashlytics.instance.setCustomKey('database_type', 'isar_community');
FirebaseCrashlytics.instance.setCustomKey('migration_version', '4.0.3');
```

### Recommended Additional Keys

```dart
// User context
FirebaseCrashlytics.instance.setCustomKey('user_id', userId);
FirebaseCrashlytics.instance.setCustomKey('premium_status', isPremium);
FirebaseCrashlytics.instance.setCustomKey('app_version', packageInfo.version);

// Device context
FirebaseCrashlytics.instance.setCustomKey('android_version', androidVersion);
FirebaseCrashlytics.instance.setCustomKey('device_model', deviceModel);
FirebaseCrashlytics.instance.setCustomKey('screen_size', '${width}x${height}');

// Data context
FirebaseCrashlytics.instance.setCustomKey('total_memories', memoryCount);
FirebaseCrashlytics.instance.setCustomKey('encrypted_memories', encryptedCount);
FirebaseCrashlytics.instance.setCustomKey('sync_status', syncStatus);

// Feature flags
FirebaseCrashlytics.instance.setCustomKey('biometric_enabled', biometricEnabled);
FirebaseCrashlytics.instance.setCustomKey('offline_mode', offlineMode);
```

---

## Monitoring Dashboard Plan

### Key Metrics to Track

#### 1. App Health
- **Crash-free rate**: Target ≥ 99.5%
- **ANR rate**: Target < 0.1%
- **App startup time**: Target < 2s
- **Memory usage**: Monitor for leaks

#### 2. User Engagement
- **Daily Active Users (DAU)**
- **Monthly Active Users (MAU)**
- **Session duration**: Average time per session
- **Retention rate**: D1, D7, D30
- **Memories created per user**: Weekly average

#### 3. Feature Adoption
- **Timeline usage**: % of users viewing timeline weekly
- **Media usage**: % of memories with photos/videos/audio
- **Encryption adoption**: % of users with encrypted memories
- **Reflection completion**: % of memories with reflections
- **Spotify integration**: % of premium users linking Spotify

#### 4. Premium Conversion
- **Conversion rate**: Free → Premium
- **Trial conversion**: Trial → Paid
- **Churn rate**: Premium cancellations
- **Revenue per user (ARPU)**
- **Lifetime value (LTV)**

#### 5. Technical Performance
- **Sync success rate**: % of successful syncs
- **Media upload success**: % of successful uploads
- **API response times**: p50, p95, p99
- **Database query times**: Monitor slow queries
- **Network errors**: By type and frequency

#### 6. Platform-Specific
- **Android version distribution**
- **iOS version distribution** (future)
- **Device model distribution**
- **Screen size distribution**
- **Language distribution**

---

## Firebase Console Setup

### Crashlytics Dashboard

**Recommended Filters**:
1. **By Version**: Monitor new releases separately
2. **By Device**: Identify problematic devices
3. **By Android Version**: Track OS compatibility
4. **By User Type**: Premium vs Free users

**Alert Configuration**:
- Crash rate > 1%
- New issue affecting > 10 users
- Regression in crash-free rate

### Analytics Dashboard

**Recommended Reports**:

1. **User Acquisition**
   - Sign-up sources (Google/Apple/Email)
   - Registration funnel conversion
   - Time to first memory created

2. **User Engagement**
   - Active users over time
   - Session frequency and duration
   - Feature usage heatmap

3. **User Retention**
   - Cohort analysis
   - Retention curves (D1, D7, D30)
   - Churn prediction

4. **Monetization**
   - Premium conversion funnel
   - Purchase events
   - Revenue over time

5. **Technical Performance**
   - App startup time distribution
   - Screen load times
   - Network performance

### Custom Dashboards

**Dashboard 1: Health Monitor**
```
┌─────────────────────────────────────┐
│ Crash-free Rate: 99.7% ↑           │
│ ANR Rate: 0.05% ↓                   │
│ Active Issues: 3                    │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ Top 5 Crashes (Last 7 Days)        │
│ 1. NullPointerException (15)       │
│ 2. NetworkException (8)             │
│ 3. OutOfMemoryError (2)             │
└─────────────────────────────────────┘
```

**Dashboard 2: Engagement Tracker**
```
┌─────────────────────────────────────┐
│ DAU: 1,234 ↑ 5%                    │
│ MAU: 12,456 ↑ 12%                   │
│ Sessions/User: 3.2                  │
│ Avg Session: 8.5 min                │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ Memories Created Today: 456         │
│ Media Uploaded: 1,234 files         │
│ Premium Conversions: 12             │
└─────────────────────────────────────┘
```

**Dashboard 3: Performance Monitor**
```
┌─────────────────────────────────────┐
│ Sync Success Rate: 98.5%            │
│ Media Upload Success: 99.1%         │
│ Avg API Response: 245ms             │
└─────────────────────────────────────┘
┌─────────────────────────────────────┐
│ Slow Queries (>500ms): 23           │
│ Network Errors: 45                  │
│ Database Locks: 2                   │
└─────────────────────────────────────┘
```

---

## Implementation Checklist

### Phase 1: Enhanced Crashlytics (Immediate)

- [ ] Add custom keys for user context
- [ ] Add custom keys for device info
- [ ] Add custom keys for data metrics
- [ ] Add breadcrumb logging for critical operations
- [ ] Test crash reporting in staging

### Phase 2: Analytics Implementation (Q4 2025)

- [ ] Create analytics service wrapper
- [ ] Implement authentication events
- [ ] Implement memory creation events
- [ ] Implement premium conversion events
- [ ] Implement feature usage events
- [ ] Set user properties
- [ ] Test events in debug mode

### Phase 3: Dashboard Setup (Q1 2026)

- [ ] Configure Crashlytics alerts
- [ ] Create custom Analytics reports
- [ ] Set up BigQuery export (optional)
- [ ] Create stakeholder dashboards
- [ ] Document monitoring procedures

### Phase 4: Optimization (Q2 2026)

- [ ] Review top crashes and fix
- [ ] Analyze user behavior patterns
- [ ] Optimize conversion funnel
- [ ] Improve retention strategies
- [ ] A/B test features (if needed)

---

## Analytics Service Example

```dart
// lib/services/analytics_service.dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Authentication
  static Future<void> logSignUp(String method) async {
    await _analytics.logEvent(
      name: 'sign_up',
      parameters: {'method': method},
    );
  }

  static Future<void> logLogin(String method, bool biometric) async {
    await _analytics.logEvent(
      name: 'login',
      parameters: {
        'method': method,
        'biometric_enabled': biometric,
      },
    );
  }

  // Memory Events
  static Future<void> logMemoryCreated({
    required int mediaCount,
    required bool hasEmotions,
    required bool hasReflection,
  }) async {
    await _analytics.logEvent(
      name: 'memory_created',
      parameters: {
        'has_media': mediaCount > 0,
        'media_count': mediaCount,
        'has_emotions': hasEmotions,
        'has_reflection': hasReflection,
      },
    );
  }

  // Premium Events
  static Future<void> logPurchaseInitiated(String productId) async {
    await _analytics.logEvent(
      name: 'purchase_initiated',
      parameters: {'product_id': productId},
    );
  }

  static Future<void> logPurchaseCompleted(
    String productId,
    String transactionId,
    double revenue,
  ) async {
    await _analytics.logEvent(
      name: 'purchase',
      parameters: {
        'product_id': productId,
        'transaction_id': transactionId,
        'value': revenue,
        'currency': 'USD',
      },
    );
  }

  // User Properties
  static Future<void> setUserProperties({
    required bool isPremium,
    required String language,
    required bool encryptionEnabled,
  }) async {
    await _analytics.setUserProperty(
      name: 'premium_status',
      value: isPremium ? 'premium' : 'free',
    );
    await _analytics.setUserProperty(
      name: 'language',
      value: language,
    );
    await _analytics.setUserProperty(
      name: 'encryption_enabled',
      value: encryptionEnabled ? 'yes' : 'no',
    );
  }

  // Screen Views
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
```

---

## Privacy Considerations

### GDPR Compliance

- ✅ Analytics data is anonymized by Firebase
- ✅ No PII (Personally Identifiable Information) logged
- ✅ User can disable analytics (if implemented)
- ⚠️ Document data collection in Privacy Policy

### Data Minimization

**DO Log**:
- Anonymous usage patterns
- Technical performance metrics
- Crash reports (with anonymized IDs)
- Aggregate statistics

**DO NOT Log**:
- Memory content
- User email addresses (use hashed user IDs)
- Encryption keys
- Personal photos/videos metadata
- Location data (unless explicit consent)

### User Consent

```dart
// Recommended: Allow users to opt-out
if (userPreferences.analyticsEnabled) {
  await AnalyticsService.logMemoryCreated(...);
}

// Settings screen option
SwitchListTile(
  title: Text('Share usage data'),
  subtitle: Text('Help us improve the app'),
  value: analyticsEnabled,
  onChanged: (value) async {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(value);
    setState(() => analyticsEnabled = value);
  },
);
```

---

## Monitoring Best Practices

### 1. Set Baselines
- Establish normal performance metrics
- Track trends over time
- Alert on significant deviations

### 2. Prioritize Issues
- **P0**: Crashes affecting > 1% of users
- **P1**: Performance degradation > 20%
- **P2**: Feature bugs affecting < 1%
- **P3**: Nice-to-have improvements

### 3. Regular Reviews
- **Daily**: Check crash dashboard
- **Weekly**: Review top issues and fix
- **Monthly**: Analyze trends and patterns
- **Quarterly**: Review goals and adjust

### 4. Incident Response
1. Detect (via alerts)
2. Assess severity
3. Fix critical issues within 24h
4. Deploy hotfix if needed
5. Post-mortem analysis

---

## Next Steps

1. ✅ Document current monitoring setup
2. ⏳ Implement AnalyticsService wrapper (Q4 2025)
3. ⏳ Add custom events to key user flows (Q4 2025)
4. ⏳ Set up Firebase dashboards (Q1 2026)
5. ⏳ Review and optimize based on data (Q2 2026)

---

**Last Updated**: October 2025
**Version**: 1.0.142
**Status**: Crashlytics ✅ | Analytics ⚠️ (needs enhancement)
