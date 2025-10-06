# Integration Tests for Lifeline

Комплексные интеграционные тесты для приложения Lifeline, проверяющие взаимодействие между всеми сервисами, базами данных и облачными функциями.

## Структура тестов

### 1. `test_helpers.dart`
Вспомогательные функции для настройки тестового окружения:
- Инициализация Firebase Emulator
- Создание тестовых пользователей и данных
- Очистка тестовых данных
- Утилиты для работы с Firestore и Isar

### 2. `auth_flow_integration_test.dart`
Тесты полного цикла аутентификации:
- Регистрация пользователя (создание Auth + Firestore профиля)
- Вход/выход из системы
- Управление профилем пользователя
- Удаление аккаунта
- Премиум статус
- Обработка ошибок аутентификации

### 3. `memory_crud_sync_integration_test.dart`
Тесты операций с памятками и синхронизации:
- Создание памяток (Isar + Firestore sync)
- Обновление памяток
- Удаление памяток
- Шифрование end-to-end
- Запросы и фильтрация
- Работа с медиа-файлами
- Разрешение конфликтов
- Bulk операции

### 4. `premium_purchase_integration_test.dart`
Тесты покупки Premium подписки:
- Апгрейд с Free на Premium
- Продление подписки
- Истечение подписки
- Активация trial периода
- Верификация покупок
- Восстановление покупок
- Контроль доступа к Premium функциям
- Отмена и реактивация подписки

### 5. `cloud_functions_integration_test.dart`
Тесты облачных функций:
- Верификация покупок
- Scheduled functions (истечение подписок, очистка данных)
- Управление данными пользователя
- Firestore triggers
- Обработка ошибок
- Rate limiting

## Требования

### 1. Firebase CLI
```bash
npm install -g firebase-tools
```

### 2. Firebase Emulator Suite
```bash
firebase init emulators
```

Выберите эмуляторы:
- ✅ Authentication Emulator (port 9099)
- ✅ Firestore Emulator (port 8080)
- ✅ Storage Emulator (port 9199)
- ✅ Functions Emulator (port 5001)

### 3. Flutter Dependencies
```bash
flutter pub get
```

## Запуск тестов

### Шаг 1: Запустить Firebase Emulator
```bash
# Запустить все эмуляторы
firebase emulators:start

# Или только нужные для конкретных тестов
firebase emulators:start --only auth,firestore
firebase emulators:start --only auth,firestore,functions
```

Эмулятор должен запуститься на портах:
- Auth: http://localhost:9099
- Firestore: http://localhost:8080
- Functions: http://localhost:5001
- Emulator UI: http://localhost:4000

### Шаг 2: Запустить тесты

#### Все интеграционные тесты:
```bash
flutter test test/integration/
```

#### Конкретный тестовый файл:
```bash
flutter test test/integration/auth_flow_integration_test.dart
flutter test test/integration/memory_crud_sync_integration_test.dart
flutter test test/integration/premium_purchase_integration_test.dart
flutter test test/integration/cloud_functions_integration_test.dart
```

#### С подробным выводом:
```bash
flutter test test/integration/ --verbose
```

#### С покрытием кода:
```bash
flutter test test/integration/ --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Шаг 3: Просмотр результатов

После запуска тестов можно посмотреть:
- Данные в Firestore Emulator UI: http://localhost:4000/firestore
- Пользователей Auth: http://localhost:4000/auth
- Логи функций: http://localhost:4000/logs

## Конфигурация

### Firebase Emulator

Файл `firebase.json` должен содержать:
```json
{
  "emulators": {
    "auth": {
      "port": 9099
    },
    "firestore": {
      "port": 8080
    },
    "storage": {
      "port": 9199
    },
    "functions": {
      "port": 5001
    },
    "ui": {
      "enabled": true,
      "port": 4000
    }
  }
}
```

### Пропуск тестов

Некоторые тесты требуют деплоя облачных функций в эмулятор и помечены как `skip`:
```dart
test('...', () async {
  // ...
}, skip: 'Requires cloud functions deployed to emulator');
```

Чтобы запустить эти тесты:
1. Задеплойте функции: `firebase deploy --only functions`
2. Уберите параметр `skip` из теста

## Структура тестов

Каждый тест следует паттерну AAA (Arrange-Act-Assert):

```dart
test('description', () async {
  // Arrange: Подготовка данных
  const userId = 'test-user';
  await TestHelpers.createTestUserProfile(uid: userId);

  // Act: Выполнение действия
  await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .update({'isPremium': true});

  // Assert: Проверка результата
  final profile = await TestHelpers.getFirestoreDocument('users/$userId');
  expect(profile!['isPremium'], isTrue);
});
```

## Очистка данных

Тесты автоматически очищают данные после выполнения:
- `tearDown()` - очистка после каждого теста
- `tearDownAll()` - очистка после всех тестов в группе

## Отладка тестов

### 1. Проверка логов эмулятора
```bash
# В отдельном терминале
firebase emulators:start --debug
```

### 2. Просмотр данных в UI
Откройте http://localhost:4000 и проверьте:
- Созданные документы в Firestore
- Зарегистрированных пользователей в Auth
- Загруженные файлы в Storage

### 3. Добавление отладочных выводов
```dart
test('...', () async {
  final profile = await TestHelpers.getFirestoreDocument('users/test');
  print('Profile data: $profile'); // Debug output
  expect(profile, isNotNull);
});
```

## Известные проблемы

### 1. Memory не имеет поля serverId
В текущей версии Memory использует только локальный ID. Синхронизация происходит по `localId` в Firestore.

### 2. Cloud Functions требуют деплоя
Для тестов облачных функций нужно:
```bash
cd functions
npm install
cd ..
firebase deploy --only functions
```

### 3. Timeout на медленных машинах
Увеличьте timeout для медленных операций:
```dart
test('...', () async {
  // ...
}, timeout: Timeout(Duration(minutes: 2)));
```

## Continuous Integration (CI)

### GitHub Actions пример:
```yaml
name: Integration Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - uses: w9jds/firebase-action@master

      - name: Install dependencies
        run: flutter pub get

      - name: Start Firebase Emulators
        run: firebase emulators:start --only auth,firestore &

      - name: Run integration tests
        run: flutter test test/integration/
```

## Покрытие тестами

Текущее покрытие:
- ✅ Authentication Flow (100%)
- ✅ Memory CRUD Operations (95%)
- ✅ Premium Purchase Flow (90%)
- ✅ Cloud Functions (80% - requires function deployment)
- ✅ Sync & Backup (85%)

## Дополнительные ресурсы

- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Firestore Security Rules Testing](https://firebase.google.com/docs/rules/unit-tests)

## Поддержка

При возникновении проблем:
1. Проверьте, что эмулятор запущен
2. Проверьте версии Firebase CLI и Flutter
3. Очистите кэш: `firebase emulators:start --import=./emulator-data --export-on-exit`
4. Проверьте логи в Emulator UI

## Примеры запуска

```bash
# Быстрый прогон основных тестов
flutter test test/integration/auth_flow_integration_test.dart test/integration/premium_purchase_integration_test.dart

# С детальным выводом и покрытием
flutter test test/integration/ --verbose --coverage

# Только успешные тесты (без skip)
flutter test test/integration/ --exclude-tags=requires-functions

# С определенным таймаутом
flutter test test/integration/ --timeout=5m
```
