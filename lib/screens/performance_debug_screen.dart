// lib/screens/performance_debug_screen.dart
// Debug экран для запуска и просмотра benchmark тестов производительности
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/performance_profiler.dart';
import '../widgets/device_performance_detector.dart';

class PerformanceDebugScreen extends StatefulWidget {
  const PerformanceDebugScreen({super.key});

  @override
  State<PerformanceDebugScreen> createState() => _PerformanceDebugScreenState();
}

class _PerformanceDebugScreenState extends State<PerformanceDebugScreen> {
  final _profiler = PerformanceProfiler();
  bool _isRunningFullBenchmark = false;
  String? _statusMessage;
  BenchmarkResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    _profiler.currentStatusNotifier.addListener(_onStatusUpdate);
  }

  @override
  void dispose() {
    _profiler.currentStatusNotifier.removeListener(_onStatusUpdate);
    super.dispose();
  }

  void _onStatusUpdate() {
    if (mounted) {
      setState(() {
        _statusMessage = _profiler.currentStatusNotifier.value;
      });
    }
  }

  Future<void> _runFullBenchmark() async {
    setState(() {
      _isRunningFullBenchmark = true;
      _statusMessage = 'Starting full benchmark suite...';
    });

    try {
      await _profiler.runFullBenchmark(
        durationPerTest: 10,
        onStatusUpdate: (status) {
          if (mounted) {
            setState(() => _statusMessage = status);
          }
        },
      );

      if (mounted) {
        setState(() {
          _isRunningFullBenchmark = false;
          _statusMessage = 'Benchmark completed! ${_profiler.results.length} tests run.';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Benchmark completed! ${_profiler.results.length} results.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRunningFullBenchmark = false;
          _statusMessage = 'Error: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Benchmark failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runQuickBenchmark(BenchmarkConfig config) async {
    if (_profiler.isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Already recording a benchmark')),
      );
      return;
    }

    _profiler.startBenchmark(config);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Started benchmark: ${config.name}'),
        duration: Duration(seconds: config.durationSeconds),
      ),
    );

    // Navigate back to home screen to see the actual performance
    if (mounted) {
      Navigator.of(context).pop();
    }

    // Wait for benchmark to complete
    await Future.delayed(Duration(seconds: config.durationSeconds + 1));

    if (_profiler.isRecording) {
      await _profiler.stopBenchmark();
    }
  }

  Future<void> _exportResults() async {
    if (_profiler.results.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No results to export')),
      );
      return;
    }

    try {
      final textFile = await _profiler.exportResultsToText();
      final jsonFile = await _profiler.exportResultsToJson();

      if (mounted) {
        await Share.shareXFiles(
          [XFile(textFile.path), XFile(jsonFile.path)],
          subject: 'Lifeline Performance Benchmark Results',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Profiler'),
        actions: [
          if (_profiler.results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _exportResults,
              tooltip: 'Export Results',
            ),
          if (_profiler.results.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                setState(() {
                  _profiler.clearResults();
                  _selectedResult = null;
                  _statusMessage = 'Results cleared';
                });
              },
              tooltip: 'Clear Results',
            ),
        ],
      ),
      body: Column(
        children: [
          // Status banner
          if (_statusMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _isRunningFullBenchmark ? Colors.orange : Colors.blue,
              child: Row(
                children: [
                  if (_isRunningFullBenchmark)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  if (_isRunningFullBenchmark) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _statusMessage!,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

          // Current FPS indicator
          ValueListenableBuilder<double>(
            valueListenable: _profiler.currentFpsNotifier,
            builder: (context, fps, _) {
              if (fps == 0) return const SizedBox.shrink();

              final color = fps >= 55
                  ? Colors.green
                  : fps >= 30
                      ? Colors.orange
                      : Colors.red;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: color.withOpacity(0.2),
                child: Text(
                  'Current FPS: ${fps.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),

          Expanded(
            child: _selectedResult != null
                ? _buildResultDetail(_selectedResult!)
                : _buildMainView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMainView() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick benchmark buttons
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Benchmarks',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Run a 10-second benchmark and return to home screen to see results',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: _isRunningFullBenchmark
                          ? null
                          : () => _runQuickBenchmark(
                                const BenchmarkConfig(
                                  quality: GraphicsQuality.low,
                                  durationSeconds: 10,
                                ),
                              ),
                      child: const Text('Low Quality'),
                    ),
                    ElevatedButton(
                      onPressed: _isRunningFullBenchmark
                          ? null
                          : () => _runQuickBenchmark(
                                const BenchmarkConfig(
                                  quality: GraphicsQuality.medium,
                                  durationSeconds: 10,
                                ),
                              ),
                      child: const Text('Medium Quality'),
                    ),
                    ElevatedButton(
                      onPressed: _isRunningFullBenchmark
                          ? null
                          : () => _runQuickBenchmark(
                                const BenchmarkConfig(
                                  quality: GraphicsQuality.high,
                                  durationSeconds: 10,
                                ),
                              ),
                      child: const Text('High Quality'),
                    ),
                    ElevatedButton(
                      onPressed: _isRunningFullBenchmark
                          ? null
                          : () => _runQuickBenchmark(
                                const BenchmarkConfig(
                                  quality: GraphicsQuality.high,
                                  auraEnabled: false,
                                  emotionEffectsEnabled: false,
                                  weatherEffectsEnabled: false,
                                  durationSeconds: 10,
                                ),
                              ),
                      child: const Text('No Effects'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Full benchmark suite
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Benchmark Suite',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Runs 10 different tests (~2 minutes total). Tests quality levels, node counts, and effects.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isRunningFullBenchmark ? null : _runFullBenchmark,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Run Full Benchmark'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Results list
        if (_profiler.results.isNotEmpty) ...[
          const Text(
            'Results',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ..._profiler.results.map((result) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getFpsColor(result.avgFps),
                  child: Text(
                    result.avgFps.toStringAsFixed(0),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(result.config.name),
                subtitle: Text(
                  'FPS: ${result.avgFps.toStringAsFixed(1)} | '
                  'Dropped: ${result.droppedFrames}/${result.totalFrames} | '
                  'Consistency: ${result.frameConsistency.toStringAsFixed(1)}%',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  setState(() => _selectedResult = result);
                },
              ),
            );
          }).toList(),
        ] else
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No results yet. Run a benchmark to see results.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildResultDetail(BenchmarkResult result) {
    return Column(
      children: [
        // Header with back button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => _selectedResult = null);
                },
              ),
              Expanded(
                child: Text(
                  result.config.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: result.toReadableString()),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copied to clipboard')),
                  );
                },
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ),

        // Results content
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Summary card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Summary',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow('Avg FPS', result.avgFps.toStringAsFixed(2),
                          color: _getFpsColor(result.avgFps)),
                      _buildMetricRow('Min FPS', result.minFps.toStringAsFixed(2)),
                      _buildMetricRow('Max FPS', result.maxFps.toStringAsFixed(2)),
                      _buildMetricRow('Total Frames', result.totalFrames.toString()),
                      _buildMetricRow('Dropped Frames',
                          '${result.droppedFrames} (${(result.droppedFrames / result.totalFrames * 100).toStringAsFixed(1)}%)'),
                      _buildMetricRow('Jank Frames',
                          '${result.jankFrames} (${(result.jankFrames / result.totalFrames * 100).toStringAsFixed(1)}%)'),
                      _buildMetricRow('Consistency',
                          '${result.frameConsistency.toStringAsFixed(2)}%',
                          color: _getConsistencyColor(result.frameConsistency)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Top bottlenecks
              const Text(
                'Top Bottlenecks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.getBottlenecks(topN: 5).map((entry) =>
                Card(
                  child: ListTile(
                    title: Text(entry.key),
                    subtitle: Text(
                      'Avg: ${(entry.value.avgFrameTime / 1000).toStringAsFixed(3)}ms | '
                      'Max: ${(entry.value.maxFrameTime / 1000).toStringAsFixed(3)}ms',
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getBudgetColor(entry.value.percentOfBudget),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${entry.value.percentOfBudget.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )),

              const SizedBox(height: 16),

              // All components
              const Text(
                'All Components',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    result.componentMetrics.entries
                        .map((e) =>
                            '${e.key}: ${(e.value.avgFrameTime / 1000).toStringAsFixed(3)}ms')
                        .join('\n'),
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getFpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _getConsistencyColor(double consistency) {
    if (consistency >= 90) return Colors.green;
    if (consistency >= 70) return Colors.orange;
    return Colors.red;
  }

  Color _getBudgetColor(double percent) {
    if (percent <= 30) return Colors.green;
    if (percent <= 60) return Colors.orange;
    return Colors.red;
  }
}
