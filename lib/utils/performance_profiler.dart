// lib/utils/performance_profiler.dart
// Профессиональный инструмент для анализа производительности главного виджета
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/device_performance_detector.dart';

/// Детальная метрика производительности для конкретного компонента
class ComponentMetrics {
  final String componentName;
  final List<double> frameTimes; // В микросекундах
  final List<double> paintTimes; // В микросекундах
  int frameCount = 0;

  double _totalFrameTime = 0.0;
  double _totalPaintTime = 0.0;
  double _maxFrameTime = 0.0;
  double _minFrameTime = double.infinity;

  ComponentMetrics(this.componentName)
      : frameTimes = [],
        paintTimes = [];

  void addFrame(double frameTimeMicros, double paintTimeMicros) {
    frameTimes.add(frameTimeMicros);
    paintTimes.add(paintTimeMicros);
    frameCount++;

    _totalFrameTime += frameTimeMicros;
    _totalPaintTime += paintTimeMicros;
    _maxFrameTime = frameTimeMicros > _maxFrameTime ? frameTimeMicros : _maxFrameTime;
    _minFrameTime = frameTimeMicros < _minFrameTime ? frameTimeMicros : _minFrameTime;
  }

  double get avgFrameTime => frameCount > 0 ? _totalFrameTime / frameCount : 0;
  double get avgPaintTime => frameCount > 0 ? _totalPaintTime / frameCount : 0;
  double get maxFrameTime => _maxFrameTime;
  double get minFrameTime => _minFrameTime == double.infinity ? 0 : _minFrameTime;

  double get avgFps => avgFrameTime > 0 ? 1000000 / avgFrameTime : 0;
  double get percentOfBudget => (avgFrameTime / 16666.67) * 100; // 60 FPS = 16.67ms per frame

  Map<String, dynamic> toJson() => {
    'componentName': componentName,
    'frameCount': frameCount,
    'avgFrameTimeMs': avgFrameTime / 1000,
    'avgPaintTimeMs': avgPaintTime / 1000,
    'maxFrameTimeMs': maxFrameTime / 1000,
    'minFrameTimeMs': minFrameTime / 1000,
    'avgFps': avgFps,
    'percentOfFrameBudget': percentOfBudget,
  };
}

/// Конфигурация теста производительности
class BenchmarkConfig {
  final GraphicsQuality quality;
  final int nodeCount; // Количество узлов на таймлайне
  final bool auraEnabled;
  final bool emotionEffectsEnabled;
  final bool weatherEffectsEnabled;
  final int durationSeconds;

  const BenchmarkConfig({
    required this.quality,
    this.nodeCount = 50,
    this.auraEnabled = true,
    this.emotionEffectsEnabled = true,
    this.weatherEffectsEnabled = true,
    this.durationSeconds = 10,
  });

  String get name =>
      'Q:${quality.name}_N:$nodeCount'
      '_A:${auraEnabled ? '1' : '0'}_E:${emotionEffectsEnabled ? '1' : '0'}'
      '_W:${weatherEffectsEnabled ? '1' : '0'}';

  Map<String, dynamic> toJson() => {
    'quality': quality.name,
    'nodeCount': nodeCount,
    'auraEnabled': auraEnabled,
    'emotionEffectsEnabled': emotionEffectsEnabled,
    'weatherEffectsEnabled': weatherEffectsEnabled,
    'durationSeconds': durationSeconds,
  };
}

/// Результаты benchmark теста
class BenchmarkResult {
  final BenchmarkConfig config;
  final DateTime timestamp;
  final Map<String, ComponentMetrics> componentMetrics;
  final List<double> overallFrameTimes;
  final String deviceInfo;

  double _totalFps = 0;
  int _fpsCount = 0;
  int _droppedFrames = 0;
  int _jankFrames = 0; // Frames > 32ms (< 30 FPS)

  BenchmarkResult({
    required this.config,
    required this.timestamp,
    required this.componentMetrics,
    required this.overallFrameTimes,
    required this.deviceInfo,
  });

  void updateFps(double fps) {
    _totalFps += fps;
    _fpsCount++;

    if (fps < 60) _droppedFrames++;
    if (fps < 30) _jankFrames++;
  }

  double get avgFps => _fpsCount > 0 ? _totalFps / _fpsCount : 0;
  double get minFps {
    if (overallFrameTimes.isEmpty) return 0;
    final maxFrameTime = overallFrameTimes.reduce((a, b) => a > b ? a : b);
    return maxFrameTime > 0 ? 1000000 / maxFrameTime : 0;
  }
  double get maxFps {
    if (overallFrameTimes.isEmpty) return 0;
    final minFrameTime = overallFrameTimes.reduce((a, b) => a < b ? a : b);
    return minFrameTime > 0 ? 1000000 / minFrameTime : 0;
  }

  int get totalFrames => overallFrameTimes.length;
  int get droppedFrames => _droppedFrames;
  int get jankFrames => _jankFrames;
  double get frameConsistency => totalFrames > 0
      ? ((totalFrames - droppedFrames) / totalFrames) * 100
      : 0;

  /// Находит самые тяжёлые компоненты
  List<MapEntry<String, ComponentMetrics>> getBottlenecks({int topN = 5}) {
    final entries = componentMetrics.entries.toList()
      ..sort((a, b) => b.value.avgFrameTime.compareTo(a.value.avgFrameTime));
    return entries.take(topN).toList();
  }

  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'timestamp': timestamp.toIso8601String(),
    'deviceInfo': deviceInfo,
    'summary': {
      'avgFps': avgFps,
      'minFps': minFps,
      'maxFps': maxFps,
      'totalFrames': totalFrames,
      'droppedFrames': droppedFrames,
      'jankFrames': jankFrames,
      'frameConsistency': frameConsistency,
    },
    'components': componentMetrics.map((k, v) => MapEntry(k, v.toJson())),
    'bottlenecks': getBottlenecks().map((e) => {
      'component': e.key,
      'avgFrameTimeMs': e.value.avgFrameTime / 1000,
      'percentOfBudget': e.value.percentOfBudget,
    }).toList(),
  };

  String toReadableString() {
    final buffer = StringBuffer();
    buffer.writeln('=' * 80);
    buffer.writeln('PERFORMANCE BENCHMARK REPORT');
    buffer.writeln('=' * 80);
    buffer.writeln('Timestamp: ${timestamp.toLocal()}');
    buffer.writeln('Device: $deviceInfo');
    buffer.writeln('\nConfiguration:');
    buffer.writeln('  Quality: ${config.quality.name}');
    buffer.writeln('  Nodes: ${config.nodeCount}');
    buffer.writeln('  Aura: ${config.auraEnabled}');
    buffer.writeln('  Emotion Effects: ${config.emotionEffectsEnabled}');
    buffer.writeln('  Weather Effects: ${config.weatherEffectsEnabled}');
    buffer.writeln('  Duration: ${config.durationSeconds}s');

    buffer.writeln('\n' + '-' * 80);
    buffer.writeln('OVERALL PERFORMANCE');
    buffer.writeln('-' * 80);
    buffer.writeln('Average FPS: ${avgFps.toStringAsFixed(2)}');
    buffer.writeln('Min FPS: ${minFps.toStringAsFixed(2)}');
    buffer.writeln('Max FPS: ${maxFps.toStringAsFixed(2)}');
    buffer.writeln('Total Frames: $totalFrames');
    buffer.writeln('Dropped Frames (< 60 FPS): $droppedFrames (${(droppedFrames / totalFrames * 100).toStringAsFixed(1)}%)');
    buffer.writeln('Jank Frames (< 30 FPS): $jankFrames (${(jankFrames / totalFrames * 100).toStringAsFixed(1)}%)');
    buffer.writeln('Frame Consistency: ${frameConsistency.toStringAsFixed(2)}%');

    buffer.writeln('\n' + '-' * 80);
    buffer.writeln('TOP BOTTLENECKS (by avg frame time)');
    buffer.writeln('-' * 80);
    final bottlenecks = getBottlenecks(topN: 10);
    for (int i = 0; i < bottlenecks.length; i++) {
      final entry = bottlenecks[i];
      buffer.writeln('${i + 1}. ${entry.key}');
      buffer.writeln('   Avg: ${(entry.value.avgFrameTime / 1000).toStringAsFixed(3)}ms');
      buffer.writeln('   Max: ${(entry.value.maxFrameTime / 1000).toStringAsFixed(3)}ms');
      buffer.writeln('   Budget: ${entry.value.percentOfBudget.toStringAsFixed(1)}%');
      buffer.writeln('   Frames: ${entry.value.frameCount}');
    }

    buffer.writeln('\n' + '-' * 80);
    buffer.writeln('ALL COMPONENTS (sorted by avg frame time)');
    buffer.writeln('-' * 80);
    final allComponents = componentMetrics.entries.toList()
      ..sort((a, b) => b.value.avgFrameTime.compareTo(a.value.avgFrameTime));

    for (final entry in allComponents) {
      buffer.writeln('${entry.key}:');
      buffer.writeln('  Avg: ${(entry.value.avgFrameTime / 1000).toStringAsFixed(3)}ms '
                     '(${entry.value.percentOfBudget.toStringAsFixed(1)}% budget)');
      buffer.writeln('  Paint: ${(entry.value.avgPaintTime / 1000).toStringAsFixed(3)}ms');
      buffer.writeln('  Min: ${(entry.value.minFrameTime / 1000).toStringAsFixed(3)}ms, '
                     'Max: ${(entry.value.maxFrameTime / 1000).toStringAsFixed(3)}ms');
      buffer.writeln('  Frames: ${entry.value.frameCount}');
    }

    buffer.writeln('\n' + '=' * 80);
    return buffer.toString();
  }
}

/// Главный класс профилировщика
class PerformanceProfiler {
  static final PerformanceProfiler _instance = PerformanceProfiler._internal();
  factory PerformanceProfiler() => _instance;
  PerformanceProfiler._internal();

  bool _isRecording = false;
  BenchmarkConfig? _currentConfig;
  DateTime? _recordingStartTime;

  final Map<String, ComponentMetrics> _componentMetrics = {};
  final List<double> _overallFrameTimes = [];
  final List<BenchmarkResult> _results = [];

  final Stopwatch _frameStopwatch = Stopwatch();
  Timer? _benchmarkTimer;

  final ValueNotifier<bool> isRecordingNotifier = ValueNotifier(false);
  final ValueNotifier<double> currentFpsNotifier = ValueNotifier(0.0);
  final ValueNotifier<String?> currentStatusNotifier = ValueNotifier(null);

  bool get isRecording => _isRecording;
  BenchmarkConfig? get currentConfig => _currentConfig;
  List<BenchmarkResult> get results => List.unmodifiable(_results);

  /// Начать запись метрик для конкретного benchmark теста
  void startBenchmark(BenchmarkConfig config) {
    if (_isRecording) {
      if (kDebugMode) {
        debugPrint('[PerformanceProfiler] Already recording, stopping previous benchmark');
      }
      stopBenchmark();
    }

    _isRecording = true;
    _currentConfig = config;
    _recordingStartTime = DateTime.now();
    _componentMetrics.clear();
    _overallFrameTimes.clear();
    _frameStopwatch.reset();

    isRecordingNotifier.value = true;
    currentStatusNotifier.value = 'Recording: ${config.name}';

    if (kDebugMode) {
      debugPrint('[PerformanceProfiler] Started benchmark: ${config.name}');
    }

    // Auto-stop after duration
    _benchmarkTimer = Timer(Duration(seconds: config.durationSeconds), () {
      stopBenchmark();
    });
  }

  /// Остановить запись и сохранить результат
  Future<BenchmarkResult> stopBenchmark() async {
    if (!_isRecording) {
      throw StateError('No benchmark is currently recording');
    }

    _benchmarkTimer?.cancel();
    _isRecording = false;
    isRecordingNotifier.value = false;
    currentStatusNotifier.value = 'Processing results...';

    final result = BenchmarkResult(
      config: _currentConfig!,
      timestamp: _recordingStartTime!,
      componentMetrics: Map.from(_componentMetrics),
      overallFrameTimes: List.from(_overallFrameTimes),
      deviceInfo: await _getDeviceInfo(),
    );

    // Calculate FPS from frame times
    for (final frameTime in _overallFrameTimes) {
      if (frameTime > 0) {
        final fps = 1000000 / frameTime; // frameTime in microseconds
        result.updateFps(fps);
      }
    }

    _results.add(result);
    currentStatusNotifier.value = 'Completed: ${_currentConfig!.name}';

    if (kDebugMode) {
      debugPrint('[PerformanceProfiler] Benchmark completed');
      debugPrint('[PerformanceProfiler] Avg FPS: ${result.avgFps.toStringAsFixed(2)}');
      debugPrint('[PerformanceProfiler] Frame consistency: ${result.frameConsistency.toStringAsFixed(2)}%');
    }

    _currentConfig = null;
    _recordingStartTime = null;

    return result;
  }

  /// Записать метрику для конкретного компонента
  void recordComponent(String componentName, double frameTimeMicros, double paintTimeMicros) {
    if (!_isRecording) return;

    _componentMetrics.putIfAbsent(
      componentName,
      () => ComponentMetrics(componentName),
    ).addFrame(frameTimeMicros, paintTimeMicros);
  }

  /// Записать общее время кадра
  void recordFrame(double frameTimeMicros) {
    if (!_isRecording) return;

    _overallFrameTimes.add(frameTimeMicros);

    if (frameTimeMicros > 0) {
      final fps = 1000000 / frameTimeMicros;
      currentFpsNotifier.value = fps;
    }
  }

  /// Начать измерение компонента (вызвать перед рендерингом)
  void startMeasurement(String componentName) {
    if (!_isRecording) return;
    _frameStopwatch.reset();
    _frameStopwatch.start();
  }

  /// Закончить измерение компонента (вызвать после рендеринга)
  void endMeasurement(String componentName, {double paintTimeMicros = 0}) {
    if (!_isRecording) return;
    _frameStopwatch.stop();
    final frameTime = _frameStopwatch.elapsedMicroseconds.toDouble();
    recordComponent(componentName, frameTime, paintTimeMicros);
  }

  /// Запустить полный автоматический benchmark со всеми конфигурациями
  Future<List<BenchmarkResult>> runFullBenchmark({
    void Function(String status)? onStatusUpdate,
    int durationPerTest = 10,
  }) async {
    final configs = [
      // Test different quality levels
      BenchmarkConfig(quality: GraphicsQuality.low, durationSeconds: durationPerTest),
      BenchmarkConfig(quality: GraphicsQuality.medium, durationSeconds: durationPerTest),
      BenchmarkConfig(quality: GraphicsQuality.high, durationSeconds: durationPerTest),

      // Test with different node counts
      BenchmarkConfig(quality: GraphicsQuality.high, nodeCount: 10, durationSeconds: durationPerTest),
      BenchmarkConfig(quality: GraphicsQuality.high, nodeCount: 50, durationSeconds: durationPerTest),
      BenchmarkConfig(quality: GraphicsQuality.high, nodeCount: 100, durationSeconds: durationPerTest),

      // Test with effects disabled
      BenchmarkConfig(
        quality: GraphicsQuality.high,
        auraEnabled: false,
        durationSeconds: durationPerTest,
      ),
      BenchmarkConfig(
        quality: GraphicsQuality.high,
        emotionEffectsEnabled: false,
        durationSeconds: durationPerTest,
      ),
      BenchmarkConfig(
        quality: GraphicsQuality.high,
        weatherEffectsEnabled: false,
        durationSeconds: durationPerTest,
      ),
      BenchmarkConfig(
        quality: GraphicsQuality.high,
        auraEnabled: false,
        emotionEffectsEnabled: false,
        weatherEffectsEnabled: false,
        durationSeconds: durationPerTest,
      ),
    ];

    final results = <BenchmarkResult>[];

    for (int i = 0; i < configs.length; i++) {
      final config = configs[i];
      final status = 'Running benchmark ${i + 1}/${configs.length}: ${config.name}';

      onStatusUpdate?.call(status);
      currentStatusNotifier.value = status;

      if (kDebugMode) {
        debugPrint('[PerformanceProfiler] $status');
      }

      startBenchmark(config);

      // Wait for benchmark to complete
      await Future.delayed(Duration(seconds: config.durationSeconds + 1));

      if (_isRecording) {
        final result = await stopBenchmark();
        results.add(result);
      }

      // Small delay between tests
      await Future.delayed(const Duration(seconds: 2));
    }

    currentStatusNotifier.value = 'All benchmarks completed';
    return results;
  }

  /// Экспортировать результаты в JSON файл
  Future<File> exportResultsToJson([List<BenchmarkResult>? specificResults]) async {
    final resultsToExport = specificResults ?? _results;

    final json = {
      'exportDate': DateTime.now().toIso8601String(),
      'deviceInfo': await _getDeviceInfo(),
      'totalBenchmarks': resultsToExport.length,
      'results': resultsToExport.map((r) => r.toJson()).toList(),
    };

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/performance_benchmark_${DateTime.now().millisecondsSinceEpoch}.json');
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(json));

    if (kDebugMode) {
      debugPrint('[PerformanceProfiler] Exported results to: ${file.path}');
    }

    return file;
  }

  /// Экспортировать результаты в читаемый текстовый файл
  Future<File> exportResultsToText([List<BenchmarkResult>? specificResults]) async {
    final resultsToExport = specificResults ?? _results;
    final buffer = StringBuffer();

    buffer.writeln('LIFELINE PERFORMANCE BENCHMARK REPORT');
    buffer.writeln('Generated: ${DateTime.now().toLocal()}');
    buffer.writeln('Device: ${await _getDeviceInfo()}');
    buffer.writeln('Total Benchmarks: ${resultsToExport.length}');
    buffer.writeln('\n\n');

    for (int i = 0; i < resultsToExport.length; i++) {
      buffer.writeln('BENCHMARK ${i + 1}/${resultsToExport.length}');
      buffer.writeln(resultsToExport[i].toReadableString());
      buffer.writeln('\n\n');
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/performance_benchmark_${DateTime.now().millisecondsSinceEpoch}.txt');
    await file.writeAsString(buffer.toString());

    if (kDebugMode) {
      debugPrint('[PerformanceProfiler] Exported results to: ${file.path}');
    }

    return file;
  }

  /// Очистить все сохранённые результаты
  void clearResults() {
    _results.clear();
    currentStatusNotifier.value = null;
  }

  Future<String> _getDeviceInfo() async {
    if (Platform.isAndroid || Platform.isIOS) {
      return '${Platform.operatingSystem} ${Platform.operatingSystemVersion}';
    }
    return Platform.operatingSystem;
  }

  void dispose() {
    _benchmarkTimer?.cancel();
    isRecordingNotifier.dispose();
    currentFpsNotifier.dispose();
    currentStatusNotifier.dispose();
  }
}
