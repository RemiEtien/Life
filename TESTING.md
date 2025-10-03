# Тесты Lifeline

В проекте реализовано **152 автоматических теста**, покрывающих критические части приложения.

## 📊 Статистика тестов

### Flutter Tests (111 тестов)

#### Unit Tests (99):
- **Encryption Service** (9) - AES-GCM шифрование
- **Memory Model** (48) - основная модель данных
- **SyncState** (26) - состояние синхронизации
- **Premium Widgets** (16) - UI компоненты премиум-функций

#### Integration Tests (12):
- **Memory + Encryption + Validation** (12) - полный flow создания воспоминаний

### Cloud Functions Tests (41 тест)

#### Unit Tests (29):
- **Receipt Hash Generation** (5) - SHA-256 хеширование чеков
- **Product ID Validation** (5) - валидация ID продуктов
- **Android Purchase Validation** (7) - проверка покупок Google Play
- **iOS Purchase Validation** (7) - проверка покупок App Store
- **Security & Edge Cases** (5) - безопасность и граничные случаи

#### Integration Tests (12):
- **Purchase Verification Flow** (12) - полный flow обработки покупок

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

# Тесты premium виджетов
flutter test test/widgets/premium_upsell_widgets_test.dart
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

### 4. Premium Widgets (16 тестов)
- ✅ **PremiumBannerCard**: показ/скрытие баннера в зависимости от статуса
- ✅ **PremiumBannerCard**: стилизация и навигация
- ✅ **PremiumFeatureLockTile**: отображение заблокированных функций
- ✅ **PremiumFeatureLockTile**: иконки и серый стиль
- ✅ **PremiumStatusCard**: отображение статуса подписки с датой истечения
- ✅ **PremiumStatusCard**: стилизация с amber рамкой
- ✅ **showPremiumDialog**: диалог с кнопками Cancel и Go Premium
- ✅ **showPremiumDialog**: закрытие и навигация

### 5. Integration Tests: Memory + Encryption (12 тестов)
- ✅ **Encrypt + Preserve Structure**: Шифрование с сохранением структуры и newlines
- ✅ **Validate → Encrypt Flow**: Валидация перед шифрованием
- ✅ **Encrypted Reflections**: Шифрование всех reflection полей
- ✅ **copyWith + Re-encrypt**: Обновление с повторным шифрованием
- ✅ **Joint Validation**: Валидация title и content вместе
- ✅ **Emotions + Encryption**: Эмоции остаются доступны, content зашифрован
- ✅ **Empty Content**: Шифрование пустой строки
- ✅ **Full Workflow**: validate → sanitize → encrypt → store
- ✅ **Media Path Validation**: Проверка путей перед добавлением
- ✅ **Media Order + Encryption**: Порядок медиа при зашифрованном описании
- ✅ **Error Prevention**: copyWith блокирует невалидные данные
- ✅ **Wrong Key Protection**: Неправильный ключ не расшифровывает

### 6. Integration Tests: Purchase Flow (12 тестов)
- ✅ **End-to-End Flow**: Полный flow от валидации до обновления статуса
- ✅ **Yearly Subscription**: Корректная обработка годовой подписки
- ✅ **Duplicate from Same User**: Отклонение повторного использования receipt
- ✅ **Fraud Prevention**: Блокировка использования чужого receipt
- ✅ **Multiple Receipts**: Разные receipts от одного пользователя
- ✅ **Early Rejection**: Инвалидный productId блокируется рано
- ✅ **Expired No Store**: Истёкшая покупка не сохраняет receipt
- ✅ **Unacknowledged Rejection**: Неподтверждённая покупка отклоняется
- ✅ **No Hash Collisions**: Похожие receipts → разные hashes
- ✅ **Missing Data**: Обработка отсутствующих данных
- ✅ **Malformed Expiry**: Некорректный timestamp
- ✅ **Concurrent Purchases**: Одновременные покупки 5 пользователей

### 7. Purchase Verification (Cloud Functions)

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

- [x] Widget tests для Premium UI компонентов ✅
- [ ] Widget tests для других экранов (MemoryEdit, MemoryView, Lifeline)
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
**Всего тестов:** 152 (111 Flutter + 41 Cloud Functions)
**Unit Tests:** 128 | **Integration Tests:** 24
**Статус:** ✅ Все тесты проходят
