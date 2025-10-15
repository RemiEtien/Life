import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar_community/isar.dart';
import '../memory.dart';
import '../models/user_profile.dart';
import 'notification_scheduler.dart';
import 'notification_service.dart';
import 'anniversary_notification_service.dart';
import 'engagement_notification_service.dart';
import 'insight_notification_service.dart';
import 'isar_service.dart';

/// Background task handler for checking and scheduling notifications
/// Runs daily at 20:00 local time via WorkManager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      debugPrint('[BackgroundWorker] Task started: $task');

      // CRITICAL: Initialize Flutter bindings in background isolate
      // Without this, plugins will throw MissingPluginException
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase (required for background tasks)
      await Firebase.initializeApp();

      // Check if user is authenticated
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('[BackgroundWorker] No authenticated user, skipping');
        return Future.value(true);
      }

      // Get user profile from Firestore
      final profileDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!profileDoc.exists) {
        debugPrint('[BackgroundWorker] User profile not found');
        return Future.value(true);
      }

      final profile = UserProfile.fromJson(user.uid, profileDoc.data()!);

      // Initialize Isar database for the user
      final isar = await IsarService.instance(user.uid);

      // Initialize notification services
      final notificationService = NotificationService();
      await notificationService.init();

      final anniversaryService = AnniversaryNotificationService(isar);
      final engagementService = EngagementNotificationService(isar);
      final insightService = InsightNotificationService(isar);

      final scheduler = NotificationScheduler(
        notificationService: notificationService,
        anniversaryService: anniversaryService,
        engagementService: engagementService,
        insightService: insightService,
      );

      // Check and schedule notifications
      await scheduler.checkAndScheduleNotifications(profile);

      debugPrint('[BackgroundWorker] Task completed successfully');
      return Future.value(true);
    } catch (e, stack) {
      debugPrint('[BackgroundWorker] Error: $e');
      debugPrint('[BackgroundWorker] Stack: $stack');
      return Future.value(false);
    }
  });
}

/// Service for managing background notification checks via WorkManager
class BackgroundNotificationWorker {
  static const String _taskName = 'lifeline_daily_notification_check';

  /// Initialize WorkManager and register the daily task
  static Future<void> initialize() async {
    try {
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register periodic task (runs daily at 20:00)
      await Workmanager().registerPeriodicTask(
        _taskName,
        _taskName,
        frequency: const Duration(hours: 24),
        initialDelay: _calculateInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      );

      debugPrint('[BackgroundWorker] Initialized successfully');
    } catch (e, stack) {
      debugPrint('[BackgroundWorker] Initialization error: $e');
      debugPrint('[BackgroundWorker] Stack: $stack');
    }
  }

  /// Calculate initial delay to run at 20:00 today (or tomorrow if past 20:00)
  static Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var targetTime = DateTime(now.year, now.month, now.day, 20, 0);

    // If it's already past 20:00 today, schedule for tomorrow
    if (now.isAfter(targetTime)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final delay = targetTime.difference(now);
    debugPrint('[BackgroundWorker] Initial delay: ${delay.inHours}h ${delay.inMinutes % 60}m');

    return delay;
  }

  /// Cancel the background task (call this on logout)
  static Future<void> cancel() async {
    try {
      await Workmanager().cancelByUniqueName(_taskName);
      debugPrint('[BackgroundWorker] Cancelled successfully');
    } catch (e) {
      debugPrint('[BackgroundWorker] Cancel error: $e');
    }
  }

  /// Trigger task immediately (for testing)
  static Future<void> triggerNow() async {
    try {
      await Workmanager().registerOneOffTask(
        '${_taskName}_test',
        _taskName,
        initialDelay: const Duration(seconds: 5),
      );
      debugPrint('[BackgroundWorker] Triggered test run');
    } catch (e) {
      debugPrint('[BackgroundWorker] Trigger error: $e');
    }
  }
}
