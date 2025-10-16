import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'anniversary_notification_service.dart';
import 'engagement_notification_service.dart';
import 'insight_notification_service.dart';
import '../models/user_profile.dart';
import 'notification_service.dart';
import '../utils/safe_logger.dart';

/// Central scheduler for managing all notification types
/// Enforces global rules: max 1 notification per week, respects user preferences
class NotificationScheduler {
  static const String _lastNotificationKey = 'last_notification_timestamp';
  static const Duration _minTimeBetweenNotifications = Duration(days: 7);

  final NotificationService _notificationService;
  final AnniversaryNotificationService _anniversaryService;
  final EngagementNotificationService _engagementService;
  final InsightNotificationService _insightService;

  NotificationScheduler({
    required NotificationService notificationService,
    required AnniversaryNotificationService anniversaryService,
    required EngagementNotificationService engagementService,
    required InsightNotificationService insightService,
  })  : _notificationService = notificationService,
        _anniversaryService = anniversaryService,
        _engagementService = engagementService,
        _insightService = insightService;

  /// Check if we can send any notification (respects global rate limit)
  Future<bool> _canSendNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotificationTimestamp = prefs.getInt(_lastNotificationKey);

    if (lastNotificationTimestamp == null) {
      return true; // Never sent a notification before
    }

    final lastNotification = DateTime.fromMillisecondsSinceEpoch(lastNotificationTimestamp);
    final now = DateTime.now();
    final timeSinceLastNotification = now.difference(lastNotification);

    return timeSinceLastNotification >= _minTimeBetweenNotifications;
  }

  /// Record that we sent a notification
  Future<void> _recordNotificationSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastNotificationKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Main entry point: check all notification types and send if appropriate
  /// Called daily by WorkManager at 20:00 local time
  Future<void> checkAndScheduleNotifications(UserProfile profile) async {
    try {
      SafeLogger.debug('Checking notifications for user ${profile.uid}', tag: 'NotificationScheduler');

      // Master switch off? Exit early
      if (!profile.notificationsEnabled) {
        SafeLogger.debug('Notifications disabled globally', tag: 'NotificationScheduler');
        return;
      }

      // Can we send any notification? (respects 1 per week limit)
      if (!await _canSendNotification()) {
        SafeLogger.debug('Too soon since last notification', tag: 'NotificationScheduler');
        return;
      }

      // Priority order: Anniversary > Engagement > Insight
      // Only send ONE notification per check

      // 1. Check Anniversary (highest priority)
      if (profile.anniversaryNotifications) {
        final anniversaryNotification = await _anniversaryService.checkForAnniversaries(profile.uid);
        if (anniversaryNotification != null) {
          SafeLogger.debug('Sending anniversary notification', tag: 'NotificationScheduler');
          await _notificationService.showLocalNotification(
            title: anniversaryNotification.title,
            body: anniversaryNotification.body,
            payload: anniversaryNotification.payload,
          );
          await _recordNotificationSent();
          return;
        }
      }

      // 2. Check Engagement (medium priority)
      if (profile.motivationalNotifications) {
        final engagementNotification = await _engagementService.checkForEngagement(profile.uid);
        if (engagementNotification != null) {
          SafeLogger.debug('Sending engagement notification', tag: 'NotificationScheduler');
          await _notificationService.showLocalNotification(
            title: engagementNotification.title,
            body: engagementNotification.body,
            payload: engagementNotification.payload,
          );
          await _recordNotificationSent();
          return;
        }
      }

      // 3. Check Insight (lowest priority)
      if (profile.insightNotifications) {
        final insightNotification = await _insightService.checkForInsight(profile.uid);
        if (insightNotification != null) {
          SafeLogger.debug('Sending insight notification', tag: 'NotificationScheduler');
          await _notificationService.showLocalNotification(
            title: insightNotification.title,
            body: insightNotification.body,
            payload: insightNotification.payload,
          );
          await _recordNotificationSent();
          return;
        }
      }

      SafeLogger.debug('No notifications to send today', tag: 'NotificationScheduler');
    } catch (e, stack) {
      SafeLogger.error('Error checking notifications', error: e, stackTrace: stack, tag: 'NotificationScheduler');
    }
  }

  /// Schedule daily check at 20:00 local time
  /// This will be called by WorkManager (implemented next)
  static Future<void> scheduleDailyCheck() async {
    SafeLogger.debug('Scheduling daily check at 20:00', tag: 'NotificationScheduler');
    // Implementation will use WorkManager/AlarmManager
    // to trigger checkAndScheduleNotifications() daily at 20:00
  }
}

/// Data class for notification content
class NotificationContent {
  final String title;
  final String body;
  final String? payload;

  const NotificationContent({
    required this.title,
    required this.body,
    this.payload,
  });
}
