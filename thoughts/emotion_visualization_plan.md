# План реализации эмоциональной визуализации (Гибридный подход)

## 🎯 Цель
Создать уникальную трехуровневую систему эмоциональной визуализации с гибкими настройками.

## 🧠 Философия дизайна

### Ключевые принципы:
1. **Опциональность** — эмоции не обязательны при создании воспоминания
2. **Гибкость** — все эффекты можно отключить в настройках
3. **Градация** — от минимализма до полного погружения
4. **Performance First** — красота не должна убивать производительность

### "Выцветшие воспоминания"
Воспоминания без эмоций выглядят как старые черно-белые фотографии:
- Серый цвет с opacity 0.3-0.4
- Отсутствие ауры и эффектов
- Мотивация: добавить цвет = "проявить" воспоминание

## 📋 Концепция

### Три уровня визуализации

#### 1. Timeline (Lifeline) — Макро-уровень
- **Градиентная окраска линии** — эмоциональный ландшафт жизни
- **Аура вокруз узлов** — свечение в цвете эмоции
- **Погодные эффекты** (zoom > 3.0) — частицы для полного погружения

#### 2. Memory View Screen — Полное погружение
- **Эмоциональный градиент фона** — атмосфера воспоминания
- **Анимированные частицы** — дождь/снег/искры на экране
- **Цветовая коррекция фото** — subtle color grading

#### 3. Emotional Timeline Export — Аналитика
- Экспорт эмоциональной карты (PNG/PDF)
- Статистика по эмоциям
- Обнаружение паттернов

### Эмоциональная палитра (8 базовых эмоций)

```dart
class EmotionColors {
  static const joy = HSLColor.fromAHSL(1.0, 48, 1.0, 0.5);      // ☀️ желтый
  static const sadness = HSLColor.fromAHSL(1.0, 208, 0.9, 0.6);  // 🌧️ синий
  static const anger = HSLColor.fromAHSL(1.0, 0, 0.8, 0.55);    // ⛈️ красный
  static const fear = HSLColor.fromAHSL(1.0, 120, 0.4, 0.45);   // 🌫️ зеленый
  static const disgust = HSLColor.fromAHSL(1.0, 90, 0.6, 0.4);  // 🍂 зелено-желтый
  static const surprise = HSLColor.fromAHSL(1.0, 30, 0.9, 0.6); // ✨ оранжевый
  static const love = HSLColor.fromAHSL(1.0, 330, 0.8, 0.5);    // 🌸 розовый
  static const neutral = HSLColor.fromAHSL(1.0, 0, 0, 0.5);     // 😐 серый
}
```

## 🎨 Визуальные эффекты (погодные)

### При zoom in (> 3.0x):

| Эмоция | Погодный эффект | Particle System |
|--------|----------------|-----------------|
| 😊 Joy | ☀️ Солнечный день | Золотые sparkles, light rays |
| ❤️ Love | 🌸 Весна | Розовые лепестки, сердечки |
| 😌 Peace | ❄️ Легкий снег | Снежинки, мягкое свечение |
| 😢 Sadness | 🌧️ Дождь | Капли дождя, тучи |
| 😡 Anger | ⛈️ Гроза | Молнии, красные искры |
| 😨 Fear | 🌫️ Туман | Fog, тени, distortion |
| 🤮 Disgust | 🍂 Осень | Коричневые листья |
| 😲 Surprise | ✨ Фейерверк | Вспышки, звезды |

## 📐 Архитектура

### 1. Модель данных

```dart
// Добавить в Memory модель (lib/memory.dart)
class Memory {
  // ... existing fields

  // НОВЫЕ ПОЛЯ для эмоций:
  String? primaryEmotion;    // 'joy' | 'sadness' | 'anger' | ... (nullable!)
  String? secondaryEmotion;  // для смешанных чувств (nullable!)
  double emotionIntensity = 0.5;  // 0.0 (слабо) - 1.0 (сильно)

  // МИГРАЦИЯ: оставляем старое поле для совместимости
  List<String> emotionsData = [];  // будет deprecated

  @ignore
  Map<String, int> get emotions {
    // Конвертируем старый формат в новый при первом чтении
    if (emotionsData.isNotEmpty && primaryEmotion == null) {
      _migrateFromOldFormat();
    }
    return {...};  // старый геттер для совместимости
  }
}

enum EmotionType {
  joy,       // ☀️ Радость
  sadness,   // 🌧️ Грусть
  anger,     // ⛈️ Гнев
  fear,      // 🌫️ Страх
  disgust,   // 🍂 Отвращение
  surprise,  // ✨ Удивление
  love,      // 🌸 Любовь
  neutral,   // 😐 Нейтральное
}
```

**Миграция старых данных:**
```dart
void _migrateFromOldFormat() {
  if (emotionsData.isEmpty) return;

  final oldEmotions = emotions;  // Map<String, int>

  // Берем эмоцию с максимальной интенсивностью
  final sorted = oldEmotions.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  if (sorted.isNotEmpty) {
    primaryEmotion = sorted.first.key;
    emotionIntensity = sorted.first.value / 100.0; // 0-100 → 0.0-1.0
  }

  if (sorted.length > 1) {
    secondaryEmotion = sorted[1].key;
  }
}
```

### 2. Настройки пользователя (UserProfile)

```dart
// В lib/models/user_profile.dart добавить:
class UserProfile {
  // ... existing fields

  // === EMOTION VISUALIZATION SETTINGS ===

  // Timeline (Lifeline) Settings
  bool enableEmotionalGradient = true;      // Градиент на линии (DEFAULT: ON)
  bool enableNodeAura = true;               // Аура вокруз узлов (DEFAULT: ON)
  bool enableWeatherEffects = false;        // Погодные частицы (DEFAULT: OFF)

  // Memory View Screen Settings
  bool enableMemoryViewGradient = true;     // Фон экрана воспоминания (DEFAULT: ON)
  bool enableMemoryViewParticles = false;   // Анимированные частицы (DEFAULT: OFF)
  bool enablePhotoColorGrading = false;     // Цветовая коррекция фото (DEFAULT: OFF)

  // Performance
  bool enableHighQualityEffects = true;     // Высокое качество (DEFAULT: ON)
}
```

**Логика для слабых устройств:**
```dart
// В device_performance_detector.dart:
if (DevicePerformanceDetector.performance == DevicePerformance.low) {
  userProfile.enableWeatherEffects = false;
  userProfile.enableMemoryViewParticles = false;
  userProfile.enableHighQualityEffects = false;
}
```

### 3. UI для выбора эмоций

**ЗАМЕНА текущего UI в memory_edit_screen.dart:**

Вместо множественных ChoiceChip (строки 1547-1583):
```dart
// НОВЫЙ UI: Круговой пикер + слайдер
Widget _buildEmotionSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('🎨 Эмоциональная окраска', style: TextStyle(fontSize: 16)),
      SizedBox(height: 8),

      // Если эмоция не выбрана — показываем мотивацию
      if (_primaryEmotion == null)
        _buildEmotionPrompt()
      else
        _buildSelectedEmotionView(),

      SizedBox(height: 12),

      // Круговой пикер (8 иконок)
      _buildCircularEmotionPicker(),
    ],
  );
}

Widget _buildEmotionPrompt() {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade800.withOpacity(0.3),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.lightbulb_outline, color: Colors.yellow.shade700),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'Добавьте эмоцию, чтобы увидеть воспоминание в цвете на жизненной линии!',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSelectedEmotionView() {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: _getEmotionColor(_primaryEmotion!).withOpacity(0.2),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${_getEmotionIcon(_primaryEmotion!)} ${_getEmotionName(_primaryEmotion!)}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.clear, size: 20),
              onPressed: () => setState(() {
                _primaryEmotion = null;
                _secondaryEmotion = null;
              }),
            ),
          ],
        ),

        // Вторичная эмоция (опционально)
        if (_secondaryEmotion != null)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Text('+ ${_getEmotionIcon(_secondaryEmotion!)} ${_getEmotionName(_secondaryEmotion!)}'),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _secondaryEmotion = null),
                ),
              ],
            ),
          )
        else
          TextButton.icon(
            onPressed: _showSecondaryEmotionPicker,
            icon: Icon(Icons.add, size: 16),
            label: Text('Добавить вторую эмоцию'),
          ),

        SizedBox(height: 12),

        // Слайдер интенсивности
        Text('Интенсивность: ${(_emotionIntensity * 100).round()}%'),
        Slider(
          value: _emotionIntensity,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          onChanged: (value) => setState(() => _emotionIntensity = value),
        ),
      ],
    ),
  );
}

Widget _buildCircularEmotionPicker() {
  final emotions = ['joy', 'love', 'surprise', 'pride', 'sadness', 'anger', 'fear', 'disgust'];

  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: emotions.map((emotion) {
      final isSelected = _primaryEmotion == emotion;
      return GestureDetector(
        onTap: () => setState(() {
          _primaryEmotion = emotion;
          _emotionIntensity = 0.5; // default
        }),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isSelected
                ? _getEmotionColor(emotion).withOpacity(0.3)
                : Colors.grey.shade800.withOpacity(0.3),
            borderRadius: BorderRadius.circular(30),
            border: isSelected
                ? Border.all(color: _getEmotionColor(emotion), width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              _getEmotionIcon(emotion),
              style: TextStyle(fontSize: 28),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// Хелперы
String _getEmotionIcon(String emotion) {
  switch (emotion) {
    case 'joy': return '☀️';
    case 'sadness': return '🌧️';
    case 'anger': return '⚡';
    case 'fear': return '🌫️';
    case 'disgust': return '🍂';
    case 'surprise': return '✨';
    case 'love': return '❤️';
    case 'pride': return '🏆';
    default: return '😐';
  }
}

Color _getEmotionColor(String emotion) {
  switch (emotion) {
    case 'joy': return Colors.yellow.shade700;
    case 'sadness': return Colors.blue.shade600;
    case 'anger': return Colors.red.shade700;
    case 'fear': return Colors.green.shade700;
    case 'disgust': return Colors.lime.shade700;
    case 'surprise': return Colors.orange.shade700;
    case 'love': return Colors.pink.shade400;
    case 'pride': return Colors.purple.shade400;
    default: return Colors.grey;
  }
}
```

### 3. Визуализация на timeline

#### Макро-уровень (zoom < 0.5)
```dart
// lifeline_painter.dart - _drawArterySystem
void _drawEmotionalGradient(Canvas canvas, Path path, List<Memory> memories) {
  // Создать gradient shader из эмоций воспоминаний
  List<Color> colors = [];
  List<double> stops = [];

  for (int i = 0; i < memories.length; i++) {
    final memory = memories[i];
    final emotionColor = EmotionColors.getColor(memory.primaryEmotion);
    colors.add(emotionColor);
    stops.add(i / (memories.length - 1));
  }

  final gradient = ui.Gradient.linear(
    startPoint,
    endPoint,
    colors,
    stops,
  );

  final paint = Paint()
    ..shader = gradient
    ..style = PaintingStyle.stroke
    ..strokeWidth = calculateWidth(memory.emotionIntensity);
}
```

#### Микро-уровень (zoom > 1.5)
```dart
// Аура вокруг узла
void _drawEmotionalAura(Canvas canvas, Offset position, Memory memory) {
  final emotionColor = EmotionColors.getColor(memory.primaryEmotion);
  final intensity = memory.emotionIntensity;

  final auraPaint = Paint()
    ..color = emotionColor.withOpacity(0.3 * intensity)
    ..maskFilter = MaskFilter.blur(
      BlurStyle.normal,
      20.0 * intensity,
    );

  canvas.drawCircle(position, 40 * intensity, auraPaint);
}
```

#### Погодные эффекты (zoom > 3.0)
```dart
// Particle system для каждой эмоции
class EmotionParticleEffect {
  final EmotionType emotion;
  final List<Particle> particles = [];

  void update(double deltaTime) {
    // Update все частицы
    // Spawn новые в зависимости от intensity
  }

  void paint(Canvas canvas) {
    for (var particle in particles) {
      particle.paint(canvas);
    }
  }
}
```

## 🚀 План реализации (поэтапный)

### 🎯 СЕГОДНЯ: Rapid Prototyping (4-6 часов)

**Цель**: Прототип нового UI эмоций + базовая визуализация на timeline

#### Этап 1: Модель данных (30 мин)
- [ ] Добавить `primaryEmotion`, `secondaryEmotion`, `emotionIntensity` в Memory
- [ ] Добавить миграцию `_migrateFromOldFormat()`
- [ ] Обновить `copyWith()` и `toJson()`/`fromJson()`

#### Этап 2: Новый UI эмоций (2 часа)
- [ ] Заменить `_buildEmotionChips()` на `_buildEmotionSection()`
- [ ] Круговой пикер (8 кнопок с иконками)
- [ ] Слайдер интенсивности 0.0-1.0
- [ ] Промпт "Добавьте эмоцию..." для пустых воспоминаний
- [ ] Поддержка вторичной эмоции

#### Этап 3: Базовая визуализация на Timeline (1.5 часа)
- [ ] "Выцветшие" воспоминания (серый с opacity 0.3) если primaryEmotion == null
- [ ] Цветные узлы на основе primaryEmotion
- [ ] Простая аура (MaskFilter.blur) вокруг узлов

#### Этап 4: Тестирование (1 час)
- [ ] Создать 5-10 тестовых воспоминаний с разными эмоциями
- [ ] Проверить визуализацию на Timeline
- [ ] Проверить миграцию старых воспоминаний
- [ ] Проверить сохранение в Firestore

---

### Phase 2: Продвинутая визуализация (неделя 1-2)
- [ ] Градиент линии на основе эмоций
- [ ] Интерполяция между воспоминаниями
- [ ] LOD для performance
- [ ] Memory View Screen: эмоциональный фон

### Phase 3: Настройки (неделя 2)
- [ ] Добавить поля в UserProfile
- [ ] UI настроек визуализации в ProfileScreen
- [ ] Условный рендеринг на основе настроек
- [ ] Onboarding: выбор стиля

### Phase 4: Погодные эффекты (неделя 3-4) — PREMIUM
- [ ] Particle system architecture
- [ ] Joy particles (sparkles)
- [ ] Sadness particles (rain)
- [ ] Anger particles (lightning)
- [ ] Остальные эффекты
- [ ] Performance optimization (pooling, culling)

### Phase 5: Memory View Transform (неделя 4-5) — PREMIUM
- [ ] Эмоциональный градиент фона
- [ ] Анимированные частицы на экране
- [ ] Color grading для фотографий
- [ ] Настройки включения/выключения

### Phase 6: Testing & Documentation (неделя 5-6)

#### Unit Tests
- [ ] `memory_test.dart`: Тесты для новых полей и миграции
  - `test_primaryEmotion_nullable()`
  - `test_emotionIntensity_range()`
  - `test_migrateFromOldFormat()` — конвертация старых эмоций
  - `test_toJson_fromJson_with_emotions()`
- [ ] `emotion_helpers_test.dart`: Тесты для цветов и иконок
  - `test_getEmotionColor()` для всех 8 эмоций
  - `test_getEmotionIcon()` для всех 8 эмоций
  - `test_blendEmotionColors()` для вторичной эмоции

#### Integration Tests
- [ ] `emotion_visualization_test.dart`
  - Создание воспоминания с эмоцией
  - Изменение эмоции
  - Удаление эмоции
  - Проверка визуализации на Timeline
- [ ] `emotion_migration_test.dart`
  - Загрузка старого воспоминания с множественными эмоциями
  - Проверка автомиграции в новый формат
  - Обратная совместимость

#### Documentation
- [ ] **README_EMOTIONS.md**: Общий обзор системы
  - Философия дизайна
  - Архитектура (3 уровня визуализации)
  - Настройки пользователя
- [ ] **EMOTION_API.md**: Документация для разработчиков
  - Memory модель (новые поля)
  - EmotionHelper класс (утилиты)
  - Как добавить новую эмоцию
- [ ] **USER_GUIDE_EMOTIONS.md**: Руководство пользователя
  - Как выбрать эмоцию
  - Что означают цвета
  - Как работают погодные эффекты
  - Настройки визуализации

### Phase 7: Analytics & Export (неделя 6-7)
- [ ] Экспорт эмоциональной карты (PNG/PDF)
- [ ] Статистика по эмоциям в ProfileScreen
- [ ] AI insights: обнаружение паттернов (интеграция с Gemini)
- [ ] A/B тестирование конверсии в Premium

## ⚠️ Технические риски

1. **Производительность**
   - Много частиц = лаги
   - Решение: LOD, particle pooling, culling

2. **Дневные кластеры**
   - Много эмоций в одном кластере
   - Решение: доминирующая эмоция

3. **Визуальный шум**
   - Слишком много эффектов
   - Решение: показывать только для активного узла

## 💰 Монетизация

**FREE:**
- Базовые цвета и аура
- Простые частицы (10-15 макс)

**PREMIUM ($3.99/month):**
- Полные погодные эффекты
- Больше частиц (50+)
- Sound effects
- Custom emotion themes

## 📊 Метрики успеха

- Timeline визуально понятна на первый взгляд
- Пользователи могут увидеть паттерны эмоций
- Производительность > 30 FPS на medium devices
- Premium conversion rate > 5%

---

## 🎯 MVP для тестирования

Минимальный набор для A/B теста:
1. ✅ 8 базовых эмоций + intensity
2. ✅ Цветовой градиент на линии
3. ✅ Аура вокруг узлов
4. ❌ Погодные эффекты (post-launch premium)

Если MVP показывает engagement - добавляем particle effects.
