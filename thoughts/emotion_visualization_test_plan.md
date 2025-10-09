# План тестирования: Система визуализации эмоций

## Дата: 2025-10-09

---

## 1. Обзор функциональности

Система визуализации эмоций включает:

### Базовые функции (FREE):
- Выбор эмоций в MemoryEditScreen (primary + secondary)
- Отображение эмоций на Timeline (цветные узлы)
- Эмоциональный градиент на линии Timeline (включается в настройках)
- Базовая визуализация в MemoryViewScreen

### PREMIUM функции:
- Частицы в MemoryViewScreen (`enableMemoryViewParticles`)
- Color grading фотографий (`enablePhotoColorGrading`)
- Погодные эффекты на Timeline (`enableWeatherEffects`, только при zoom > 3.0)

---

## 2. Тестовые сценарии

### 2.1. Тест: Выбор эмоций (Emotion Picker)

**Файл:** `lib/screens/memory_edit_screen.dart`

**Шаги:**
1. Открыть создание/редактирование воспоминания
2. Нажать на новый emotion picker (круг с иконкой эмоции)
3. Выбрать primary эмоцию (например, "Joy")
4. Выбрать secondary эмоцию (например, "Love")
5. Настроить интенсивность слайдером
6. Сохранить воспоминание

**Ожидаемое поведение:**
- ✅ Emotion picker отображается как круг с иконкой и цветом эмоции
- ✅ При нажатии открывается bottom sheet с выбором эмоций
- ✅ Primary эмоция выбирается из списка (joy, sadness, anger, fear, disgust, surprise, love, pride)
- ✅ Secondary эмоция опциональна
- ✅ Слайдер intensity от 0.0 до 1.0 (default 0.5)
- ✅ Цвет и иконка обновляются после выбора
- ✅ Данные сохраняются в `primaryEmotion`, `secondaryEmotion`, `emotionIntensity`

---

### 2.2. Тест: Цветные узлы на Timeline

**Файл:** `lib/widgets/lifeline_painter.dart`

**Шаги:**
1. Создать несколько воспоминаний с разными эмоциями:
   - Joy (желтый)
   - Sadness (синий)
   - Anger (красный)
   - Love (розовый)
2. Открыть Timeline
3. Проверить цвет узлов воспоминаний

**Ожидаемое поведение:**
- ✅ Каждый узел окрашен в цвет primary эмоции
- ✅ Joy → желтый/золотой
- ✅ Sadness → синий
- ✅ Anger → красный/оранжевый
- ✅ Love → розовый/пурпурный
- ✅ Воспоминания без эмоций → серый цвет по умолчанию

---

### 2.3. Тест: Эмоциональный градиент на линии Timeline

**Файл:** `lib/widgets/lifeline_painter.dart`, метод `_drawEmotionalGradientLine`

**Шаги:**
1. Создать 5+ воспоминаний с разными эмоциями
2. Открыть Profile → Settings
3. Включить настройку "Emotional Gradient"
4. Вернуться на Timeline
5. Наблюдать линию Timeline

**Ожидаемое поведение:**
- ✅ Когда выключено: линия красная (стандартная)
- ✅ Когда включено: линия показывает плавный градиент от цветов всех эмоций воспоминаний
- ✅ Градиент идет от начала к концу Timeline
- ✅ Цвета плавно переходят друг в друга
- ✅ Используется linear gradient shader
- ✅ Эффект свечения сохраняется (blur layers)

---

### 2.4. Тест: Миграция старого формата эмоций

**Файл:** `lib/memory.dart`, метод `_migrateFromOldFormat`

**Шаги:**
1. Загрузить воспоминание со старым форматом `emotionsData` из Firestore:
   ```json
   {
     "emotionsData": ["joy:80", "love:60", "surprise:40"]
   }
   ```
2. Проверить поля после загрузки

**Ожидаемое поведение:**
- ✅ `primaryEmotion` = "joy" (самая высокая интенсивность)
- ✅ `secondaryEmotion` = "love" (вторая по интенсивности)
- ✅ `emotionIntensity` = 0.8 (80/100)
- ✅ Debug print: `[EMOTION MIGRATION] Migrated: ...`
- ✅ Миграция происходит только если `primaryEmotion == null`

---

### 2.5. Тест: PREMIUM - Частицы в MemoryViewScreen

**Файл:** `lib/widgets/emotion_particles.dart`

**Требования:** PREMIUM подписка

**Шаги:**
1. Открыть Profile → Settings
2. Включить "Memory View Particles" (PREMIUM)
3. Открыть воспоминание с эмоцией Joy
4. Наблюдать анимацию

**Ожидаемое поведение:**
- ✅ Частицы отображаются только если PREMIUM + настройка включена
- ✅ Joy → круглые частицы, всплывают вверх (velocity -0.002)
- ✅ Sadness → капли дождя, падают вниз (velocity 0.003)
- ✅ Anger → искры молнии, быстрое движение (velocity 0.008)
- ✅ Love → сердечки, плавно падают (velocity 0.002)
- ✅ Fear → туман, медленное движение (velocity 0.001)
- ✅ Surprise → звезды
- ✅ Количество частиц: 10-50, зависит от intensity
- ✅ Цвет частиц соответствует эмоции
- ✅ Частицы респавнятся бесконечно (loop animation)

---

### 2.6. Тест: PREMIUM - Color Grading фотографий

**Файл:** `lib/screens/memory_view_screen.dart`, метод `_getColorGradingFilter`

**Требования:** PREMIUM подписка

**Шаги:**
1. Создать воспоминание с фотографией
2. Установить эмоцию Joy (желтый)
3. Установить интенсивность 1.0 (максимум)
4. Открыть Profile → Settings
5. Включить "Photo Color Grading" (PREMIUM)
6. Открыть воспоминание

**Ожидаемое поведение:**
- ✅ Фотография имеет легкий желтый оттенок (overlay blend mode)
- ✅ Opacity filter = `0.15 * intensity`, max 0.3
- ✅ При intensity = 1.0 → opacity = 0.15
- ✅ При intensity = 0.5 → opacity = 0.075
- ✅ Цвет фильтра соответствует primary эмоции
- ✅ Когда выключено: фотография без фильтра
- ✅ ColorFilter применяется через `ColorFiltered` widget

---

### 2.7. Тест: PREMIUM - Погодные эффекты на Timeline

**Файл:** `lib/widgets/timeline_weather_effects.dart`

**Требования:** PREMIUM подписка

**Шаги:**
1. Создать 10+ воспоминаний с эмоцией Sadness
2. Открыть Profile → Settings
3. Включить "Weather Effects" (PREMIUM)
4. Открыть Timeline
5. Увеличить масштаб (zoom) до > 3.0
6. Наблюдать эффекты

**Ожидаемое поведение:**
- ✅ Эффекты НЕ отображаются при zoom < 3.0
- ✅ При zoom > 3.0 появляются погодные частицы
- ✅ Система вычисляет доминирующую эмоцию из видимых воспоминаний
- ✅ Sadness → дождь (капли падают вниз)
- ✅ Joy → sparkles (искры всплывают)
- ✅ Anger → молнии (быстрые искры)
- ✅ Fear → туман (медленный drift)
- ✅ Количество частиц: 10-40, зависит от zoom уровня
- ✅ Формула: `((zoomScale - 3.0) * 20).clamp(10, 40)`
- ✅ Частицы игнорируют pointer events (`IgnorePointer`)

---

### 2.8. Тест: Firestore сериализация

**Файл:** `lib/memory.dart`, методы `toFirestore()` и `fromFirestore()`

**Шаги:**
1. Создать Memory с эмоциями:
   ```dart
   memory
     ..primaryEmotion = 'anger'
     ..secondaryEmotion = 'disgust'
     ..emotionIntensity = 0.9
   ```
2. Вызвать `toFirestore()`
3. Проверить JSON output
4. Загрузить из Firestore с этими полями
5. Проверить восстановленные значения

**Ожидаемое поведение:**
- ✅ `toFirestore()` включает поля:
  - `'primaryEmotion': 'anger'`
  - `'secondaryEmotion': 'disgust'`
  - `'emotionIntensity': 0.9`
- ✅ `fromFirestore()` корректно восстанавливает поля
- ✅ Если поля отсутствуют:
  - `primaryEmotion` = `null`
  - `secondaryEmotion` = `null`
  - `emotionIntensity` = `0.5` (default)
- ✅ Старое поле `emotions` (Map) сохраняется для обратной совместимости

---

### 2.9. Тест: copyWith для эмоций

**Файл:** `lib/memory.dart`, метод `copyWith()`

**Шаги:**
1. Создать Memory с эмоциями
2. Вызвать `copyWith()` с новыми эмоциями:
   ```dart
   updated = original.copyWith(
     primaryEmotion: 'sadness',
     secondaryEmotion: 'fear',
     emotionIntensity: 0.8,
   )
   ```
3. Проверить обновленные значения

**Ожидаемое поведение:**
- ✅ Новые эмоции применяются корректно
- ✅ Другие поля (title, date, etc.) сохраняются
- ✅ Если эмоции не указаны в copyWith → сохраняются старые значения
- ✅ Можно обновить только intensity, оставив emotions теми же

---

### 2.10. Тест: UserProfile настройки

**Файл:** `lib/models/user_profile.dart`

**Шаги:**
1. Открыть Profile → Settings
2. Найти секцию "Emotion Visualization" / "Визуализация эмоций"
3. Проверить наличие toggle switches

**Ожидаемое поведение:**
- ✅ FREE настройки:
  - `enableEmotionalGradient` - градиент на линии Timeline
- ✅ PREMIUM настройки (с badge "PREMIUM"):
  - `enableMemoryViewParticles` - частицы в просмотре воспоминания
  - `enablePhotoColorGrading` - цветокоррекция фотографий
  - `enableWeatherEffects` - погодные эффекты на Timeline
- ✅ Каждая настройка имеет описание
- ✅ Изменения сохраняются в Firestore
- ✅ Эффекты применяются сразу после включения

---

## 3. Проверка производительности

### 3.1. Timeline с большим количеством воспоминаний

**Сценарий:**
- 100+ воспоминаний с разными эмоциями
- Градиент включен
- Погодные эффекты включены (PREMIUM)

**Ожидаемое поведение:**
- ✅ Плавная прокрутка (60 fps)
- ✅ Погодные эффекты появляются только при zoom > 3.0
- ✅ Градиент рендерится эффективно (кэширование в `_updateStructureCache`)
- ✅ Количество частиц адаптируется к zoom уровню

### 3.2. Particle System в MemoryViewScreen

**Сценарий:**
- Эмоция с intensity = 1.0 (50 частиц)
- Particles включены (PREMIUM)

**Ожидаемое поведение:**
- ✅ Анимация плавная (60 fps)
- ✅ Частицы не перекрывают UI
- ✅ `IgnorePointer` не блокирует взаимодействие с контентом
- ✅ Animation controller корректно dispose при выходе

---

## 4. Граничные случаи (Edge Cases)

### 4.1. Воспоминание без эмоций
- ✅ `primaryEmotion = null`
- ✅ Узел на Timeline → серый цвет
- ✅ Частицы НЕ отображаются в MemoryView
- ✅ Color grading НЕ применяется
- ✅ В emotion picker отображается "Not set" / "Не выбрано"

### 4.2. Только secondary эмоция (без primary)
- ✅ Это невалидное состояние - не должно возникать
- ✅ UI должен требовать primary перед secondary
- ✅ Если все же возникает: secondary игнорируется

### 4.3. Intensity = 0.0
- ✅ Частицы: минимум 10 частиц
- ✅ Color grading: opacity → 0.0 (нет эффекта)
- ✅ Цвет узла: тусклый вариант эмоции

### 4.4. Intensity = 1.0
- ✅ Частицы: максимум 50 частиц
- ✅ Color grading: opacity → 0.15 (clamped to 0.3 max)
- ✅ Цвет узла: яркий насыщенный

### 4.5. FREE пользователь пытается включить PREMIUM функции
- ✅ Toggle switch заблокирован
- ✅ Отображается badge "PREMIUM"
- ✅ При нажатии → показать upsell диалог

---

## 5. Чек-лист перед релизом

- [ ] Все unit тесты проходят (`flutter test test/memory_emotion_test.dart`)
- [ ] Миграция старых данных работает корректно
- [ ] PREMIUM функции корректно gated
- [ ] Настройки сохраняются и применяются
- [ ] Производительность на слабых устройствах приемлемая
- [ ] Color grading не слишком интенсивный (max opacity проверен)
- [ ] Погодные эффекты не мешают видимости Timeline
- [ ] Particle animations не вызывают lag
- [ ] Код документирован (комментарии для ключевых методов)
- [ ] Нет console errors/warnings
- [ ] Firestore rules позволяют новые поля emotion
- [ ] Backward compatibility: старые клиенты могут читать новые данные

---

## 6. Известные ограничения

1. **copyWith не может очистить nullable поля** - это ограничение Dart, требуется обходной путь (создание нового Memory)
2. **Web не поддерживается** - Isar имеет проблемы с JS integer precision
3. **Погодные эффекты только при zoom > 3.0** - для производительности
4. **Количество частиц ограничено** - максимум 50 для производительности

---

## 7. Следующие шаги (Future Enhancements)

- [ ] Больше эмоций (anticipation, trust, etc.)
- [ ] Комбинированные эмоции (joy+surprise = деlight)
- [ ] AI анализ текста для автоматического определения эмоций
- [ ] Статистика эмоций (графики, тренды)
- [ ] Эмоциональные insights ("Вы часто чувствуете радость по вторникам")
- [ ] Экспорт эмоциональной истории
- [ ] Больше particle эффектов (снег, листья, конфетти)
- [ ] Настройка intensity particles отдельно от emotion intensity

---

**Автор:** Claude
**Версия системы:** 1.0
**Дата последнего обновления:** 2025-10-09
