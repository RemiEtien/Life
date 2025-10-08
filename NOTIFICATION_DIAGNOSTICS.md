# Диагностика проблем с уведомлениями

## Проблема
На втором тестовом девайсе (версия 145) уведомления вообще не приходят, несмотря на то что разрешения выданы в Android и в настройках профиля.

## Реализованные инструменты диагностики

Добавлены два новых метода в `NotificationService` для диагностики проблем:

### 1. `getDiagnosticInfo()`
Возвращает детальную информацию о состоянии уведомлений:
- `notificationsEnabled` - включены ли уведомления на уровне Android
- `canScheduleExactAlarms` - разрешение на точные алармы (Android 13+)
- `pendingNotificationsCount` - количество запланированных уведомлений
- `pendingNotifications` - список всех запланированных уведомлений
- `activeNotificationsCount` - количество активных уведомлений
- `cachedPermissionStatus` - закешированный статус разрешений
- `lastPermissionCheckTime` - время последней проверки разрешений
- `currentTimezone` - текущая временная зона
- `currentTime` - текущее время

### 2. `sendTestNotification()`
Отправляет тестовое уведомление немедленно для проверки работоспособности.

## Как использовать

### Вариант 1: Через Flutter DevTools Console
```dart
// Получить диагностическую информацию
final notificationService = NotificationService();
await notificationService.init();
final diagnostics = await notificationService.getDiagnosticInfo();
print(diagnostics);

// Отправить тестовое уведомление
final success = await notificationService.sendTestNotification();
print('Test notification sent: $success');
```

### Вариант 2: Добавить в UI профиля (рекомендуется для отладки)

Можно добавить кнопку в ProfileScreen для тестирования:

```dart
// Добавить в build метод ProfileScreen
if (kDebugMode)
  ListTile(
    leading: Icon(Icons.bug_report),
    title: Text('Test Notifications'),
    onTap: () async {
      final notificationService = ref.read(notificationServiceProvider);

      // Показать диагностику
      final diagnostics = await notificationService.getDiagnosticInfo();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Notification Diagnostics'),
          content: SingleChildScrollView(
            child: Text(
              diagnostics.entries
                  .map((e) => '${e.key}: ${e.value}')
                  .join('\n\n'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await notificationService.sendTestNotification();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                      ? 'Test notification sent!'
                      : 'Failed to send test notification'),
                  ),
                );
              },
              child: Text('Send Test'),
            ),
          ],
        ),
      );
    },
  ),
```

## Частые причины проблем с уведомлениями

### 1. Разрешение SCHEDULE_EXACT_ALARM (Android 13+)
**Проблема:** На Android 13+ (API 33) требуется специальное разрешение на точные алармы.

**Диагностика:**
- Проверить `canScheduleExactAlarms` в `getDiagnosticInfo()`
- Должно быть `true`

**Решение:**
1. Открыть Settings → Apps → Lifeline → Alarms & reminders
2. Включить "Allow setting alarms and reminders"

### 2. Battery Optimization
**Проблема:** Android агрессивно оптимизирует батарею и убивает фоновые задачи.

**Диагностика:**
- Проверить количество `pendingNotifications` - если 0, уведомления не были запланированы
- Логи в console должны показывать `[BackgroundWorker] Task started`

**Решение:**
1. Settings → Battery → Battery optimization
2. Найти Lifeline → Don't optimize

### 3. WorkManager Constraints
**Проблема:** WorkManager требует выполнения условий (constraints) для запуска задачи.

**Текущие constraints:**
- `networkType: NetworkType.connected` - требуется подключение к сети
- `requiresBatteryNotLow: true` - батарея не должна быть на низком уровне

**Диагностика:**
- Проверить подключение к Wi-Fi или мобильной сети
- Проверить уровень батареи > 15%

**Решение:**
- Убедиться что девайс подключен к сети
- Зарядить батарею выше 15%

### 4. Notification Channel
**Проблема:** Канал уведомлений может быть отключен в настройках Android.

**Решение:**
1. Settings → Apps → Lifeline → Notifications
2. Включить "Lifeline Reminders"
3. Установить importance на High

### 5. Do Not Disturb режим
**Проблема:** Режим "Не беспокоить" может блокировать уведомления.

**Решение:**
1. Проверить Quick Settings → Do Not Disturb (должно быть выключено)
2. Или добавить Lifeline в исключения DND

### 6. App Standby Buckets (Android 9+)
**Проблема:** Android распределяет приложения по "buckets" и ограничивает фоновую активность.

**Решение:**
1. Регулярно открывать приложение
2. Или в настройках разработчика: Settings → Developer options → Standby apps → Active

## Пошаговая диагностика на проблемном девайсе

1. **Запустить диагностику:**
   ```dart
   final diagnostics = await notificationService.getDiagnosticInfo();
   ```

2. **Проверить ключевые параметры:**
   - `notificationsEnabled` = true?
   - `canScheduleExactAlarms` = true?
   - `pendingNotificationsCount` > 0?

3. **Отправить тестовое уведомление:**
   ```dart
   await notificationService.sendTestNotification();
   ```
   - Если появилось - проблема в планировании
   - Если не появилось - проблема в разрешениях

4. **Проверить логи:**
   - Искать `[NotificationService]` в Flutter console
   - Искать `[BackgroundWorker]` в Flutter console
   - Проверить есть ли ошибки

5. **Проверить системные настройки:**
   - Settings → Apps → Lifeline → Permissions → Notifications: Allowed
   - Settings → Apps → Lifeline → Alarms & reminders: Allowed (Android 13+)
   - Settings → Apps → Lifeline → Battery → Unrestricted

## Версии Android и особенности

- **Android 12 (API 31):** Новые ограничения на AlarmManager
- **Android 13 (API 33):** Требуется `POST_NOTIFICATIONS` runtime permission
- **Android 13 (API 33):** Требуется `SCHEDULE_EXACT_ALARM` для точных уведомлений
- **Android 14 (API 34):** Более строгие ограничения на фоновые задачи

## Решения для production

Если проблемы продолжаются, рассмотреть:

1. **Убрать constraints для WorkManager:**
   ```dart
   constraints: Constraints(
     // networkType: NetworkType.connected,  // Убрать
     // requiresBatteryNotLow: true,         // Убрать
   ),
   ```

2. **Использовать AlarmManager вместо WorkManager** для критичных уведомлений (action plans)

3. **Добавить Foreground Service** для более надежной доставки

4. **Показывать in-app подсказки** о настройке разрешений

## Локация изменений

- `lib/services/notification_service.dart:261-340` - Новые методы диагностики
  - `getDiagnosticInfo()` - детальная информация
  - `sendTestNotification()` - тестовое уведомление
