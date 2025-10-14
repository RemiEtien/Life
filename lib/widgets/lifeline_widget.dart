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
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/app_localizations.dart';
import '../models/user_profile.dart';
import '../utils/error_handler.dart';
import '../providers/application_providers.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../memory.dart';
import '../screens/memory_edit_screen.dart';
import '../screens/memory_view_screen.dart';
import '../screens/profile_screen.dart';
import '../services/message_service.dart';
import 'floating_message_overlay.dart';
import 'global_audio_player_widget.dart';
import 'lifeline_painter.dart';
import 'device_performance_detector.dart';
import 'monthly_cluster_bottom_sheet.dart';
import '../services/lifeline_calculator.dart';
import '../services/onboarding_service.dart';
import '../services/sync_service.dart';
import 'onboarding_overlay.dart';

enum TappableType { singleNode, dailyCluster, monthlyCluster, monthInCluster }

class TappableItem {
  final TappableType type;
  final dynamic data;

  TappableItem({required this.type, required this.data});

  String title(BuildContext context) {
    if (type == TappableType.singleNode) {
      return (data as Memory).title;
    } else if (type == TappableType.dailyCluster) {
      final memories = data as List<Memory>;
      if (memories.isEmpty) return 'Cluster';
      final date = memories.first.date;
      return 'Day: ${DateFormat.yMd().format(date)} (${memories.length})';
    } else if (type == TappableType.monthInCluster) {
      final mapData = data as Map<String, dynamic>;
      final memories = mapData['memories'] as List<Memory>;
      final month = mapData['month'] as DateTime;
      return '${DateFormat.MMMM().format(month)}\n${memories.length}';
    } else {
      // monthlyCluster - data is Map
      final mapData = data as Map<String, dynamic>;
      final memories = mapData['memories'] as List<Memory>;
      final month = mapData['month'] as DateTime;
      return 'Month: ${DateFormat.yMMM().format(month)} (${memories.length})';
    }
  }

  IconData get icon {
    if (type == TappableType.singleNode) {
      return Icons.history_edu_outlined;
    } else if (type == TappableType.dailyCluster) {
      return Icons.style_outlined;
    } else if (type == TappableType.monthInCluster) {
      return Icons.calendar_today;
    } else {
      return Icons.calendar_month;
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
    with TickerProviderStateMixin, WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  late final AnimationController _mainController;
  late final AnimationController _pulseController;
  late final AnimationController _geometryController;
  late final AnimationController _backgroundController;
  late final AnimationController _branchController;
  // НОВЫЕ ПЕРЕМЕННЫЕ: Контроллер и анимация для плавного зума
  AnimationController? _zoomAnimationController;
  Animation<Matrix4>? _zoomAnimation;

  final TransformationController _transformationController =
      TransformationController();

  LayoutResult? _cachedLayoutResult;
  bool _isAdmin = false;
  bool _hasLoadedMemoriesOnce = false; // Track if memories have been loaded at least once

  List<TappableItem>? _selectionItems;
  Offset? _selectionCenter;

  final Map<String, ui.Paragraph> _cachedParagraphs = {};
  final Map<String, ui.Image> _cachedImages = {};
  Size _lastKnownSize = Size.zero;
  final Map<String, Offset> _nodePositions = {};
  final Map<String, (Offset, List<Memory>)> _dailyClusterData = {};
  final Map<String, (Offset, List<Memory>, DateTime, List<String>)> _monthlyClusterData = {};

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
  bool _centerOnNextLayout = false;
  bool _isDisposed = false;

  // НОВАЯ ПЕРЕМЕННАЯ: Для хранения позиции двойного тапа
  Offset _doubleTapLocalPosition = Offset.zero;

  // --- ИСПРАВЛЕНИЕ БАГА ГЕОМЕТРИИ: Переменные для очереди перерасчета ---
  bool _recalculationNeeded = false;
  List<Memory>? _pendingMemoriesForRecalculation;

  // NEW: Кэш UserProfile для использования в асинхронных операциях
  UserProfile? _cachedUserProfile;
  // --- КОНЕЦ ИСПРАВЛЕНИЯ ---

  final ValueNotifier<PaintTimings?> _paintTimingsNotifier =
      ValueNotifier(null);

  // AutomaticKeepAliveClientMixin: Keep widget alive during navigation
  @override
  bool get wantKeepAlive => true;

  final String _adminUid = 'BGnE9FuIasfIOj5ln3rQHIBiulv2';

  final _fabKey = GlobalKey();
  final _statsCardKey = GlobalKey();
  final _controlsPanelKey = GlobalKey();

  ProviderSubscription<AsyncValue<List<Memory>>>? _memoriesSubscription;
  ProviderSubscription<AsyncValue<UserProfile?>>? _profileSubscription;
  ProviderSubscription<SyncState>? _syncSubscription;

  List<Memory> _currentMemories = [];

  late VoidCallback _geometryAnimationListener;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _centerOnNextLayout = true; // Запрашиваем центрирование при первой загрузке
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
      if (mounted && _debugMode && !_isDisposed) {
        // Calculate zoom snapshot for logging
        String? zoomSnapshot;
        if (_performanceMonitor.isRecording && _cachedLayoutResult != null) {
          final totalWidth = _cachedLayoutResult!.totalWidth;
          final minScale = _calculateMinScale(totalWidth, _lastKnownSize.width);
          final currentScale = _transformationController.value.getMaxScaleOnAxis();
          final relativeZoom = (minScale > 0.0001) ? currentScale / minScale : 1.0;

          // Use CORRECT formula (same as painter - interpolated)
          // Painter: varies at 1x, converges to SAME VISUAL SIZE at 8x
          const maxRelativeZoom = 8.0;
          const startRadiusConstant = 4.0;  // Small at 1x (~12px)
          const targetRadiusConstant = 133.0;  // Larger at 8x (~50px)

          // Calculate starting radius (proportional for uniform visual size)
          final startRadius = startRadiusConstant * minScale;

          // Calculate target radius (proportional for uniform visual size)
          final targetRadius = targetRadiusConstant * minScale;

          // Calculate interpolation progress
          final clampedZoom = relativeZoom.clamp(1.0, maxRelativeZoom);
          final t = (clampedZoom - 1.0) / (maxRelativeZoom - 1.0);

          // Linear interpolation to get kNodeBaseRadius
          final kNodeBaseRadius = startRadius + (targetRadius - startRadius) * t;

          const actualMultiplier = 1.5; // From _drawSingleMemoryNode
          final actualNodeRadius = kNodeBaseRadius * actualMultiplier;
          final nodeSize = (actualNodeRadius * 2) / currentScale;

          // Calculate what node size SHOULD be at 8x zoom (uniform ~13px)
          final targetScale8x = minScale * 8.0;
          final expectedNodeSizeAt8x = (targetRadius * actualMultiplier * 2) / targetScale8x;

          // Determine zoom level
          String level;
          if (relativeZoom < 2.0) {
            level = 'LVL1(Yearly)';
          } else if (relativeZoom < 4.0) {
            level = 'LVL2(Monthly)';
          } else {
            level = 'LVL3(Individual)';
          }

          zoomSnapshot = 'Zoom:${relativeZoom.toStringAsFixed(2)}x | Node:${nodeSize.toStringAsFixed(2)}px | $level | minScale:${minScale.toStringAsFixed(4)} | kNodeBase:${kNodeBaseRadius.toStringAsFixed(2)} | actualRadius:${actualNodeRadius.toStringAsFixed(2)} | Expected@8x:${expectedNodeSizeAt8x.toStringAsFixed(2)}px';
        }

        _performanceMonitor.tick(zoomSnapshot: zoomSnapshot);
      }
    });

    _geometryAnimationListener = () {
      if (!_isDisposed && mounted) {
        _geometryAnimationTick();
      }
    };

    final geometryAndBranchListener =
        Listenable.merge([_geometryController, _branchController]);
    geometryAndBranchListener.addListener(_geometryAnimationListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed) {
        _setupListeners();
        ref.read(onboardingServiceProvider.notifier).startOnAppLaunch();
        ref.read(syncServiceProvider).syncFromCloudToLocal();
      }
    });
  }

  void _setupListeners() {
    _memoriesSubscription = ref.listenManual<AsyncValue<List<Memory>>>(
        memoriesStreamProvider, _onMemoriesChanged,
        fireImmediately: true);

    _profileSubscription = ref.listenManual<AsyncValue<UserProfile?>>(
      userProfileProvider,
      (previous, next) {
        if (_isDisposed || !mounted) return;

        final profile = next.asData?.value;
        if (profile != null) {
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
      },
    );
    _syncSubscription = ref.listenManual<SyncState>(
      syncNotifierProvider,
      (previous, next) {
        if (_isDisposed || !mounted) return;

        if (previous != null) {
          if (!previous.isSyncing &&
              next.isSyncing &&
              next.currentStatus != 'Idle') {
            ref
                .read(messageProvider.notifier)
                .addMessage('Sync started...', type: MessageType.info);
          } else if (previous.isSyncing && !next.isSyncing) {
            if (next.currentStatus.contains('failed')) {
              ref
                  .read(messageProvider.notifier)
                  .addMessage('Sync failed. Will retry later.',
                      type: MessageType.error);
            } else {
              ref
                  .read(messageProvider.notifier)
                  .addMessage('Sync complete!', type: MessageType.success);
            }
          }
        }
      },
    );
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
      } catch (e, stackTrace) {
        ErrorHandler.logError(e, stackTrace, reason: 'Failed to save visual settings');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(e,
              fallback: 'Failed to save visual settings. Please try again.'))),
          );
        }
      }
    }
  }

  void _geometryAnimationTick() {
    if (_isDisposed || !mounted) return;

    try {
      if (_cachedLayoutResult != null) {
        _requestGeometryUpdate(_cachedLayoutResult!, _currentMemories);
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        debugPrint('Error in _geometryAnimationTick: $e');
      }
    }
  }

  void _onMemoriesChanged(
      AsyncValue<List<Memory>>? previous, AsyncValue<List<Memory>> next) {
    if (_isDisposed || !mounted) return;

    if (next is AsyncData<List<Memory>>) {
      final memories = next.value;
      if (mounted && !_isDisposed) {
        // Mark that memories have been loaded at least once
        _hasLoadedMemoriesOnce = true;

        // FIX: Load images and paragraphs immediately, even if size not known yet
        // This prevents "empty lifeline on fresh install" issue
        _loadMemoryImages(memories);
        _updateParagraphs(memories);

        // Recalculation will be skipped if size is not known (handled inside _requestFullRecalculation)
        // but will trigger automatically when size becomes available in build()
        _requestFullRecalculation(memories);
      }
    }
  }

  Future<void> _loadMemoryImages(List<Memory> memories) async {
    if (_isDisposed || !mounted) return;

    for (final memory in memories) {
      if (_isDisposed || !mounted) break;

      final coverPath = memory.coverPath;
      if (coverPath != null &&
          coverPath.isNotEmpty &&
          !_cachedImages.containsKey(coverPath)) {
        final thumbPath = memory.coverThumbPath;
        if (thumbPath == null) continue;

        final ImageProvider provider = thumbPath.startsWith('http')
            ? CachedNetworkImageProvider(thumbPath)
            : FileImage(File(thumbPath));

        try {
          final image = await _getUiImageFromProvider(provider);
          if (image != null && mounted && !_isDisposed) {
            setState(() {
              _cachedImages[coverPath] = image;
            });
          }
        } catch (e) {
          if (mounted && !_isDisposed) {
            debugPrint('Error loading image: $e');
          }
        }
      }
    }
  }

  Future<ui.Image?> _getUiImageFromProvider(ImageProvider provider) async {
    final completer = Completer<ui.Image?>();
    final stream = provider.resolve(const ImageConfiguration());

    final listener = ImageStreamListener(
      (imageInfo, synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(imageInfo.image);
        }
      },
      onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          if (kDebugMode) {
            debugPrint('Error loading ui.Image: $exception');
          }
          completer.complete(null);
        }
      },
    );

    stream.addListener(listener);
    final result = await completer.future;
    stream.removeListener(listener);
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
          final bool shouldReverse =
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

    _memoriesSubscription?.close();
    _profileSubscription?.close();
    _syncSubscription?.close();

    _mainController.stop();
    _pulseController.stop();
    _geometryController.stop();
    _backgroundController.stop();
    _branchController.stop();

    // НОВОЕ: Уничтожаем контроллер анимации зума
    _zoomAnimationController?.dispose();

    final geometryAndBranchListener =
        Listenable.merge([_geometryController, _branchController]);
    geometryAndBranchListener.removeListener(_geometryAnimationListener);

    _mainController.dispose();
    _pulseController.dispose();
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
      path.cubicTo(points[i], points[i + 1], points[i + 2], points[i + 3],
          points[i + 4], points[i + 5]);
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
    if (!mounted || _lastKnownSize.isEmpty || _isDisposed) return;
    _cachedParagraphs.clear();
    for (final memory in memories) {
      if (_isDisposed) break;
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
    final groupedByDay = groupBy(sortedMemories,
        (m) => DateTime(m.date.year, m.date.month, m.date.day));

    final newPlacementResults = <dynamic>[];
    final sortedEntries = groupedByDay.entries.sortedBy((entry) => entry.key);

    final int itemCount = sortedEntries.length;

    double nodeSpacing;
    double totalWidth;

    if (itemCount < 10) {
      final double baseWidth = max(800.0, availableSize.width);
      final double availableSpace = baseWidth - 2 * margin;

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
    if (_isCalculating || !mounted || _lastKnownSize.isEmpty || _isDisposed) {
      // --- ИСПРАВЛЕНИЕ БАГА ГЕОМЕТРИИ: Если расчет уже идет, ставим в очередь новый ---
      if (_isCalculating) {
        _recalculationNeeded = true;
        _pendingMemoriesForRecalculation = memories;
      }
      // --- КОНЕЦ ИСПРАВЛЕНИЯ ---
      return;
    }

    final layoutResult = _calculateLayout(_lastKnownSize, memories);

    if (mounted && !_isDisposed) {
      setState(() {
        _cachedLayoutResult = layoutResult;
      });
      _requestGeometryUpdate(layoutResult, memories);
    }
  }

  void _requestGeometryUpdate(
      LayoutResult layoutResult, List<Memory> memories) {
    if (!mounted || _isDisposed) return; // Убрали проверку _isCalculating отсюда

    if (mounted && !_isDisposed) setState(() => _isCalculating = true);

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
      if (_isDisposed || !mounted) {
        receivePort.close();
        return;
      }

      if (message is CalculationOutput) {
        final mainPath = _buildCubicPathFromPoints(message.mainPathPoints);
        final branches = message.branchPoints
            .map((p) => _buildLinePathFromPoints(p))
            .toList();
        final roots =
            message.rootPoints.map((p) => _buildCubicPathFromPoints(p)).toList();
        final yearPath =
            _createFlatYearLine(totalWidth, _lastKnownSize.height);

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

        if (mounted && !_isDisposed) {
          setState(() {
            _renderData = newRenderData;
            _updateStructureCache(newRenderData,
                Size(totalWidth, _lastKnownSize.height), memories, _cachedUserProfile);
            _isCalculating = false;

            // --- ИСПРАВЛЕНИЕ БАГА ГЕОМЕТРИИ: Проверяем, не нужно ли пересчитать снова ---
            if (_recalculationNeeded) {
              final pendingMemories = _pendingMemoriesForRecalculation;
              _recalculationNeeded = false;
              _pendingMemoriesForRecalculation = null;

              if (pendingMemories != null) {
                // Запускаем перерасчет в следующем кадре, чтобы избежать конфликтов состояния
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isDisposed) {
                    _requestFullRecalculation(pendingMemories);
                  }
                });
              }
            } else if (_centerOnNextLayout) {
              // Центрируем только если нет ожидающего перерасчета
              _centerOnNextLayout = false; // Сбрасываем флаг

              // FIX: Set initial scale immediately (without animation) to prevent showing wrong zoom level on first frame
              final currentScale = _transformationController.value.getMaxScaleOnAxis();
              final isFirstInitialization = (currentScale - 1.0).abs() < 0.01;

              if (isFirstInitialization && totalWidth > 0 && _lastKnownSize.width > 0) {
                // First initialization - set scale immediately without animation
                final minScale = _calculateMinScale(totalWidth, _lastKnownSize.width);
                final screenCenter = _lastKnownSize.center(Offset.zero);
                final contentCenterY = _lastKnownSize.height / 2;
                final contentCenter = Offset(totalWidth / 2, contentCenterY);

                final targetMatrix = Matrix4.identity();
                targetMatrix.translate(screenCenter.dx, screenCenter.dy);
                targetMatrix.scale(minScale, minScale);
                targetMatrix.translate(-contentCenter.dx, -contentCenter.dy);

                _transformationController.value = targetMatrix;
              } else {
                // Subsequent calls - use animation
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_isDisposed) {
                    _animateToFullTimeline();
                  }
                });
              }
            }
            // --- КОНЕЦ ИСПРАВЛЕНИЯ ---
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

  // RESTORED from v149: Calculate maximum scale using ABSOLUTE SCALE approach
  // This creates a "visual lock" - all timelines zoom to the same absolute scale
  // regardless of their length, ensuring nodes appear the same size at max zoom
  //
  // Strategy:
  // 1. Use base content width of 1200px as reference
  // 2. Calculate maxScale based on this fixed width, not actual timeline length
  // 3. All timelines zoom to same absolute scale → same visual node size
  // 4. Node radius is constant (10.0), no dynamic adjustments needed
  double _calculateMaxScale(double minScale, double screenWidth) {
    const double kBaseContentWidth = 1200.0;  // Visual lock reference width
    final baseScale = _calculateMinScale(kBaseContentWidth, screenWidth);
    const zoomFactor = 6.0;  // 6x zoom from base
    final desiredMaxScale = baseScale * zoomFactor;
    return max(minScale, desiredMaxScale);  // Never less than minScale
  }

  void _updateStructureCache(
      RenderData data, Size size, List<Memory> memories, UserProfile? userProfile) {
    if (!mounted || size.isEmpty || _isDisposed) return;

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
      userProfile: userProfile, // NEW: передаем настройки
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
    if (mounted && !_isDisposed) {
      setState(() {
        _structureCache?.dispose();
        _structureCache = newCache;
      });
    }
  }

  void _onNodePosition(String id, Offset pos) => _nodePositions[id] = pos;
  void _onDailyClusterPosition(String id, Offset pos, List<Memory> memories) =>
      _dailyClusterData[id] = (pos, memories);

  void _onMonthlyClusterPosition(List<String> monthKeys, Offset pos, List<Memory> memories, DateTime month) {
    // Use first month key as the ID for the cluster
    final clusterId = monthKeys.first;
    _monthlyClusterData[clusterId] = (pos, memories, month, monthKeys);
  }

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

    // Calculate relative zoom for consistent behavior across devices
    final totalWidth = _cachedLayoutResult?.totalWidth ?? _lastKnownSize.width;
    final minScale = _calculateMinScale(totalWidth, _lastKnownSize.width);
    // If currentScale is close to 1.0, it means initial centering hasn't happened yet
    final isUninitialized = (currentScale - 1.0).abs() < 0.01;
    final relativeZoom = isUninitialized || minScale <= 0.0001
        ? 1.0
        : currentScale / minScale;

    final scenePosition = _transformationController.toScene(d.localPosition);
    final hitRadiusInScene = kTapRadiusOnScreen / currentScale;
    final List<TappableItem> hits =
        _findTappableItems(scenePosition, hitRadiusInScene, relativeZoom);

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

  // НОВЫЙ МЕТОД: Обрабатывает двойной тап для зума
  void _handleDoubleTap() {
    if (_zoomAnimationController?.isAnimating ?? false) return;
    if (_cachedLayoutResult == null) return;

    final matrix = _transformationController.value;
    final currentScale = matrix.getMaxScaleOnAxis();

    final totalWidth = _cachedLayoutResult!.totalWidth;
    final screenWidth = _lastKnownSize.width;

    final minScale = _calculateMinScale(totalWidth, screenWidth);
    final maxScale = _calculateMaxScale(minScale, screenWidth);

    // Определяем целевой масштаб: если мы уже приближены, то отдаляем, иначе приближаем к максимальному уровню
    final targetScale = (currentScale - minScale).abs() > 0.1 ? minScale : maxScale;

    // Анимируем к новому масштабу, центрируясь на точке касания
    _animateZoomToPoint(targetScale, _doubleTapLocalPosition);
  }

  // ИСПРАВЛЕНИЕ: Полностью переписанная логика для корректного зума к точке.
  void _animateZoomToPoint(double targetScale, Offset focalPoint) {
    _zoomAnimationController?.stop(); // Останавливаем любую текущую анимацию зума

    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    // CRITICAL: Clamp targetScale to maxScale limit (2.6)
    // This ensures we never zoom deeper than 10px nodes
    final totalWidth = _cachedLayoutResult?.totalWidth ?? _lastKnownSize.width;
    final screenWidth = _lastKnownSize.width;
    final minScale = _calculateMinScale(totalWidth, screenWidth);
    final maxScale = _calculateMaxScale(minScale, screenWidth);
    final clampedTargetScale = targetScale.clamp(minScale, maxScale);

    // Избегаем ненужной анимации, если масштаб уже почти целевой
    if ((clampedTargetScale - currentScale).abs() < 0.01) return;

    // Точка в координатах сцены (контента), которая должна остаться под пальцем
    final sceneFocalPoint = _transformationController.toScene(focalPoint);

    // Вычисляем новое смещение (translation) для матрицы, чтобы
    // точка sceneFocalPoint после масштабирования оказалась под точкой focalPoint на экране.
    final double tx = focalPoint.dx - sceneFocalPoint.dx * clampedTargetScale;
    final double ty = focalPoint.dy - sceneFocalPoint.dy * clampedTargetScale;

    // Создаем новую целевую матрицу "с нуля"
    final targetMatrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(clampedTargetScale);

    // Запускаем анимацию к новой матрице
    _animateToMatrix(targetMatrix);
  }

  // НОВЫЙ МЕТОД: Общая функция для плавной анимации матрицы
  void _animateToMatrix(Matrix4 target) {
    _zoomAnimationController?.dispose();
    _zoomAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _zoomAnimation = Matrix4Tween(
      begin: _transformationController.value,
      end: target,
    ).animate(CurvedAnimation(
        parent: _zoomAnimationController!, curve: Curves.easeInOutCubic));

    _zoomAnimation!.addListener(() {
      _transformationController.value = _zoomAnimation!.value;
    });
    
    _zoomAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _zoomAnimationController?.dispose();
        _zoomAnimationController = null;
        _zoomAnimation = null;
      }
    });

    _zoomAnimationController!.forward();
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
    } else if (item.type == TappableType.monthlyCluster) {
      try {
        final data = item.data;
        if (kDebugMode) {
          print('[MONTHLY CLUSTER TAP] data type: ${data.runtimeType}');
          print('[MONTHLY CLUSTER TAP] data: $data');
        }

        if (data is! Map<String, dynamic>) {
          if (kDebugMode) {
            print('[ERROR] monthlyCluster data is not a Map, it is: ${data.runtimeType}');
          }
          return;
        }

        final monthKeys = data['monthKeys'] as List<String>?;
        final month = data['month'] as DateTime?;
        final memoriesList = data['memories'];

        if (monthKeys == null || monthKeys.isEmpty || month == null || memoriesList == null) {
          if (kDebugMode) {
            print('[ERROR] Missing required fields in monthlyCluster data');
          }
          return;
        }

        if (memoriesList is! List<Memory>) {
          if (kDebugMode) {
            print('[ERROR] memories field is not List<Memory>, it is: ${memoriesList.runtimeType}');
          }
          return;
        }

        // If single month, show directly; if multiple, show month selection
        if (monthKeys.length == 1) {
          _showMonthlyClusterBottomSheet(monthKeys.first, month, memoriesList);
        } else {
          _showMonthSelectionMenu(monthKeys, memoriesList);
        }
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print('[ERROR] Error handling monthlyCluster tap: $e');
          print('[STACKTRACE] $stackTrace');
        }
      }
    } else if (item.type == TappableType.monthInCluster) {
      // Handle selection of a specific month from the cluster selection menu
      final data = item.data as Map<String, dynamic>;
      final monthKey = data['monthKey'] as String;
      final month = data['month'] as DateTime;
      final memories = data['memories'] as List<Memory>;
      _showMonthlyClusterBottomSheet(monthKey, month, memories);
    }
  }

  List<TappableItem> _findTappableItems(Offset scenePosition, double hitRadius, double currentScale) {
    final memories = ref.read(memoriesStreamProvider).asData?.value ?? [];
    final List<TappableItem> hits = [];
    final List<String> processedNodeIds = [];

    // Calculate level thresholds for tap detection (same as painter)
    final totalWidth = _cachedLayoutResult?.totalWidth ?? 1.0;
    final screenWidth = _lastKnownSize.width;
    final minScale = _calculateMinScale(totalWidth, screenWidth);

    // Calculate level thresholds (same as painter)
    const double kBaseContentWidth = 1200.0;
    final baseScale = (screenWidth * 0.95) / kBaseContentWidth;
    final effectiveBase = max(minScale, baseScale);
    final kLevel2Threshold = effectiveBase * 1.5;
    final kLevel3Threshold = effectiveBase * 3.0;

    // Проверяем месячные кластеры (приоритет выше чем дневные)
    // Месячные кластеры кликабельны только в LEVEL 2 (kLevel2Threshold <= currentScale < kLevel3Threshold)
    if (currentScale >= kLevel2Threshold && currentScale < kLevel3Threshold) {
      _monthlyClusterData.forEach((clusterId, data) {
        final pos = data.$1;
        final memoriesInCluster = data.$2;
        final month = data.$3;
        final monthKeys = data.$4;
        // Увеличенный радиус тапа для месячных кластеров (они крупнее)
        if ((pos - scenePosition).distance < hitRadius * 2) {
          hits.add(TappableItem(
              type: TappableType.monthlyCluster,
              data: {'monthKeys': monthKeys, 'memories': memoriesInCluster, 'month': month}));
          for (var mem in memoriesInCluster) {
            processedNodeIds.add(mem.universalId);
          }
        }
      });
    }

    // Дневные кластеры и одиночные воспоминания кликабельны только в LEVEL 3 (currentScale >= kLevel3Threshold)
    if (currentScale >= kLevel3Threshold) {
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
    }

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

  void _showMonthSelectionMenu(List<String> monthKeys, List<Memory> allMemories) {
    // Group memories by month
    final Map<String, List<Memory>> memoriesByMonth = {};
    for (final memory in allMemories) {
      final monthKey = '${memory.date.year}-${memory.date.month.toString().padLeft(2, '0')}';
      memoriesByMonth.putIfAbsent(monthKey, () => []).add(memory);
    }

    // Create TappableItem for each month
    final items = monthKeys.map((monthKey) {
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final monthDate = DateTime(year, month);
      final memories = memoriesByMonth[monthKey] ?? [];

      return TappableItem(
        type: TappableType.monthInCluster,
        data: {
          'monthKey': monthKey,
          'month': monthDate,
          'memories': memories,
        },
      );
    }).toList();

    // Show circular selection menu
    if (mounted) {
      setState(() {
        _selectionItems = items;
        _selectionCenter = _lastKnownSize.center(Offset.zero);
      });
    }
  }

  void _showMonthlyClusterBottomSheet(
      String monthKey, DateTime month, List<Memory> memories) {
    final userId = ref.read(authStateChangesProvider).asData?.value?.uid;
    if (userId == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return MonthlyClusterBottomSheet(
              monthKey: monthKey,
              month: month,
              memories: memories,
              onZoomToMonth: () => _zoomToMonth(month, memories),
              userId: userId,
              images: _cachedImages,
              scrollController: scrollController,
            );
          },
        );
      },
    );
  }

  void _zoomToMonth(DateTime month, List<Memory> memories) {
    // Находим среднюю позицию всех воспоминаний месяца
    if (memories.isEmpty) return;

    double sumX = 0;
    int count = 0;

    for (final memory in memories) {
      final pos = _nodePositions[memory.universalId];
      if (pos != null) {
        sumX += pos.dx;
        count++;
      }
    }

    if (count == 0) return;

    final centerX = sumX / count;
    final screenWidth = _lastKnownSize.width;

    // Целевой масштаб - достаточно близко чтобы видеть индивидуальные узлы (Level 3)
    const targetScale = 2.0; // Это примерно zoom 765% (2.0 * 0.261 базового)

    // Вычисляем смещение чтобы центрировать месяц на экране
    final tx = screenWidth / 2 - centerX * targetScale;
    final ty = _lastKnownSize.height / 2; // Центрируем по вертикали

    final targetMatrix = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(targetScale);

    _animateToMatrix(targetMatrix);
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
          .addMessage('Memory saved successfully!', type: MessageType.success);
    }
  }

  void _showFullTimeline() {
    if (!mounted || _isDisposed) return;
    
    // Всегда устанавливаем флаг, чтобы показать намерение центрировать
    setState(() {
      _centerOnNextLayout = true;
    });

    // Пытаемся запустить анимацию сразу, если данные уже готовы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDisposed && _centerOnNextLayout) {
        if (_cachedLayoutResult != null && _renderData != null) {
          // Данные готовы - центрируем сразу
          _animateToFullTimeline();
          setState(() {
            _centerOnNextLayout = false;
          });
        } else {
          // ИСПРАВЛЕНИЕ: Данные еще не готовы, но запрашиваем пересчет
          // Флаг _centerOnNextLayout остается true и центрирование произойдет
          // после готовности данных в _requestGeometryUpdate
          if (kDebugMode) {
            debugPrint('[LifelineWidget] Data not ready for centering, requesting recalculation');
          }
          _requestFullRecalculation(_currentMemories);
        }
      }
    });
  }

  void _animateToFullTimeline() {
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

    _animateToMatrix(targetMatrix);
  }

  void _toggleDebugMode() => setState(() => _debugMode = !_debugMode);

  Future<void> _sharePerformanceLog(String log) async {
    try {
      // Save log to temporary file
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final file = File('${directory.path}/performance_log_$timestamp.txt');
      await file.writeAsString(log);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Lifeline Performance Log',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export log: $e')),
        );
      }
    }
  }

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
                                      memories,
                                      _cachedUserProfile);
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
    super.build(context); // Keep widget alive
    final l10n = AppLocalizations.of(context)!;
    _nodePositions.clear();
    _dailyClusterData.clear();

    final memoriesAsyncValue = ref.watch(memoriesStreamProvider);
    _currentMemories = memoriesAsyncValue.asData?.value ?? [];
    final syncState = ref.watch(syncNotifierProvider);
    final userId = ref.watch(authStateChangesProvider).asData?.value?.uid;
    final onboardingState = ref.watch(onboardingServiceProvider);
    final userProfile = ref.watch(userProfileProvider).asData?.value; // NEW: для эмоциональных эффектов
    _cachedUserProfile = userProfile; // Кэшируем для использования в асинхронных операциях

    final isTimelineInteractionDisabled = onboardingState.isActive &&
        onboardingState.currentStep == OnboardingStep.addFirstMemory;

    // Check admin status from userProfile or fallback to hardcoded UID
    _isAdmin = (userProfile?.isAdmin ?? false) || userId == _adminUid;

    return LayoutBuilder(builder: (context, constraints) {
      final newSize = Size(constraints.maxWidth, constraints.maxHeight);
      if (newSize.isFinite &&
          newSize != _lastKnownSize &&
          newSize.width > 0 &&
          !_isDisposed) {
        _lastKnownSize = newSize;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_isDisposed) {
            _requestFullRecalculation(_currentMemories);
          }
        });
      }

      // FIX: Don't use fallback width until we have real layout data
      // This prevents incorrect geometry on first render
      final totalWidth = _cachedLayoutResult?.totalWidth;
      final screenWidth = constraints.maxWidth;

      // If we don't have layout data yet OR memories haven't loaded once, show loading indicator
      // This prevents showing empty lifeline geometry on fresh install
      if (totalWidth == null || !_hasLoadedMemoriesOnce) {
        return const Center(child: CircularProgressIndicator());
      }

      final minScale = _calculateMinScale(totalWidth, screenWidth);
      final maxScale = _calculateMaxScale(minScale, screenWidth);
      final contentHeight = constraints.maxHeight;

      // DEBUG: Log maxScale calculation
      if (kDebugMode) {
        debugPrint('[LifelineWidget] totalWidth=$totalWidth, screenWidth=$screenWidth, minScale=$minScale, maxScale=$maxScale');
      }

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
                  Center(child: Text('Error loading memories: $err')),
              data: (memories) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: isTimelineInteractionDisabled ? null : _onTapDown,
                  // НОВОЕ: Добавляем обработчики для двойного тапа
                  onDoubleTapDown: (details) => _doubleTapLocalPosition = details.localPosition,
                  onDoubleTap: isTimelineInteractionDisabled ? null : _handleDoubleTap,
                  child: InteractiveViewer(
                    transformationController: _transformationController,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    minScale: minScale,
                    maxScale: maxScale,
                    constrained: false,
                    panEnabled: !isTimelineInteractionDisabled,
                    scaleEnabled: !isTimelineInteractionDisabled,
                    onInteractionUpdate: (details) {
                      // CRITICAL: Enforce maxScale limit during pinch zoom
                      // This prevents zooming beyond 2.6 (10px nodes)
                      final currentScale = _transformationController.value.getMaxScaleOnAxis();
                      if (currentScale > maxScale) {
                        // Clamp the scale to maxScale while preserving translation
                        final matrix = _transformationController.value.clone();
                        final currentTranslation = matrix.getTranslation();
                        final scaleFactor = maxScale / currentScale;

                        // Scale down to maxScale, adjusting translation to keep focal point
                        matrix.setIdentity();
                        matrix.translate(currentTranslation.x * scaleFactor, currentTranslation.y * scaleFactor);
                        matrix.scale(maxScale);

                        _transformationController.value = matrix;
                      }
                    },
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
                                    final minScale = _calculateMinScale(totalWidth, screenWidth);
                                    // If currentScale is close to 1.0, it means initial centering hasn't happened yet
                                    // Use minScale as fallback to prevent showing wrong zoom level on first frame
                                    final isUninitialized = (currentScale - 1.0).abs() < 0.01;
                                    final relativeZoom = isUninitialized || minScale <= 0.0001
                                        ? 1.0
                                        : currentScale / minScale;
                                    return CustomPaint(
                                      size: Size(totalWidth, contentHeight),
                                      painter: LifelinePainter(
                                        progress: _mainController.value,
                                        memories: memories,
                                        paragraphs: _cachedParagraphs,
                                        onNodePosition: _onNodePosition,
                                        onDailyClusterPosition:
                                            _onDailyClusterPosition,
                                        onMonthlyClusterPosition:
                                            _onMonthlyClusterPosition,
                                        zoomScale: relativeZoom,
                                        currentScale: currentScale,
                                        minScale: minScale, // NEW: Base scale for fixed node sizing
                                        screenWidth: screenWidth, // NEW: Real screen width for baseScale calculation
                                        pulseValue: _pulseController.value,
                                        renderData: _renderData!,
                                        timingsNotifier:
                                            _paintTimingsNotifier,
                                        images: _cachedImages,
                                        branchIntensity: _branchIntensity,
                                        userProfile: userProfile, // NEW: для условного рендеринга
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
            _buildDraftsBanner(l10n),
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
                  border: Border.all(
                      color: Colors.white.withAlpha((255 * 0.2).round()))),
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
                  border: Border.all(
                      color: Colors.white.withAlpha((255 * 0.2).round()))),
              child: IconButton(
                icon: const Icon(Icons.tune, color: Colors.white),
                onPressed: () => _showVisualSettings(l10n),
                tooltip: l10n.lifelineVisualSettingsTooltip,
              )),
          Container(
              decoration: BoxDecoration(
                  color: Colors.black.withAlpha((255 * 0.6).round()),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                      color: Colors.white.withAlpha((255 * 0.2).round()))),
              child: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) async {
                    switch (value) {
                      case 'toggle_debug':
                        _toggleDebugMode();
                        break;
                      case 'profile_settings':
                        // **ИСПРАВЛЕНО:** Логика упрощена.
                        // Теперь мы просто ждем результат и вызываем центрирование.
                        // Запуск онбординга произойдет автоматически благодаря Riverpod.
                        final result = await Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const ProfileScreen()));
                        if (result == 'replay_onboarding' && mounted) {
                          _showFullTimeline();
                        }
                        break;
                      case 'sign_out':
                        unawaited(ref.read(audioPlayerProvider.notifier).stopAndReset());
                        unawaited(ref
                            .read(encryptionServiceProvider.notifier)
                            .lockSession());
                        unawaited(ref.read(authServiceProvider).signOut());
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
    final memoriesCount = memories.length;
    final startYear = memoriesCount > 0 ? memories.last.date.year : 0;
    final endYear = memoriesCount > 0 ? memories.first.date.year : 0;

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
                      if (memoriesCount > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                            l10n.lifelinePeriodRange(startYear, endYear),
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
                      // Show insights when NOT syncing
                      if (!syncState.isSyncing && memoriesCount > 0) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final insight = _getCurrentInsight(memories, l10n);
                            if (insight == null) return const SizedBox.shrink();

                            return Text(
                              insight,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ],
                      if (_isAdmin && _debugMode) ...[
                        const SizedBox(height: 4),
                        ValueListenableBuilder<Matrix4>(
                          valueListenable: _transformationController,
                          builder: (context, value, child) {
                            final totalWidth =
                                _cachedLayoutResult?.totalWidth ??
                                    _lastKnownSize.width;
                            final minScale = _calculateMinScale(
                                totalWidth, _lastKnownSize.width);
                            final rawScale = value.getMaxScaleOnAxis();

                            final displayScale = (minScale > 0.0001)
                                ? (rawScale / minScale * 100).round()
                                : 0;

                            // Calculate zoom diagnostics
                            final maxScale = _calculateMaxScale(minScale, _lastKnownSize.width);
                            final relativeZoom = (minScale > 0.0001) ? rawScale / minScale : 1.0;

                            // Calculate node size using INTERPOLATED formula (same as painter)
                            // Painter: varies at 1x, converges to SAME VISUAL SIZE at 8x
                            const maxRelativeZoom = 8.0;
                            const startRadiusConstant = 4.0;  // Small at 1x (~12px)
                            const targetRadiusConstant = 133.0;  // Larger at 8x (~50px)

                            // Calculate starting radius (proportional for uniform visual size)
                            final startRadius = startRadiusConstant * minScale;

                            // Calculate target radius (proportional for uniform visual size)
                            final targetRadius = targetRadiusConstant * minScale;

                            // Calculate interpolation progress
                            final clampedZoom = relativeZoom.clamp(1.0, maxRelativeZoom);
                            final t = (clampedZoom - 1.0) / (maxRelativeZoom - 1.0);

                            // Linear interpolation to get kNodeBaseRadius
                            final kNodeBaseRadius = startRadius + (targetRadius - startRadius) * t;

                            const actualMultiplier = 1.5;
                            final actualNodeRadius = kNodeBaseRadius * actualMultiplier;
                            final nodeVisualSize = (actualNodeRadius * 2) / rawScale;

                            // DIAGNOSTIC: Calculate what SHOULD happen at 8x zoom
                            final targetScale8x = minScale * 8.0;
                            final expectedNodeSizeAt8x = (targetRadius * actualMultiplier * 2) / targetScale8x;

                            // DIAGNOSTIC: Calculate level thresholds (same logic as painter)
                            const double kBaseContentWidth = 1200.0;
                            final baseScale = (_lastKnownSize.width * 0.95) / kBaseContentWidth;
                            final effectiveBase = max(minScale, baseScale);
                            final kLevel2Threshold = effectiveBase * 1.5;
                            final kLevel3Threshold = effectiveBase * 3.0;

                            // Determine current level
                            String currentLevel;
                            Color levelColor;
                            if (rawScale < kLevel2Threshold) {
                              currentLevel = 'LEVEL 1 (Yearly)';
                              levelColor = Colors.purpleAccent;
                            } else if (rawScale < kLevel3Threshold) {
                              currentLevel = 'LEVEL 2 (Monthly)';
                              levelColor = Colors.blueAccent;
                            } else {
                              currentLevel = 'LEVEL 3 (Individual)';
                              levelColor = Colors.greenAccent;
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Scale: $displayScale%',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                                Text(
                                  'Screen: ${_lastKnownSize.width.toStringAsFixed(0)}x${_lastKnownSize.height.toStringAsFixed(0)}px',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                                Text(
                                  'Timeline width: ${totalWidth.toStringAsFixed(0)}px',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                                Text(
                                  'Node size: ${nodeVisualSize.toStringAsFixed(2)}px',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                // DIAGNOSTIC INFO
                                Text(
                                  '🔍 DIAGNOSTICS:',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'minScale: ${minScale.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                                Text(
                                  'currentScale: ${rawScale.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                                Text(
                                  'kNodeBase: ${kNodeBaseRadius.toStringAsFixed(2)} → actual: ${actualNodeRadius.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                                Text(
                                  'Expected @ 8x: ${expectedNodeSizeAt8x.toStringAsFixed(2)}px',
                                  style: TextStyle(
                                      color: (expectedNodeSizeAt8x - 10.0).abs() < 0.5 ? Colors.greenAccent : Colors.redAccent,
                                      fontSize: 9),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Relative Zoom: ${relativeZoom.toStringAsFixed(2)}x',
                                  style: TextStyle(
                                      color: relativeZoom >= 12.0 ? Colors.greenAccent : Colors.yellowAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Zoom Range: 1.0x → ${(maxScale / minScale).toStringAsFixed(1)}x',
                                  style: const TextStyle(
                                      color: Colors.cyanAccent, fontSize: 10),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📊 ZOOM LEVELS:',
                                  style: const TextStyle(
                                      color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'baseScale: ${baseScale.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                                Text(
                                  'effectiveBase: ${effectiveBase.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 9),
                                ),
                                Text(
                                  'Level 2 threshold: ${kLevel2Threshold.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.blueAccent, fontSize: 9),
                                ),
                                Text(
                                  'Level 3 threshold: ${kLevel3Threshold.toStringAsFixed(4)}',
                                  style: const TextStyle(
                                      color: Colors.greenAccent, fontSize: 9),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentLevel,
                                  style: TextStyle(
                                      color: levelColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
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
                        // Performance recording controls
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                setState(() {
                                  if (_performanceMonitor.isRecording) {
                                    _performanceMonitor.stopRecording();
                                  } else {
                                    final timelineWidth = _cachedLayoutResult?.totalWidth;
                                    final screenWidth = _lastKnownSize.width;
                                    final minScale = timelineWidth != null && screenWidth > 0
                                        ? _calculateMinScale(timelineWidth, screenWidth)
                                        : 0.0;
                                    _performanceMonitor.startRecording(
                                      screenSize: _lastKnownSize,
                                      timelineWidth: timelineWidth,
                                      minScale: minScale,
                                    );
                                  }
                                });
                              },
                              icon: Icon(
                                _performanceMonitor.isRecording
                                    ? Icons.stop
                                    : Icons.fiber_manual_record,
                                size: 16,
                              ),
                              label: Text(
                                _performanceMonitor.isRecording ? 'Stop' : 'Record',
                                style: const TextStyle(fontSize: 11),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _performanceMonitor.isRecording
                                    ? Colors.red
                                    : Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: _performanceMonitor.performanceLog.isEmpty
                                  ? null
                                  : () async {
                                      final log = _performanceMonitor.exportLog();
                                      await _sharePerformanceLog(log);
                                    },
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('Export',
                                  style: TextStyle(fontSize: 11)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
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
                                  timingRow('Nodes', timings.nodes,
                                      Colors.orangeAccent),
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

  Widget _buildDraftsBanner(AppLocalizations l10n) {
    final draftsAsyncValue = ref.watch(draftsStreamProvider);
    final drafts = draftsAsyncValue.asData?.value ?? [];

    if (drafts.isEmpty) {
      return const SizedBox.shrink();
    }

    final userId = ref.watch(authStateChangesProvider).asData?.value?.uid;
    if (userId == null) {
      return const SizedBox.shrink();
    }

    // Single draft: show inline banner with Resume/Delete
    if (drafts.length == 1) {
      final draft = drafts.first;
      final lastModified = draft.lastModified;
      final timeAgo = _formatTimeAgo(lastModified, l10n);

      return Positioned(
        right: 16,
        top: 80,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha((255 * 0.15).round()),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withAlpha((255 * 0.6).round()), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.drafts, color: Colors.amber, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Draft',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _resumeDraft(draft, userId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber.withAlpha((255 * 0.3).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.draftBannerResume,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: () => _deleteDraft(draft),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: const Icon(Icons.close, color: Colors.white60, size: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Multiple drafts: show banner with "View all" button
    return Positioned(
      right: 16,
      top: 80,
      child: GestureDetector(
        onTap: () => _showDraftsListPopup(drafts, userId, l10n),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha((255 * 0.15).round()),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.amber.withAlpha((255 * 0.6).round()), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drafts, color: Colors.amber, size: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${drafts.length} Drafts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.draftBannerMultipleSubtitle,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha((255 * 0.3).round()),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, color: Colors.amber, size: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.timeAgoJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeAgoMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHours(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.timeAgoDays(difference.inDays);
    } else {
      return l10n.timeAgoWeeks((difference.inDays / 7).floor());
    }
  }

  Future<void> _resumeDraft(Memory draft, String userId) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MemoryEditScreen(
          initial: draft,
          userId: userId,
        ),
      ),
    );

    if (result == true && mounted) {
      ref.read(messageProvider.notifier).addMessage(
        AppLocalizations.of(context)!.draftResumedSuccess,
        type: MessageType.success,
      );
    }
  }

  Future<void> _deleteDraft(Memory draft) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.draftDeleteDialogTitle),
        content: Text(l10n.draftDeleteDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.draftDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.draftDeleteConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final repo = ref.read(memoryRepositoryProvider);
        await repo?.delete(draft.id);
        if (mounted) {
          ref.read(messageProvider.notifier).addMessage(
            l10n.draftDeletedSuccess,
            type: MessageType.success,
          );
        }
      } catch (e) {
        if (mounted) {
          ref.read(messageProvider.notifier).addMessage(
            l10n.draftDeletedError,
            type: MessageType.error,
          );
        }
      }
    }
  }

  void _showDraftsListPopup(List<Memory> drafts, String userId, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => DraftsListDialog(
        userId: userId,
        l10n: l10n,
        onDraftSelected: (draft) async {
          Navigator.of(context).pop();
          await _resumeDraft(draft, userId);
        },
        onDraftDeleted: (draft) async {
          await _deleteDraft(draft);
        },
      ),
    );
  }

  // === STREAK & PROGRESS INSIGHTS ===

  /// Calculate current streak (consecutive days with memories)
  int _calculateStreak(List<Memory> memories) {
    if (memories.isEmpty) return 0;

    // Get unique dates sorted descending
    final uniqueDates = memories.map((m) {
      final date = m.date;
      return DateTime(date.year, date.month, date.day);
    }).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    int streak = 0;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Check if there's a memory today or yesterday to start counting
    final latestMemory = uniqueDates.first;
    final daysSinceLatest = todayDate.difference(latestMemory).inDays;

    if (daysSinceLatest > 1) {
      return 0; // Streak broken
    }

    // Count consecutive days
    DateTime expectedDate = latestMemory;
    for (final memoryDate in uniqueDates) {
      final diff = expectedDate.difference(memoryDate).inDays;

      if (diff == 0) {
        streak++;
        expectedDate = memoryDate.subtract(const Duration(days: 1));
      } else if (diff > 0) {
        break; // Gap found, streak ends
      }
    }

    return streak;
  }

  /// Calculate timeline span in years
  int _calculateTimelineSpan(List<Memory> memories) {
    if (memories.length < 2) return 0;

    final dates = memories.map((m) => m.date).toList();
    final earliest = dates.reduce((a, b) => a.isBefore(b) ? a : b);
    final latest = dates.reduce((a, b) => a.isAfter(b) ? a : b);

    final years = latest.year - earliest.year;
    return years > 0 ? years : 0;
  }

  /// Get current insight to display
  String? _getCurrentInsight(List<Memory> memories, AppLocalizations l10n) {
    if (memories.isEmpty) {
      return l10n.lifelineInsightStartJourney;
    }

    final now = DateTime.now();
    final insights = <_InsightData>[];

    // 1. Streak (highest priority)
    final streak = _calculateStreak(memories);
    if (streak > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightStreakDays(streak),
        priority: 100,
      ));
    }

    // 2. This month
    final thisMonthCount = memories
        .where((m) => m.date.year == now.year && m.date.month == now.month)
        .length;
    if (thisMonthCount > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightMemoriesThisMonth(thisMonthCount),
        priority: 50,
      ));
    }

    // 3. This week
    final weekAgo = now.subtract(const Duration(days: 7));
    final thisWeekCount = memories.where((m) => m.date.isAfter(weekAgo)).length;
    if (thisWeekCount > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightMemoriesThisWeek(thisWeekCount),
        priority: 45,
      ));
    }

    // 4. Reflections
    final reflectionCount =
        memories.where((m) => m.insightScore > 0).length;
    if (reflectionCount > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightReflectionsCount(reflectionCount),
        priority: 40,
      ));
    }

    // 5. Photos
    final photoCount =
        memories.fold<int>(0, (sum, m) => sum + m.mediaPaths.length);
    if (photoCount > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightPhotosCount(photoCount),
        priority: 35,
      ));
    }

    // 6. Audio notes
    final audioCount = memories
        .fold<int>(0, (sum, m) => sum + m.displayableAudioPaths.length);
    if (audioCount > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightAudioCount(audioCount),
        priority: 33,
      ));
    }

    // 7. Timeline span
    final years = _calculateTimelineSpan(memories);
    if (years > 0) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightSpanningYears(years),
        priority: 30,
      ));
    }

    // 8. Total memories
    if (memories.length >= 10) {
      insights.add(_InsightData(
        text: l10n.lifelineInsightTotalMemories(memories.length),
        priority: 25,
      ));
    }

    // 9. Emotional balance (if we have emotions)
    final memoriesWithEmotions =
        memories.where((m) => m.emotions.isNotEmpty).length;
    if (memoriesWithEmotions > 5) {
      final avgValence = memories
              .where((m) => m.emotions.isNotEmpty)
              .map((m) => m.valence)
              .reduce((a, b) => a + b) /
          memoriesWithEmotions;

      if (avgValence > 0.3) {
        insights.add(_InsightData(
          text: l10n.lifelineInsightPositiveVibes,
          priority: 20,
        ));
      } else if (avgValence < -0.3) {
        insights.add(_InsightData(
          text: l10n.lifelineInsightGrowthJourney,
          priority: 20,
        ));
      } else {
        insights.add(_InsightData(
          text: l10n.lifelineInsightBalancedEmotions,
          priority: 20,
        ));
      }
    }

    // Rotate insights based on hour (changes every hour)
    if (insights.isNotEmpty) {
      // Sort by priority
      insights.sort((a, b) => b.priority.compareTo(a.priority));

      // Use hour for rotation, but prioritize high-priority insights
      final hourOfDay = DateTime.now().hour;
      final rotationIndex = hourOfDay % insights.length;

      return insights[rotationIndex].text;
    }

    // Fallback for new users
    return l10n.lifelineInsightBuildStreak;
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
      final contentMatch =
          memory.content?.toLowerCase().contains(query) ?? false;
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
                      prefixIcon: Icon(Icons.search,
                          color: Colors.white.withAlpha(178)),
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
                        // --- ИЗМЕНЕНИЕ: Добавлен замок для зашифрованных воспоминаний ---
                        trailing: memory.isEncrypted
                            ? const Icon(Icons.lock_outline,
                                color: Colors.white54, size: 20)
                            : null,
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
      } else if (item.type == TappableType.dailyCluster) {
        coverPath = (item.data as List<Memory>).first.coverPath;
      } else if (item.type == TappableType.monthlyCluster) {
        final mapData = item.data as Map<String, dynamic>;
        final memories = mapData['memories'] as List<Memory>;
        coverPath = memories.first.coverPath;
      } else if (item.type == TappableType.monthInCluster) {
        final mapData = item.data as Map<String, dynamic>;
        final memories = mapData['memories'] as List<Memory>;
        coverPath = memories.isNotEmpty ? memories.first.coverPath : null;
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

class _InsightData {
  final String text;
  final int priority;

  _InsightData({required this.text, required this.priority});
}

class PerformanceMonitor {
  int _frameCount = 0;
  final Stopwatch _stopwatch = Stopwatch()..start();
  final ValueNotifier<double> fpsNotifier = ValueNotifier(0.0);

  // Performance logging
  final List<String> _performanceLog = [];
  bool _isRecording = false;
  DateTime? _recordingStartTime;

  // Performance metrics
  double _minFps = double.infinity;
  double _maxFps = 0;
  double _avgFps = 0;
  int _fpsCount = 0;

  double get fps => fpsNotifier.value;
  bool get isRecording => _isRecording;
  List<String> get performanceLog => List.unmodifiable(_performanceLog);

  void tick({String? zoomSnapshot}) {
    _frameCount++;
    if (_stopwatch.elapsedMilliseconds >= 1000) {
      final elapsedSeconds = _stopwatch.elapsedMilliseconds / 1000.0;
      final currentFps = _frameCount / elapsedSeconds;
      fpsNotifier.value = currentFps;

      // Update metrics
      if (currentFps < _minFps) _minFps = currentFps;
      if (currentFps > _maxFps) _maxFps = currentFps;
      _avgFps = (_avgFps * _fpsCount + currentFps) / (_fpsCount + 1);
      _fpsCount++;

      // Record to log if recording
      if (_isRecording) {
        final timestamp = DateTime.now().difference(_recordingStartTime!).inSeconds;
        if (zoomSnapshot != null) {
          _performanceLog.add('[$timestamp s] FPS: ${currentFps.toStringAsFixed(1)} | $zoomSnapshot');
        } else {
          _performanceLog.add('[$timestamp s] FPS: ${currentFps.toStringAsFixed(1)}');
        }
      }

      _frameCount = 0;
      _stopwatch.reset();
      _stopwatch.start();
    }
  }

  void startRecording({Size? screenSize, double? timelineWidth, double? minScale}) {
    _isRecording = true;
    _recordingStartTime = DateTime.now();
    _performanceLog.clear();
    _minFps = double.infinity;
    _maxFps = 0;
    _avgFps = 0;
    _fpsCount = 0;
    _performanceLog.add('=== NODE SIZE DIAGNOSTIC LOG ===');
    _performanceLog.add('Start Time: ${_recordingStartTime!.toIso8601String()}');
    if (screenSize != null) {
      _performanceLog.add('Screen: ${screenSize.width.toStringAsFixed(0)}x${screenSize.height.toStringAsFixed(0)}px');
    }
    if (timelineWidth != null) {
      _performanceLog.add('Timeline Width: ${timelineWidth.toStringAsFixed(0)}px');
    }
    if (minScale != null) {
      _performanceLog.add('minScale: ${minScale.toStringAsFixed(6)}');
      const startRadiusConstant = 4.0;
      const targetRadiusConstant = 133.0;
      const actualMultiplier = 1.5;

      final startRadius = startRadiusConstant * minScale;
      final targetRadius = targetRadiusConstant * minScale;

      _performanceLog.add('kNodeBaseRadius @ 1x zoom: ${startRadius.toStringAsFixed(4)}');
      _performanceLog.add('kNodeBaseRadius @ 8x zoom: ${targetRadius.toStringAsFixed(4)} (uniform target)');

      final targetScale8x = minScale * 8.0;
      final expectedNodeSizeAt8x = (targetRadius * actualMultiplier * 2) / targetScale8x;
      _performanceLog.add('Expected node size @ 8x zoom: ${expectedNodeSizeAt8x.toStringAsFixed(2)}px (uniform ~13px)');
    }
    _performanceLog.add('');
    _performanceLog.add('INSTRUCTIONS:');
    _performanceLog.add('1. Zoom to 8.00x on this timeline');
    _performanceLog.add('2. Check the "Node size" value in debug menu');
    _performanceLog.add('3. Check the "Expected @ 8x" value (should be green and ~10px)');
    _performanceLog.add('4. Stop recording and export this log');
    _performanceLog.add('');
  }

  void stopRecording() {
    if (_isRecording) {
      _isRecording = false;
      _performanceLog.add('=== Performance Recording Stopped ===');
      _performanceLog.add('Duration: ${DateTime.now().difference(_recordingStartTime!).inSeconds} seconds');
      _performanceLog.add('Min FPS: ${_minFps.toStringAsFixed(1)}');
      _performanceLog.add('Max FPS: ${_maxFps.toStringAsFixed(1)}');
      _performanceLog.add('Avg FPS: ${_avgFps.toStringAsFixed(1)}');
    }
  }

  void logMetric(String metric) {
    if (_isRecording) {
      final timestamp = DateTime.now().difference(_recordingStartTime!).inSeconds;
      _performanceLog.add('[$timestamp s] $metric');
    }
  }

  String exportLog() {
    return _performanceLog.join('\n');
  }

  void clearLog() {
    _performanceLog.clear();
    _minFps = double.infinity;
    _maxFps = 0;
    _avgFps = 0;
    _fpsCount = 0;
  }

  void dispose() {
    fpsNotifier.dispose();
  }
}

/// Dialog showing list of all draft memories
class DraftsListDialog extends ConsumerWidget {
  final String userId;
  final AppLocalizations l10n;
  final Function(Memory) onDraftSelected;
  final Function(Memory) onDraftDeleted;

  const DraftsListDialog({
    super.key,
    required this.userId,
    required this.l10n,
    required this.onDraftSelected,
    required this.onDraftDeleted,
  });

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.timeAgoJustNow;
    } else if (difference.inMinutes < 60) {
      return l10n.timeAgoMinutes(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.timeAgoHours(difference.inHours);
    } else if (difference.inDays < 7) {
      return l10n.timeAgoDays(difference.inDays);
    } else {
      return l10n.timeAgoWeeks((difference.inDays / 7).floor());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch drafts stream to auto-update when drafts are deleted
    final draftsAsyncValue = ref.watch(draftsStreamProvider);
    final drafts = draftsAsyncValue.asData?.value ?? [];

    // Auto-close dialog if no drafts left
    if (drafts.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Icon(Icons.drafts, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.draftListDialogTitle(drafts.length),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Drafts list
            Flexible(
              child: drafts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Text(
                        l10n.draftListItemNoContent,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: drafts.length,
                      itemBuilder: (context, index) {
                        final draft = drafts[index];
                        final timeAgo = _formatTimeAgo(draft.lastModified);
                        final hasTitle = draft.title.isNotEmpty;
                        final hasContent = draft.content != null && draft.content!.isNotEmpty;
                        final previewText = hasContent
                            ? draft.content!.length > 80
                                ? '${draft.content!.substring(0, 80)}...'
                                : draft.content!
                            : l10n.draftListItemNoContent;

                        return ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.amber.withAlpha((255 * 0.2).round()),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.drafts, color: Colors.amber),
                          ),
                          title: Text(
                            hasTitle ? draft.title : l10n.draftListItemNoTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: hasTitle ? null : Colors.grey,
                              fontStyle: hasTitle ? null : FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                previewText,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.draftListItemLastModified(timeAgo),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            onPressed: () => onDraftDeleted(draft),
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            tooltip: l10n.draftBannerDelete,
                          ),
                          onTap: () => onDraftSelected(draft),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

