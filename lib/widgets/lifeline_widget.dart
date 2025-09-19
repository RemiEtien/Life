import 'dart:ui' as ui;
import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/models/user_profile.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/screens/memory_edit_screen.dart';
import 'package:lifeline/screens/memory_view_screen.dart';
import 'package:lifeline/screens/profile_screen.dart';
import 'package:lifeline/services/message_service.dart';
import 'package:lifeline/widgets/floating_message_overlay.dart';
import 'package:lifeline/widgets/global_audio_player_widget.dart';
import 'package:lifeline/widgets/lifeline_painter.dart';
import 'package:lifeline/widgets/device_performance_detector.dart';
import 'package:lifeline/services/lifeline_calculator.dart';
import 'package:lifeline/services/onboarding_service.dart';
import 'package:lifeline/services/sync_service.dart';
import 'package:lifeline/widgets/onboarding_overlay.dart';

enum TappableType { singleNode, dailyCluster }

class TappableItem {
  final TappableType type;
  final dynamic data;

  TappableItem({required this.type, required this.data});

  String title(BuildContext context) {
    if (type == TappableType.singleNode) {
      return (data as Memory).title;
    } else {
      final memories = data as List<Memory>;
      if (memories.isEmpty) return "Cluster";
      final date = memories.first.date;
      return 'Day: ${DateFormat.yMd().format(date)} (${memories.length})';
    }
  }

  IconData get icon {
    if (type == TappableType.singleNode) {
      return Icons.history_edu_outlined;
    } else {
      return Icons.style_outlined;
    }
  }
}

class YearPosition {
  final int year;
  final double x;
  YearPosition({required this.year, required this.x});
}

class RenderData {
  final ui.Path mainPath;
  final ui.Path yearPath;
  final List<ui.Path> branches;
  final List<ui.Path> roots;
  final List<dynamic> placementResults;
  final List<YearPosition> yearPositions;

  RenderData({
    required this.mainPath,
    required this.yearPath,
    required this.branches,
    required this.roots,
    required this.placementResults,
    required this.yearPositions,
  });
}

class LayoutResult {
  final double totalWidth;
  final List<dynamic> placementResults;
  final List<YearPosition> yearPositions;

  LayoutResult({
    required this.totalWidth,
    required this.placementResults,
    required this.yearPositions,
  });
}

class LifelineWidget extends ConsumerStatefulWidget {
  final double height;
  const LifelineWidget({super.key, this.height = 300});

  @override
  ConsumerState<LifelineWidget> createState() => _LifelineWidgetState();
}

class _LifelineWidgetState extends ConsumerState<LifelineWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _geometryController;
  late final AnimationController _backgroundController;
  late final AnimationController _branchController;

  final TransformationController _transformationController =
      TransformationController();

  LayoutResult? _cachedLayoutResult;
  bool _isAdmin = false;

  List<TappableItem>? _selectionItems;
  Offset? _selectionCenter;

  final Map<String, ui.Paragraph> _cachedParagraphs = {};
  final Map<String, ui.Image> _cachedImages = {};
  Size _lastKnownSize = Size.zero;
  final Map<String, Offset> _nodePositions = {};
  final Map<String, (Offset, List<Memory>)> _dailyClusterData = {};

  RenderData? _renderData;
  ui.Picture? _structureCache;
  bool _isCalculating = false;

  bool _debugMode = false;
  late bool _animationEnabled;
  late double _geometrySpeed;
  late double _geometryAmplitude;
  late double _yearLineYPosition;
  late double _branchDensity;
  late double _branchIntensity;

  static const double kTapRadiusOnScreen = 40.0;

  final _performanceMonitor = PerformanceMonitor();
  bool _isInitialLayoutDone = false;
  bool _isDisposed = false;

  final ValueNotifier<PaintTimings?> _paintTimingsNotifier =
      ValueNotifier(null);

  final String _adminUid = 'BGnE9FuIasfIOj5ln3rQHIBiulv2';

  // --- NEW: GlobalKeys for Onboarding ---
  final _fabKey = GlobalKey();
  final _statsCardKey = GlobalKey();
  final _controlsPanelKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    WidgetsBinding.instance.addObserver(this);

    _initializeVisualSettings();

    _mainController =
        AnimationController(vsync: this, duration: const Duration(minutes: 20))
          ..repeat(reverse: true);
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(minutes: 2))
          ..repeat(reverse: true);
    _geometryController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat(reverse: true);
    _backgroundController = AnimationController(
        vsync: this, duration: const Duration(minutes: 15))
      ..repeat();
    _branchController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();

    _mainController.addListener(() {
      if (mounted && _debugMode) {
        _performanceMonitor.tick();
      }
    });

    final geometryAndBranchListener =
        Listenable.merge([_geometryController, _branchController]);
    geometryAndBranchListener.addListener(_geometryAnimationTick);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(onboardingServiceProvider.notifier).startOnAppLaunch();
        ref.read(syncServiceProvider).syncFromCloudToLocal();
      }
    });
  }

  void _initializeVisualSettings() {
    final profile = ref.read(userProfileProvider).asData?.value;
    if (profile != null) {
      _animationEnabled = profile.visualAnimationEnabled;
      _geometrySpeed = profile.visualSpeed;
      _geometryAmplitude = profile.visualAmplitude;
      _yearLineYPosition = profile.visualYearLinePosition;
      _branchDensity = profile.visualBranchDensity;
      _branchIntensity = profile.visualBranchIntensity;
    } else {
      // Fallback to default values if profile is not available yet
      _animationEnabled = true;
      _geometrySpeed = 2.0;
      _geometryAmplitude = 10.0;
      _yearLineYPosition = 0.65;
      _branchDensity = 0.35;
      _branchIntensity = 0.6;
    }
  }

  Future<void> _saveVisualSettings() async {
    final profile = ref.read(userProfileProvider).asData?.value;
    final userService = ref.read(userServiceProvider);

    if (profile != null) {
      final updatedProfile = profile.copyWith(
        visualAnimationEnabled: _animationEnabled,
        visualSpeed: _geometrySpeed,
        visualAmplitude: _geometryAmplitude,
        visualYearLinePosition: _yearLineYPosition,
        visualBranchDensity: _branchDensity,
        visualBranchIntensity: _branchIntensity,
      );
      try {
        await userService.updateUserProfile(updatedProfile);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save visual settings: $e')),
          );
        }
      }
    }
  }

  void _geometryAnimationTick() {
    if (_cachedLayoutResult != null) {
      final memories = ref.read(memoriesStreamProvider).asData?.value ?? [];
      _requestGeometryUpdate(_cachedLayoutResult!, memories);
    }
  }

  void _onMemoriesChanged(
      AsyncValue<List<Memory>>? previous, AsyncValue<List<Memory>> next) {
    if (next is AsyncData<List<Memory>>) {
      final memories = next.value;
      if (mounted && !_lastKnownSize.isEmpty) {
        _loadMemoryImages(memories);
        _updateParagraphs(memories);
        _requestFullRecalculation(memories);
      }
    }
  }

  // --- ИЗМЕНЕНО: Логика загрузки и кэширования изображений ---
  Future<void> _loadMemoryImages(List<Memory> memories) async {
    for (final memory in memories) {
      final coverPath = memory.coverPath;
      if (coverPath != null &&
          coverPath.isNotEmpty &&
          !_cachedImages.containsKey(coverPath)) {
        // Создаем провайдер в зависимости от типа пути (локальный или сетевой)
        ImageProvider provider = coverPath.startsWith('http')
            ? CachedNetworkImageProvider(coverPath)
            : FileImage(File(coverPath));

        _getUiImageFromProvider(provider).then((image) {
          if (image != null && mounted) {
            setState(() {
              _cachedImages[coverPath] = image;
            });
          }
        });
      }
    }
  }

  // --- НОВЫЙ МЕТОД: Конвертирует ImageProvider в ui.Image для CustomPainter ---
  Future<ui.Image?> _getUiImageFromProvider(ImageProvider provider) async {
    final completer = Completer<ui.Image?>();
    final stream = provider.resolve(const ImageConfiguration());

    final listener = ImageStreamListener(
      (ImageInfo imageInfo, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(imageInfo.image);
        }
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          if (kDebugMode) {
            print("Error loading ui.Image: $exception");
          }
          completer.complete(null);
        }
      },
    );

    stream.addListener(listener);
    final result = await completer.future;
    stream.removeListener(listener); // Обязательно удаляем слушатель
    return result;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool isResumed = state == AppLifecycleState.resumed;
    if (_animationEnabled == isResumed) return;
    setState(() {
      _animationEnabled = isResumed;
      final controllers = [
        _mainController,
        _pulseController,
        _geometryController,
        _backgroundController,
        _branchController
      ];
      for (final controller in controllers) {
        if (isResumed) {
          bool shouldReverse =
              controller == _mainController || controller == _pulseController;
          controller.repeat(reverse: shouldReverse);
        } else {
          controller.stop();
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _mainController.dispose();
    _pulseController.dispose();
    final geometryAndBranchListener =
        Listenable.merge([_geometryController, _branchController]);
    geometryAndBranchListener.removeListener(_geometryAnimationTick);
    _geometryController.dispose();
    _backgroundController.dispose();
    _branchController.dispose();
    _transformationController.dispose();
    _structureCache?.dispose();
    _performanceMonitor.dispose();
    _paintTimingsNotifier.dispose();
    super.dispose();
  }

  ui.Path _buildCubicPathFromPoints(List<double> points) {
    final path = ui.Path();
    if (points.length < 2) return path;

    path.moveTo(points[0], points[1]);
    for (int i = 2; i < points.length; i += 6) {
      path.cubicTo(
          points[i], points[i + 1], points[i + 2], points[i + 3], points[i + 4], points[i + 5]);
    }
    return path;
  }

  ui.Path _buildLinePathFromPoints(List<double> points) {
    final path = ui.Path();
    if (points.length < 2) return path;

    path.moveTo(points[0], points[1]);
    for (int i = 2; i < points.length; i += 2) {
      path.lineTo(points[i], points[i + 1]);
    }
    return path;
  }

  void _updateParagraphs(List<Memory> memories) {
    if (!mounted || _lastKnownSize.isEmpty) return;
    _cachedParagraphs.clear();
    for (final memory in memories) {
      final key = memory.universalId;
      _cachedParagraphs[key] = _createTextParagraph(memory, _lastKnownSize);
    }
  }

  ui.Paragraph _createTextParagraph(Memory memory, Size size) {
    final maxWidth = size.width - 20;
    const maxTextWidth = 150.0;
    final textWidth = min(maxTextWidth, maxWidth);
    final textStyle = GoogleFonts.orbitron(
        color: Colors.white.withAlpha(230),
        fontSize: 6.0,
        fontWeight: FontWeight.w600,
        shadows: [
          const ui.Shadow(
              color: Colors.black, blurRadius: 4.0, offset: Offset(1.0, 1.0))
        ]);
    final titleBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
        textAlign: TextAlign.center,
        fontFamily: textStyle.fontFamily,
        fontSize: textStyle.fontSize,
        fontWeight: textStyle.fontWeight))
      ..pushStyle(
          ui.TextStyle(color: textStyle.color, shadows: textStyle.shadows))
      ..addText(memory.title.toUpperCase())
      ..pop();
    return titleBuilder.build()
      ..layout(ui.ParagraphConstraints(width: textWidth));
  }

  LayoutResult _calculateLayout(Size availableSize, List<Memory> memories) {
    if (memories.isEmpty) {
      return LayoutResult(
          totalWidth: max(availableSize.width, 800.0),
          placementResults: [],
          yearPositions: []);
    }

    const int timeGapThresholdInDays = 90;
    const double margin = 80.0;

    final sortedMemories = List<Memory>.from(memories)
      ..sort((a, b) => a.date.compareTo(b.date));
    final groupedByDay = groupBy(
        sortedMemories, (m) => DateTime(m.date.year, m.date.month, m.date.day));

    final newPlacementResults = <dynamic>[];
    final sortedEntries = groupedByDay.entries.sortedBy((entry) => entry.key);

    int itemCount = sortedEntries.length;

    double nodeSpacing;
    double totalWidth;

    if (itemCount < 10) {
      double baseWidth = max(800.0, availableSize.width);
      double availableSpace = baseWidth - 2 * margin;

      if (itemCount <= 1) {
        nodeSpacing = 0;
        totalWidth = baseWidth;
      } else {
        nodeSpacing = availableSpace / (itemCount - 1);
        totalWidth = baseWidth;
      }
    } else {
      nodeSpacing = 50.0;
      totalWidth = margin * 2 + (itemCount - 1) * nodeSpacing;
      totalWidth = max(totalWidth, max(availableSize.width, 800.0));
    }

    double currentX = (totalWidth > availableSize.width)
        ? margin
        : (totalWidth - (itemCount - 1) * nodeSpacing) / 2;

    for (int i = 0; i < sortedEntries.length; i++) {
      final dayEntry = sortedEntries[i];
      final currentDate = dayEntry.key;

      if (i > 0 && itemCount >= 10) {
        final lastDate = sortedEntries[i - 1].key;
        if (currentDate.difference(lastDate).inDays > timeGapThresholdInDays) {
          final gapMarkerX = currentX - nodeSpacing / 2;
          newPlacementResults.add(TimeGapPlacementInfo(
            position: Offset(gapMarkerX, 0),
            startDate: lastDate,
            endDate: currentDate,
          ));
        }
      }

      final position = Offset(currentX, 0);

      if (dayEntry.value.length > 1) {
        final clusterId =
            '${currentDate.year}-${currentDate.month}-${currentDate.day}';
        newPlacementResults.add(DailyClusterPlacementInfo(
            memories: dayEntry.value, position: position, id: clusterId));
      } else {
        newPlacementResults.add(PlacementInfo(dayEntry.value.first, position));
      }

      if (i < sortedEntries.length - 1) {
        currentX += nodeSpacing;
      }
    }

    final yearPositions = _calculateYearPositions(newPlacementResults);

    return LayoutResult(
      totalWidth: totalWidth,
      placementResults: newPlacementResults,
      yearPositions: yearPositions,
    );
  }

  List<YearPosition> _calculateYearPositions(List<dynamic> placements) {
    final Map<int, List<double>> yearXPositions = {};
    for (final placement in placements) {
      final DateTime date;
      final double x;
      if (placement is DailyClusterPlacementInfo) {
        date = placement.memories.first.date;
        x = placement.position.dx;
      } else if (placement is PlacementInfo) {
        date = placement.memory.date;
        x = placement.nodePosition.dx;
      } else {
        continue;
      }

      final year = date.year;
      yearXPositions.putIfAbsent(year, () => []).add(x);
    }

    final finalPositions = <YearPosition>[];
    yearXPositions.forEach((year, xList) {
      final avgX = xList.reduce((a, b) => a + b) / xList.length;
      finalPositions.add(YearPosition(year: year, x: avgX));
    });
    finalPositions.sort((a, b) => a.year.compareTo(b.year));
    return finalPositions;
  }

  double _findDistanceForX(double targetX, ui.PathMetric metric) {
    double low = 0.0;
    double high = metric.length;
    double mid = 0.0;

    for (int i = 0; i < 10; i++) {
      mid = (low + high) / 2;
      final position = metric.getTangentForOffset(mid)!.position;
      if (position.dx < targetX) {
        low = mid;
      } else {
        high = mid;
      }
    }
    return mid;
  }

  List<dynamic> _updateYCoordinates(
      List<dynamic> horizontalPlacements, ui.Path path) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return horizontalPlacements;
    final metric = metrics.first;

    final updatedPlacements = [];

    for (final placement in horizontalPlacements) {
      final double targetX;
      if (placement is PlacementInfo) {
        targetX = placement.nodePosition.dx;
      } else if (placement is DailyClusterPlacementInfo) {
        targetX = placement.position.dx;
      } else if (placement is TimeGapPlacementInfo) {
        targetX = placement.position.dx;
      } else {
        continue;
      }

      final distance = _findDistanceForX(targetX, metric);
      final tangent = metric.getTangentForOffset(distance);

      if (tangent != null) {
        final positionOnPath = tangent.position;

        if (placement is PlacementInfo) {
          updatedPlacements
              .add(PlacementInfo(placement.memory, positionOnPath));
        } else if (placement is DailyClusterPlacementInfo) {
          updatedPlacements.add(DailyClusterPlacementInfo(
              memories: placement.memories,
              position: positionOnPath,
              id: placement.id));
        } else if (placement is TimeGapPlacementInfo) {
          updatedPlacements.add(TimeGapPlacementInfo(
            position: positionOnPath,
            startDate: placement.startDate,
            endDate: placement.endDate,
          ));
        }
      } else {
        updatedPlacements.add(placement);
      }
    }
    return updatedPlacements;
  }

  void _requestFullRecalculation(List<Memory> memories) {
    if (_isCalculating || !mounted || _lastKnownSize.isEmpty) return;

    final layoutResult = _calculateLayout(_lastKnownSize, memories);

    if (mounted) {
      setState(() {
        _cachedLayoutResult = layoutResult;
      });
      _requestGeometryUpdate(layoutResult, memories);
    }
  }

  void _requestGeometryUpdate(LayoutResult layoutResult, List<Memory> memories) {
    if (_isCalculating || !mounted) return;

    if (mounted) setState(() => _isCalculating = true);

    final totalWidth = layoutResult.totalWidth;

    final receivePort = ReceivePort();
    final input = CalculationInput(
      sendPort: receivePort.sendPort,
      size: Size(totalWidth, _lastKnownSize.height),
      geometrySpeed: _geometrySpeed,
      geometryAmplitude: _geometryAmplitude,
      timeValue: _geometryController.value,
      branchDensity: _branchDensity,
      branchAnimationValue: _branchController.value,
    );

    receivePort.listen((message) {
      if (message is CalculationOutput) {
        final mainPath = _buildCubicPathFromPoints(message.mainPathPoints);
        final branches =
            message.branchPoints.map((p) => _buildLinePathFromPoints(p)).toList();
        final roots =
            message.rootPoints.map((p) => _buildCubicPathFromPoints(p)).toList();
        final yearPath = _createFlatYearLine(totalWidth, _lastKnownSize.height);

        final finalPlacementResults =
            _updateYCoordinates(layoutResult.placementResults, mainPath);

        final newRenderData = RenderData(
          mainPath: mainPath,
          yearPath: yearPath,
          branches: branches,
          roots: roots,
          placementResults: finalPlacementResults,
          yearPositions: layoutResult.yearPositions,
        );

        if (mounted) {
          setState(() {
            _renderData = newRenderData;
            _updateStructureCache(newRenderData,
                Size(totalWidth, _lastKnownSize.height), memories);
            _isCalculating = false;

            if (!_isInitialLayoutDone) {
              _isInitialLayoutDone = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _showFullTimeline();
              });
            }
          });
        }
      }
      receivePort.close();
    });

    Isolate.spawn(lifelineIsolateEntry, input);
  }

  ui.Path _createFlatYearLine(double width, double height) {
    final path = ui.Path();
    final y = height * _yearLineYPosition;
    const margin = 80.0;
    path.moveTo(margin, y);
    path.lineTo(width - margin, y);
    return path;
  }

  double _calculateMinScale(double contentWidth, double screenWidth) {
    if (contentWidth <= 0 || screenWidth <= 0) return 0.1;
    final minScale = (screenWidth * 0.95) / contentWidth;
    return minScale;
  }

  void _updateStructureCache(
      RenderData data, Size size, List<Memory> memories) {
    if (!mounted || size.isEmpty) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final stopwatch = Stopwatch()..start();
    StructurePainter.paintStructure(
      canvas,
      size,
      data.mainPath,
      data.yearPath,
      data.roots,
      memories,
      data.yearPositions,
      _yearLineYPosition,
    );
    stopwatch.stop();
    final structureTime = (stopwatch.elapsedMicroseconds / 1000).round();

    final currentTimings = _paintTimingsNotifier.value ?? PaintTimings();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _paintTimingsNotifier.value = PaintTimings(
          background: currentTimings.background,
          structure: structureTime,
          nodes: currentTimings.nodes,
          labels: currentTimings.labels,
          macroView: currentTimings.macroView,
        );
      }
    });

    final newCache = recorder.endRecording();
    if (mounted) {
      setState(() {
        _structureCache?.dispose();
        _structureCache = newCache;
      });
    }
  }

  void _onNodePosition(String id, Offset pos) => _nodePositions[id] = pos;
  void _onDailyClusterPosition(String id, Offset pos, List<Memory> memories) =>
      _dailyClusterData[id] = (pos, memories);

  void _onTapDown(TapDownDetails d) {
    if (_selectionItems != null) {
      if (mounted) {
        setState(() {
          _selectionItems = null;
          _selectionCenter = null;
        });
      }
      return;
    }

    final currentScale = _transformationController.value.getMaxScaleOnAxis();

    final scenePosition = _transformationController.toScene(d.localPosition);
    final hitRadiusInScene = kTapRadiusOnScreen / currentScale;
    final List<TappableItem> hits =
        _findTappableItems(scenePosition, hitRadiusInScene);

    final userId = ref.read(authStateChangesProvider).asData?.value?.uid;
    if (userId == null) return;

    if (hits.isEmpty) return;

    if (hits.length == 1) {
      final item = hits.first;
      HapticFeedback.lightImpact();
      _handleTappableItemAction(item, d.globalPosition, userId);
    } else {
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          _selectionItems = hits;
          _selectionCenter = _lastKnownSize.center(Offset.zero);
        });
      }
    }
  }

  void _handleTappableItemAction(
      TappableItem item, Offset globalPosition, String userId) {
    if (item.type == TappableType.singleNode) {
      _showMemoryDetails(item.data as Memory, userId);
    } else if (item.type == TappableType.dailyCluster) {
      final memoriesInCluster = item.data as List<Memory>;
      final itemsForMenu = memoriesInCluster
          .map((mem) => TappableItem(type: TappableType.singleNode, data: mem))
          .toList();

      if (mounted) {
        setState(() {
          _selectionItems = itemsForMenu;
          _selectionCenter = _lastKnownSize.center(Offset.zero);
        });
      }
    }
  }

  List<TappableItem> _findTappableItems(Offset scenePosition, double hitRadius) {
    final memories = ref.read(memoriesStreamProvider).asData?.value ?? [];
    final List<TappableItem> hits = [];
    final List<String> processedNodeIds = [];

    _dailyClusterData.forEach((id, data) {
      final pos = data.$1;
      final memoriesInCluster = data.$2;
      if ((pos - scenePosition).distance < hitRadius) {
        hits.add(TappableItem(
            type: TappableType.dailyCluster, data: memoriesInCluster));
        for (var mem in memoriesInCluster) {
          processedNodeIds.add(mem.universalId);
        }
      }
    });

    _nodePositions.forEach((id, pos) {
      if (!processedNodeIds.contains(id) &&
          (pos - scenePosition).distance < hitRadius) {
        final memory = memories.firstWhereOrNull((m) => m.universalId == id);
        if (memory != null) {
          hits.add(TappableItem(type: TappableType.singleNode, data: memory));
        }
      }
    });

    return hits;
  }

  Future<void> _showMemoryDetails(Memory memory, String userId) async {
    await Navigator.of(context).push<bool>(PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            MemoryViewScreen(memory: memory, userId: userId),
        transitionsBuilder: (_, animation, __, child) {
          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(position: animation.drive(tween), child: child);
        }));
  }

  void _showMemoriesListPopup(List<Memory> memories, AppLocalizations l10n) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return DraggableScrollableSheet(
              initialChildSize: 0.6,
              minChildSize: 0.3,
              maxChildSize: 0.9,
              builder: (_, scrollController) {
                return MemoriesListPopup(
                    l10n: l10n,
                    memories: memories,
                    scrollController: scrollController,
                    onMemorySelected: (memory) {
                      final userId =
                          ref.read(authStateChangesProvider).asData?.value?.uid;
                      if (userId == null) return;
                      Navigator.of(context).pop();
                      _showMemoryDetails(memory, userId);
                    });
              });
        });
  }

  Future<void> _openCreate(String? userId) async {
    if (userId == null) return;

    final bool? saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => MemoryEditScreen(userId: userId)));

    if (saved == true && mounted) {
      ref
          .read(messageProvider.notifier)
          .addMessage("Memory saved successfully!", type: MessageType.success);
    }
  }

  void _showFullTimeline() {
    if (_cachedLayoutResult == null ||
        _lastKnownSize.isEmpty ||
        _renderData == null) {
      return;
    }

    final totalWidth = _cachedLayoutResult!.totalWidth;
    if (totalWidth <= 0 || _lastKnownSize.width <= 0) {
      return;
    }

    final minScale = _calculateMinScale(totalWidth, _lastKnownSize.width);
    final screenCenter = _lastKnownSize.center(Offset.zero);

    final contentCenterY = _lastKnownSize.height / 2;

    final contentCenter = Offset(totalWidth / 2, contentCenterY);

    final targetMatrix = Matrix4.identity();
    targetMatrix.translate(screenCenter.dx, screenCenter.dy);
    targetMatrix.scale(minScale, minScale);
    targetMatrix.translate(-contentCenter.dx, -contentCenter.dy);

    final controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    final animation =
        Matrix4Tween(begin: _transformationController.value, end: targetMatrix)
            .animate(
                CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));
    animation
        .addListener(() => _transformationController.value = animation.value);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      }
    });
    controller.forward();
  }

  void _toggleDebugMode() => setState(() => _debugMode = !_debugMode);
  void _toggleAnimation() {
    setState(() {
      _animationEnabled = !_animationEnabled;
      final canAnimate =
          DevicePerformanceDetector.capabilities.performance !=
              DevicePerformance.low;
      if (_animationEnabled && canAnimate) {
        _mainController.repeat(reverse: true);
        _pulseController.repeat(reverse: true);
        _geometryController.repeat(reverse: true);
        _backgroundController.repeat();
      } else {
        _mainController.stop();
        _pulseController.stop();
        _geometryController.stop();
        _backgroundController.stop();
      }
    });
    _saveVisualSettings();
  }

  void _showVisualSettings(AppLocalizations l10n) {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setStateInDialog) => AlertDialog(
                    title: Text(l10n.lifelineVisualSettingsDialogTitle),
                    content: SingleChildScrollView(
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.lifelineVisualSettingsSpeed),
                            Slider(
                                value: _geometrySpeed,
                                min: 0.1,
                                max: 5.0,
                                divisions: 49,
                                label: _geometrySpeed.toStringAsFixed(1),
                                onChanged: (v) {
                                  setState(() => _geometrySpeed = v);
                                  setStateInDialog(() {});
                                },
                                onChangeEnd: (_) => _saveVisualSettings()),
                            Text(l10n.lifelineVisualSettingsAmplitude),
                            Slider(
                                value: _geometryAmplitude,
                                min: 1.0,
                                max: 50.0,
                                divisions: 49,
                                label: _geometryAmplitude.toStringAsFixed(1),
                                onChanged: (v) {
                                  setState(() => _geometryAmplitude = v);
                                  setStateInDialog(() {});
                                },
                                onChangeEnd: (_) => _saveVisualSettings()),
                            const Divider(),
                            Text(l10n.lifelineVisualSettingsYearLine),
                            Slider(
                              value: _yearLineYPosition,
                              min: 0.4,
                              max: 0.9,
                              divisions: 50,
                              label:
                                  '${(_yearLineYPosition * 100).toStringAsFixed(0)}%',
                              onChanged: (v) {
                                setState(() => _yearLineYPosition = v);
                                setStateInDialog(() {});
                              },
                              onChangeEnd: (v) {
                                _saveVisualSettings();
                                if (_renderData != null) {
                                  final memories = ref
                                          .read(memoriesStreamProvider)
                                          .asData
                                          ?.value ??
                                      [];
                                  _updateStructureCache(
                                      _renderData!,
                                      Size(_cachedLayoutResult!.totalWidth,
                                          _lastKnownSize.height),
                                      memories);
                                }
                              },
                            ),
                            const Divider(),
                            Text(l10n.lifelineVisualSettingsBranchDensity),
                            Slider(
                              value: _branchDensity,
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              label: (_branchDensity * 100).toStringAsFixed(0),
                              onChanged: (v) {
                                setState(() => _branchDensity = v);
                                setStateInDialog(() {});
                              },
                              onChangeEnd: (_) => _saveVisualSettings(),
                            ),
                            Text(l10n.lifelineVisualSettingsBranchIntensity),
                            Slider(
                              value: _branchIntensity,
                              min: 0.0,
                              max: 1.0,
                              divisions: 20,
                              label:
                                  (_branchIntensity * 100).toStringAsFixed(0),
                              onChanged: (v) {
                                setState(() => _branchIntensity = v);
                                setStateInDialog(() {});
                              },
                              onChangeEnd: (_) => _saveVisualSettings(),
                            ),
                            const Divider(),
                            SwitchListTile(
                              title: Text(l10n.lifelineVisualSettingsAnimate),
                              value: _animationEnabled,
                              onChanged: (value) {
                                _toggleAnimation();
                                setStateInDialog(() {});
                              },
                              secondary: Icon(_animationEnabled
                                  ? Icons.play_arrow
                                  : Icons.pause),
                            ),
                          ]),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.lifelineVisualSettingsDoneButton))
                    ])));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    _nodePositions.clear();
    _dailyClusterData.clear();

    ref.listen<AsyncValue<List<Memory>>>(
        memoriesStreamProvider, _onMemoriesChanged);

    ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (previous, next) {
      final profile = next.asData?.value;
      if (profile != null) {
        // Compare with current state to avoid unnecessary rebuilds
        if (profile.visualAnimationEnabled != _animationEnabled ||
            profile.visualSpeed != _geometrySpeed ||
            profile.visualAmplitude != _geometryAmplitude ||
            profile.visualYearLinePosition != _yearLineYPosition ||
            profile.visualBranchDensity != _branchDensity ||
            profile.visualBranchIntensity != _branchIntensity) {
          setState(() {
            _animationEnabled = profile.visualAnimationEnabled;
            _geometrySpeed = profile.visualSpeed;
            _geometryAmplitude = profile.visualAmplitude;
            _yearLineYPosition = profile.visualYearLinePosition;
            _branchDensity = profile.visualBranchDensity;
            _branchIntensity = profile.visualBranchIntensity;
          });
        }
      }
    });

    ref.listen<SyncState>(syncNotifierProvider, (previous, next) {
      if (previous != null) {
        if (!previous.isSyncing &&
            next.isSyncing &&
            next.currentStatus != "Idle") {
          ref
              .read(messageProvider.notifier)
              .addMessage("Sync started...", type: MessageType.info);
        } else if (previous.isSyncing && !next.isSyncing) {
          if (next.currentStatus.contains("failed")) {
            ref
                .read(messageProvider.notifier)
                .addMessage("Sync failed. Will retry later.",
                    type: MessageType.error);
          } else {
            ref
                .read(messageProvider.notifier)
                .addMessage("Sync complete!", type: MessageType.success);
          }
        }
      }
    });

    final memoriesAsyncValue = ref.watch(memoriesStreamProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final userId = ref.watch(authStateChangesProvider).asData?.value?.uid;
    final onboardingState = ref.watch(onboardingServiceProvider);
    final isTimelineInteractionDisabled = onboardingState.isActive &&
        onboardingState.currentStep == OnboardingStep.addFirstMemory;

    _isAdmin = userId == _adminUid;

    return LayoutBuilder(builder: (context, constraints) {
      final newSize = Size(constraints.maxWidth, constraints.maxHeight);
      if (newSize.isFinite &&
          newSize != _lastKnownSize &&
          newSize.width > 0) {
        _lastKnownSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            final memories = memoriesAsyncValue.asData?.value ?? [];
            _updateParagraphs(memories);
            _requestFullRecalculation(memories);
          }
        });
      }

      final totalWidth =
          _cachedLayoutResult?.totalWidth ?? constraints.maxWidth;
      final screenWidth = constraints.maxWidth;

      final minScale = _calculateMinScale(totalWidth, screenWidth);
      const double kBaseContentWidth = 1200.0;
      final baseScale = _calculateMinScale(kBaseContentWidth, screenWidth);
      const zoomFactor = 5.0;
      final desiredMaxScale = baseScale * zoomFactor;
      final maxScale = max(minScale, desiredMaxScale);
      final contentHeight = constraints.maxHeight;

      return Container(
        color: const Color(0xFF0A0A0F),
        child: Stack(
          children: [
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _backgroundController,
                builder: (context, child) {
                  final stopwatch = Stopwatch()..start();
                  final painter = BackgroundPainter(
                      progress: _animationEnabled
                          ? _backgroundController.value
                          : 0.0);
                  stopwatch.stop();
                  final backgroundTime =
                      (stopwatch.elapsedMicroseconds / 1000).round();

                  final currentTimings =
                      _paintTimingsNotifier.value ?? PaintTimings();
                  if (currentTimings.background != backgroundTime) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_isDisposed) {
                        _paintTimingsNotifier.value = PaintTimings(
                          background: backgroundTime,
                          structure: currentTimings.structure,
                          nodes: currentTimings.nodes,
                          labels: currentTimings.labels,
                          macroView: currentTimings.macroView,
                        );
                      }
                    });
                  }
                  return CustomPaint(
                    size: Size.infinite,
                    painter: painter,
                  );
                },
              ),
            ),
            memoriesAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) =>
                  Center(child: Text("Error loading memories: $err")),
              data: (memories) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: isTimelineInteractionDisabled ? null : _onTapDown,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: minScale,
                    maxScale: maxScale,
                    constrained: false,
                    panEnabled: !isTimelineInteractionDisabled,
                    scaleEnabled: !isTimelineInteractionDisabled,
                    child: SizedBox(
                      width: totalWidth,
                      height: contentHeight,
                      child: (_renderData == null || userId == null)
                          ? const Center(child: CircularProgressIndicator())
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                // Layer 1: The static structure, wrapped in RepaintBoundary
                                RepaintBoundary(
                                  child: CustomPaint(
                                    size: Size(totalWidth, contentHeight),
                                    painter: StructurePainter(
                                      progress: _mainController.value,
                                      structureCache: _structureCache,
                                    ),
                                  ),
                                ),
                                // Layer 2: The dynamic elements, redrawn on animation ticks
                                AnimatedBuilder(
                                  animation: Listenable.merge(
                                      [_mainController, _pulseController]),
                                  builder: (context, child) {
                                    final currentScale =
                                        _transformationController.value
                                            .getMaxScaleOnAxis();
                                    return CustomPaint(
                                      size: Size(totalWidth, contentHeight),
                                      painter: LifelinePainter(
                                        progress: _mainController.value,
                                        memories: memories,
                                        paragraphs: _cachedParagraphs,
                                        onNodePosition: _onNodePosition,
                                        onDailyClusterPosition:
                                            _onDailyClusterPosition,
                                        zoomScale: currentScale,
                                        pulseValue: _pulseController.value,
                                        renderData: _renderData!,
                                        timingsNotifier:
                                            _paintTimingsNotifier,
                                        images: _cachedImages,
                                        branchIntensity: _branchIntensity,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
            const GlobalAudioPlayerWidget(),
            _buildControlsOverlay(l10n),
            _buildStatsOverlay(
                syncState, memoriesAsyncValue.asData?.value ?? [], l10n),
            const FloatingMessageOverlay(),
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                key: _fabKey,
                onPressed: () => _openCreate(userId),
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
            if (_selectionItems != null && _selectionCenter != null)
              SelectionMenu(
                items: _selectionItems!,
                center: _selectionCenter!,
                images: _cachedImages,
                onClose: () {
                  if (mounted) {
                    setState(() {
                      _selectionItems = null;
                      _selectionCenter = null;
                    });
                  }
                },
                onItemSelected: (item) {
                  final currentCenter = _selectionCenter;
                  if (mounted) {
                    setState(() {
                      _selectionItems = null;
                      _selectionCenter = null;
                    });
                  }
                  if (currentCenter != null) {
                    final currentUserId =
                        ref.read(authStateChangesProvider).asData?.value?.uid;
                    if (currentUserId != null) {
                      Future.microtask(() {
                        _handleTappableItemAction(
                            item, currentCenter, currentUserId);
                      });
                    }
                  }
                },
              ),
            OnboardingOverlay(
              fabKey: _fabKey,
              statsCardKey: _statsCardKey,
              controlsPanelKey: _controlsPanelKey,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildControlsOverlay(AppLocalizations l10n) {
    return Positioned(
        key: _controlsPanelKey, // NEW: Assign key
        top: 16,
        right: 16,
        child: Row(children: [
          Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  borderRadius: BorderRadius.circular(25),
                  border:
                      Border.all(color: Colors.white.withAlpha((255 * 0.2).round()))),
              child: IconButton(
                icon: const Icon(Icons.fit_screen, color: Colors.white),
                onPressed: _showFullTimeline,
                tooltip: l10n.lifelineShowFullTimelineTooltip,
              )),
          Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  borderRadius: BorderRadius.circular(25),
                  border:
                      Border.all(color: Colors.white.withAlpha((255 * 0.2).round()))),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => _showVisualSettings(l10n),
                tooltip: l10n.lifelineVisualSettingsTooltip,
              )),
          Container(
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  borderRadius: BorderRadius.circular(25),
                  border:
                      Border.all(color: Colors.white.withAlpha((255 * 0.2).round()))),
              child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) {
                    switch (value) {
                      case 'toggle_debug':
                        _toggleDebugMode();
                        break;
                      case 'profile_settings':
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ProfileScreen()));
                        break;
                      case 'sign_out':
                        ref.read(audioPlayerProvider.notifier).stopAndReset();
                        ref
                            .read(encryptionServiceProvider.notifier)
                            .lockSession();
                        ref.read(authServiceProvider).signOut();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                        PopupMenuItem(
                            value: 'profile_settings',
                            child: ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(l10n.lifelineMenuProfile))),
                        const PopupMenuDivider(),
                        if (_isAdmin)
                          PopupMenuItem(
                              value: 'toggle_debug',
                              child: ListTile(
                                  leading: Icon(Icons.bug_report,
                                      color: _debugMode ? Colors.red : null),
                                  title: Text(_debugMode
                                      ? l10n.lifelineMenuDebugOff
                                      : l10n.lifelineMenuDebugOn))),
                        if (_isAdmin) const PopupMenuDivider(),
                        PopupMenuItem(
                            value: 'sign_out',
                            child: ListTile(
                                leading: const Icon(Icons.exit_to_app),
                                title: Text(l10n.lifelineMenuSignOut))),
                      ]))
        ]));
  }

  Widget _buildStatsOverlay(
      SyncState syncState, List<Memory> memories, AppLocalizations l10n) {
    return Positioned(
        left: 16,
        bottom: 16,
        child: GestureDetector(
            key: _statsCardKey, // NEW: Assign key
            onTap: () => _showMemoriesListPopup(memories, l10n),
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.black.withAlpha((255 * 0.6).round()),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.white.withAlpha((255 * 0.2).round()))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.lifelineMemoriesCount(memories.length),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                      if (memories.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                            l10n.lifelinePeriodRange(
                                memories.first.date.year, memories.last.date.year),
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 10))
                      ],
                      if (syncState.isSyncing) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(
                                width: 12,
                                height: 12,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2)),
                            const SizedBox(width: 8),
                            Text(
                                l10n.lifelineSyncStatus(
                                    syncState.currentStatus,
                                    syncState.pendingJobs),
                                style: const TextStyle(
                                    color: Colors.lightBlueAccent,
                                    fontSize: 10)),
                          ],
                        ),
                        if (syncState.progress != null) ...[
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              height: 4,
                              width: 100,
                              child: LinearProgressIndicator(
                                value: syncState.progress,
                                backgroundColor:
                                    Colors.white.withAlpha((255 * 0.2).round()),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    Colors.lightBlueAccent),
                              ),
                            ),
                          )
                        ]
                      ],
                      if (_isCalculating)
                        Text(l10n.lifelineCalculating,
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 10)),
                      if (_isAdmin && _debugMode) ...[
                        const SizedBox(height: 4),
                        ValueListenableBuilder<Matrix4>(
                          valueListenable: _transformationController,
                          builder: (context, value, child) {
                            final totalWidth = _cachedLayoutResult?.totalWidth ??
                                _lastKnownSize.width;
                            final minScale = _calculateMinScale(
                                totalWidth, _lastKnownSize.width);
                            final rawScale = value.getMaxScaleOnAxis();

                            final displayScale = (minScale > 0.0001)
                                ? (rawScale / minScale * 100).round()
                                : 0;

                            return Text(
                              l10n.lifelineScaleValue(displayScale),
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 10),
                            );
                          },
                        ),
                        ValueListenableBuilder<double>(
                          valueListenable: _performanceMonitor.fpsNotifier,
                          builder: (context, fps, child) {
                            return Text(
                                l10n.lifelineFpsValue(fps.toStringAsFixed(1)),
                                style: const TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold));
                          },
                        ),
                        ValueListenableBuilder<PaintTimings?>(
                          valueListenable: _paintTimingsNotifier,
                          builder: (context, timings, child) {
                            if (timings == null || timings.total == 0) {
                              return const SizedBox.shrink();
                            }
                            Widget timingRow(
                                String label, int value, Color color) {
                              final percentage = (value / timings.total * 100);
                              return Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Row(
                                  children: [
                                    Text('${label.padRight(11)}: ',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 9)),
                                    SizedBox(
                                      width: 50,
                                      child: LinearProgressIndicator(
                                        value: percentage / 100,
                                        backgroundColor: color
                                            .withAlpha((255 * 0.2).round()),
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                color),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${percentage.toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 9)),
                                  ],
                                ),
                              );
                            }

                            return Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      l10n.lifelineFramePaintValue(
                                          timings.total),
                                      style: const TextStyle(
                                          color: Colors.lightGreenAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  timingRow('Background', timings.background,
                                      Colors.blueAccent),
                                  timingRow('Structure', timings.structure,
                                      Colors.redAccent),
                                  timingRow(
                                      'Nodes', timings.nodes, Colors.orangeAccent),
                                  timingRow('Labels', timings.labels,
                                      Colors.purpleAccent),
                                  timingRow('Macro View', timings.macroView,
                                      Colors.cyanAccent),
                                ],
                              ),
                            );
                          },
                        ),
                      ]
                    ]))));
  }
}

class MemoriesListPopup extends StatefulWidget {
  final List<Memory> memories;
  final ScrollController scrollController;
  final ValueChanged<Memory> onMemorySelected;
  final AppLocalizations l10n;
  const MemoriesListPopup(
      {super.key,
      required this.memories,
      required this.scrollController,
      required this.onMemorySelected,
      required this.l10n});
  @override
  State<MemoriesListPopup> createState() => _MemoriesListPopupState();
}

class _MemoriesListPopupState extends State<MemoriesListPopup> {
  final TextEditingController _searchController = TextEditingController();
  List<Memory> _filteredMemories = [];

  @override
  void initState() {
    super.initState();
    _filteredMemories = widget.memories;
    _searchController.addListener(_filterMemories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMemories);
    _searchController.dispose();
    super.dispose();
  }

  void _filterMemories() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredMemories = widget.memories);
      return;
    }
    final filtered = widget.memories.where((memory) {
      final titleMatch = memory.title.toLowerCase().contains(query);
      final contentMatch = memory.content?.toLowerCase().contains(query) ?? false;
      final dateMatch =
          DateFormat.yMMMd().format(memory.date).toLowerCase().contains(query);
      return titleMatch || contentMatch || dateMatch;
    }).toList();
    setState(() => _filteredMemories = filtered);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: const Color(0xFF1a1a2a).withAlpha(242),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            border: Border.all(color: Colors.white.withAlpha(51))),
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: widget.l10n.lifelineSearchHint,
                      hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                      prefixIcon:
                          Icon(Icons.search, color: Colors.white.withAlpha(178)),
                      filled: true,
                      fillColor: Colors.black.withAlpha(76),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none)))),
          Expanded(
              child: ListView.builder(
                  controller: widget.scrollController,
                  itemCount: _filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = _filteredMemories[index];
                    return ListTile(
                        leading: const Icon(Icons.article_outlined,
                            color: Colors.white70),
                        title: Text(memory.title,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        subtitle: Text(DateFormat.yMMMd().format(memory.date),
                            style: const TextStyle(color: Colors.white60)),
                        onTap: () => widget.onMemorySelected(memory));
                  }))
        ]));
  }
}

class SelectionMenu extends StatefulWidget {
  final List<TappableItem> items;
  final Offset center;
  final VoidCallback onClose;
  final ValueChanged<TappableItem> onItemSelected;
  final Map<String, ui.Image> images;

  const SelectionMenu({
    super.key,
    required this.items,
    required this.center,
    required this.onClose,
    required this.onItemSelected,
    required this.images,
  });

  @override
  State<SelectionMenu> createState() => _SelectionMenuState();
}

class _SelectionMenuState extends State<SelectionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.black.withAlpha(191)),
          ),
        ),
        ..._buildSelectionItems(),
      ],
    );
  }

  List<Widget> _buildSelectionItems() {
    final List<Widget> items = [];
    final double baseDistance = widget.items.length > 4 ? 120.0 : 100.0;
    const double itemSize = 60.0;

    for (int i = 0; i < widget.items.length; i++) {
      final item = widget.items[i];
      final angle = (i / widget.items.length) * 2 * pi - (pi / 2);

      String? coverPath;
      if (item.type == TappableType.singleNode) {
        coverPath = (item.data as Memory).coverPath;
      } else {
        coverPath = (item.data as List<Memory>).first.coverPath;
      }
      final image = (coverPath != null) ? widget.images[coverPath] : null;

      items.add(
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final distance = baseDistance * _animation.value;
            final x =
                widget.center.dx + cos(angle) * distance - (itemSize * 1.5 / 2);
            final y = widget.center.dy + sin(angle) * distance - (itemSize / 2);

            return Positioned(
              left: x,
              top: y,
              width: itemSize * 1.5,
              height: itemSize + 40,
              child: GestureDetector(
                onTap: () => widget.onItemSelected(item),
                child: Opacity(
                  opacity: _animation.value.clamp(0.0, 1.0),
                  child: _SelectionItem(item: item, image: image),
                ),
              ),
            );
          },
        ),
      );
    }
    return items;
  }
}

class _SelectionItem extends StatelessWidget {
  final TappableItem item;
  final ui.Image? image;
  const _SelectionItem({required this.item, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: item.type == TappableType.dailyCluster
                ? Colors.amber.shade700
                : Theme.of(context).colorScheme.primary,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 8, spreadRadius: 2)
            ],
          ),
          child: ClipOval(
            child: image != null
                ? RawImage(image: image!, fit: BoxFit.cover)
                : Center(
                    child: Icon(item.icon, color: Colors.white, size: 30)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.title(context),
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
        )
      ],
    );
  }
}

class PerformanceMonitor {
  int _frameCount = 0;
  DateTime? _fpsStartTime;
  final ValueNotifier<double> fpsNotifier = ValueNotifier<double>(0.0);

  void tick() {
    final currentTime = DateTime.now();

    _fpsStartTime ??= currentTime;

    _frameCount++;
    final elapsedTime = currentTime.difference(_fpsStartTime!).inMilliseconds;

    if (elapsedTime >= 1000) {
      final fps = (_frameCount * 1000 / elapsedTime);
      fpsNotifier.value = fps;

      _frameCount = 0;
      _fpsStartTime = currentTime;
    }
  }

  void dispose() {
    fpsNotifier.dispose();
  }
}

