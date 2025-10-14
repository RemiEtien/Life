import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../memory.dart';
import '../models/user_profile.dart';
import '../utils/emotion_colors.dart';
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

typedef MonthlyClusterPosCallback = void Function(
    List<String> monthKeys, Offset pos, List<Memory> memories, DateTime month);

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

    // Снижено для производительности: было 200, стало 50
    final starCount = DevicePerformanceDetector.getAdaptiveParticleCount(50);
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
      double yearLineYFactor,
      {UserProfile? userProfile}) {
    _drawRoots(canvas, roots);

    // Стандартная красная линия (градиент удален - выглядел плохо)
    _drawArterySystem(canvas, mainPath);

    _drawYearLine(canvas, yearPath);
    _drawYearLabels(
        canvas, yearPositions, size.height * yearLineYFactor, memories);
  }

  // Стандартная линия без градиента
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

  // Новый метод: линия с градиентом на основе эмоций
  static void _drawEmotionalGradientLine(Canvas canvas, ui.Path mainPath, List<Memory> memories) {
    const pulse = 1.0;

    // Создаем список цветов на основе эмоций воспоминаний
    final colors = <Color>[];
    for (final memory in memories) {
      colors.add(_getEmotionColorStatic(memory.primaryEmotion));
    }

    // Если меньше 2 цветов, используем стандартный цвет
    if (colors.length < 2) {
      _drawArterySystem(canvas, mainPath);
      return;
    }

    // Создаем вертикальный градиент (Timeline идет сверху вниз по оси Y)
    final bounds = mainPath.getBounds();
    final gradient = ui.Gradient.linear(
      Offset(bounds.center.dx, bounds.top),     // Начало по центру X, сверху по Y
      Offset(bounds.center.dx, bounds.bottom),  // Конец по центру X, снизу по Y
      colors,
      List.generate(colors.length, (i) => i / (colors.length - 1)),
    );

    final mainLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(7);

    // Рисуем с градиентом используя _drawSingleArtery логику
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Слои для свечения (упрощенная версия _drawSingleArtery)
    for (int layer = mainLayerCount; layer >= 1; layer--) {
      final layerProgress = layer / mainLayerCount;
      paint.strokeWidth = (160.0 * pulse * layerProgress).clamp(1.0, 350.0);
      paint.shader = gradient;

      if (layer > 3) {
        paint.maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 20.0 * (layerProgress));
      } else if (layer > 1) {
        paint.maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5.0);
      } else {
        paint.maskFilter = null;
      }

      canvas.drawPath(mainPath, paint);
    }
  }

  static Color _getEmotionColorStatic(String? emotion) {
    return EmotionColors.getColor(emotion);
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
  final MonthlyClusterPosCallback? onMonthlyClusterPosition;
  final double zoomScale; // Relative zoom (for backward compatibility)
  final double currentScale; // NEW: Absolute zoom scale for universal level boundaries
  final double minScale; // NEW: Base scale for dynamic node sizing
  final double screenWidth; // NEW: Real screen width for baseScale calculation
  final double pulseValue;
  final double branchIntensity; // NEW

  final RenderData renderData;
  final Map<String, ui.Image> images;
  final ValueNotifier<PaintTimings?>? timingsNotifier;
  final UserProfile? userProfile; // NEW: для условного рендеринга эффектов

  // RESTORED from v149: Simple constant node radius
  // With absolute scale system (1200px visual lock), nodes automatically
  // appear same size at maxScale on all timelines without dynamic adjustments
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
    this.onMonthlyClusterPosition,
    this.zoomScale = 1.0,
    required this.currentScale,
    required this.minScale, // NEW: Base scale for fixed node sizing
    required this.screenWidth, // NEW: Real screen width for baseScale calculation
    this.pulseValue = 0.0,
    this.timingsNotifier,
    required this.images,
    required this.branchIntensity,
    this.userProfile, // NEW: может быть null
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stopwatch = Stopwatch();
    int nodesTime = 0;
    int labelsTime = 0;
    int macroViewTime = 0;

    if (size.width <= 0 || size.height <= 0 || memories.isEmpty) return;

    // DIAGNOSTIC: Log node sizing parameters once per paint
    if (kDebugMode) {
      debugPrint('[LifelinePainter] minScale=$minScale, kNodeBaseRadius=$kNodeBaseRadius, currentScale=$currentScale, relativeZoom=$zoomScale');
    }

    final mainPath = renderData.mainPath;
    final placementResults = renderData.placementResults;
    final visibleRect = canvas.getDestinationClipBounds().inflate(kVisibilityBuffer);

    // === 3-LEVEL ZOOM SYSTEM (ABSOLUTE SCALE BASED - v149 RESTORED) ===
    // Strategy: Use absolute currentScale thresholds based on 1200px visual lock
    // All timelines transition at the SAME absolute scale values
    //
    // Formula: baseScale = screenWidth / 1200.0, maxScale = baseScale × 6.0
    // Level thresholds are proportional to baseScale:
    // LEVEL 1 (Yearly): currentScale < baseScale × 2.0
    // LEVEL 2 (Monthly): baseScale × 2.0 <= currentScale < baseScale × 4.0
    // LEVEL 3 (Individual): currentScale >= baseScale × 4.0
    //
    // This ensures nodes appear same size at maxScale on ALL timelines

    // Calculate baseScale from screen width (visual lock reference)
    const double kBaseContentWidth = 1200.0;
    // CRITICAL: Use REAL screen width, not timeline content width!
    // screenWidth is passed from widget (constraints.maxWidth of viewport)
    final baseScale = (screenWidth * 0.95) / kBaseContentWidth;

    // CRITICAL FIX: For long timelines where minScale < baseScale,
    // we need to adjust thresholds relative to minScale, not baseScale
    // Otherwise thresholds can be below minScale and levels never trigger!
    final effectiveBase = max(minScale, baseScale);

    // Absolute scale thresholds (adjusted for timeline length)
    // Use factors that work from effectiveBase to maxScale
    final kLevel2Threshold = effectiveBase * 1.5;  // Monthly clusters start at 150% of base
    final kLevel3Threshold = effectiveBase * 3.0;  // Individual nodes start at 300% of base

    // DEBUG: Log level detection at each paint
    if (kDebugMode) {
      String currentLevel;
      if (currentScale < kLevel2Threshold) {
        currentLevel = 'LEVEL 1 (Yearly)';
      } else if (currentScale >= kLevel2Threshold && currentScale < kLevel3Threshold) {
        currentLevel = 'LEVEL 2 (Monthly)';
      } else {
        currentLevel = 'LEVEL 3 (Individual)';
      }
      debugPrint('[LifelinePainter] currentScale=$currentScale, Level2Threshold=$kLevel2Threshold, Level3Threshold=$kLevel3Threshold => $currentLevel');
    }

    // Use ABSOLUTE currentScale for level determination (v149 system)
    if (currentScale < kLevel2Threshold) {
      // LEVEL 1: Yearly gradient
      if (kDebugMode) debugPrint('[LifelinePainter] Drawing yearly gradient');
      stopwatch.start();
      _drawYearlyGradient(canvas, mainPath, size, currentScale, effectiveBase, kLevel2Threshold);
      stopwatch.stop();
      macroViewTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();
    }
    else if (currentScale >= kLevel2Threshold) {
      // LEVEL 2 & 3: Monthly clusters (visible in Level 2, invisible but clickable in Level 3)
      if (kDebugMode) {
        if (currentScale < kLevel3Threshold) {
          debugPrint('[LifelinePainter] Drawing monthly clusters (visible)');
        } else {
          debugPrint('[LifelinePainter] Drawing monthly clusters (invisible but clickable)');
        }
      }
      stopwatch.start();
      _drawMonthlyClusters(canvas, mainPath, size, currentScale, placementResults, effectiveBase, kLevel2Threshold, kLevel3Threshold);
      stopwatch.stop();
      macroViewTime = stopwatch.elapsedMicroseconds;
      stopwatch.reset();
    }

    // Calculate detailOpacity for Level 3
    // Fade in individual nodes as we approach kLevel3Threshold
    final fadeInStart = kLevel3Threshold - effectiveBase;  // Start fading 1 effectiveBase unit before threshold
    final detailOpacity = (currentScale < fadeInStart)
        ? 0.0
        : ((currentScale - fadeInStart) / effectiveBase).clamp(0.0, 1.0);

    // --- Draw animated branches dynamically ---
    // FIXED: Removed "detailOpacity > 0" condition to make branches always visible
    // OPTIMIZATION: Skip branches entirely when zoomed out very far (not visible anyway)
    if (branchIntensity > 0 && zoomScale > 0.8) {
      final branches =
          renderData.branches; // These paths are pre-animated from the isolate
      const arteryColor = Color(0xFFFF8A80);
      final baseBranchLayerCount = DevicePerformanceDetector.getAdaptiveLayerCount(4);

      // LOD OPTIMIZATION: Reduce layers when zoomed out (less detail needed)
      // At zoom < 2.5 (< 250%), reduce to 70% of layers (more visible at yearly zoom)
      // At zoom < 1.5 (< 150%), reduce to 50% of layers
      final branchLayerCount = zoomScale < 1.5
          ? (baseBranchLayerCount * 0.5).round().clamp(1, baseBranchLayerCount)
          : zoomScale < 2.5
              ? (baseBranchLayerCount * 0.7).round().clamp(1, baseBranchLayerCount)
              : baseBranchLayerCount;

      final pulse = sin(pulseValue * pi * 2) * 0.1 + 0.95;

      // LOD OPTIMIZATION: Draw more branches at yearly zoom level
      // At zoom < 1.5, draw every 2nd branch (was: every 4th)
      // At zoom < 2.5, draw all branches (was: every 2nd at < 2.0)
      // At zoom >= 2.5, draw all branches
      final branchStep = zoomScale < 1.5 ? 2 : 1;

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

    // Labels fade in after zoom 1.2 (Level 3)
    final labelsOpacity = ((zoomScale - 1.2) / 0.5).clamp(0.0, 1.0);
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
    // PASS 1: Draw all auras first (background layer)
    // IMPORTANT: Only draw auras for individual nodes in Level 3

    // DEBUG: Count PlacementInfo items and detailOpacity
    if (kDebugMode) {
      final placementInfoCount = placementResults.whereType<PlacementInfo>().length;
      final dailyClusterCount = placementResults.whereType<DailyClusterPlacementInfo>().length;
      debugPrint('[LifelinePainter] placementResults: $placementInfoCount PlacementInfo, $dailyClusterCount DailyClusterPlacementInfo');
      debugPrint('[LifelinePainter] detailOpacity=$detailOpacity (fadeInStart=${kLevel3Threshold - effectiveBase})');
    }

      for (final item in placementResults) {
        if (item is PlacementInfo) {
          // Skip individual node auras outside Level 3
          if (currentScale < kLevel3Threshold) continue;

          if (visibleRect
              .inflate(kNodeBaseRadius * 2)
              .contains(item.nodePosition)) {
            final index = memories
                .indexWhere((m) => m.universalId == item.memory.universalId);
            final individualPulse = sin(pulseValue * pi * 2 + index * 0.8) * 0.3 + 0.7;
            final breathPulse = sin(progress * pi * 0.5 + index * 0.5) * 0.2 + 0.8;
            final combinedPulse = individualPulse * breathPulse;
            final nodeRadius = kNodeBaseRadius * combinedPulse * 1.5;
            final adjustedPos = item.nodePosition.translate(0, kNodeVerticalOffset);

            if (item.memory.primaryEmotion != null) {
              _drawEmotionAura(canvas, adjustedPos, nodeRadius, detailOpacity, item.memory);
            }
          }
        } else if (item is DailyClusterPlacementInfo) {
          if (visibleRect
              .inflate(kDailyClusterBaseRadius * 2)
              .contains(item.position)) {
            final index = memories
                .indexWhere((m) => m.universalId == item.memories.first.universalId);
            final individualPulse = sin(pulseValue * pi * 2 + index * 0.8) * 0.3 + 0.7;
            final breathPulse = sin(progress * pi * 0.5 + index * 0.5) * 0.2 + 0.8;
            final combinedPulse = individualPulse * breathPulse;
            final nodeRadius = kDailyClusterBaseRadius * combinedPulse;
            final adjustedPos = item.position.translate(0, kNodeVerticalOffset);

            if (item.memories.first.primaryEmotion != null) {
              _drawEmotionAura(canvas, adjustedPos, nodeRadius, detailOpacity, item.memories.first);
            }
          }
        }
      }

      // PASS 2: Draw all nodes on top (foreground layer)
      // IMPORTANT: Only draw individual nodes in Level 3
      int drawnIndividualNodes = 0;
      int drawnDailyClusters = 0;

      for (final item in placementResults) {
        if (item is PlacementInfo) {
          // Skip individual nodes outside Level 3
          if (currentScale < kLevel3Threshold) continue;

          if (visibleRect
              .inflate(kNodeBaseRadius * 2)
              .contains(item.nodePosition)) {
            final index = memories
                .indexWhere((m) => m.universalId == item.memory.universalId);
            final image = images[item.memory.coverPath];
            _drawSingleMemoryNode(
                canvas, item.nodePosition, item.memory, index, detailOpacity, image);
            onNodePosition?.call(item.memory.universalId, item.nodePosition);
            drawnIndividualNodes++;
          }
        } else if (item is DailyClusterPlacementInfo) {
          if (visibleRect
              .inflate(kDailyClusterBaseRadius * 2)
              .contains(item.position)) {
            final image = images[item.memories.first.coverPath];
            _drawDailyClusterNode(canvas, item.position, item, detailOpacity, image);
            onDailyClusterPosition?.call(item.id, item.position, item.memories);
            drawnDailyClusters++;
          }
        } else if (item is TimeGapPlacementInfo) {
          // Show time gaps at high zoom levels (300%-500%)
          if (zoomScale >= 3.0 && zoomScale <= 5.0) {
            if (visibleRect.inflate(20).contains(item.position)) {
              _drawTimeGapMarker(canvas, item, size, detailOpacity);
            }
          }
        }
      }

    // DEBUG: Log drawing statistics
    if (kDebugMode) {
      debugPrint('[LifelinePainter] Drew $drawnIndividualNodes individual nodes, $drawnDailyClusters daily clusters');
    }

    stopwatch.stop();
    nodesTime = stopwatch.elapsedMicroseconds;
    stopwatch.reset();

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

  /// LEVEL 1: Draw yearly gradient - one averaged circle per year
  void _drawYearlyGradient(Canvas canvas, ui.Path path, Size size, double currentScale, double baseScale, double kLevel2Threshold) {
    if (!userProfile!.enableYearlyGradient) return;
    if (memories.length < 2) return;
    if (path.computeMetrics().isEmpty) return;

    // Fade out transition for yearly gradient (LEVEL 1: currentScale < kLevel2Threshold)
    // Fully visible from baseScale × 1.0 to baseScale × 1.8, fade out until kLevel2Threshold
    final fadeStart = baseScale * 1.8;
    final fadeOutOpacity = (currentScale > fadeStart)
        ? ((kLevel2Threshold - currentScale) / (kLevel2Threshold - fadeStart)).clamp(0.0, 1.0)
        : 1.0;
    final finalOpacity = fadeOutOpacity;

    if (finalOpacity <= 0.0) return;

    final intensity = userProfile!.yearlyGradientIntensity;
    final radius = userProfile!.yearlyGradientRadius;
    final blur = userProfile!.yearlyGradientBlur;
    final saturation = userProfile!.yearlyGradientSaturation;

    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;
    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.compareTo(b.date));
    final minDate = sortedMemories.first.date;
    final maxDate = sortedMemories.last.date;
    final totalSpan = maxDate.difference(minDate).inMilliseconds;
    if (totalSpan == 0) return;

    // Group memories by year and calculate average emotion color
    final Map<int, List<Memory>> memoriesByYear = {};
    for (final memory in sortedMemories) {
      memoriesByYear.putIfAbsent(memory.date.year, () => []).add(memory);
    }

    // Draw one circle per year with averaged emotion color
    memoriesByYear.forEach((year, yearMemories) {
      // Calculate average emotion color for the year
      final emotionCounts = <String, int>{};
      for (final memory in yearMemories) {
        if (memory.primaryEmotion != null) {
          emotionCounts[memory.primaryEmotion!] =
              (emotionCounts[memory.primaryEmotion!] ?? 0) + 1;
        }
      }

      // Get dominant emotion
      String? dominantEmotion;
      int maxCount = 0;
      emotionCounts.forEach((emotion, count) {
        if (count > maxCount) {
          maxCount = count;
          dominantEmotion = emotion;
        }
      });

      final emotionColor = EmotionColors.getColor(dominantEmotion);
      final saturatedColor = _boostSaturation(emotionColor, saturation);

      // Position at start of year
      final firstDayOfYear = DateTime(year);
      final t = (firstDayOfYear.difference(minDate).inMilliseconds / totalSpan)
          .clamp(0.0, 1.0);
      final pos = metrics.getTangentForOffset(t * totalLen)?.position;

      if (pos != null) {
        final paint = Paint()
          ..color = saturatedColor.withOpacity(intensity * finalOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
        canvas.drawCircle(pos, radius, paint);
      }
    });
  }

  /// LEVEL 2: Draw monthly cluster nodes (like daily clusters with photos)
  void _drawMonthlyClusters(
    Canvas canvas,
    ui.Path path,
    Size size,
    double currentScale,
    List<dynamic> placementResults,
    double baseScale,
    double kLevel2Threshold,
    double kLevel3Threshold,
  ) {
    if (memories.isEmpty) return;
    if (path.computeMetrics().isEmpty) return;

    // Fade in/out transitions for monthly clusters (LEVEL 2: kLevel2Threshold to kLevel3Threshold)
    // Fade in from kLevel2Threshold to kLevel2Threshold + 0.2*baseScale
    final fadeInEnd = kLevel2Threshold + baseScale * 0.2;
    final fadeInOpacity = (currentScale < fadeInEnd)
        ? ((currentScale - kLevel2Threshold) / (fadeInEnd - kLevel2Threshold)).clamp(0.0, 1.0)
        : 1.0;
    // Fade out from kLevel3Threshold - 0.4*baseScale to kLevel3Threshold
    final fadeOutStart = kLevel3Threshold - baseScale * 0.4;
    final fadeOutOpacity = (currentScale > fadeOutStart)
        ? ((kLevel3Threshold - currentScale) / (kLevel3Threshold - fadeOutStart)).clamp(0.0, 1.0)
        : 1.0;
    final finalOpacity = fadeInOpacity * fadeOutOpacity;

    if (finalOpacity <= 0.0) return;

    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.compareTo(b.date));
    final minDate = sortedMemories.first.date;
    final maxDate = sortedMemories.last.date;
    final totalSpan = maxDate.difference(minDate).inMilliseconds;
    if (totalSpan == 0) return;

    // Group ALL memories by month using actual placement positions
    // Build a lookup map for faster position finding
    final Map<String, Offset> memoryPositions = {};
    for (final item in placementResults) {
      if (item is PlacementInfo) {
        memoryPositions[item.memory.universalId] = item.nodePosition;
      } else if (item is DailyClusterPlacementInfo) {
        // Use cluster position for all memories in the cluster
        for (final memory in item.memories) {
          memoryPositions[memory.universalId] = item.position;
        }
      }
    }

    final Map<String, ({List<Memory> memories, List<Offset> positions})> monthlyGroups = {};

    // Group ALL memories, not just those in placementResults
    for (final memory in memories) {
      final monthKey = '${memory.date.year}-${memory.date.month.toString().padLeft(2, '0')}';

      if (!monthlyGroups.containsKey(monthKey)) {
        monthlyGroups[monthKey] = (memories: [], positions: []);
      }
      monthlyGroups[monthKey]!.memories.add(memory);

      // Try to find position in placementResults
      final position = memoryPositions[memory.universalId];
      if (position != null) {
        monthlyGroups[monthKey]!.positions.add(position);
      }
    }

    // Sort month keys chronologically
    final sortedMonthKeys = monthlyGroups.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    // Calculate cluster positions using REAL positions from placementResults
    final List<({String key, Offset pos, List<Memory> memories})> clusterPositions = [];

    for (final monthKey in sortedMonthKeys) {
      final group = monthlyGroups[monthKey]!;
      final monthMemories = group.memories;
      final positions = group.positions;

      // Skip if no positions found for this month
      if (positions.isEmpty) continue;

      // FIXED: Calculate average position using REAL coordinates from placementResults
      // This ensures monthly cluster is at the center of mass of its actual nodes,
      // not at an abstract point on path based on timestamp
      final avgDx = positions.map((p) => p.dx).reduce((a, b) => a + b) / positions.length;
      final avgDy = positions.map((p) => p.dy).reduce((a, b) => a + b) / positions.length;
      final avgPos = Offset(avgDx, avgDy);

      clusterPositions.add((key: monthKey, pos: avgPos, memories: monthMemories));
    }

    // Group nearby monthly clusters (if they're too close, combine them)
    const minMonthSpacing = 40.0; // Minimum distance between month clusters (diameter of node is ~60px)
    final List<({
      List<String> monthKeys,
      Offset pos,
      List<Memory> memories,
    })> groupedClusters = [];

    for (int i = 0; i < clusterPositions.length; i++) {
      final current = clusterPositions[i];

      // Check if this cluster should be merged with the last grouped cluster
      if (groupedClusters.isNotEmpty) {
        final lastGroup = groupedClusters.last;

        // Calculate actual distance considering the path curve (not just X distance)
        final dx = current.pos.dx - lastGroup.pos.dx;
        final dy = current.pos.dy - lastGroup.pos.dy;
        final distance = sqrt(dx * dx + dy * dy);

        if (distance < minMonthSpacing) {
          // Merge into last group
          final combinedMemories = [...lastGroup.memories, ...current.memories];

          // FIXED: Use average of REAL positions (center of mass), not timestamp-based calculation
          final avgPos = Offset(
            (lastGroup.pos.dx + current.pos.dx) / 2,
            (lastGroup.pos.dy + current.pos.dy) / 2,
          );

          groupedClusters[groupedClusters.length - 1] = (
            monthKeys: [...lastGroup.monthKeys, current.key],
            pos: avgPos,
            memories: combinedMemories,
          );
          continue;
        }
      }

      // Start new group
      groupedClusters.add((
        monthKeys: [current.key],
        pos: current.pos,
        memories: current.memories,
      ));
    }

    // Node radius for drawing - clusters stay ON the lifeline, no displacement
    const nodeRadius = 30.0;

    // PASS 1: Draw auras (only if enabled in settings)
    if (userProfile!.enableMonthlyClusters) {
      final intensity = userProfile!.monthlyClusterIntensity;
      final auraRadius = userProfile!.monthlyClusterRadius;
      final blur = userProfile!.monthlyClusterBlur;
      final saturation = userProfile!.monthlyClusterSaturation;

      for (var clusterIndex = 0; clusterIndex < groupedClusters.length; clusterIndex++) {
        final cluster = groupedClusters[clusterIndex];

        // Calculate breathing animation (same as daily clusters)
        final individualPulse = sin(pulseValue * pi * 2 + clusterIndex * 0.8) * 0.3 + 0.7;
        final breathPulse = sin(progress * pi * 0.5 + clusterIndex * 0.5) * 0.2 + 0.8;
        final combinedPulse = individualPulse * breathPulse;

        // Get dominant emotion
        final emotionCounts = <String, int>{};
        for (final memory in cluster.memories) {
          if (memory.primaryEmotion != null) {
            emotionCounts[memory.primaryEmotion!] =
                (emotionCounts[memory.primaryEmotion!] ?? 0) + 1;
          }
        }

        String? dominantEmotion;
        int maxCount = 0;
        emotionCounts.forEach((emotion, count) {
          if (count > maxCount) {
            maxCount = count;
            dominantEmotion = emotion;
          }
        });

        final emotionColor = EmotionColors.getColor(dominantEmotion);
        final saturatedColor = _boostSaturation(emotionColor, saturation);

        // Draw aura (background glow) with breathing animation
        final auraPaint = Paint()
          ..color = saturatedColor.withOpacity(intensity * finalOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

        final adjustedPos = cluster.pos.translate(0, kNodeVerticalOffset);
        canvas.drawCircle(adjustedPos, auraRadius * intensity * combinedPulse, auraPaint);
      }
    }

    // PASS 2: Draw nodes with photos
    for (var clusterIndex = 0; clusterIndex < groupedClusters.length; clusterIndex++) {
      final cluster = groupedClusters[clusterIndex];
      // Calculate breathing animation (same as daily clusters)
      final individualPulse = sin(pulseValue * pi * 2 + clusterIndex * 0.8) * 0.3 + 0.7;
      final breathPulse = sin(progress * pi * 0.5 + clusterIndex * 0.5) * 0.2 + 0.8;
      final combinedPulse = individualPulse * breathPulse;
      final animatedRadius = nodeRadius * combinedPulse;

      // Pick first memory with a photo, or first memory if none have photos
      Memory? selectedMemory;
      for (final memory in cluster.memories) {
        if (memory.coverPath != null && images[memory.coverPath] != null) {
          selectedMemory = memory;
          break;
        }
      }
      selectedMemory ??= cluster.memories.first;
      final image = images[selectedMemory.coverPath];

      final adjustedPos = cluster.pos.translate(0, kNodeVerticalOffset);

      // Draw photo or default node
      if (image != null) {
        final imageRect = Rect.fromCircle(center: adjustedPos, radius: animatedRadius);
        final imagePath = Path()..addOval(imageRect);

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
          srcRect = Rect.fromLTWH(
              0, (imgHeight - croppedHeight) / 2, imgWidth, croppedHeight);
        }

        canvas.drawImageRect(image, srcRect, imageRect, Paint());
        canvas.restore();

        // Draw border
        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(finalOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawPath(imagePath, borderPaint);
      } else {
        // Draw default colored node
        final emotionCounts = <String, int>{};
        for (final memory in cluster.memories) {
          if (memory.primaryEmotion != null) {
            emotionCounts[memory.primaryEmotion!] =
                (emotionCounts[memory.primaryEmotion!] ?? 0) + 1;
          }
        }

        String? dominantEmotion;
        int maxCount = 0;
        emotionCounts.forEach((emotion, count) {
          if (count > maxCount) {
            maxCount = count;
            dominantEmotion = emotion;
          }
        });

        final emotionColor = EmotionColors.getColor(dominantEmotion);
        final nodePaint = Paint()..color = emotionColor.withOpacity(finalOpacity);
        canvas.drawCircle(adjustedPos, animatedRadius, nodePaint);

        final borderPaint = Paint()
          ..color = Colors.white.withOpacity(finalOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;
        canvas.drawCircle(adjustedPos, animatedRadius, borderPaint);
      }

      // Only show count text at high zoom level (LEVEL 3)
      // Show when currentScale reaches kLevel3Threshold
      if (currentScale >= kLevel3Threshold) {
        final ringColor = Color.lerp(const Color(0xFFFF6B6B), Colors.white, 0.7)!;
        final textStyle = GoogleFonts.orbitron(
          color: ringColor.withOpacity(finalOpacity),
          fontSize: 10.0,
          fontWeight: FontWeight.bold,
          shadows: const [ui.Shadow(color: Colors.black, blurRadius: 4.0)],
        );
        final textSpan = TextSpan(text: cluster.memories.length.toString(), style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr,
        );
        textPainter.layout();
        final textPos = Offset(
          adjustedPos.dx - textPainter.width / 2,
          adjustedPos.dy - textPainter.height / 2,  // Center inside node
        );
        textPainter.paint(canvas, textPos);
      }
    }

    // PASS 3: Draw month labels with connector lines (stems)
    const verticalOffset = 40.0;
    bool wasLastAbove = false;

    for (int i = 0; i < groupedClusters.length; i++) {
      final cluster = groupedClusters[i];

      // Generate label text based on number of months in cluster
      final String monthName;
      final DateTime monthDate;
      if (cluster.monthKeys.length == 1) {
        final parts = cluster.monthKeys.first.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        monthDate = DateTime(year, month);
        monthName = DateFormat.yMMM().format(monthDate); // "Jan 2025"
      } else {
        // Multiple months - show range
        final firstParts = cluster.monthKeys.first.split('-');
        final lastParts = cluster.monthKeys.last.split('-');
        final firstYear = int.parse(firstParts[0]);
        final firstMonth = int.parse(firstParts[1]);
        final lastYear = int.parse(lastParts[0]);
        final lastMonth = int.parse(lastParts[1]);

        final firstDate = DateTime(firstYear, firstMonth);
        final lastDate = DateTime(lastYear, lastMonth);
        monthDate = firstDate;

        if (firstYear == lastYear) {
          // Same year: "Jan-Mar 2025"
          monthName = '${DateFormat.MMM().format(firstDate)}-${DateFormat.yMMM().format(lastDate)}';
        } else {
          // Different years: "Dec 2024-Feb 2025"
          monthName = '${DateFormat.yMMM().format(firstDate)}-${DateFormat.yMMM().format(lastDate)}';
        }
      }

      final adjustedPos = cluster.pos.translate(0, kNodeVerticalOffset);

      // Create label paragraph
      final labelStyle = TextStyle(
        color: Colors.white.withOpacity(finalOpacity),
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        shadows: const [
          ui.Shadow(color: Colors.black, blurRadius: 12.0),
          ui.Shadow(color: Colors.black, blurRadius: 8.0),
          ui.Shadow(color: Colors.black, blurRadius: 4.0),
        ],
      );
      final labelSpan = TextSpan(text: monthName, style: labelStyle);
      final labelPainter = TextPainter(
        text: labelSpan,
        textAlign: TextAlign.center,
        textDirection: ui.TextDirection.ltr,
      );
      labelPainter.layout();

      // Alternate label position (above/below) like memory labels
      final placeAbove = !wasLastAbove;
      wasLastAbove = placeAbove;

      final labelX = adjustedPos.dx - labelPainter.width / 2;
      final labelY = placeAbove
          ? adjustedPos.dy - verticalOffset - labelPainter.height
          : adjustedPos.dy + verticalOffset;

      final textRect = Rect.fromLTWH(labelX, labelY, labelPainter.width, labelPainter.height);

      // Draw connector line (stem)
      _drawConnectorLine(canvas, cluster.pos, textRect, placeAbove, finalOpacity);

      // Draw label with full opacity (like daily clusters)
      canvas.saveLayer(
        textRect.inflate(2),
        Paint()..color = Colors.white.withAlpha((255 * finalOpacity).round())
      );
      labelPainter.paint(canvas, Offset(labelX, labelY));
      canvas.restore();

      // Report position for tap detection
      onMonthlyClusterPosition?.call(cluster.monthKeys, cluster.pos, cluster.memories, monthDate);
    }
  }

  /// Helper: Get position of a memory on the path
  Offset? _getMemoryPositionOnPath(ui.Path path, Memory memory) {
    if (path.computeMetrics().isEmpty) return null;
    final metrics = path.computeMetrics().first;
    final totalLen = metrics.length;

    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.compareTo(b.date));
    final minDate = sortedMemories.first.date;
    final maxDate = sortedMemories.last.date;
    final totalSpan = maxDate.difference(minDate).inMilliseconds;

    if (totalSpan == 0) return metrics.getTangentForOffset(0)?.position;

    final t = (memory.date.difference(minDate).inMilliseconds / totalSpan).clamp(0.0, 1.0);
    return metrics.getTangentForOffset(t * totalLen)?.position;
  }

  /// Helper: Boost color saturation
  Color _boostSaturation(Color color, double multiplier) {
    final hslColor = HSLColor.fromColor(color);
    return hslColor
        .withSaturation((hslColor.saturation * multiplier).clamp(0.0, 1.0))
        .toColor();
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

    // AURA is now drawn in separate pass before nodes (see paint() method)

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

      final imagePaint = Paint()..color = Colors.white.withOpacity(opacity);
      canvas.drawImageRect(image, srcRect, imageRect, imagePaint);
      canvas.restore();

      canvas.drawPath(imagePath, borderPaint);
    } else {
      _drawDefaultNode(canvas, adjustedPos, nodeRadius, opacity, index, memory);
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
    // Проверка: аура включена в настройках и воспоминание имеет эмоцию
    if (memory.primaryEmotion == null) return;

    // DEBUG: Проверяем настройку
    final auraEnabled = userProfile?.enableNodeAura ?? true;
    if (!auraEnabled) return;

    final emotionColor = _getEmotionColor(memory.primaryEmotion);
    final intensity = memory.emotionIntensity;

    // Адаптивный blur radius для производительности
    final blurRadius = DevicePerformanceDetector.getAdaptiveBlurRadius(30.0 * intensity);
    if (blurRadius <= 0) {
      return; // Skip на low-end устройствах
    }

    final auraPaint = Paint()
      ..color = emotionColor.withValues(alpha: 0.525 * intensity * opacity) // Увеличено на 50%
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius);

    // Основная аура (рисуется ДО узла, поэтому будет "за" ним)
    canvas.drawCircle(pos, nodeRadius * 2.5 * intensity, auraPaint);

    // Вторичная эмоция (если есть) — второе кольцо ауры
    if (memory.secondaryEmotion != null) {
      final secondaryColor = _getEmotionColor(memory.secondaryEmotion);
      final secondaryPaint = Paint()
        ..color = secondaryColor.withValues(alpha: 0.375 * intensity * opacity) // Увеличено на 50%
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, blurRadius * 1.5);

      canvas.drawCircle(pos, nodeRadius * 3.5 * intensity, secondaryPaint);
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

    // Only show count text at high zoom level (LEVEL 3)
    // Calculate dynamic level3Threshold (66% of maxRelativeZoom)
    const double kFixedMaxScale = 2.6;
    final estimatedMinScale = zoomScale > 0.1 ? currentScale / zoomScale : currentScale;
    final maxRelativeZoom = estimatedMinScale > 0.001 ? kFixedMaxScale / estimatedMinScale : 10.0;
    final level3Threshold = maxRelativeZoom * 0.66;

    if (zoomScale >= level3Threshold) {
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
          textDirection: ui.TextDirection.ltr);
      textPainter.layout();
      final textPos = Offset(
          adjustedPos.dx - textPainter.width / 2, adjustedPos.dy - textPainter.height / 2);
      textPainter.paint(canvas, textPos);
    }
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
        textDirection: ui.TextDirection.ltr,
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
      textDirection: ui.TextDirection.ltr,
    );
    textPainter.layout();
    final textPos = Offset(pos.dx - textPainter.width / 2, pos.dy);
    textPainter.paint(canvas, textPos);
  }

  // === EMOTION VISUALIZATION HELPERS ===

  /// Возвращает цвет эмоции для узла (насыщенный, яркий)
  Color _getEmotionColor(String? emotion) {
    return EmotionColors.getColor(emotion);
  }

  @override
  bool shouldRepaint(covariant LifelinePainter old) {
    return old.progress != progress ||
        old.pulseValue != pulseValue ||
        !listEquals(old.memories, memories) ||
        old.zoomScale != zoomScale ||
        old.currentScale != currentScale ||
        !mapEquals(old.images, images) ||
        old.branchIntensity != branchIntensity ||
        old.renderData != renderData;
  }
}
