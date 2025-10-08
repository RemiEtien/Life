# Smart Notifications System

## Overview

Lifeline implements an intelligent notification system designed to provide **rare but meaningful** reminders about significant life moments. The system respects user time and attention by avoiding notification spam while ensuring important memories resurface at the right time.

## Philosophy

- **Not a daily journal**: Lifeline is for significant emotional moments, not everyday entries
- **Quality over quantity**: Maximum 1 notification per week across all types
- **Smart timing**: All notifications sent at 20:00 local time (reflection hour)
- **User control**: Granular settings per notification type
- **Context-aware**: No notifications if user was recently active

## Notification Types

### 1. Anniversary Notifications 🎂

Reminds users of significant past moments on their anniversaries.

**Features:**
- Triggers on: 1, 2, 5, 10, 15, 20, 25, 30, 40, 50 year anniversaries
- Uses `memory.date` (event date), not `createdAt`
- Shows memory content preview in notification body
- Highest priority in the system

**Example:**
```
Title: "5 Years Ago..."
Body: "That incredible moment when we decided to start our journey..."
```

**Implementation:** `AnniversaryNotificationService`

### 2. Engagement Notifications 💪

Smart motivational reminders based on user activity patterns.

**Features:**
- Analyzes last 10 memories to establish frequency pattern
- Sends reminder if inactive for 3x average interval
- Minimum 21 days between engagement notifications
- Requires at least 3 memories to establish pattern
- Inactivity capped at 90 days maximum

**Logic:**
```dart
avgInterval = average time between last 10 memories
inactivityThreshold = avgInterval * 3 (clamped to 21-90 days)

if (daysSinceLastMemory >= inactivityThreshold) {
  sendNotification()
}
```

**Example:**
```
Title: "Your Lifeline Awaits"
Body: "Has anything meaningful happened recently? Take a moment to capture it."
```

**Implementation:** `EngagementNotificationService`

### 3. Insight Notifications 🧠

Emotional journey reflections based on pattern analysis.

**Features:**
- Requires minimum 10 memories total
- Analyzes last 3 months of activity (min 5 memories)
- Identifies dominant emotion and percentage
- Minimum 60 days between insight notifications
- Personalized messages per emotion type

**Supported Emotions:**
- joy, gratitude, peace, love, hope, reflection, growth
- sadness, anxiety, anger (with supportive messaging)

**Example:**
```
Title: "Your Emotional Journey"
Body: "These past months have been filled with joy. 12 moments captured,
      with happiness at the heart of your journey."
```

**Implementation:** `InsightNotificationService`

## Global Rules

The `NotificationScheduler` enforces these constraints:

1. **Rate Limiting**: Maximum 1 notification per 7 days (any type)
2. **Priority Order**: Anniversary > Engagement > Insight
3. **Master Switch**: Respects global `notificationsEnabled` flag
4. **Type Switches**: Respects individual type preferences
5. **No Spam**: Only one notification per daily check

## Architecture

```
┌─────────────────────────────────────┐
│   BackgroundNotificationWorker     │
│   (WorkManager - Daily at 20:00)    │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│     NotificationScheduler           │
│  - Check global rate limit          │
│  - Load user preferences            │
│  - Check each type in priority order│
└───────────┬─────────────────────────┘
            │
            ├──► AnniversaryNotificationService
            │    └─► Query Isar for anniversaries
            │
            ├──► EngagementNotificationService
            │    └─► Analyze activity pattern
            │
            └──► InsightNotificationService
                 └─► Analyze emotional patterns
```

## User Settings

Located in Profile > Settings:

```
☑ Notifications
  ☑ Anniversary reminders
    "Remind me of meaningful moments from the past"

  ☑ Occasional motivations
    "Gentle reminders to capture important moments"

  ☑ Emotional insights
    "Reflections on your emotional journey"
```

**Localized in 9 languages:**
- English, Russian, German, French, Spanish
- Portuguese, Arabic, Hebrew, Chinese

## Implementation Details

### Background Scheduling

Uses `workmanager` package for reliable background execution:

```dart
// Runs daily at 20:00 local time
Workmanager().registerPeriodicTask(
  'lifeline_daily_notification_check',
  'lifeline_daily_notification_check',
  frequency: Duration(hours: 24),
  initialDelay: _calculateInitialDelay(), // Until 20:00 today/tomorrow
  constraints: Constraints(
    networkType: NetworkType.connected,
    requiresBatteryNotLow: true,
  ),
);
```

### State Persistence

Uses `SharedPreferences` for tracking:
- Last notification sent (any type): `last_notification_timestamp`
- Last engagement notification: `last_engagement_notification`
- Last insight notification: `last_insight_notification`

### Database Access

- Anniversary & Engagement: Query Isar for user's memories
- Insight: Analyzes `memory.emotions` map
- All services use `memory.lastModified` for chronology

### Notification Display

Uses `flutter_local_notifications`:
- Channel: `lifeline_channel_id` - "Lifeline Reminders"
- Importance: Max
- Priority: High
- Icon: App launcher icon
- Payload: `memory:${memoryId}` for deep linking

## Testing

### Manual Testing

Trigger immediate test notification:
```dart
await BackgroundNotificationWorker.triggerNow();
```

### Debug Logging

All services log to console with prefixes:
- `[NotificationScheduler]`
- `[Anniversary]`
- `[Engagement]`
- `[Insight]`
- `[BackgroundWorker]`

### Test Scenarios

1. **Anniversary Test**: Create memory dated 1 year ago, wait for 20:00
2. **Engagement Test**: Delete last notification timestamp, trigger manually
3. **Insight Test**: Add 10+ memories with emotions, trigger manually

## Performance Considerations

- **Lightweight**: Queries only necessary data from Isar
- **Non-blocking**: Background task completes in <2 seconds
- **Battery-friendly**: WorkManager respects battery constraints
- **Network-aware**: Only runs when connected (for Firestore profile fetch)

## Privacy & Security

- ✅ All notification content generated locally
- ✅ No server-side processing of memory content
- ✅ User can disable entirely via master switch
- ✅ Granular control per notification type
- ✅ No external analytics on notification behavior

## Future Enhancements

Potential improvements:
- [ ] ML-based optimal timing (learn user's preferred reflection time)
- [ ] Custom notification time picker
- [ ] Notification history view
- [ ] A/B testing different message templates
- [ ] Rich notifications with memory preview image
- [ ] Weekly digest option (all anniversaries in one notification)

## Localization Strings

All notification UI strings follow pattern:
- `notificationAnniversaryTitle`
- `notificationAnniversarySubtitle`
- `notificationMotivationalTitle`
- `notificationMotivationalSubtitle`
- `notificationInsightTitle`
- `notificationInsightSubtitle`

Located in: `lib/l10n/app_*.arb`

## Files

**Core Services:**
- `lib/services/notification_scheduler.dart` - Main orchestrator
- `lib/services/anniversary_notification_service.dart` - Anniversary logic
- `lib/services/engagement_notification_service.dart` - Engagement logic
- `lib/services/insight_notification_service.dart` - Insight logic
- `lib/services/background_notification_worker.dart` - WorkManager integration
- `lib/services/notification_service.dart` - Low-level notification display

**UI:**
- `lib/screens/profile_screen.dart` - Settings UI

**Models:**
- `lib/models/user_profile.dart` - User preferences storage

**Localization:**
- `lib/l10n/app_*.arb` - Translated strings (9 languages)

---

**Last Updated:** 2025-10-08
**Version:** 1.0.146+146
