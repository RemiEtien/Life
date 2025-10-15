// lib/widgets/device_performance_detector.dart
// Файл для определения класса производительности устройства и адаптации эффектов.
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// User's manual graphics quality setting
enum GraphicsQuality {
  auto,   // Auto-detect based on device
  low,    // Force low quality
  medium, // Force medium quality
  high,   // Force high quality
}

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
    maxParticleCount: 250,      // Increased from 150
    maxBlurRadius: 120,          // Increased from 80
    effectsQuality: 1.5,         // Increased from 1.0 for extra layers
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
    canHandleBlur: true,  // Changed: enable minimal blur for auras even on low
    canHandleComplexGradients: false,
    canHandleManyParticles: false,
    maxParticleCount: 25,
    maxBlurRadius: 15,
    effectsQuality: 0.3,  // Reduced from 0.4 to keep auras subtle but visible
  );
}

class DevicePerformanceDetector {
  static DeviceCapabilities? _cachedCapabilities;
  static DeviceCapabilities? _autoDetectedCapabilities;
  static GraphicsQuality _userPreference = GraphicsQuality.auto;
  static const String _prefsKey = 'graphics_quality_setting';

  static DeviceCapabilities get capabilities {
    // If user has manual preference, use it
    if (_userPreference != GraphicsQuality.auto) {
      switch (_userPreference) {
        case GraphicsQuality.high:
          return DeviceCapabilities.high;
        case GraphicsQuality.medium:
          return DeviceCapabilities.medium;
        case GraphicsQuality.low:
          return DeviceCapabilities.low;
        case GraphicsQuality.auto:
          break;
      }
    }

    // Otherwise use auto-detected or default to medium
    return _cachedCapabilities ?? DeviceCapabilities.medium;
  }

  static Future<void> initialize() async {
    // Load user preference
    await _loadUserPreference();

    // Auto-detect capabilities
    _autoDetectedCapabilities = await _detectCapabilities();

    // FIX: Apply capabilities based on user preference
    if (_userPreference == GraphicsQuality.auto) {
      _cachedCapabilities = _autoDetectedCapabilities;
    } else {
      // Set capabilities based on manual preference
      switch (_userPreference) {
        case GraphicsQuality.high:
          _cachedCapabilities = DeviceCapabilities.high;
          break;
        case GraphicsQuality.medium:
          _cachedCapabilities = DeviceCapabilities.medium;
          break;
        case GraphicsQuality.low:
          _cachedCapabilities = DeviceCapabilities.low;
          break;
        case GraphicsQuality.auto:
          // Already handled above
          break;
      }
    }
  }

  static Future<void> _loadUserPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedValue = prefs.getString(_prefsKey);
      if (savedValue != null) {
        _userPreference = GraphicsQuality.values.firstWhere(
          (e) => e.name == savedValue,
          orElse: () => GraphicsQuality.auto,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DevicePerformance] Error loading preference: $e');
      }
    }
  }

  /// Set user's graphics quality preference
  static Future<void> setGraphicsQuality(GraphicsQuality quality) async {
    _userPreference = quality;

    // Update cached capabilities based on preference
    if (quality == GraphicsQuality.auto) {
      _cachedCapabilities = _autoDetectedCapabilities ?? DeviceCapabilities.medium;
    } else {
      // Force specific quality - will be handled by capabilities getter
    }

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, quality.name);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DevicePerformance] Error saving preference: $e');
      }
    }
  }

  /// Get current graphics quality setting
  static GraphicsQuality get currentGraphicsQuality => _userPreference;

  /// Get auto-detected device performance level
  static DevicePerformance get autoDetectedPerformance =>
      _autoDetectedCapabilities?.performance ?? DevicePerformance.medium;

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

      if (!iosInfo.model.contains('iPhone') && !iosInfo.isPhysicalDevice) {
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
        // High quality: add 70% more layers for ultra-smooth gradients and natural glow
        // Base 7 layers → 12 layers for professional look
        return (baseLayerCount * 1.7).round();
      case DevicePerformance.medium:
        return (baseLayerCount * 0.6).round().clamp(1, baseLayerCount);
      case DevicePerformance.low:
        return max(1, (baseLayerCount * 0.3).round());
    }
  }

  /// SMART LOD-BASED LAYER COUNT
  /// Returns optimal layer count based on zoom level and component type
  /// This prevents GPU overload by reducing blur layers where they're less visible
  ///
  /// Parameters:
  /// - baseLayerCount: baseline layer count (e.g., 7 for main line)
  /// - zoomLevel: 1 = Yearly gradient, 2 = Monthly clusters, 3 = Individual nodes
  /// - componentType: 'mainLine', 'branches', 'aura'
  static int getSmartLayerCount(int baseLayerCount, int zoomLevel, String componentType) {
    final perf = capabilities.performance;

    // LOW quality: always minimal layers regardless of zoom
    if (perf == DevicePerformance.low) {
      return max(1, (baseLayerCount * 0.3).round());
    }

    // MEDIUM quality: slightly adaptive, but conservative
    if (perf == DevicePerformance.medium) {
      return (baseLayerCount * 0.6).round().clamp(1, baseLayerCount);
    }

    // HIGH quality: SMART LOD system
    // Strategy: Allocate GPU budget where visual impact is highest
    if (perf == DevicePerformance.high) {
      switch (componentType) {
        case 'mainLine':
          // Main line gets most detail at Level 1-2 (far away, big impact)
          // At Level 3, reduce layers since focus shifts to nodes
          if (zoomLevel == 1 || zoomLevel == 2) {
            return (baseLayerCount * 1.2).round();  // 7 → 8 layers (beautiful, not overkill)
          } else { // zoomLevel == 3
            return (baseLayerCount * 0.7).round();  // 7 → 5 layers (save GPU for nodes)
          }

        case 'branches':
          // Branches less important at all zoom levels on high
          if (zoomLevel == 1) {
            return (baseLayerCount * 0.4).round();  // 7 → 3 layers (distant, low detail)
          } else if (zoomLevel == 2) {
            return (baseLayerCount * 0.6).round();  // 7 → 4 layers (medium detail)
          } else { // zoomLevel == 3
            return (baseLayerCount * 0.5).round();  // 7 → 4 layers (nodes are focus)
          }

        case 'aura':
          // Auras only visible at Level 3, give them good quality
          if (zoomLevel == 3) {
            return (baseLayerCount * 0.8).round();  // 7 → 6 layers (beautiful auras!)
          } else {
            return 0;  // No auras at Level 1-2
          }

        default:
          // Fallback to standard high quality
          return (baseLayerCount * 1.2).round();
      }
    }

    // Fallback
    return baseLayerCount;
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
