# Тесты Lifeline

В проекте реализовано **112 автоматических тестов**, покрывающих критические части приложения.

## 📊 Статистика тестов

### Flutter Tests (83 теста)
- **Encryption Service** (9 тестов) - AES-GCM шифрование
- **Memory Model** (48 тестов) - основная модель данных
- **SyncState** (26 тестов) - состояние синхронизации

### Cloud Functions Tests (29 тестов)
- **Receipt Hash Generation** (5 тестов) - SHA-256 хеширование чеков
- **Product ID Validation** (5 тестов) - валидация ID продуктов
- **Android Purchase Validation** (7 тестов) - проверка покупок Google Play
- **iOS Purchase Validation** (7 тестов) - проверка покупок App Store
- **Security & Edge Cases** (5 тестов) - безопасность и граничные случаи

## 🚀 Запуск тестов

### Все Flutter тесты
```bash
flutter test
```

### Отдельные тесты Flutter
```bash
# Тесты шифрования
flutter test test/services/encryption_service_test.dart

# Тесты модели Memory
flutter test test/models/memory_test.dart

# Тесты синхронизации
flutter test test/services/sync_service_test.dart
```

### Cloud Functions тесты
```bash
cd functions
npm test
```

### Все тесты разом
```bash
# Flutter тесты
flutter test

# Cloud Functions тесты (в отдельном терминале)
cd functions && npm test
```

## ✅ Что покрыто тестами

### 1. Шифрование (Encryption Service)
- ✅ Корректное шифрование/расшифрование AES-GCM
- ✅ Сохранение переносов строк в зашифрованном тексте
- ✅ Разные IV генерируют разные шифртексты
- ✅ Неправильный ключ не может расшифровать
- ✅ Обработка пустых строк и Unicode символов
- ✅ Формат payload: `gcm_v1:IV:CIPHER`
- ✅ Валидация Base64 кодирования

### 2. Модель Memory
- ✅ Базовые свойства и дефолтные значения
- ✅ Getter/Setter для эмоций (emotionsData ↔ Map)
- ✅ Вычисление valence (эмоциональной окраски)
- ✅ Подсчёт insight score
- ✅ Cover path helpers
- ✅ copyWith() с валидацией
- ✅ Сортировка медиафайлов по ключам
- ✅ getFileKey() helper функция

### 3. SyncState
- ✅ Создание состояния с дефолтными/кастомными значениями
- ✅ copyWith() для всех полей
- ✅ Immutability
- ✅ Типичные workflow состояния (idle, syncing, paused, complete, failed)
- ✅ Progress значения (0.0, 0.1, 0.3, 0.6, 0.8, 0.9, 1.0)
- ✅ Status сообщения
- ✅ Edge cases (отрицательные значения, progress > 1.0)

### 4. Purchase Verification (Cloud Functions)

#### Receipt Hash (SHA-256)
- ✅ Консистентное хеширование
- ✅ Предотвращение коллизий (vs старого substring подхода)
- ✅ Обработка пустых строк и Unicode
- ✅ Детерминированность (одинаковый hash для одного receipt)

#### Product ID Validation
- ✅ Валидные ID: `lifeline_premium_monthly`, `lifeline_premium_yearly`
- ✅ Отклонение невалидных ID
- ✅ Case-sensitive проверка
- ✅ Защита от SQL injection

#### Android Purchases (Google Play)
- ✅ Валидация корректной покупки
- ✅ Отклонение истёкших подписок
- ✅ Проверка purchaseState (0 = PURCHASED)
- ✅ Проверка acknowledgementState (1 = ACKNOWLEDGED)
- ✅ Обработка отсутствующих полей
- ✅ Edge case: покупка истекает ровно сейчас

#### iOS Purchases (App Store)
- ✅ Валидация корректной покупки
- ✅ Проверка bundle ID (`com.momentic.lifeline`)
- ✅ Отклонение истёкших подписок
- ✅ Фильтрация по productId
- ✅ Выбор самой новой транзакции
- ✅ Обработка пустых receipt_info
- ✅ Множественные транзакции (expired + valid)

#### Security
- ✅ Детерминированное хеширование (100 итераций)
- ✅ Обработка очень длинных receipt строк (10000 символов)
- ✅ Timestamp валидация (string и number)

## 🛡️ Критические уязвимости, покрытые тестами

### 1. Receipt Replay Attack (CRITICAL - исправлено)
**Проблема:** Один receipt мог использоваться многократно
**Решение:** SHA-256 хеширование + Firestore deduplication
**Тесты:**
- ✅ Хеш одинаковый для одного receipt
- ✅ Хеш разный для разных receipt
- ✅ Предотвращение коллизий

### 2. Product ID Injection (HIGH - исправлено)
**Проблема:** Не было валидации productId
**Решение:** Whitelist проверка
**Тесты:**
- ✅ Только 2 валидных ID принимаются
- ✅ SQL injection отклоняется

### 3. Bundle ID Spoofing (HIGH - исправлено)
**Проблема:** Не проверялся bundle_id в iOS receipts
**Решение:** Строгая проверка `com.momentic.lifeline`
**Тесты:**
- ✅ Неправильный bundle ID отклоняется

### 4. Expired Purchase Acceptance (CRITICAL - исправлено)
**Проблема:** Не проверялся expiry time
**Решение:** Проверка timestamp
**Тесты:**
- ✅ Android: истёкшие покупки отклоняются
- ✅ iOS: истёкшие транзакции отклоняются
- ✅ Edge case: покупка истекающая ровно сейчас

### 5. Wrong Product Purchase (MEDIUM - исправлено)
**Проблема:** Можно было использовать receipt другого продукта
**Решение:** Фильтрация по productId
**Тесты:**
- ✅ iOS: фильтрация latest_receipt_info по productId
- ✅ Выбор правильной транзакции из нескольких

## 📝 Примеры запуска

### Быстрая проверка после изменений
```bash
# Запустить только изменённые тесты
flutter test test/models/memory_test.dart

# С verbose выводом
flutter test --verbose

# С coverage
flutter test --coverage
```

### CI/CD интеграция
```yaml
# .github/workflows/tests.yml
name: Tests
on: [push, pull_request]
jobs:
  flutter-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test

  functions-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '20'
      - run: cd functions && npm install && npm test
```

## 🎯 Что НЕ покрыто (для будущих улучшений)

- [ ] Widget tests для UI компонентов
- [ ] Integration tests с реальным Firestore
- [ ] E2E тесты для полного user flow
- [ ] Performance tests для больших объёмов данных
- [ ] Mock тесты для SyncService (требует сложных моков)
- [ ] Rate limiting тесты (требуют временных задержек)

## 📚 Дополнительная информация

### Технологии
- **Flutter Tests:** `flutter_test` package
- **Cloud Functions Tests:** Jest 29.7.0
- **Assertions:** `expect()` API

### Соглашения
- Названия тестов описывают поведение (BDD style)
- Arrange-Act-Assert pattern
- Группировка по функциональности (`group()` / `describe()`)
- Edge cases выделены в отдельные группы

### Полезные команды
```bash
# Flutter coverage report
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html

# Jest coverage
cd functions && npm test -- --coverage

# Watch mode для разработки
flutter test --watch  # (не поддерживается из коробки, нужен плагин)
cd functions && npm test -- --watch
```

---

**Последнее обновление:** 2025-10-03
**Всего тестов:** 112 (83 Flutter + 29 Cloud Functions)
**Статус:** ✅ Все тесты проходят
