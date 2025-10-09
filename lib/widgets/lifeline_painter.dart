import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../memory.dart';
import 'device_performance_detector.dart';
import 'lifeline_widget.dart'; // Import for YearPosition

// --- NEW: A dedicated class to hold performance timings ---
class PaintTimings {
  final int background;
  final int structure;
  final int nodes;
  final int labels;
  final int macroView;
  final int total;

  PaintTimings({
    this.background = 0,
    this.structure = 0,
    this.nodes = 0,
    this.labels = 0,
    this.macroView = 0,
  }) : total = background + structure + nodes + labels + macroView;

  PaintTimings copyWith({
    int? background,
    int? structure,
    int? nodes,
    int? labels,
    int? macroView,
  }) {
    return PaintTimings(
      background: background ?? this.background,
      structure: structure ?? this.structure,
      nodes: nodes ?? this.nodes,
      labels: labels ?? this.labels,
      macroView: macroView ?? this.macroView,
    );
  }

  String toDebugString() {
    if (total == 0) return 'No paint timings yet.';

    final bgPercent =
        total > 0 ? (background / total * 100).toStringAsFixed(1) : '0.0';
    final structPercent =
        total > 0 ? (structure / total * 100).toStringAsFixed(1) : '0.0';
    final nodesPercent =
        total > 0 ? (nodes / total * 100).toStringAsFixed(1) : '0.0';
    final labelsPercent =
        total > 0 ? (labels / total * 100).toStringAsFixed(1) : '0.0';
    final macroPercent =
        total > 0 ? (macroView / total * 100).toStringAsFixed(1) : '0.0';

    return '''
--- PAINT TIMING (ms) ---
Background: $background ms ($bgPercent%)
Structure: $structure ms ($structPercent%)
Nodes: $nodes ms ($nodesPercent%)
Labels: $labels ms ($labelsPercent%)
Macro View: $macroView ms ($macroPercent%)
Total: $total ms
''';
  }
}

enum DetailLevel { macro, detail }

typedef DailyClusterPosCallback = void Function(
    String id, Offset pos, List<Memory> memories);

typedef NodePosCallback = void Function(String id, Offset pos);

class PlacementInfo {
  final Memory memory;
  final Offset nodePosition;
  Rect? textRect;

  PlacementInfo(this.memory, this.nodePosition);
}

class DailyClusterPlacementInfo {
  final List<Memory> memories;
  final Offset position;
  final String id;

  DailyClusterPlacementInfo({
    required this.memories,
    required this.position,
    required this.id,
  });
}

class TimeGapPlacementInfo {
  final Offset position;
  final DateTime startDate;
  final DateTime endDate;
  int get days => endDate.difference(startDate).inDays;

  TimeGapPlacementInfo({
    required this.position,
    required this.startDate,
    required this.endDate,
  });
}

class BackgroundPainter extends CustomPainter {
  final double progress;
  BackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = ui.Gradient.radial(
        size.center(Offset.zero),
        size.width * 1.2,
        [
          const Color(0xFF0A0A0F),
          const Color(0xFF1a1a2a),
          const Color(0xFF2a1a2a),
          const Color(0xFF0D0C11)
        ],
        [0.0, 0.3, 0.7, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final random = Random(42);
    final capabilities = DevicePerformanceDetector.capabilities;
    final nebulaCount = DevicePerformanceDetector.getAdaptiveLayerCount(8);
    for (int i = 0; i < nebulaCount; i++) {
      final center = Offset(
          (random.nextDouble() * size.width * 1.5) - (size.width * 0.25),
          (random.nextDouble() * size.height * 1.2) - (size.height * 0.1));
      final animatedCenter = (capabilities.performance !=
              DevicePerformance.low)
          ? center.translate(sin(progress * pi * 2 * 0.2 + i) * 100,
              cos(progress * pi * 2 * 0.3 + i) * 50)
          : center;
      final mistRadius = 300 + random.nextDouble() * 200;

      // High quality: more vibrant and visible nebula
      final isHighQuality = capabilities.performance == DevicePerformance.high;
      final baseAlpha = isHighQuality ? 15 : 5;
      final alphaRange = isHighQuality ? 15 : 5;
      final redBase = isHighQuality ? 80 : 50;
      final redRange = isHighQuality ? 50 : 30;
      final greenBase = isHighQuality ? 50 : 30;
      final greenRange = isHighQuality ? 40 : 30;
      final blueBase = isHighQuality ? 100 : 60;
      final blueRange = isHighQuality ? 60 : 30;

      final mistPaint = Paint()
        ..shader = ui.Gradient.radial(
          animatedCenter,
          mistRadius,
          [
            Color.fromARGB(
                (baseAlpha + random.nextInt(alphaRange)).clamp(0, 255),
                (redBase + random.nextInt(redRange)),
                (greenBase + random.nextInt(greenRange)),
                (blueBase + random.nextInt(blueRange))),
            Colors.transparent
          ],
        );
      canvas.drawCircle(animatedCenter, mistRadius, mistPaint);
    }

    final starCount = DevicePerformanceDetector.getAdaptiveParticleCount(200);
    for (int i = 0; i < starCount; i++) {
      final starPos =
          Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      final twinkle = (capabilities.performance != DevicePerformance.low)
          ? sin(progress * pi * 2 * 1.0 + i * 0.1) * 0.5 + 0.5
          : 0.75;

      // High quality: brighter, more visible stars
      final isHighQuality = capabilities.performance == DevicePerformance.high;
      final baseOpacity = isHighQuality ? 0.3 : 0.2;
      final opacityRange = isHighQuality ? 0.6 : 0.4;
      final opacity = (random.nextDouble() * opacityRange + baseOpacity) * twinkle;
      final starSize = random.nextDouble() * (isHighQuality ? 3.5 : 2.5) + 0.5;

      final starPaint = Paint()
        ..color = Colors.white.withAlpha((255 * opacity).round())
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, starSize * 0.7);
      canvas.drawCircle(starPos, starSize, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class StructurePainter extends CustomPainter {
  final double progress;
  final ui.Picture? structureCache;

  StructurePainter({
    required this.progress,
    this.structureCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (structureCache != null) {
      canvas.drawPicture(structureCache!);
    }
  }

  // --- MODIFIED: Branches are no longer part of the static structure painter ---
  static void paintStructure(
      Canvas canvas,
      Size size,
      ui.Path mainPath,
      ui.Path yearPath,
      List<ui.Path> roots,
      List<Memory> memories,
      List<YearPosition> yearPositions,
      double yearLineYFactor) {
    _drawRoots(canvas, roots);
    _drawArterySystem(canvas, mainPath);
    _drawYearLine(canvas, yearPath);
    _drawYearLabels(
        canvas, yearPositions, size.height * yearLineYFactor, memories);
  }

  // --- MODIFIED: Only draws the main path now ---
  static void _drawArterySystem(Canvas canvas, ui.Path mainPath) {
    const pulse = 1.0;
    const arteryColor = Color(0xFFFF8A80);

    final mainLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(7);
    _drawSingleArtery(canvas, mainPath,
        baseColor: arteryColor,
        intensity: 1.0,
        width: 1.0,
        pulse: pulse,
        maxLayers: mainLayerCount);
  }

  static void _drawRoots(Canvas canvas, List<ui.Path> roots) {
    const pulse = 1.0;
    const rootColor = Color(0xFF6B8DFF);

    final rootLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(3);
    for (final root in roots) {
      _drawSingleArtery(canvas, root,
          baseColor: rootColor,
          intensity: 0.4,
          width: 0.2,
          pulse: pulse,
          maxLayers: rootLayerCount);
    }
  }

  static void _drawSingleArtery(
    Canvas canvas,
    ui.Path path, {
    required Color baseColor,
    required double intensity,
    required double width,
    required double pulse,
    int maxLayers = 7,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // УЛУЧШЕНИЕ: Более плавный и натуральный градиент свечения
    // Каждый слой с blur для мягкого перехода
    // 12 слоев для high quality = профессиональное свечение

    // Слой 12: Максимально широкое, почти невидимое свечение (ultra high quality)
    if (maxLayers > 11) {
      paint.strokeWidth = (160.0 * pulse * width * intensity).clamp(1.0, 350.0);
      paint.color = baseColor.withValues(alpha: 0.02 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 50.0);
      canvas.drawPath(path, paint);
    }

    // Слой 11: Очень широкое внешнее свечение
    if (maxLayers > 10) {
      paint.strokeWidth = (140.0 * pulse * width * intensity).clamp(1.0, 320.0);
      paint.color = baseColor.withValues(alpha: 0.025 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 45.0);
      canvas.drawPath(path, paint);
    }

    // Слой 10: Очень широкое, едва заметное свечение
    if (maxLayers > 9) {
      paint.strokeWidth = (120.0 * pulse * width * intensity).clamp(1.0, 300.0);
      paint.color = baseColor.withValues(alpha: 0.03 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 40.0);
      canvas.drawPath(path, paint);
    }

    // Слой 9: Широкое внешнее свечение
    if (maxLayers > 8) {
      paint.strokeWidth = (90.0 * pulse * width * intensity).clamp(1.0, 250.0);
      paint.color = baseColor.withValues(alpha: 0.05 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 30.0);
      canvas.drawPath(path, paint);
    }

    // Слой 8: Среднее свечение
    if (maxLayers > 7) {
      paint.strokeWidth = (70.0 * pulse * width * intensity).clamp(1.0, 200.0);
      paint.color = baseColor.withValues(alpha: 0.08 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 25.0);
      canvas.drawPath(path, paint);
    }

    // Слой 7: Переходное свечение
    if (maxLayers > 6) {
      paint.strokeWidth = (55.0 * pulse * width * intensity).clamp(1.0, 180.0);
      paint.color = baseColor.withValues(alpha: 0.12 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0);
      canvas.drawPath(path, paint);
    }

    // Слой 6: Заметное свечение
    if (maxLayers > 5) {
      paint.strokeWidth = (40.0 * pulse * width * intensity).clamp(1.0, 150.0);
      paint.color = baseColor.withValues(alpha: 0.15 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 15.0);
      canvas.drawPath(path, paint);
    }

    // Слой 5: Яркое свечение
    if (maxLayers > 4) {
      paint.strokeWidth = (28.0 * pulse * width * intensity).clamp(1.0, 120.0);
      paint.color = baseColor.withValues(alpha: 0.25 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12.0);
      canvas.drawPath(path, paint);
    }

    // Слой 4: Внутреннее свечение
    if (maxLayers > 3) {
      paint.strokeWidth = (18.0 * pulse * width * intensity).clamp(1.0, 90.0);
      paint.color = baseColor.withValues(alpha: 0.35 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8.0);
      canvas.drawPath(path, paint);
    }

    // Слой 3: Переход к ядру
    if (maxLayers > 2) {
      paint.strokeWidth = (10.0 * pulse * width * intensity).clamp(1.0, 60.0);
      paint.color = baseColor.withValues(alpha: 0.5 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);
      canvas.drawPath(path, paint);
    }

    // Слой 2: Яркое ядро
    if (maxLayers > 1) {
      paint.strokeWidth = (5.0 * pulse * width * intensity).clamp(1.0, 40.0);
      paint.color = Color.lerp(baseColor, Colors.white, 0.3)!.withValues(alpha: 0.75 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3.0);
      canvas.drawPath(path, paint);
    }

    // Слой 1: Центральная светящаяся линия
    if (maxLayers > 0) {
      paint.strokeWidth = (2.5 * pulse * width).clamp(1.0, 15.0);
      paint.color = Color.lerp(baseColor, Colors.white, 0.7)!.withValues(alpha: 0.95 * intensity);
      paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 1.5);
      canvas.drawPath(path, paint);
    }
  }

  static void _drawYearLine(Canvas canvas, ui.Path path) {
    final yearLinePaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.05).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, yearLinePaint);
  }

  static void _drawYearLabels(Canvas canvas, List<YearPosition> yearPositions,
      double lineY, List<Memory> memories) {
    if (memories.isEmpty) return;
    final activeYears = memories.map((m) => m.date.year).toSet();

    for (final yearPos in yearPositions) {
      if (activeYears.contains(yearPos.year)) {
        final textStyle = GoogleFonts.orbitron(
            color: Colors.white.withAlpha((255 * 0.3).round()),
            fontSize: 10.0,
            fontWeight: FontWeight.bold);
        final textBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
          textAlign: TextAlign.center,
          fontFamily: textStyle.fontFamily,
          fontSize: textStyle.fontSize,
          fontWeight: textStyle.fontWeight,
        ))..addText(yearPos.year.toString());
        final paragraph = textBuilder.build()
          ..layout(const ui.ParagraphConstraints(width: 50));
        final textPos = Offset(yearPos.x - paragraph.width / 2, lineY - 25);
        canvas.drawParagraph(paragraph, textPos);
      }
    }
  }

  @override
  bool shouldRepaint(covariant StructurePainter old) {
    return old.progress != progress || old.structureCache != structureCache;
  }
}

class LifelinePainter extends CustomPainter {
  final double progress;
  final List<Memory> memories;
  final Map<String, ui.Paragraph> paragraphs;
  final NodePosCallback? onNodePosition;
  final DailyClusterPosCallback? onDailyClusterPosition;
  final double zoomScale;
  final double pulseValue;
  final double branchIntensity; // NEW

  final RenderData renderData;
  final Map<String, ui.Image> images;
  final ValueNotifier<PaintTimings?>? timingsNotifier;

  static const double kMacroDetailThreshold = 0.8;
  static const double kTransitionRange = 0.3;
  static const double kNodeBaseRadius = 10.0;
  static const double kDailyClusterBaseRadius = 13.0;
  static const double kVisibilityBuffer = 100.0;
  static const double kNodeVerticalOffset = 0.0;

  LifelinePainter({
    required this.progress,
    required this.renderData,
    this.memories = const <Memory>[],
    required this.paragraphs,
    this.onNodePosition,
    this.onDailyClusterPosition,
    this.zoomScale = 1.0,
    this.pulseValue = 0.0,
    this.timingsNotifier,
    required this.images,
    required this.branchIntensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stopwatch = Stopwatch();
    int nodesTime = 0;
    int labelsTime = 0;
    int macroViewTime = 0;

    if (size.width <= 0 || size.height <= 0 || memories.isEmpty) return;

    final mainPath = renderData.mainPath;
    final placementResults = renderData.placementResults;
    final visibleRect = canvas.getDestinationClipBounds().inflate(kVisibilityBuffer);
    final macroToDetail = ((zoomScale - (kMacroDetailThreshold - kTransitionRange / 2)) / kTransitionRange).clamp(0.0, 1.0);
    final macroOpacity = 1.0 - macroToDetail;
    final detailOpacity = macroToDetail;

    if (macroOpacity > 0) {
      stopwatch.start();
      _drawMacroView(canvas, mainPath, size, macroOpacity);
      stopwatch.stop();
      macroViewTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();
    }

    // --- Draw animated branches dynamically ---
    // FIXED: Removed "detailOpacity > 0" condition to make branches always visible
    // OPTIMIZATION: Skip branches entirely when zoomed out very far (not visible anyway)
    if (branchIntensity > 0 && zoomScale > 0.2) {
      final branches =
          renderData.branches; // These paths are pre-animated from the isolate
      const arteryColor = Color(0xFFFF8A80);
      final baseBranchLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(4);

      // LOD OPTIMIZATION: Reduce layers when zoomed out (less detail needed)
      // At zoom < 0.5, reduce to 60% of layers (saves GPU time)
      // At zoom < 0.3, reduce to 40% of layers
      final branchLayerCount = zoomScale < 0.3
          ? (baseBranchLayerCount * 0.4).round().clamp(1, baseBranchLayerCount)
          : zoomScale < 0.5
              ? (baseBranchLayerCount * 0.6).round().clamp(1, baseBranchLayerCount)
              : baseBranchLayerCount;

      final pulse = sin(pulseValue * pi * 2) * 0.1 + 0.95;

      // LOD OPTIMIZATION: Draw fewer branches when zoomed out
      // At zoom < 0.3, draw every 4th branch
      // At zoom < 0.5, draw every 2nd branch
      // At zoom >= 0.5, draw all branches
      final branchStep = zoomScale < 0.3 ? 4 : zoomScale < 0.5 ? 2 : 1;

      for (int i = 0; i < branches.length; i += branchStep) {
        final branchPath = branches[i];
        // We use the static method from StructurePainter, but call it here for dynamic rendering
        StructurePainter._drawSingleArtery(canvas, branchPath,
            baseColor: arteryColor,
            intensity: 0.4 *
                branchIntensity, // Use the dynamic intensity from the slider
            width: 0.3,
            pulse: pulse,
            maxLayers: branchLayerCount);
      }
    }
    // --- End of branch drawing ---

    if (detailOpacity > 0) {
      final labelsOpacity =
          ((zoomScale - kMacroDetailThreshold) / 0.5).clamp(0.0, 1.0);
      if (labelsOpacity > 0) {
        final singleNodeInfos =
            placementResults.whereType<PlacementInfo>().toList();
        stopwatch.start();
        _drawMemoryLabels(
            canvas,
            size, // ИСПРАВЛЕНО: Используем полный размер холста, а не границы пути
            singleNodeInfos,
            visibleRect,
            detailOpacity * labelsOpacity);
        stopwatch.stop();
        labelsTime = stopwatch.elapsedMicroseconds;
        stopwatch.reset();
      }

      stopwatch.start();
      for (final item in placementResults) {
        if (item is PlacementInfo) {
          if (visibleRect
              .inflate(kNodeBaseRadius * 2)
              .contains(item.nodePosition)) {
            final index = memories
                .indexWhere((m) => m.universalId == item.memory.universalId);
            final image = images[item.memory.coverPath];
            _drawSingleMemoryNode(
                canvas, item.nodePosition, item.memory, index, detailOpacity, image);
            onNodePosition?.call(item.memory.universalId, item.nodePosition);
          }
        } else if (item is DailyClusterPlacementInfo) {
          if (visibleRect
              .inflate(kDailyClusterBaseRadius * 2)
              .contains(item.position)) {
            final image = images[item.memories.first.coverPath];
            _drawDailyClusterNode(canvas, item.position, item, detailOpacity, image);
            onDailyClusterPosition?.call(item.id, item.position, item.memories);
          }
        } else if (item is TimeGapPlacementInfo) {
          if (zoomScale >= 3 && zoomScale <= 5.0) {
            if (visibleRect.inflate(20).contains(item.position)) {
              _drawTimeGapMarker(canvas, item, size, detailOpacity);
            }
          }
        }
      }
      stopwatch.stop();
      nodesTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (timingsNotifier != null) {
        final currentTimings = timingsNotifier!.value ?? PaintTimings();
        timingsNotifier!.value = currentTimings.copyWith(
          macroView: (macroViewTime / 1000).round(),
          labels: (labelsTime / 1000).round(),
          nodes: (nodesTime / 1000).round(),
        );
      }
    });
  }

  void _drawMacroView(Canvas canvas, ui.Path path, Size size, double opacity) {
    if (memories.length < 2 || opacity <= 0) return;
    if (path.computeMetrics().isEmpty) return;
    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;
    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.compareTo(b.date));
    final minDate = sortedMemories.first.date;
    final maxDate = sortedMemories.last.date;
    final totalSpan = maxDate.difference(minDate).inMilliseconds;
    if (totalSpan == 0) return;
    final Map<int, int> memoriesPerYear = {};
    for (final memory in sortedMemories) {
      memoriesPerYear.update(memory.date.year, (value) => value + 1,
          ifAbsent: () => 1);
    }
    if (memoriesPerYear.isEmpty) return;
    final maxCount = memoriesPerYear.values.reduce(max);
    memoriesPerYear.forEach((year, count) {
      final firstDayOfYear = DateTime(year);
      final t =
          (firstDayOfYear.difference(minDate).inMilliseconds / totalSpan)
              .clamp(0.0, 1.0);
      final pos = metrics.getTangentForOffset(t * totalLen)?.position;
      if (pos != null) {
        final intensity = count / maxCount;
        final paint = Paint()
          ..color = Color.lerp(Colors.blue.withAlpha((255 * 0.1).round()),
                  Colors.red.withAlpha((255 * 0.6).round()), intensity)!
              .withAlpha((255 * opacity).round())
          ..maskFilter =
              ui.MaskFilter.blur(ui.BlurStyle.normal, 30 + 40 * intensity);
        canvas.drawCircle(pos, 40 + 60 * intensity, paint);
      }
    });
  }

  void _drawMemoryLabels(Canvas canvas, Size size,
      List<PlacementInfo> placementInfos, Rect visibleRect, double opacity) {
    if (opacity <= 0) return;

    final sortedInfos = List<PlacementInfo>.from(placementInfos)
      ..sort((a, b) => a.nodePosition.dx.compareTo(b.nodePosition.dx));

    Rect? lastPlacedRect;
    bool wasLastPlacedAbove = false;

    for (int i = 0; i < sortedInfos.length; i++) {
      final info = sortedInfos[i];

      if (!visibleRect.inflate(400).contains(info.nodePosition)) {
        continue;
      }

      final paragraph = paragraphs[info.memory.universalId];
      if (paragraph == null) continue;

      const verticalOffset = 40.0;
      const horizontalPadding = 10.0;
      final nodePos = info.nodePosition;

      // ИСПРАВЛЕНО: Убрана специальная логика для последнего элемента, используется полный размер холста.
      double calculateTextX(Offset nodePosition) {
        double x = nodePosition.dx - paragraph.width / 2;
        // Проверяем левую границу
        if (x < 5.0) x = 5.0;
        // Проверяем правую границу для ВСЕХ элементов
        if (x + paragraph.width > size.width - 5.0) {
          x = size.width - 5.0 - paragraph.width;
        }
        return x;
      }

      final textX = calculateTextX(nodePos);

      final topRect = Rect.fromLTWH(textX,
          nodePos.dy - verticalOffset - paragraph.height, paragraph.width, paragraph.height);
      final bottomRect =
          Rect.fromLTWH(textX, nodePos.dy + verticalOffset, paragraph.width, paragraph.height);

      bool placeAbove;

      if (lastPlacedRect == null) {
        placeAbove = true;
      } else {
        placeAbove = !wasLastPlacedAbove;
      }

      Rect potentialRect = placeAbove ? topRect : bottomRect;

      if (lastPlacedRect != null &&
          lastPlacedRect.inflate(horizontalPadding).overlaps(potentialRect)) {
        placeAbove = !placeAbove;
        potentialRect = placeAbove ? topRect : bottomRect;
      }

      final finalRect = potentialRect;

      _drawConnectorLine(canvas, nodePos, finalRect, placeAbove, opacity);

      canvas.saveLayer(finalRect.inflate(2),
          Paint()..color = Colors.white.withAlpha((255 * opacity).round()));
      canvas.drawParagraph(paragraph, finalRect.topLeft);
      canvas.restore();

      lastPlacedRect = finalRect;
      wasLastPlacedAbove = placeAbove;
    }
  }

  void _drawConnectorLine(
      Canvas canvas, Offset nodePos, Rect textRect, bool isAbove, double opacity) {
    final linePaint = Paint()
      ..color = Colors.white.withAlpha((255 * 0.4 * opacity).round())
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    const double nodeOffset = 15.0;

    final adjustedNodePos = nodePos.translate(0, kNodeVerticalOffset);

    final startPoint = Offset(
        adjustedNodePos.dx, adjustedNodePos.dy + (isAbove ? -nodeOffset : nodeOffset));
    final endPoint = isAbove
        ? Offset(adjustedNodePos.dx, textRect.bottom)
        : Offset(adjustedNodePos.dx, textRect.top);

    canvas.drawLine(startPoint, endPoint, linePaint);
  }

  void _drawSingleMemoryNode(Canvas canvas, Offset pos, Memory memory, int index,
      double opacity, ui.Image? image) {
    final individualPulse = sin(pulseValue * pi * 2 + index * 0.8) * 0.3 + 0.7;
    final breathPulse = sin(progress * pi * 0.5 + index * 0.5) * 0.2 + 0.8;
    final combinedPulse = individualPulse * breathPulse;

    final nodeRadius = kNodeBaseRadius * combinedPulse * 1.5;

    final adjustedPos = pos.translate(0, kNodeVerticalOffset);

    if (image != null) {
      final imageRect = Rect.fromCircle(center: adjustedPos, radius: nodeRadius);
      final imagePath = Path()..addOval(imageRect);

      final borderPaint = Paint()
        ..color = Colors.white.withAlpha((200 * opacity).round())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * combinedPulse;

      canvas.save();
      canvas.clipPath(imagePath);

      final double imgWidth = image.width.toDouble();
      final double imgHeight = image.height.toDouble();
      final double aspectRatio = imgWidth / imgHeight;

      Rect srcRect;
      if (aspectRatio > 1.0) {
        final croppedWidth = imgHeight;
        srcRect = Rect.fromLTWH(
            (imgWidth - croppedWidth) / 2, 0, croppedWidth, imgHeight);
      } else {
        final croppedHeight = imgWidth;
        srcRect =
            Rect.fromLTWH(0, (imgHeight - croppedHeight) / 2, imgWidth, croppedHeight);
      }

      canvas.drawImageRect(image, srcRect, imageRect, Paint());
      canvas.restore();

      canvas.drawPath(imagePath, borderPaint);
    } else {
      _drawDefaultNode(canvas, adjustedPos, nodeRadius, opacity, index, memory);
    }

    // ЭМОЦИОНАЛЬНАЯ АУРА: добавляем свечение вокруг узлов с эмоциями
    if (memory.primaryEmotion != null) {
      _drawEmotionAura(canvas, adjustedPos, nodeRadius, opacity, memory);
    }

    // --- ИЗМЕНЕНИЕ: Рисуем замок, если воспоминание зашифровано ---
    if (memory.isEncrypted) {
      _drawLockIcon(canvas, adjustedPos, nodeRadius, opacity);
    }
  }

  void _drawDefaultNode(
      Canvas canvas, Offset adjustedPos, double nodeRadius, double opacity, int index, Memory memory) {
    final combinedPulse = nodeRadius / (kNodeBaseRadius * 1.5);
    final paint = Paint();

    // ЭМОЦИОНАЛЬНАЯ ОКРАСКА: используем цвет эмоции или выцветший серый
    final hasEmotion = memory.primaryEmotion != null;
    final nodeColor = hasEmotion
        ? _getEmotionColor(memory.primaryEmotion)
        : Colors.grey.shade700; // "выцветшее" воспоминание

    // Для воспоминаний без эмоции: уменьшаем opacity (эффект выцветшей фотографии)
    final emotionOpacityMultiplier = hasEmotion ? 1.0 : 0.3;

    paint.color = nodeColor.withValues(alpha: (0.6 * combinedPulse) * opacity * emotionOpacityMultiplier);
    canvas.drawCircle(adjustedPos, nodeRadius, paint);

    final coreColor = Color.lerp(nodeColor, Colors.white, 0.6)!;
    paint.color = coreColor.withValues(alpha: (0.9 * combinedPulse) * opacity * emotionOpacityMultiplier);
    canvas.drawCircle(adjustedPos, nodeRadius * 0.7, paint);

    final brightIntensity = 0.7 + sin(pulseValue * pi * 4 + index * 1.2) * 0.3;
    paint.color =
        Colors.white.withValues(alpha: 0.9 * brightIntensity * combinedPulse * opacity * emotionOpacityMultiplier);
    canvas.drawCircle(adjustedPos, nodeRadius * 0.3, paint);
  }

  /// Рисует ауру (свечение) вокруг узла с эмоцией
  void _drawEmotionAura(Canvas canvas, Offset pos, double nodeRadius, double opacity, Memory memory) {
    final emotionColor = _getEmotionColor(memory.primaryEmotion);
    final intensity = memory.emotionIntensity;

    // Адаптивный blur radius для производительности
    final blurRadius = DevicePerformanceDetector.getAdaptiveBlurRadius(20.0 * intensity);
    if (blurRadius <= 0) return; // Skip на low-end устройствах

    final auraPaint = Paint()
      ..color = emotionColor.withValues(alpha: 0.3 * intensity * opacity)
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius);

    // Основная аура
    canvas.drawCircle(pos, nodeRadius * 1.8 * intensity, auraPaint);

    // Вторичная эмоция (если есть) — второе кольцо ауры
    if (memory.secondaryEmotion != null) {
      final secondaryColor = _getEmotionColor(memory.secondaryEmotion);
      final secondaryPaint = Paint()
        ..color = secondaryColor.withValues(alpha: 0.2 * intensity * opacity)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius * 1.5);

      canvas.drawCircle(pos, nodeRadius * 2.5 * intensity, secondaryPaint);
    }
  }

  void _drawDailyClusterNode(Canvas canvas, Offset pos,
      DailyClusterPlacementInfo clusterInfo, double opacity, ui.Image? image) {
    final index = memories
        .indexWhere((m) => m.universalId == clusterInfo.memories.first.universalId);
    final individualPulse = sin(pulseValue * pi * 2 + index * 0.8) * 0.3 + 0.7;
    final breathPulse = sin(progress * pi * 0.5 + index * 0.5) * 0.2 + 0.8;
    final combinedPulse = individualPulse * breathPulse;
    final nodeRadius = kDailyClusterBaseRadius * combinedPulse;

    final adjustedPos = pos.translate(0, kNodeVerticalOffset);

    _drawSingleMemoryNode(canvas, pos, clusterInfo.memories.first, index, opacity, image);

    final ringColor = Color.lerp(const Color(0xFFFF6B6B), Colors.white, 0.7)!;

    final ringPaint = Paint()
      ..color = ringColor.withValues(alpha: 0.7 * combinedPulse * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * combinedPulse;
    canvas.drawCircle(adjustedPos, nodeRadius * 1.5, ringPaint);

    final ringBlur =
        DevicePerformanceDetector.getAdaptiveBlurRadius(10 * combinedPulse);
    if (ringBlur > 0) {
      final ringGlow = Paint()
        ..color = ringColor.withValues(alpha: 0.3 * combinedPulse * opacity)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, ringBlur)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(adjustedPos, nodeRadius * 1.5, ringGlow);
    }
    
    // --- ИЗМЕНЕНИЕ: Проверяем, есть ли в кластере зашифрованные воспоминания ---
    final bool isClusterEncrypted = clusterInfo.memories.any((m) => m.isEncrypted);
    if(isClusterEncrypted) {
      _drawLockIcon(canvas, adjustedPos, nodeRadius * 1.5, opacity);
    }

    final textStyle = GoogleFonts.orbitron(
        color: ringColor.withValues(alpha: opacity),
        fontSize: 10.0,
        fontWeight: FontWeight.bold,
        shadows: const [ui.Shadow(color: Colors.black, blurRadius: 4.0)]);
    final textSpan =
        TextSpan(text: clusterInfo.memories.length.toString(), style: textStyle);
    final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    textPainter.layout();
    final textPos = Offset(
        adjustedPos.dx - textPainter.width / 2, adjustedPos.dy - textPainter.height / 2);
    textPainter.paint(canvas, textPos);
  }

  // --- НОВЫЙ МЕТОД: Рисует иконку замка ---
  void _drawLockIcon(Canvas canvas, Offset center, double nodeRadius, double opacity) {
    final iconSize = nodeRadius * 0.7;
    const icon = Icons.lock_outline;
    final textStyle = TextStyle(
        color: Colors.white.withValues(alpha: 0.9 * opacity),
        fontSize: iconSize,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
    );
    final textSpan = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: textStyle,
    );
    final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final iconPosition = Offset(
        center.dx - textPainter.width / 2,
        center.dy + nodeRadius - textPainter.height,
    );
    
    final backgroundRect = Rect.fromCenter(
        center: iconPosition.translate(textPainter.width / 2, textPainter.height / 2),
        width: textPainter.width + 4,
        height: textPainter.height + 4
    );
    final backgroundPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4 * opacity)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2.0);
    canvas.drawRRect(RRect.fromRectAndRadius(backgroundRect, const Radius.circular(4)), backgroundPaint);

    textPainter.paint(canvas, iconPosition);
  }


  void _drawTimeGapMarker(
      Canvas canvas, TimeGapPlacementInfo info, Size canvasSize, double opacity) {
    final pos = info.position.translate(0, 20.0);

    final textStyle = GoogleFonts.orbitron(
      color: Colors.cyan.withAlpha((200 * opacity).round()),
      fontSize: 5.0,
      fontWeight: FontWeight.normal,
    );
    final textSpan = TextSpan(
      text: '${info.days} days',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textPos = Offset(pos.dx - textPainter.width / 2, pos.dy);
    textPainter.paint(canvas, textPos);
  }

  // === EMOTION VISUALIZATION HELPERS ===

  /// Возвращает цвет эмоции для узла
  Color _getEmotionColor(String? emotion) {
    if (emotion == null) return const Color(0xFFFF6B6B); // default red

    switch (emotion) {
      case 'joy':
        return const Color(0xFFFFC107); // yellow
      case 'sadness':
        return const Color(0xFF2196F3); // blue
      case 'anger':
        return const Color(0xFFF44336); // red
      case 'fear':
        return const Color(0xFF4CAF50); // green
      case 'disgust':
        return const Color(0xFFCDDC39); // lime
      case 'surprise':
        return const Color(0xFFFF9800); // orange
      case 'love':
        return const Color(0xFFE91E63); // pink
      case 'pride':
        return const Color(0xFF9C27B0); // purple
      default:
        return const Color(0xFFFF6B6B); // default red
    }
  }

  @override
  bool shouldRepaint(covariant LifelinePainter old) {
    return old.progress != progress ||
        old.pulseValue != pulseValue ||
        !listEquals(old.memories, memories) ||
        old.zoomScale != zoomScale ||
        !mapEquals(old.images, images) ||
        old.branchIntensity != branchIntensity ||
        old.renderData != renderData;
  }
}
