import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import '../utils/safe_logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // MEMORY LEAK FIX: Move StreamController inside class and make it lazily initialized
  // This allows proper disposal when needed
  StreamController<String?>? _onNotificationTapController;

  /// Stream for notification tap events
  /// Creates the controller lazily on first access
  Stream<String?> get onNotificationTap {
    _onNotificationTapController ??= StreamController<String?>.broadcast();
    return _onNotificationTapController!.stream;
  }

  /// Add notification tap event to stream
  void _addNotificationTap(String? payload) {
    _onNotificationTapController ??= StreamController<String?>.broadcast();
    _onNotificationTapController!.add(payload);
  }

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Cache permission status to avoid repeated permission requests
  bool? _permissionsGranted;
  DateTime? _lastPermissionCheck;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        if (response.payload != null) {
          // Отправляем payload (ID воспоминания) в поток
          _addNotificationTap(response.payload);
        }
      },
    );

    // CRITICAL FIX: Initialize timezone data and set local timezone
    tz.initializeTimeZones();
    try {
      // Get the device's local timezone name
      final String timezoneName = await FlutterTimezone.getLocalTimezone();
      // Set the local location for tz.local to use device timezone
      tz.setLocalLocation(tz.getLocation(timezoneName));

      SafeLogger.debug('Set local timezone to: $timezoneName', tag: 'NotificationService');
    } catch (e) {
      SafeLogger.error('Failed to set local timezone, using UTC', error: e, tag: 'NotificationService');
      // Fallback to UTC if timezone detection fails
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<bool> _requestPermissions({bool forceCheck = false}) async {
    // Return cached result if available and not forcing a new check
    // Re-check permissions every 24 hours or if forced
    if (!forceCheck &&
        _permissionsGranted != null &&
        _lastPermissionCheck != null) {
      final timeSinceLastCheck = DateTime.now().difference(_lastPermissionCheck!);
      if (timeSinceLastCheck.inHours < 24) {
        SafeLogger.debug('Using cached permission status: $_permissionsGranted', tag: 'NotificationService');
        return _permissionsGranted!;
      }
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? notificationPermissionGranted =
          await androidImplementation?.requestNotificationsPermission();
      // Разрешение на уведомления является обязательным.
      if (notificationPermissionGranted == false) {
        _permissionsGranted = false;
        _lastPermissionCheck = DateTime.now();
        return false;
      }

      // **FIX:** Only request exact alarms permission once
      // On Android 13+ this opens system settings - avoid repeated requests
      final bool? exactAlarmPermissionGranted =
          await androidImplementation?.requestExactAlarmsPermission();

      // На Android < 13 (API 33), `requestExactAlarmsPermission` вернет null,
      // но разрешение считается выданным, если оно есть в манифесте.
      // Поэтому мы считаем `null` или `true` как успех.
      final result = exactAlarmPermissionGranted ?? true;

      _permissionsGranted = result;
      _lastPermissionCheck = DateTime.now();

      SafeLogger.debug('Permission check result: $result (cached)', tag: 'NotificationService');

      return result;
    }
    // Для iOS разрешения запрашиваются при инициализации
    _permissionsGranted = true;
    _lastPermissionCheck = DateTime.now();
    return true;
  }

  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload, // ID воспоминания
  }) async {
    final bool permissionsGranted = await _requestPermissions();

    if (!permissionsGranted) {
      SafeLogger.warning('Notification permissions not granted. Aborting schedule.', tag: 'NotificationService');
      return false;
    }

    try {
      // Convert to timezone-aware datetime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      SafeLogger.debug('Scheduling notification:\n  - Original date: $scheduledDate\n  - Timezone date: $tzScheduledDate\n  - Local timezone: ${tz.local.name}\n  - Current time: ${tz.TZDateTime.now(tz.local)}', tag: 'NotificationService');

      // Ensure we're not scheduling in the past
      final now = tz.TZDateTime.now(tz.local);
      if (tzScheduledDate.isBefore(now)) {
        SafeLogger.warning('Trying to schedule notification in the past. Scheduling for 1 minute from now.', tag: 'NotificationService');
        // Schedule for 1 minute from now if date is in the past
        final adjustedDate = now.add(const Duration(minutes: 1));
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          adjustedDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'lifeline_channel_id',
              'Lifeline Reminders',
              channelDescription: 'Reminders for your action plans',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: payload,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
        return true;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lifeline_channel_id',
            'Lifeline Reminders',
            channelDescription: 'Reminders for your action plans',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } catch (e) {
      SafeLogger.error('Error scheduling notification', error: e, tag: 'NotificationService');
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Show a local notification immediately
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    final bool permissionsGranted = await _requestPermissions();

    if (!permissionsGranted) {
      SafeLogger.warning('Permissions not granted for local notification', tag: 'NotificationService');
      return;
    }

    try {
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'lifeline_channel_id',
            'Lifeline Reminders',
            channelDescription: 'Reminders for your action plans',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        payload: payload,
      );

      SafeLogger.debug('Showed local notification: $title', tag: 'NotificationService');
    } catch (e) {
      SafeLogger.error('Error showing local notification', error: e, tag: 'NotificationService');
    }
  }

  /// Get detailed notification diagnostic information
  /// Returns a map with permission status, pending notifications, and system info
  Future<Map<String, dynamic>> getDiagnosticInfo() async {
    final diagnostics = <String, dynamic>{};

    try {
      // Check notification permissions
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Check if notifications are enabled
          final areNotificationsEnabled = await androidImplementation.areNotificationsEnabled();
          diagnostics['notificationsEnabled'] = areNotificationsEnabled;

          // Check exact alarm permission (Android 13+)
          final canScheduleExactAlarms = await androidImplementation.canScheduleExactNotifications();
          diagnostics['canScheduleExactAlarms'] = canScheduleExactAlarms;
        }
      }

      // Get pending notifications
      final pendingNotifications = await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
      diagnostics['pendingNotificationsCount'] = pendingNotifications.length;
      diagnostics['pendingNotifications'] = pendingNotifications
          .map((n) => {
                'id': n.id,
                'title': n.title,
                'body': n.body,
                'payload': n.payload,
              })
          .toList();

      // Get active notifications
      final activeNotifications = await _flutterLocalNotificationsPlugin.getActiveNotifications();
      diagnostics['activeNotificationsCount'] = activeNotifications.length;

      // Cached permission status
      diagnostics['cachedPermissionStatus'] = _permissionsGranted;
      diagnostics['lastPermissionCheckTime'] = _lastPermissionCheck?.toIso8601String();

      // Timezone info
      diagnostics['currentTimezone'] = tz.local.name;
      diagnostics['currentTime'] = tz.TZDateTime.now(tz.local).toIso8601String();

      SafeLogger.debug('Diagnostic Info: ${diagnostics.entries.map((e) => '${e.key}: ${e.value}').join(', ')}', tag: 'NotificationService');
    } catch (e) {
      diagnostics['error'] = e.toString();
      SafeLogger.error('Error getting diagnostic info', error: e, tag: 'NotificationService');
    }

    return diagnostics;
  }

  /// Test notification - shows immediately for debugging
  Future<bool> sendTestNotification() async {
    try {
      await showLocalNotification(
        id: 999999,
        title: 'Lifeline Test',
        body: 'This is a test notification. Time: ${DateTime.now()}',
        payload: 'test',
      );
      return true;
    } catch (e) {
      SafeLogger.error('Test notification failed', error: e, tag: 'NotificationService');
      return false;
    }
  }
}
