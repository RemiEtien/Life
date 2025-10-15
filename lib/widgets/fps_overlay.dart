// lib/widgets/fps_overlay.dart
// FPS overlay that shows real-time performance metrics on the timeline
import 'package:flutter/material.dart';
import '../utils/performance_profiler.dart';

class FPSOverlay extends StatelessWidget {
  const FPSOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final profiler = PerformanceProfiler();

    return ValueListenableBuilder<bool>(
      valueListenable: profiler.isRecordingNotifier,
      builder: (context, isRecording, _) {
        if (!isRecording) return const SizedBox.shrink();

        return Positioned(
          top: 16,
          right: 16,
          child: ValueListenableBuilder<double>(
            valueListenable: profiler.currentFpsNotifier,
            builder: (context, fps, _) {
              final color = fps >= 55
                  ? Colors.green
                  : fps >= 30
                      ? Colors.orange
                      : Colors.red;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'RECORDING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fps.toStringAsFixed(1)} FPS',
                      style: TextStyle(
                        color: color,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    ValueListenableBuilder<String?>(
                      valueListenable: profiler.currentStatusNotifier,
                      builder: (context, status, _) {
                        if (status == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            status,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
