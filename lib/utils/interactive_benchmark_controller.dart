// lib/utils/interactive_benchmark_controller.dart
// Контроллер для автоматизации зума и скролла во время benchmark
import 'dart:async';
import 'package:flutter/foundation.dart';

/// Паттерн интерактивного действия во время benchmark
enum InteractionPattern {
  /// Статичный просмотр (без действий)
  static,

  /// Медленный скролл вниз по таймлайну
  slowScroll,

  /// Быстрый скролл (симуляция свайпа)
  fastScroll,

  /// Плавное увеличение масштаба от min до max
  smoothZoomIn,

  /// Плавное уменьшение масштаба от max до min
  smoothZoomOut,

  /// Циклический зум (in -> out -> in)
  cyclicZoom,

  /// Скролл + зум одновременно (самый тяжёлый режим)
  scrollAndZoom,

  /// Реалистичное использование: скролл, пауза, зум, пауза, скролл
  realisticUsage,
}

/// Контроллер для автоматического управления TransformationController
class InteractiveBenchmarkController {
  final void Function(double scale)? onScaleChange;
  final void Function(double offsetY)? onScrollChange;

  Timer? _animationTimer;
  InteractionPattern? _currentPattern;
  DateTime? _startTime;
  int _durationSeconds = 10;

  double _currentScale = 1.0;
  double _currentOffsetY = 0.0;
  double _minScale = 1.0;
  double _maxScale = 6.0;
  double _contentHeight = 1000.0;

  final ValueNotifier<String> statusNotifier = ValueNotifier('Idle');
  final ValueNotifier<double> progressNotifier = ValueNotifier(0.0);

  InteractiveBenchmarkController({
    this.onScaleChange,
    this.onScrollChange,
  });

  /// Запустить автоматическую интерактивность с заданным паттерном
  void start({
    required InteractionPattern pattern,
    required int durationSeconds,
    required double minScale,
    required double maxScale,
    required double contentHeight,
  }) {
    stop(); // Stop any existing animation

    _currentPattern = pattern;
    _startTime = DateTime.now();
    _durationSeconds = durationSeconds;
    _minScale = minScale;
    _maxScale = maxScale;
    _contentHeight = contentHeight;
    _currentScale = minScale;
    _currentOffsetY = 0.0;

    statusNotifier.value = 'Running: ${pattern.name}';
    progressNotifier.value = 0.0;

    if (kDebugMode) {
      debugPrint('[InteractiveBenchmark] Started pattern: ${pattern.name}');
    }

    // Start animation loop (60 FPS)
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      _updateAnimation,
    );
  }

  void _updateAnimation(Timer timer) {
    if (_startTime == null || _currentPattern == null) {
      stop();
      return;
    }

    final elapsed = DateTime.now().difference(_startTime!);
    final elapsedSeconds = elapsed.inMilliseconds / 1000.0;
    final progress = (elapsedSeconds / _durationSeconds).clamp(0.0, 1.0);

    progressNotifier.value = progress;

    // Stop when duration reached
    if (progress >= 1.0) {
      stop();
      return;
    }

    // Apply pattern-specific transformations
    switch (_currentPattern!) {
      case InteractionPattern.static:
        // Do nothing
        break;

      case InteractionPattern.slowScroll:
        _applySlowScroll(progress);
        break;

      case InteractionPattern.fastScroll:
        _applyFastScroll(progress);
        break;

      case InteractionPattern.smoothZoomIn:
        _applySmoothZoomIn(progress);
        break;

      case InteractionPattern.smoothZoomOut:
        _applySmoothZoomOut(progress);
        break;

      case InteractionPattern.cyclicZoom:
        _applyCyclicZoom(progress);
        break;

      case InteractionPattern.scrollAndZoom:
        _applyScrollAndZoom(progress);
        break;

      case InteractionPattern.realisticUsage:
        _applyRealisticUsage(progress);
        break;
    }
  }

  void _applySlowScroll(double progress) {
    // Медленный равномерный скролл от 0 до contentHeight
    _currentOffsetY = progress * _contentHeight;
    onScrollChange?.call(_currentOffsetY);
  }

  void _applyFastScroll(double progress) {
    // Быстрый скролл с ускорением в начале и замедлением в конце
    final easedProgress = _easeInOutCubic(progress);
    _currentOffsetY = easedProgress * _contentHeight * 2; // 2x speed
    onScrollChange?.call(_currentOffsetY);
  }

  void _applySmoothZoomIn(double progress) {
    // Плавное увеличение от minScale до maxScale
    final easedProgress = _easeInOutQuad(progress);
    _currentScale = _minScale + (_maxScale - _minScale) * easedProgress;
    onScaleChange?.call(_currentScale);
  }

  void _applySmoothZoomOut(double progress) {
    // Плавное уменьшение от maxScale до minScale
    final easedProgress = _easeInOutQuad(progress);
    _currentScale = _maxScale - (_maxScale - _minScale) * easedProgress;
    onScaleChange?.call(_currentScale);
  }

  void _applyCyclicZoom(double progress) {
    // Циклический зум: in (0-0.33), hold (0.33-0.66), out (0.66-1.0)
    if (progress < 0.33) {
      // Zoom in
      final localProgress = progress / 0.33;
      final easedProgress = _easeInOutQuad(localProgress);
      _currentScale = _minScale + (_maxScale - _minScale) * easedProgress;
    } else if (progress < 0.66) {
      // Hold at max
      _currentScale = _maxScale;
    } else {
      // Zoom out
      final localProgress = (progress - 0.66) / 0.34;
      final easedProgress = _easeInOutQuad(localProgress);
      _currentScale = _maxScale - (_maxScale - _minScale) * easedProgress;
    }
    onScaleChange?.call(_currentScale);
  }

  void _applyScrollAndZoom(double progress) {
    // Одновременно скролл и зум (самая тяжёлая нагрузка)
    final scrollProgress = _easeLinear(progress);
    final zoomProgress = _easeInOutQuad(progress);

    _currentOffsetY = scrollProgress * _contentHeight;
    _currentScale = _minScale + (_maxScale - _minScale) * zoomProgress;

    onScrollChange?.call(_currentOffsetY);
    onScaleChange?.call(_currentScale);
  }

  void _applyRealisticUsage(double progress) {
    // Реалистичное использование с паузами
    // 0.0-0.2: Scroll down
    // 0.2-0.3: Pause
    // 0.3-0.5: Zoom in
    // 0.5-0.6: Pause
    // 0.6-0.8: Scroll down more
    // 0.8-0.9: Pause
    // 0.9-1.0: Zoom out

    if (progress < 0.2) {
      // Scroll phase 1
      final localProgress = progress / 0.2;
      _currentOffsetY = localProgress * _contentHeight * 0.3;
      onScrollChange?.call(_currentOffsetY);
    } else if (progress < 0.3) {
      // Pause (no changes)
    } else if (progress < 0.5) {
      // Zoom in
      final localProgress = (progress - 0.3) / 0.2;
      final easedProgress = _easeInOutQuad(localProgress);
      _currentScale = _minScale + (_maxScale - _minScale) * easedProgress * 0.7;
      onScaleChange?.call(_currentScale);
    } else if (progress < 0.6) {
      // Pause (no changes)
    } else if (progress < 0.8) {
      // Scroll phase 2
      final localProgress = (progress - 0.6) / 0.2;
      final baseOffset = _contentHeight * 0.3;
      _currentOffsetY = baseOffset + localProgress * _contentHeight * 0.4;
      onScrollChange?.call(_currentOffsetY);
    } else if (progress < 0.9) {
      // Pause (no changes)
    } else {
      // Zoom out
      final localProgress = (progress - 0.9) / 0.1;
      final easedProgress = _easeInOutQuad(localProgress);
      final startScale = _minScale + (_maxScale - _minScale) * 0.7;
      _currentScale = startScale - (startScale - _minScale) * easedProgress;
      onScaleChange?.call(_currentScale);
    }
  }

  // Easing functions for smooth animations
  double _easeLinear(double t) => t;

  double _easeInOutQuad(double t) {
    return t < 0.5 ? 2 * t * t : 1 - 2 * (1 - t) * (1 - t);
  }

  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - 4 * (1 - t) * (1 - t) * (1 - t);
  }

  /// Остановить автоматическую анимацию
  void stop() {
    _animationTimer?.cancel();
    _animationTimer = null;
    _currentPattern = null;
    _startTime = null;
    statusNotifier.value = 'Stopped';
    progressNotifier.value = 0.0;

    if (kDebugMode) {
      debugPrint('[InteractiveBenchmark] Stopped');
    }
  }

  bool get isRunning => _animationTimer != null && _animationTimer!.isActive;

  void dispose() {
    stop();
    statusNotifier.dispose();
    progressNotifier.dispose();
  }
}

/// Расширенная конфигурация benchmark с паттерном интерактивности
class InteractiveBenchmarkConfig {
  final String name;
  final InteractionPattern pattern;
  final int durationSeconds;

  const InteractiveBenchmarkConfig({
    required this.name,
    required this.pattern,
    this.durationSeconds = 10,
  });

  /// Предустановленные конфигурации для полного теста
  static List<InteractiveBenchmarkConfig> get fullSuite => [
    const InteractiveBenchmarkConfig(
      name: 'Static View',
      pattern: InteractionPattern.static,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Slow Scroll',
      pattern: InteractionPattern.slowScroll,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Fast Scroll (Swipe)',
      pattern: InteractionPattern.fastScroll,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Smooth Zoom In',
      pattern: InteractionPattern.smoothZoomIn,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Smooth Zoom Out',
      pattern: InteractionPattern.smoothZoomOut,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Cyclic Zoom',
      pattern: InteractionPattern.cyclicZoom,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Scroll + Zoom (Heavy)',
      pattern: InteractionPattern.scrollAndZoom,
    ),
    const InteractiveBenchmarkConfig(
      name: 'Realistic Usage',
      pattern: InteractionPattern.realisticUsage,
    ),
  ];
}
