import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

// Поток для передачи события нажатия на уведомление
final StreamController<String?> onNotificationTap = StreamController.broadcast();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

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
          onNotificationTap.add(response.payload);
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

      if (kDebugMode) {
        debugPrint('[NotificationService] Set local timezone to: $timezoneName');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NotificationService] Failed to set local timezone: $e. Using UTC.');
      }
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
        if (kDebugMode) {
          debugPrint(
              '[NotificationService] Using cached permission status: $_permissionsGranted');
        }
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

      if (kDebugMode) {
        debugPrint(
            '[NotificationService] Permission check result: $result (cached)');
      }

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
      if (kDebugMode) {
        debugPrint('Notification permissions not granted. Aborting schedule.');
      }
      return false;
    }

    try {
      // Convert to timezone-aware datetime
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      if (kDebugMode) {
        debugPrint('[NotificationService] Scheduling notification:');
        debugPrint('  - Original date: $scheduledDate');
        debugPrint('  - Timezone date: $tzScheduledDate');
        debugPrint('  - Local timezone: ${tz.local.name}');
        debugPrint('  - Current time: ${tz.TZDateTime.now(tz.local)}');
      }

      // Ensure we're not scheduling in the past
      final now = tz.TZDateTime.now(tz.local);
      if (tzScheduledDate.isBefore(now)) {
        if (kDebugMode) {
          debugPrint('[NotificationService] Warning: Trying to schedule notification in the past. Scheduling for 1 minute from now.');
        }
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
      if (kDebugMode) {
        debugPrint('Error scheduling notification: $e');
      }
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}

