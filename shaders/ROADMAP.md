# 🎨 Graphics Overhaul Roadmap
## Бескомпромисная визуализация линии жизни

### 🎯 Цель
Создать визуально впечатляющий опыт на уровне AAA-игр с производительностью 60 FPS на современных устройствах (Galaxy Fold4+) и 30+ FPS на бюджетных.

### 📊 Текущая проблема
- **Производительность:** ~13 FPS на Galaxy Fold4 при максимальном зуме (debug build)
- **Причина:** CPU-bound рендеринг через `MaskFilter.blur` - применяется к каждому объекту отдельно
- **Ограничения:** Нет многослойного свечения, объемного освещения, продвинутых эффектов

### 🎬 Референсы
**Основной:** The Alters - атмосферное свечение, volumetric lighting, эмоциональная цветокоррекция, кинематографическая глубина

Визуальный стиль:
- Многослойное свечение вокруг воспоминаний (как в The Alters)
- Объемное освещение и лучи света
- Атмосферные туманности на фоне
- Cinematic depth of field
- Динамические тени и particle effects

---

## 📋 Phase 1: GPU-Accelerated Core Effects (Приоритет: ВЫСОКИЙ)

### 1.1 Fragment Shaders Infrastructure
**Задача:** Перенести все эффекты с CPU на GPU через GLSL shaders

**Файлы для создания:**
```
shaders/
├── glow_multi_layer.frag       # Многослойное свечение для нод
├── volumetric_light.frag       # Объемные лучи света
├── bloom.frag                  # Bloom эффект для ярких участков
├── chromatic_aberration.frag   # Хроматическая аберрация
├── particles.frag              # GPU-ускоренные частицы
└── depth_fog.frag              # Объемный туман по глубине
```

**Технические детали:**
- Использовать `FragmentProgram.fromAsset()` для загрузки
- Кэшировать скомпилированные шейдеры в `LifelineWidget`
- Передавать uniform-параметры через `shader.setFloat()`
- Применять к `Paint.shader` вместо `Paint.maskFilter`

**Ожидаемый прирост:** ~5-8x производительности (60+ FPS вместо 13 FPS)

---

### 1.2 Multi-Layer Glow Shader
**Приоритет:** КРИТИЧЕСКИЙ

**Описание:**
Заменить `MaskFilter.blur` на GPU-шейдер с многослойным свечением:
- **Layer 1:** Tight glow (радиус 5-10px, alpha 0.9)
- **Layer 2:** Medium glow (радиус 20-30px, alpha 0.5)
- **Layer 3:** Wide glow (радиус 40-60px, alpha 0.2)
- **Layer 4:** Atmospheric glow (радиус 80-100px, alpha 0.05)

**Параметры шейдера:**
```glsl
uniform vec2 uResolution;       // Размер canvas
uniform vec2 uNodePosition;     // Позиция ноды
uniform float uIntensity;       // Интенсивность свечения (0.0-1.0)
uniform vec3 uColor;            // Цвет свечения (RGB)
uniform float uTime;            // Для анимации пульсации
uniform float uBlurRadius;      // Динамический радиус размытия
```

**Текущие места применения:**
- Line 169: `lifeline_painter.dart` - звезды на фоне
- Line 492: Эмоциональные якоря (macro view)
- Line 686: Кольца вокруг daily clusters
- Line 748: Фон иконки замка

**Задачи:**
- [ ] Написать GLSL код для Gaussian blur в fragment shader
- [ ] Реализовать multi-pass rendering для слоев
- [ ] Интегрировать в `_drawSingleMemoryNode()`
- [ ] Интегрировать в `_drawDailyClusterNode()`
- [ ] Интегровать в `BackgroundPainter` для звезд
- [ ] Тестировать на Galaxy Fold4

---

### 1.3 Volumetric Light Shader
**Приоритет:** ВЫСОКИЙ

**Описание:**
Объемные лучи света, исходящие от воспоминаний (как в первом референсе).

**Эффект:**
- Конические лучи от ярких нод
- Рассеивание по направлению к камере
- God rays эффект
- Затухание по расстоянию

**Параметры:**
```glsl
uniform vec2 uLightSource;      // Источник света (позиция ноды)
uniform float uRayLength;       // Длина лучей
uniform float uRayDensity;      // Плотность/видимость лучей
uniform float uScattering;      // Рассеивание
uniform vec3 uLightColor;       // Цвет света
```

**Задачи:**
- [ ] Создать `volumetric_light.frag`
- [ ] Применять только к эмоционально насыщенным воспоминаниям
- [ ] Добавить в `_drawMacroView()` для visual impact
- [ ] Adaptive quality: отключать на weak devices

---

### 1.4 Bloom Post-Processing
**Приоритет:** СРЕДНИЙ

**Описание:**
Яркие участки "растекаются" светом (как свечение неоновых вывесок).

**Технический подход:**
1. Render scene to texture (offscreen)
2. Extract bright pixels (threshold > 0.8)
3. Blur bright pixels (Gaussian)
4. Composite back onto scene

**Задачи:**
- [ ] Создать `bloom.frag`
- [ ] Реализовать dual-pass rendering (threshold + blur)
- [ ] Интегрировать через `Canvas.saveLayer` with `ImageFilter`
- [ ] Настроить threshold и intensity параметры

---

## 📋 Phase 2: Advanced Visual Effects (Приоритет: СРЕДНИЙ)

### 2.1 Gradient Glow на линии жизни
**Описание:**
Переливающееся свечение вдоль main path с цветовыми переходами.

**Эффект:**
- Красный → Оранжевый → Желтый → Белый (по интенсивности)
- Animated flow вдоль пути
- Пульсация синхронизированная с нодами

**Текущее состояние:**
`StructurePainter._drawArterySystem()` - статичные слои без градиента

**Задачи:**
- [ ] Добавить `shader` вместо `color` в Paint
- [ ] Создать animated gradient shader
- [ ] Параметризовать по эмоциональной интенсивности участка

---

### 2.2 GPU Particle System
**Описание:**
Светящиеся частицы вокруг нод (искры, пыль, энергия).

**Параметры:**
- 50-200 частиц на ноду (adaptive)
- Physics: притяжение к ноде + Brownian motion
- Fade out по времени жизни
- Billboard rendering (всегда смотрят на камеру)

**Задачи:**
- [ ] Создать `particles.frag`
- [ ] Реализовать particle pool для переиспользования
- [ ] Добавить в `_drawSingleMemoryNode()`
- [ ] Параметры: количество, скорость, размер, цвет

---

### 2.3 Depth-Based Fog
**Описание:**
Объемный туман на дальних участках линии для глубины сцены.

**Эффект:**
- Exponential fog по Z-координате
- Синий/фиолетовый оттенок
- Усиливается в macro view

**Задачи:**
- [ ] Создать `depth_fog.frag`
- [ ] Рассчитывать Z-depth из позиции на пути
- [ ] Применять к фону в `BackgroundPainter`

---

### 2.4 Animated Nebulae
**Описание:**
Анимированные туманности на фоне (как во втором референсе).

**Текущее состояние:**
`BackgroundPainter` - статичные gradients с базовой анимацией

**Улучшения:**
- Perlin noise для органичной формы
- Slow drift анимация (20-30 sec цикл)
- Multi-layer composition (3-5 слоев туманностей)
- Color variation (фиолетовый, синий, красный)

**Задачи:**
- [ ] Создать noise texture generator
- [ ] Shader для procedural nebulae
- [ ] Кэшировать в `ui.Picture` для performance

---

## 📋 Phase 3: Optimization & Performance (Приоритет: КРИТИЧЕСКИЙ)

### 3.1 Shader Compilation Caching
**Проблема:**
Компиляция shader'ов при каждом запуске (100-300ms delay).

**Решение:**
- Загружать и компилировать все shaders в `initState()` `LifelineWidget`
- Кэшировать `FragmentProgram` в widget state
- Передавать скомпилированные шейдеры в painter'ы

**Задачи:**
- [ ] Создать `ShaderCache` class
- [ ] Pre-compile при старте приложения
- [ ] Graceful fallback если shader не загрузился

---

### 3.2 Instanced Rendering
**Проблема:**
Каждая нода рисуется отдельным draw call (100+ calls per frame).

**Решение:**
- Batch все ноды одного типа в один draw call
- Использовать `Canvas.drawAtlas()` для nodes
- Передавать positions/colors через uniform arrays в shader

**Ожидаемый прирост:** ~2-3x FPS

**Задачи:**
- [ ] Рефакторинг `_drawSingleMemoryNode()` для batch rendering
- [ ] Собирать все node positions в List
- [ ] Один вызов `drawAtlas()` вместо множества `drawCircle()`

---

### 3.3 LOD System (Level of Detail)
**Описание:**
Автоматическое снижение качества для дальних объектов.

**Уровни:**
- **LOD 0 (Close):** Все эффекты включены (particles, volumetric light, 4-layer glow)
- **LOD 1 (Medium):** 2-layer glow, no particles
- **LOD 2 (Far):** Single glow layer, simplified shader
- **LOD 3 (Very Far):** Solid color, no effects

**Задачи:**
- [ ] Рассчитывать distance от камеры до ноды
- [ ] Автоматически выбирать LOD по distance
- [ ] Интегрировать в `_drawSingleMemoryNode()`

---

### 3.4 Occlusion Culling
**Текущее состояние:**
`visibleRect.contains()` - базовая проверка

**Улучшения:**
- Spatial hash grid для быстрого поиска видимых объектов
- Frustum culling для off-screen nodes
- Early exit если объект за границей canvas

**Ожидаемый прирост:** ~20-30% FPS при большом масштабе

**Задачи:**
- [ ] Реализовать QuadTree для spatial indexing
- [ ] Предварительный проход для visibility determination
- [ ] Кэшировать результаты между frames

---

### 3.5 Adaptive Quality System
**Описание:**
Автоматическое снижение качества на слабых устройствах.

**Уровни качества:**
```dart
enum GraphicsQuality {
  ultra,   // Galaxy Fold4+: все эффекты включены
  high,    // Mid-range: particles отключены, 3-layer glow
  medium,  // Budget: 2-layer glow, упрощенные shaders
  low,     // Old devices: fallback to MaskFilter (compatibility)
}
```

**Автоопределение:**
- Измерять FPS первые 5 секунд
- Если FPS < 50 → downgrade quality
- Если FPS > 58 → upgrade quality (если возможно)

**Задачи:**
- [ ] Расширить `DevicePerformanceDetector`
- [ ] Добавить `GraphicsQuality` enum
- [ ] Динамическое переключение в runtime
- [ ] UI toggle в settings для ручного выбора

---

## 📋 Phase 4: Cinematic Effects (Приоритет: НИЗКИЙ)

### 4.1 Depth of Field
**Описание:**
Размытие фона/переднего плана как в камере (как в первом референсе).

**Параметры:**
- Focus point: текущая центральная нода
- Focus range: 100-200px radius
- Blur intensity: exponential falloff

**Задачи:**
- [ ] Создать `depth_of_field.frag`
- [ ] Dual-pass: render to texture + blur based on depth
- [ ] Применять только в detail view (zoom > 2.0)

---

### 4.2 Vignette Effect
**Описание:**
Затемнение по краям экрана для кинематографичности.

**Задачи:**
- [ ] Простой radial gradient overlay
- [ ] Параметр intensity в settings (0.0-0.5)
- [ ] Применять в `BackgroundPainter`

---

### 4.3 Camera Shake
**Описание:**
Легкая тряска камеры синхронизированная с пульсацией нод.

**Задачи:**
- [ ] Offset canvas transform на 1-2px
- [ ] Perlin noise для organic motion
- [ ] Опциональный параметр (по умолчанию OFF)

---

### 4.4 Smooth Zoom Transitions
**Описание:**
Плавные переходы масштаба с easing.

**Текущее состояние:**
Linear interpolation в `LifelineWidget`

**Улучшения:**
- Easing curves: ease-in-out, cubic-bezier
- Animated transition 300-500ms
- Velocity-based zoom (быстрый pinch = быстрый zoom)

**Задачи:**
- [ ] Добавить `AnimationController` для zoom
- [ ] Custom easing curve
- [ ] Интеграция с gesture detector

---

## 📋 Phase 5: Interactive Lighting (Приоритет: НИЗКИЙ)

### 5.1 Dynamic Shadows
**Описание:**
Тени от нод на линию жизни.

**Подход:**
- Shadow map technique (offscreen rendering)
- Soft shadows через PCF (Percentage Closer Filtering)

**Задачи:**
- [ ] Render depth map
- [ ] Shadow shader с softness parameter
- [ ] Только для top-N ближайших нод (performance)

---

### 5.2 Glow Interaction
**Описание:**
Ноды рядом усиливают свечение друг друга.

**Эффект:**
- Proximity detection (distance < 100px)
- Additive blending glow colors
- Resonance animation при взаимодействии

**Задачи:**
- [ ] Spatial query для ближайших нод
- [ ] Модификация intensity в shader
- [ ] Additive blending mode

---

### 5.3 Touch Ripple Effect
**Описание:**
Волны света при касании экрана.

**Эффект:**
- Radial wave от точки касания
- Distortion линии жизни
- Fade out через 1-2 секунды

**Задачи:**
- [ ] Gesture detector для tap position
- [ ] Ripple shader с expanding radius
- [ ] Animation controller

---

### 5.4 Emotional Color Grading
**Описание:**
Цветовая коррекция сцены по эмоциональности воспоминаний.

**Палитра:**
- **Позитивные:** Теплые тона (оранжевый, желтый)
- **Негативные:** Холодные тона (синий, фиолетовый)
- **Нейтральные:** Серо-белые тона

**Задачи:**
- [ ] Рассчитывать средний emotional score видимых нод
- [ ] Color grading shader (LUT-based)
- [ ] Smooth transition между настроениями

---

## 🎯 Success Metrics

### Performance Targets
- ✅ **60 FPS** на Galaxy Fold4 (release build) с максимальными эффектами
- ✅ **55+ FPS** на Galaxy Fold4 (debug build)
- ✅ **45+ FPS** на mid-range устройствах (Snapdragon 7 Gen 1)
- ✅ **30+ FPS** на бюджетных устройствах (Snapdragon 6 Gen 1)

### Visual Quality Targets
- ✅ Multi-layer glow с 3+ слоями
- ✅ Volumetric lighting на ключевых воспоминаниях
- ✅ Bloom effect для ярких участков
- ✅ Cinematic depth и atmosphere
- ✅ 0 visual artifacts или flickering

### Technical Targets
- ✅ Все CPU-bound эффекты переведены на GPU
- ✅ < 100ms shader compilation time
- ✅ Instanced rendering для nodes
- ✅ Adaptive quality system работает автоматически
- ✅ Fallback на старые эффекты на unsupported devices

---

## 📚 Technical References

### Flutter Shaders Documentation
- [Fragment Shaders in Flutter 3.0+](https://docs.flutter.dev/development/ui/advanced/shaders)
- [FragmentProgram API](https://api.flutter.dev/flutter/dart-ui/FragmentProgram-class.html)

### GLSL Resources
- [The Book of Shaders](https://thebookofshaders.com/)
- [Shadertoy Examples](https://www.shadertoy.com/)
- [GPU Gems: Efficient Gaussian Blur](https://developer.nvidia.com/gpugems/gpugems3/part-iv-image-effects/chapter-40-incremental-computation-gaussian)

### Performance Optimization
- [Flutter Performance Best Practices](https://docs.flutter.dev/perf/best-practices)
- [Custom Painter Optimization](https://docs.flutter.dev/perf/rendering-performance)
- [GPU-accelerated rendering in Flutter](https://medium.com/flutter/flutter-gpu-accelerated-ui-rendering-3d67a1b19b26)

---

## 🚀 Implementation Order (Рекомендуемый)

### Sprint 1: Core Infrastructure (1-2 недели)
1. ✅ Создать структуру папки `shaders/`
2. ✅ Настроить `pubspec.yaml` для shaders
3. ✅ Создать `ShaderCache` class
4. ✅ Реализовать `glow_multi_layer.frag`
5. ✅ Интегрировать в `_drawSingleMemoryNode()`

### Sprint 2: Visual Impact (1 неделя)
1. ✅ Реализовать `volumetric_light.frag`
2. ✅ Добавить gradient glow на main path
3. ✅ Улучшить animated nebulae
4. ✅ Тестировать на Galaxy Fold4

### Sprint 3: Optimization (1 неделя)
1. ✅ Instanced rendering для nodes
2. ✅ LOD system
3. ✅ Adaptive quality автоматика
4. ✅ Performance profiling и tuning

### Sprint 4: Polish (опционально)
1. ✅ Bloom post-processing
2. ✅ Particle system
3. ✅ Cinematic effects
4. ✅ Final tuning и bug fixes

---

## 🔄 Version History

### v0.1 (Current)
- CPU-based `MaskFilter.blur`
- Performance: ~13 FPS на Galaxy Fold4
- Basic glow effects

### v0.2 (Target)
- GPU-based multi-layer glow
- Performance: 60 FPS на Galaxy Fold4
- Volumetric lighting
- Adaptive quality system

### v1.0 (Future Vision)
- Полный набор cinematic effects
- Interactive lighting
- Particle systems
- AAA-уровень визуализации

---

## 📝 Notes

- Все шейдеры должны иметь fallback на CPU-версию для compatibility
- Тестировать на реальных устройствах, не только на эмуляторе
- Профилировать с Flutter DevTools для поиска bottlenecks
- Постепенное внедрение (feature flags) для A/B тестирования
- Возможность отключения эффектов в Settings для пользователей

---

**Last Updated:** 2025-10-06
**Status:** 📋 Planning Phase
**Next Milestone:** Sprint 1 - Core Infrastructure
