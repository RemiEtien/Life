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
      final mistPaint = Paint()
        ..shader = ui.Gradient.radial(
          animatedCenter,
          mistRadius,
          [
            Color.fromARGB(
                (5 + random.nextInt(5)).clamp(0, 255),
                (50 + random.nextInt(30)),
                (30 + random.nextInt(30)),
                (60 + random.nextInt(30))),
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
      final opacity = (random.nextDouble() * 0.4 + 0.2) * twinkle;
      final starSize = random.nextDouble() * 2.5 + 0.5;
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

    if (maxLayers > 4) {
      paint.strokeWidth = (40.0 * pulse * width * intensity).clamp(1.0, 200.0);
      paint.color = baseColor.withValues(alpha: 0.1 * intensity);
      canvas.drawPath(path, paint);
    }
    if (maxLayers > 2) {
      paint.strokeWidth = (15.0 * pulse * width * intensity).clamp(1.0, 100.0);
      paint.color = baseColor.withValues(alpha: 0.2 * intensity);
      canvas.drawPath(path, paint);
    }
    if (maxLayers > 1) {
      paint.strokeWidth = (6.0 * pulse * width * intensity).clamp(1.0, 50.0);
      paint.color = baseColor.withValues(alpha: 0.7 * intensity);
      canvas.drawPath(path, paint);
    }
    if (maxLayers > 0) {
      paint.strokeWidth = (2.0 * pulse * width).clamp(1.0, 10.0);
      paint.color =
          Color.lerp(baseColor, Colors.white, 0.8)!.withValues(alpha: 0.9 * intensity);
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
    if (branchIntensity > 0) {
      final branches =
          renderData.branches; // These paths are pre-animated from the isolate
      const arteryColor = Color(0xFFFF8A80);
      final branchLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(4);
      final pulse = sin(pulseValue * pi * 2) * 0.1 + 0.95;

      for (final branchPath in branches) {
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
      _drawDefaultNode(canvas, adjustedPos, nodeRadius, opacity, index);
    }

    // --- ИЗМЕНЕНИЕ: Рисуем замок, если воспоминание зашифровано ---
    if (memory.isEncrypted) {
      _drawLockIcon(canvas, adjustedPos, nodeRadius, opacity);
    }
  }

  void _drawDefaultNode(
      Canvas canvas, Offset adjustedPos, double nodeRadius, double opacity, int index) {
    final combinedPulse = nodeRadius / (kNodeBaseRadius * 1.5);
    final paint = Paint();
    const nodeColor = Color(0xFFFF6B6B);

    paint.color = nodeColor.withValues(alpha: (0.6 * combinedPulse) * opacity);
    canvas.drawCircle(adjustedPos, nodeRadius, paint);

    final coreColor = Color.lerp(nodeColor, Colors.white, 0.6)!;
    paint.color = coreColor.withValues(alpha: (0.9 * combinedPulse) * opacity);
    canvas.drawCircle(adjustedPos, nodeRadius * 0.7, paint);

    final brightIntensity = 0.7 + sin(pulseValue * pi * 4 + index * 1.2) * 0.3;
    paint.color =
        Colors.white.withValues(alpha: 0.9 * brightIntensity * combinedPulse * opacity);
    canvas.drawCircle(adjustedPos, nodeRadius * 0.3, paint);
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
