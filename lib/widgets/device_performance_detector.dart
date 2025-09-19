// lib/widgets/device_performance_detector.dart
// Файл для определения класса производительности устройства и адаптации эффектов.
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

// --- НОВЫЙ КЛАСС: Динамический бюджет рендеринга ---
class PerformanceBudget {
  /// Максимальное количество слоев с эффектом размытия, которое можно использовать сейчас.
  static int maxBlurLayers = 7;
  /// Флаг для использования упрощенной версии узлов (например, без сложных свечений).
  static bool useSimplifiedNodes = false;

  /// Обновляет бюджет производительности на основе текущего FPS.
  /// Этот метод следует вызывать каждый или почти каждый кадр.
  static void updateBudget(double currentFPS) {
    if (currentFPS < 25) { // Более агрессивный порог
      maxBlurLayers = 2; // Только ядро и одно свечение
      useSimplifiedNodes = true;
    } else if (currentFPS < 45) {
      maxBlurLayers = 4; // Среднее качество
      useSimplifiedNodes = false;
    } else {
      maxBlurLayers = 7; // Максимальное качество
      useSimplifiedNodes = false;
    }
  }
}

enum DevicePerformance { high, medium, low }

class DeviceCapabilities {
  final DevicePerformance performance;
  final bool canHandleBlur;
  final bool canHandleComplexGradients;
  final bool canHandleManyParticles;
  final int maxParticleCount;
  final int maxBlurRadius;
  final double effectsQuality; // 0.0 - 1.0

  const DeviceCapabilities({
    required this.performance,
    required this.canHandleBlur,
    required this.canHandleComplexGradients,
    required this.canHandleManyParticles,
    required this.maxParticleCount,
    required this.maxBlurRadius,
    required this.effectsQuality,
  });

  bool get canHandleComplexParticles => canHandleManyParticles;

  static const high = DeviceCapabilities(
    performance: DevicePerformance.high,
    canHandleBlur: true,
    canHandleComplexGradients: true,
    canHandleManyParticles: true,
    maxParticleCount: 150,
    maxBlurRadius: 80,
    effectsQuality: 1.0,
  );

  static const medium = DeviceCapabilities(
    performance: DevicePerformance.medium,
    canHandleBlur: true,
    canHandleComplexGradients: true,
    canHandleManyParticles: false,
    maxParticleCount: 75,
    maxBlurRadius: 40,
    effectsQuality: 0.7,
  );

  static const low = DeviceCapabilities(
    performance: DevicePerformance.low,
    canHandleBlur: false,
    canHandleComplexGradients: false,
    canHandleManyParticles: false,
    maxParticleCount: 25,
    maxBlurRadius: 15,
    effectsQuality: 0.4,
  );
}

class DevicePerformanceDetector {
  static DeviceCapabilities? _cachedCapabilities;

  static DeviceCapabilities get capabilities {
    return _cachedCapabilities ?? DeviceCapabilities.low;
  }

  static Future<void> initialize() async {
    _cachedCapabilities ??= await _detectCapabilities();
  }

  static Future<DeviceCapabilities> _detectCapabilities() async {
    if (kDebugMode && !Platform.isAndroid && !Platform.isIOS) {
      return DeviceCapabilities.high;
    }

    if (Platform.isIOS) {
      return await _detectiOSCapabilities();
    } else if (Platform.isAndroid) {
      return await _detectAndroidCapabilities();
    } else {
      return DeviceCapabilities.high;
    }
  }

  static Future<DeviceCapabilities> _detectiOSCapabilities() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final iosInfo = await deviceInfo.iosInfo;

      if (!iosInfo.model.contains("iPhone") && !iosInfo.isPhysicalDevice) {
        return DeviceCapabilities.high;
      }
      final modelVersion = int.tryParse(iosInfo.utsname.machine.split(',')[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (modelVersion > 12) {
          return DeviceCapabilities.high;
      }
      return DeviceCapabilities.medium;
    } catch (e) {
      return DeviceCapabilities.medium;
    }
  }

  static Future<DeviceCapabilities> _detectAndroidCapabilities() async {
    try {
      final cores = Platform.numberOfProcessors;

      if (cores >= 8) {
        return DeviceCapabilities.high;
      } else if (cores >= 6) {
        return DeviceCapabilities.medium;
      } else {
        return DeviceCapabilities.low;
      }
    } catch (e) {
      return DeviceCapabilities.low;
    }
  }

  static Future<DeviceCapabilities> benchmarkPerformance() async {
    final stopwatch = Stopwatch()..start();

    final path = ui.Path();
    for (int i = 0; i < 100; i++) {
      path.lineTo(i.toDouble(), sin(i * 0.1) * 50);
    }
    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      metric.getTangentForOffset(metric.length / 2);
    }

    stopwatch.stop();

    if (stopwatch.elapsedMicroseconds < 500) {
      return DeviceCapabilities.high;
    } else if (stopwatch.elapsedMicroseconds < 2000) {
      return DeviceCapabilities.medium;
    } else {
      return DeviceCapabilities.low;
    }
  }

  static double getAdaptiveBlurRadius(double baseRadius) {
    final caps = capabilities;
    if (!caps.canHandleBlur) return 0.0;

    return (baseRadius * caps.effectsQuality).clamp(0.0, caps.maxBlurRadius.toDouble());
  }

  static int getAdaptiveParticleCount(int baseCount) {
    final caps = capabilities;
    return (baseCount * caps.effectsQuality).round().clamp(5, caps.maxParticleCount);
  }

  static bool shouldUseComplexGradients() {
    return capabilities.canHandleComplexGradients;
  }

  // Исправлено: возвращает int
  static int getAdaptiveLayerCount(int baseLayerCount) {
    switch (capabilities.performance) {
      case DevicePerformance.high:
        return baseLayerCount;
      case DevicePerformance.medium:
        return (baseLayerCount * 0.6).round().clamp(1, baseLayerCount);
      case DevicePerformance.low:
        return max(1, (baseLayerCount * 0.3).round());
    }
  }
}

class PerformanceMonitor {
  int _frameCount = 0;
  final Stopwatch _stopwatch = Stopwatch()..start();
  final ValueNotifier<double> fpsNotifier = ValueNotifier(0.0);

  double get fps => fpsNotifier.value;

  void tick() {
    _frameCount++;
    if (_stopwatch.elapsedMilliseconds >= 1000) {
      final elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
      fpsNotifier.value = _frameCount / elapsedSeconds;
      _frameCount = 0;
      _stopwatch.reset();
      _stopwatch.start();
    }
  }

  void dispose() {
    fpsNotifier.dispose();
  }
}
