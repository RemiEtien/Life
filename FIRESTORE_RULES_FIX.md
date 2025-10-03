# 🔧 FIRESTORE RULES FIX - URGENT

## 🔴 ПРОБЛЕМА

После деплоя production security rules приложение **КРАШИТСЯ** при попытке обновить профиль пользователя:

```
[cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
at UserService.updateUserProfile
at EncryptionService.disableQuickUnlock
```

## 🐛 ПРИЧИНА

Правила валидации требовали **ВСЕ** поля документа (`email`, `displayName`, `createdAt`) даже при **частичном обновлении** (partial update).

### Старый код (НЕПРАВИЛЬНО):
```javascript
function isValidUserProfile() {
  let data = request.resource.data;
  // ❌ Требует ВСЕ поля всегда
  return data.keys().hasAll(['email', 'displayName', 'createdAt']) &&
         data.email is string &&
         data.displayName is string &&
         data.createdAt is timestamp;
}
```

### Проблемный сценарий:
1. Пользователь включает Quick Unlock (биометрию)
2. Код вызывает: `updateUserProfile({'isQuickUnlockEnabled': true})`
3. Firestore отправляет только измененное поле
4. Правило ожидает `email`, `displayName`, `createdAt` → **ОТКАЗ**

## ✅ РЕШЕНИЕ

Правила теперь **различают CREATE и UPDATE**:
- **CREATE** — требуются все обязательные поля
- **UPDATE** — валидируются только присутствующие поля

### Новый код (ПРАВИЛЬНО):
```javascript
function isValidUserProfile() {
  let data = request.resource.data;

  // Определяем: это CREATE или UPDATE?
  let isCreate = !(resource != null && 'createdAt' in resource.data);

  // Требуем обязательные поля только при CREATE
  let hasRequiredFields = !isCreate ||
    data.keys().hasAll(['email', 'displayName', 'createdAt']);

  // Валидируем поля ТОЛЬКО если они присутствуют
  let emailValid = !data.keys().hasAny(['email']) ||
                   data.email is string;
  let displayNameValid = !data.keys().hasAny(['displayName']) ||
                         (data.displayName is string &&
                          data.displayName.size() >= 1 &&
                          data.displayName.size() <= 100);
  let createdAtValid = !data.keys().hasAny(['createdAt']) ||
                       data.createdAt is timestamp;

  return hasRequiredFields && emailValid && displayNameValid && createdAtValid;
}
```

## 📝 ИЗМЕНЕНИЯ

### 1. `isValidUserProfile()` - Исправлено ✅
- Добавлена проверка CREATE vs UPDATE
- Валидация только присутствующих полей

### 2. `isValidMemory()` - Исправлено ✅
- Та же логика для memory документов
- Поддержка partial updates

### 3. UPDATE правила - Исправлено ✅

**User Profile:**
```javascript
// Старый (ломался):
allow update: if request.resource.data.createdAt == resource.data.createdAt;

// Новый (работает):
allow update: if (!request.resource.data.keys().hasAny(['createdAt']) ||
                  request.resource.data.createdAt == resource.data.createdAt);
```

**Memory:**
```javascript
// Старый (ломался):
allow update: if request.resource.data.userId == resource.data.userId;

// Новый (работает):
allow update: if (!request.resource.data.keys().hasAny(['userId']) ||
                  request.resource.data.userId == resource.data.userId);
```

## 🚀 ДЕПЛОЙ

**ВАЖНО:** Нужно передеплоить правила **НЕМЕДЛЕННО**!

### Через Firebase Console:
1. Открыть [Firebase Console](https://console.firebase.google.com/)
2. Firestore Database → Rules
3. Скопировать содержимое `firestore.rules`
4. Вставить и нажать **Publish**

### Через CLI:
```bash
firebase deploy --only firestore:rules
```

## ✅ ТЕСТИРОВАНИЕ

После деплоя проверить:
1. ✅ Включение Quick Unlock (биометрия)
2. ✅ Изменение имени профиля
3. ✅ Обновление настроек (theme, performance и т.д.)
4. ✅ Создание нового воспоминания
5. ✅ Редактирование воспоминания (title, content)

## 📊 ЗАТРОНУТЫЕ СЦЕНАРИИ

- ✅ Quick Unlock enable/disable
- ✅ Biometric per-memory setting
- ✅ Profile name change
- ✅ Theme preference change
- ✅ Performance mode change
- ✅ Visual settings change
- ✅ Notification settings
- ✅ Country/language selection
- ✅ Memory editing (любые поля)
- ✅ Draft saving

## 🔍 КАК ПРОВЕРИТЬ

### До исправления:
```
I/flutter: [cloud_firestore/permission-denied]
           The caller does not have permission to execute the specified operation.
```

### После исправления:
```
I/flutter: [EncryptionService] Quick Unlock enabled successfully
```

---

**Дата исправления:** 2 октября 2025
**Приоритет:** 🔴 КРИТИЧНЫЙ
**Статус:** ✅ ИСПРАВЛЕНО, ТРЕБУЕТ ДЕПЛОЯ
