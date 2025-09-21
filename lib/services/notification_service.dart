import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

// Поток для передачи события нажатия на уведомление
final StreamController<String?> onNotificationTap = StreamController.broadcast();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

    // ИЗМЕНЕНО: Добавлен обработчик onDidReceiveNotificationResponse
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          // Отправляем payload (ID воспоминания) в поток
          onNotificationTap.add(response.payload);
        }
      },
    );
    tz.initializeTimeZones();
  }

  Future<bool> _requestPermissions() async {
    // Для Android 13+ требуется явное разрешение на уведомления
    if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        final bool? notificationPermissionGranted =
            await androidImplementation?.requestNotificationsPermission();
        if (notificationPermissionGranted == false) return false;

        final bool? exactAlarmPermissionGranted =
            await androidImplementation?.requestExactAlarmsPermission();
        return exactAlarmPermissionGranted ?? false;
    }
    // Для iOS разрешения запрашиваются при инициализации
    return true;
  }

  // ИЗМЕНЕНО: Метод теперь принимает payload
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
        print("Notification permissions not granted. Aborting schedule.");
      }
      return false;
    }

    try {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
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
        payload: payload, // Передаем payload
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // ИСПРАВЛЕНО: Этот параметр устарел и удален в новой версии пакета
        // uiLocalNotificationDateInterpretation:
        //     UILocalNotificationDateInterpretation.absoluteTime,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Error scheduling notification: $e");
      }
      return false;
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}

