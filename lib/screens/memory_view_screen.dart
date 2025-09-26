import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/memory_edit_screen.dart';
import 'package:lifeline/services/audio_service.dart';
import 'package:lifeline/services/encryption_service.dart';
import 'package:lifeline/services/export_service.dart';
import 'package:lifeline/services/message_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class MemoryViewScreen extends ConsumerStatefulWidget {
  final Memory memory;
  final String userId;
  final bool isShared;

  const MemoryViewScreen({
    super.key,
    required this.memory,
    required this.userId,
    this.isShared = false,
  });

  @override
  ConsumerState<MemoryViewScreen> createState() => _MemoryViewScreenState();
}

class _MemoryViewScreenState extends ConsumerState<MemoryViewScreen> {
  late Memory _currentMemory;
  bool _wasChanged = false;
  late PageController _pageController;
  static const int _infiniteScrollInitialPage = 5000;

  int _currentPage = 0;

  bool _isSoundPlaying = false;
  double _currentVolume = 1.0;

  final Map<String, VideoPlayerController> _videoControllers = {};
  final ap.AudioPlayer _audioNotePlayer = ap.AudioPlayer();
  bool _isAudioNotePlaying = false;
  int _currentAudioNoteIndex = 0;
  bool _isExporting = false;

  VideoPlayerController? _activeVideoController;

  final Map<String, String?> _decryptedContent = {};
  bool _needsUnlock = false;

  List<String> _displayImagePaths = [];
  List<String> _displayVideoPaths = [];
  List<String> _displayThumbPaths = [];

  late final AudioNotifier _audioNotifier;

  @override
  void initState() {
    super.initState();
    _audioNotifier = ref.read(audioPlayerProvider.notifier);

    _currentMemory = widget.memory;
    _startAmbientSound();
    _initializeMedia();
  }

  void _initializeMedia() {
    _displayImagePaths = _currentMemory.displayableMediaPaths;
    _displayVideoPaths = _currentMemory.displayableVideoPaths;
    _displayThumbPaths = _currentMemory.displayableThumbPaths;

    final allMedia = [..._displayImagePaths, ..._displayVideoPaths];
    int initialPage = _infiniteScrollInitialPage;
    if(allMedia.isNotEmpty) {
      initialPage = _infiniteScrollInitialPage - (_infiniteScrollInitialPage % allMedia.length);
    }
    
    _pageController = PageController(initialPage: initialPage);
    _pageController.addListener(() {
      if (_pageController.hasClients && _pageController.page != null) {
        if (allMedia.isEmpty) return;

        final page = _pageController.page!.round();
        final effectivePage = page % allMedia.length;

        if (effectivePage != _currentPage) {
          _activeVideoController?.pause();
          if (mounted) {
            setState(() {
              _currentPage = effectivePage;
            });
          }
        }
      }
    });


    _initializeVideoControllers();
  }

  void _decryptContent() {
    final encryptionService = ref.read(encryptionServiceProvider.notifier);
    bool currentlyNeedsUnlock = false;

    String? processField(String? value) {
      if (!_currentMemory.isEncrypted) {
        return value;
      }

      final decrypted = encryptionService.decrypt(value);
      if (decrypted == null && (value != null && value.isNotEmpty)) {
        currentlyNeedsUnlock = true;
      }
      return decrypted;
    }

    _decryptedContent['content'] = processField(_currentMemory.content);
    _decryptedContent['reflectionImpact'] =
        processField(_currentMemory.reflectionImpact);
    _decryptedContent['reflectionLesson'] =
        processField(_currentMemory.reflectionLesson);
    _decryptedContent['reflectionAutoThought'] =
        processField(_currentMemory.reflectionAutoThought);
    _decryptedContent['reflectionEvidenceFor'] =
        processField(_currentMemory.reflectionEvidenceFor);
    _decryptedContent['reflectionEvidenceAgainst'] =
        processField(_currentMemory.reflectionEvidenceAgainst);
    _decryptedContent['reflectionReframe'] =
        processField(_currentMemory.reflectionReframe);
    _decryptedContent['reflectionAction'] =
        processField(_currentMemory.reflectionAction);

    if (mounted && _needsUnlock != currentlyNeedsUnlock) {
      setState(() {
        _needsUnlock = currentlyNeedsUnlock;
      });
    }
  }

  void _initializeVideoControllers() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();

    for (final path in _displayVideoPaths) {
      if (path.startsWith('http')) {
        DefaultCacheManager().getSingleFile(path).then((file) {
          if (mounted) {
            _initializeVideoControllerForFile(path, file);
          }
        }).catchError((e) {
          // Handle video download error
        });
      } else {
        final file = File(path);
        if (file.existsSync()) {
          _initializeVideoControllerForFile(path, file);
        }
      }
    }
  }

  void _initializeVideoControllerForFile(String originalPath, File file) {
    if (!mounted || _videoControllers.containsKey(originalPath)) return;

    final controller = VideoPlayerController.file(file);
    _videoControllers[originalPath] = controller;
    controller.initialize().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _startAmbientSound() {
    if (_currentMemory.ambientSound != null &&
        _currentMemory.ambientSound!.isNotEmpty) {
      _audioNotifier.playAmbientSound(_currentMemory.ambientSound!);
      _isSoundPlaying = true;
    }
  }

  @override
  void dispose() {
    _audioNotifier.stopAmbientSound();
    _audioNotifier.resumeGlobalPlayerIfNeeded();
    
    _pageController.dispose();
    _audioNotePlayer.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _activeVideoController?.pause();
    super.dispose();
  }

  void _toggleSoundPlayback() {
    setState(() {
      if (_isSoundPlaying) {
        _audioNotifier.stopAmbientSound();
        _isSoundPlaying = false;
      } else {
        if (_currentMemory.ambientSound != null) {
          _audioNotifier.playAmbientSound(_currentMemory.ambientSound!);
          _isSoundPlaying = true;
        }
      }
    });
  }

  void _changeVolume(double volume) {
    setState(() {
      _currentVolume = volume;
      _audioNotifier.setVolume(volume);
    });
  }

  Future<void> _playAudioNote() async {
    await _audioNotifier.pauseGlobalPlayer();
    final audioPaths = _currentMemory.displayableAudioPaths;
    if (audioPaths.isEmpty) return;

    if (_isAudioNotePlaying) {
      await _audioNotePlayer.pause();
      setState(() => _isAudioNotePlaying = false);
      return;
    }

    final audioPath = audioPaths[_currentAudioNoteIndex];
    ap.Source source;
    if (audioPath.startsWith('http')) {
      final file = await DefaultCacheManager().getSingleFile(audioPath);
      source = ap.DeviceFileSource(file.path);
    } else {
      source = ap.DeviceFileSource(audioPath);
    }

    await _audioNotePlayer.play(source);
    setState(() => _isAudioNotePlaying = true);

    _audioNotePlayer.onPlayerComplete.first.then((_) {
      if (mounted) {
        setState(() {
          _isAudioNotePlaying = false;
          _currentAudioNoteIndex =
              (_currentAudioNoteIndex + 1) % audioPaths.length;
        });
      }
    });
  }

  Future<void> _editMemory() async {
    final memoryForEdit = _currentMemory.copyWith(
      content: _decryptedContent['content'],
      reflectionImpact: _decryptedContent['reflectionImpact'],
      reflectionLesson: _decryptedContent['reflectionLesson'],
      reflectionAutoThought: _decryptedContent['reflectionAutoThought'],
      reflectionEvidenceFor: _decryptedContent['reflectionEvidenceFor'],
      reflectionEvidenceAgainst: _decryptedContent['reflectionEvidenceAgainst'],
      reflectionReframe: _decryptedContent['reflectionReframe'],
      reflectionAction: _decryptedContent['reflectionAction'],
    );

    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            MemoryEditScreen(initial: memoryForEdit, userId: widget.userId),
      ),
    );
    if (result == true && mounted) {
      final updatedMemory =
          await ref.read(memoryRepositoryProvider)?.getById(_currentMemory.id);
      if (updatedMemory != null) {
        setState(() {
          _currentMemory = updatedMemory;
          _wasChanged = true;
          _initializeMedia();
          _decryptContent();
        });
      }
    }
  }

  Future<void> _deleteMemory() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _HoldToDeleteDialog(l10n: l10n),
    );

    if (confirmed == true) {
      final memoryRepo = ref.read(memoryRepositoryProvider);
      final firestoreService = ref.read(firestoreServiceProvider);
      final currentContext = context;

      if (memoryRepo == null) {
        if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
              SnackBar(content: Text(l10n.memoryViewErrorLocalDb)));
        }
        return;
      }

      final memoryToDelete = _currentMemory;
      await memoryRepo.delete(memoryToDelete.id);
      
      if (!mounted) return;
      Navigator.of(currentContext).pop(true);

      ref.read(messageProvider.notifier).addMessage(
            l10n.memoryViewMemoryDeleted,
            type: MessageType.info,
          );

      if (memoryToDelete.firestoreId != null) {
        await firestoreService.deleteMemory(widget.userId, memoryToDelete);
      }
    }
  }

  void _shareMemory() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => _ShareMenu(
        l10n: l10n,
        onExport: () {
          Navigator.of(context).pop();
          _exportAndShare('pdf');
        },
      ),
    );
  }

  Future<void> _exportAndShare(String format) async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    final currentContext = context;

    try {
      final ByteData fontRegular =
          await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final ByteData fontBold =
          await rootBundle.load('assets/fonts/Roboto-Bold.ttf');

      final encryptionService = ref.read(encryptionServiceProvider.notifier);
      Memory memoryToExport = _currentMemory;
      if (memoryToExport.isEncrypted && _needsUnlock) {
         if (mounted) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            const SnackBar(
                content: Text('Please unlock the memory to export.')),
          );
        }
        setState(() => _isExporting = false);
        return;
      }
      if (memoryToExport.isEncrypted) {
        memoryToExport = encryptionService.decryptMemory(memoryToExport);
      }

      final imagePathsToProcess = memoryToExport.displayableMediaPaths;
      final tempDir = await getTemporaryDirectory();
      final List<String> localImagePaths = [];

      for (final path in imagePathsToProcess) {
        if (path.startsWith('http')) {
          try {
            final file = await DefaultCacheManager().getSingleFile(path);
            localImagePaths.add(file.path);
          } catch (e) {
            // ignore: avoid_print
            print('Failed to download image for export: $path');
          }
        } else {
          localImagePaths.add(path);
        }
      }

      List<SpotifyTrackDetails> spotifyDetails = [];
      if (memoryToExport.spotifyTrackIds.isNotEmpty) {
        final spotifyService = ref.read(spotifyServiceProvider);
        final detailsFutures = memoryToExport.spotifyTrackIds
            .map((id) => spotifyService.getTrackDetails(id))
            .toList();
        final results = await Future.wait(detailsFutures);
        spotifyDetails = results.whereType<SpotifyTrackDetails>().toList();
      }

      final port = ReceivePort();
      final isolateData = ExportIsolateData(
        sendPort: port.sendPort,
        memories: [memoryToExport],
        format: format,
        orbitronRegular: fontRegular,
        orbitronBold: fontBold,
        localImagePaths: localImagePaths,
        spotifyDetails: spotifyDetails,
      );

      await Isolate.spawn(generateExportFile, isolateData);

      final Uint8List fileBytes = await port.first;

      final fileName =
          'Lifeline_Memory_${DateFormat('yyyyMMdd').format(_currentMemory.date)}.$format';
      final file =
          await File('${tempDir.path}/$fileName').writeAsBytes(fileBytes);

      await Share.shareXFiles([XFile(file.path)], text: _currentMemory.title);
    } catch (e, stack) {
      // ignore: avoid_print
      print('Export failed: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(currentContext).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _toggleActionCompleted() async {
    final l10n = AppLocalizations.of(context)!;
    
    final updatedMemory = _currentMemory.copyWith(
      reflectionActionCompleted: !_currentMemory.reflectionActionCompleted,
    );

    setState(() {
      _currentMemory = updatedMemory;
      _wasChanged = true;
    });

    try {
      final repo = ref.read(memoryRepositoryProvider);
      final firestore = ref.read(firestoreServiceProvider);
      if (repo != null) {
        await repo.update(updatedMemory);
        if(!mounted) return;
        await firestore.updateMemory(widget.userId, updatedMemory);
      }
      if (mounted) {
        final message = updatedMemory.reflectionActionCompleted
            ? l10n.memoryViewActionCompleted
            : l10n.memoryViewActionIncomplete;
        ref
            .read(messageProvider.notifier)
            .addMessage(message, type: MessageType.info);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(l10n.memoryViewErrorUpdatingAction(e.toString()))),
        );
      }
      setState(() {
        _currentMemory = _currentMemory.copyWith(
          reflectionActionCompleted: !_currentMemory.reflectionActionCompleted,
        );
      });
    }
  }

  Future<void> _handleUnlockRequest() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.memoryViewUnlockDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.memoryViewUnlockDialogContent),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: l10n.memoryEditMasterPasswordHint,
                        errorText: errorText,
                      ),
                      onSubmitted: (_) async {
                        setState(() {
                          isLoading = true;
                          errorText = null;
                        });
                        final success = await ref
                            .read(encryptionServiceProvider.notifier)
                            .unlockSession(passwordController.text);
                        if (!mounted) return;
                        if (success) {
                          Navigator.of(context).pop(true);
                        } else {
                          setState(() {
                            errorText = l10n.memoryViewIncorrectPassword;
                            isLoading = false;
                          });
                        }
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(l10n.profileCancel)),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorText = null;
                          });
                          final success = await ref
                              .read(encryptionServiceProvider.notifier)
                              .unlockSession(passwordController.text);
                          if (!mounted) return;
                          if (success) {
                            Navigator.of(context).pop(true);
                          } else {
                            setState(() {
                              errorText = l10n.memoryViewIncorrectPassword;
                              isLoading = false;
                            });
                          }
                        },
                  child: Text(l10n.memoryViewUnlockButton),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showMediaPopup(int initialIndex) {
    final allMedia = [..._displayImagePaths, ..._displayVideoPaths];
    if (allMedia.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((255 * 0.85).round()),
      builder: (context) {
        return _MediaViewerPopup(
          allMedia: allMedia,
          allThumbnails: [..._displayThumbPaths, ..._displayVideoPaths],
          initialIndex: initialIndex,
          videoControllers: _videoControllers,
          displayImagePathsCount: _displayImagePaths.length,
        );
      },
    ).then((_) {
      _activeVideoController?.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    ref.listen(encryptionServiceProvider, (previous, next) {
      _decryptContent();
    });

    _decryptContent();

    final String? coverPath =
        _displayImagePaths.isNotEmpty ? _displayImagePaths.first : null;
    final String? coverThumbPath =
        _displayThumbPaths.isNotEmpty ? _displayThumbPaths.first : null;

    final bool hasCover = coverThumbPath != null;
    Widget coverImageWidget = const SizedBox.shrink();

    if (hasCover) {
      coverImageWidget = coverThumbPath!.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: coverThumbPath,
              fit: BoxFit.cover,
              color: Colors.black.withAlpha((255 * 0.3).round()),
              colorBlendMode: BlendMode.darken,
              placeholder: (context, url) =>
                  Container(color: Colors.black.withAlpha((255 * 0.3).round())),
              errorWidget: (context, url, error) =>
                  Container(color: Colors.black.withAlpha((255 * 0.3).round())),
            )
          : Image.file(
              File(coverThumbPath),
              fit: BoxFit.cover,
              color: Colors.black.withAlpha((255 * 0.3).round()),
              colorBlendMode: BlendMode.darken,
            );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        await _audioNotifier.stopAmbientSound();
        await _audioNotifier.resumeGlobalPlayerIfNeeded();

        if (mounted) {
          Navigator.of(context).pop(_wasChanged);
        }
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFF0D0C11),
          body: Stack(
            children: [
              if (hasCover && !_needsUnlock)
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      key: ValueKey(coverPath),
                      child: coverImageWidget,
                    ),
                  ),
                ),
              if (hasCover && !_needsUnlock)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(color: Colors.black.withAlpha((255 * 0.2).round())),
                  ),
                ),
              NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverAppBar(
                      leading: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 30),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        tooltip: l10n.memoryViewBackTooltip,
                      ),
                      actions: [
                        if (!_needsUnlock && !widget.isShared) ...[
                          _isExporting
                              ? const Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(Icons.share_outlined,
                                      color: Colors.white, size: 26),
                                  onPressed: _shareMemory,
                                  tooltip: l10n.memoryViewShareTooltip,
                                ),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: Colors.white, size: 26),
                            onPressed: _editMemory,
                            tooltip: l10n.memoryViewEditTooltip,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.white, size: 26),
                            onPressed: _deleteMemory,
                            tooltip: l10n.memoryViewDeleteTooltip,
                          ),
                        ]
                      ],
                      title: Text(_currentMemory.title,
                          style: GoogleFonts.orbitron(fontSize: 18)),
                      centerTitle: true,
                      backgroundColor: innerBoxIsScrolled
                          ? const Color(0xFF0D0C11)
                          : Colors.transparent,
                      elevation: 0,
                      pinned: true,
                      floating: true,
                      bottom: TabBar(
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white.withAlpha((255 * 0.6).round()),
                        tabs: [
                          Tab(text: l10n.memoryViewTabMemory),
                          Tab(text: l10n.memoryViewTabInTheWorld),
                        ],
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  children: [
                    _buildMemoryTab(),
                    _buildInTheWorldTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final l10n = AppLocalizations.of(context)!;
    final content = _decryptedContent['content'];
    final hasSpotify = _currentMemory.spotifyTrackIds.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.4).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.2).round())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.yMMMMd().format(_currentMemory.date).toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    color: Colors.white.withAlpha((255 * 0.7).round()),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _currentMemory.title,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: const [
                      Shadow(blurRadius: 10.0, color: Colors.black54)
                    ],
                  ),
                ),
                if (_currentMemory.isEncrypted)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.lock,
                            color: Colors.amber.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.memoryViewEncryptedTitle,
                          style: TextStyle(
                              color: Colors.amber.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (_needsUnlock)
                  _buildLockedContentPlaceholder(showUnlockButton: false)
                else if (content != null && content.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                      height: 1.6,
                    ),
                  ),
                ],
                if (hasSpotify && !_needsUnlock) ...[
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 16),
                  ..._currentMemory.spotifyTrackIds.map((trackId) => Consumer(
                        builder: (context, ref, child) {
                          final trackAsyncValue =
                              ref.watch(spotifyTrackDetailsProvider(trackId));
                          return trackAsyncValue.when(
                            loading: () =>
                                const _SpotifyTrackLoadingSkeleton(),
                            error: (err, stack) => _SpotifyTrackError(
                              l10n: l10n,
                              onRetry: () => ref
                                  .refresh(spotifyTrackDetailsProvider(trackId)),
                            ),
                            data: (track) {
                              if (track == null) {
                                return const SizedBox.shrink();
                              }
                              return _buildSpotifyTrackInfo(track);
                            },
                          );
                        },
                      ))
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionCard() {
    final l10n = AppLocalizations.of(context)!;
    final impact = _decryptedContent['reflectionImpact'];
    final lesson = _decryptedContent['reflectionLesson'];
    final autoThought = _decryptedContent['reflectionAutoThought'];
    final evidenceFor = _decryptedContent['reflectionEvidenceFor'];
    final evidenceAgainst = _decryptedContent['reflectionEvidenceAgainst'];
    final reframe = _decryptedContent['reflectionReframe'];
    final action = _decryptedContent['reflectionAction'];

    final hasSimpleReflection = (impact?.isNotEmpty ?? false) || (lesson?.isNotEmpty ?? false);
    final hasEmotions = _currentMemory.emotions.isNotEmpty;
    final hasAdvancedReflection = (autoThought?.isNotEmpty ?? false) ||
        (reframe?.isNotEmpty ?? false) ||
        (evidenceFor?.isNotEmpty ?? false) ||
        (evidenceAgainst?.isNotEmpty ?? false);
    final hasAction = action?.isNotEmpty ?? false;

    if (!hasSimpleReflection && !hasEmotions && !hasAdvancedReflection && !hasAction) {
      return const SizedBox.shrink();
    }

    if (_needsUnlock) {
      return _buildLockedContentPlaceholder(isReflection: true, showUnlockButton: false);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.1).round())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.memoryViewReflectionTitle.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    color: Colors.white.withAlpha((255 * 0.7).round()),
                    letterSpacing: 1.2,
                  ),
                ),
                if (hasSimpleReflection) ...[
                  const SizedBox(height: 16),
                  if (impact?.isNotEmpty ?? false)
                    _buildReflectionItem(
                        title: l10n.memoryViewReflectionImpact, content: impact!),
                  if (lesson?.isNotEmpty ?? false)
                    _buildReflectionItem(
                        title: l10n.memoryViewReflectionLesson, content: lesson!),
                ],
                if (hasEmotions) ...[
                  const SizedBox(height: 16),
                  Text(l10n.memoryEditEmotionsLabel,
                      style: TextStyle(
                          color: Colors.white.withAlpha((255 * 0.9).round()),
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _currentMemory.emotions.entries
                        .map((entry) => Chip(
                              label: Text('${entry.key} (${entry.value}%)'),
                              backgroundColor: Colors.white.withAlpha((255 * 0.1).round()),
                              labelStyle: const TextStyle(color: Colors.white),
                            ))
                        .toList(),
                  )
                ],
                if (hasAdvancedReflection) ...[
                  const Divider(height: 32),
                  Text(l10n.memoryEditCbtHelperTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 16),
                  // *** ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ №1: Проверяем каждое поле на null перед отрисовкой ***
                  _buildCbtStepItem(
                      step: 1,
                      title: l10n.memoryViewCbtStep1Title,
                      content: autoThought),
                  _buildCbtStepItem(
                      step: 2,
                      title: l10n.memoryViewCbtStep2Title,
                      content: evidenceFor),
                  _buildCbtStepItem(
                      step: 3,
                      title: l10n.memoryViewCbtStep3Title,
                      content: evidenceAgainst),
                  _buildCbtStepItem(
                      step: 4,
                      title: l10n.memoryViewCbtStep4Title,
                      content: reframe),
                ],
                if (hasAction) ...[
                  const Divider(height: 32),
                  Text(l10n.memoryEditActionPlanTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        _currentMemory.reflectionActionCompleted
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: _currentMemory.reflectionActionCompleted
                            ? Colors.green
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              action!, // Мы уже знаем, что action не null
                              style: TextStyle(
                                color: Colors.white.withAlpha((255 * 0.9).round()),
                                height: 1.5,
                                decoration:
                                    _currentMemory.reflectionActionCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                              ),
                            ),
                            if (_currentMemory.reflectionFollowUpAt != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  l10n.memoryViewActionReminder(DateFormat.yMd()
                                      .add_jm()
                                      .format(_currentMemory.reflectionFollowUpAt!)),
                                  style: TextStyle(
                                      color: Colors.white.withAlpha((255 * 0.6).round()),
                                      fontSize: 12),
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!widget.isShared)
                        IconButton(
                          onPressed: _toggleActionCompleted,
                          icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                          tooltip: _currentMemory.reflectionActionCompleted
                              ? l10n.memoryViewMarkIncompleteTooltip
                              : l10n.memoryViewMarkCompleteTooltip,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReflectionItem({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.9).round()),
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(content,
              style:
                  TextStyle(color: Colors.white.withAlpha((255 * 0.8).round()), height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCbtStepItem(
      {required int step, required String title, required String? content}) {
    final l10n = AppLocalizations.of(context)!;
    if (content == null || content.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(
              text: l10n.memoryEditCbtStepLabel(step),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary),
            ),
            TextSpan(
              text: title,
              style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.9).round()),
                  fontWeight: FontWeight.bold),
            ),
          ])),
          const SizedBox(height: 4),
          Text(content,
              style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.8).round()),
                  height: 1.5,
                  fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildLockedContentPlaceholder({
    bool isReflection = false,
    bool isMedia = false,
    bool showUnlockButton = true,
  }) {
    final l10n = AppLocalizations.of(context)!;
    String title = l10n.memoryViewContentEncrypted;
    if (isReflection) title = l10n.memoryViewReflectionEncrypted;
    if (isMedia) title = l10n.memoryViewMediaEncrypted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.lock_outline, color: Colors.amber.shade600, size: 40),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: Colors.amber.shade600,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.memoryViewUnlockDialogContent,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withAlpha((255 * 0.7).round())),
            ),
            if (showUnlockButton) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _handleUnlockRequest,
                icon: const Icon(Icons.key),
                label: Text(l10n.memoryViewUnlockButton),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber.shade700,
                  foregroundColor: Colors.white,
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildMemoryTab() {
    final allMedia = [..._displayImagePaths, ..._displayVideoPaths];
    final hasMedia = allMedia.isNotEmpty;

    final mediaWidget = hasMedia
        ? SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context)
                      .copyWith(dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  }),
                  child: _buildMediaGallery(),
                ),
                _buildGalleryControls(allMedia.length),
              ],
            ),
          )
        : const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
      children: [
        if (_needsUnlock)
          _buildLockedContentPlaceholder(isMedia: true)
        else
          mediaWidget,
        if (allMedia.length > 1 && !_needsUnlock)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: _buildPageIndicator(allMedia.length),
          ),
        _buildInfoCard(),
        if (_currentMemory.ambientSound != null &&
            _currentMemory.ambientSound!.isNotEmpty) ...[
          _buildAmbientSoundControls(),
        ],
        if (_currentMemory.displayableAudioPaths.isNotEmpty) ...[
          _buildAudioNoteControls(),
        ],
        _buildReflectionCard(),
      ],
    );
  }

  Widget _buildInTheWorldTab() {
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, child) {
        final userProfileAsyncValue = ref.watch(userProfileProvider);

        return userProfileAsyncValue.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _ErrorState(
            message: l10n.memoryViewErrorCouldNotLoadProfile,
            onRetry: () => ref.refresh(userProfileProvider),
          ),
          data: (userProfile) {
            final args = AnchorProviderArgs(
              date: _currentMemory.date,
              countryCode: userProfile?.countryCode,
              languageCode: userProfile?.languageCode,
            );
            final anchorAsyncValue = ref.watch(emotionalAnchorProvider(args));

            return anchorAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => _ErrorState(
                message: l10n.memoryViewErrorCouldNotLoadHistoricalData,
                onRetry: () => ref.refresh(emotionalAnchorProvider(args)),
              ),
              data: (bundle) {
                if (bundle == null ||
                    (bundle.worldNews.isEmpty && bundle.musicChart.isEmpty)) {
                  return _EmptyState(message: l10n.memoryViewNoHistoricalData);
                }
                return _InTheWorldTabs(bundle: bundle, l10n: l10n);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSpotifyTrackInfo(SpotifyTrackDetails track) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: () async {
          if (track.trackUrl != null) {
            final uri = Uri.parse(track.trackUrl!);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          }
        },
        child: Row(
          children: [
            if (track.albumArtUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: track.albumArtUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.music_note),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.artist,
                    style: TextStyle(
                      color: Colors.white.withAlpha((255 * 0.7).round()),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.play_circle_outline,
                color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    final allMedia = [..._displayImagePaths, ..._displayVideoPaths];
    final allThumbnails = [..._displayThumbPaths, ..._displayVideoPaths];

    return PageView.builder(
      controller: _pageController,
      itemBuilder: (context, index) {
        if (allMedia.isEmpty) return const SizedBox.shrink();
        final realIndex = index % allMedia.length;
        final path = allMedia[realIndex];

        Widget mediaWidget;

        if (realIndex < _displayImagePaths.length) {
           final thumbPath = allThumbnails.length > realIndex ? allThumbnails[realIndex] : path;
          
          final thumbProvider = thumbPath.startsWith('http')
              ? CachedNetworkImageProvider(thumbPath)
              : FileImage(File(thumbPath)) as ImageProvider;

          final fullImageProvider = path.startsWith('http')
              ? CachedNetworkImageProvider(path)
              : FileImage(File(path)) as ImageProvider;

          mediaWidget = Image(
            image: fullImageProvider,
            fit: BoxFit.contain,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded) return child;
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: frame != null
                    ? child
                    : Image(image: thumbProvider, fit: BoxFit.contain),
              );
            },
            errorBuilder: (context, error, stackTrace) =>
                Container(color: Colors.grey.shade800),
          );

        } else {
          final controller = _videoControllers[path];
          if (controller != null && controller.value.isInitialized) {
            mediaWidget = _VideoPlayerItem(
              key: ValueKey(path),
              controller: controller,
              onPlayStateChanged: (playingController) {
                if (_activeVideoController != playingController &&
                    _activeVideoController != null) {
                  _activeVideoController!.pause();
                }
                _activeVideoController = playingController;
              },
            );
          } else {
            mediaWidget = const Center(child: CircularProgressIndicator());
          }
        }

        return GestureDetector(
          onTap: () => _showMediaPopup(index),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: mediaWidget,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmbientSoundControls() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.1).round())),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.memoryViewAmbientSound(_currentMemory.ambientSound!),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    color: Colors.white.withAlpha((255 * 0.7).round()),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                          _isSoundPlaying
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                          color: Colors.white,
                          size: 36),
                      onPressed: _toggleSoundPlayback,
                    ),
                    Expanded(
                      child: Slider(
                        value: _currentVolume,
                        min: 0.0,
                        max: 1.0,
                        onChanged: _changeVolume,
                        activeColor: Colors.white,
                        inactiveColor: Colors.white.withAlpha((255 * 0.3).round()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryControls(int count) {
    if (count <= 1) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withAlpha((255 * 0.3).round()),
          ),
        ),
        IconButton(
          onPressed: () {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withAlpha((255 * 0.3).round()),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int count) {
    if (count <= 1) return const SizedBox.shrink();
    List<Widget> dots = [];
    for (int i = 0; i < count; i++) {
      dots.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == i
                ? Colors.white
                : Colors.white.withAlpha((255 * 0.5).round()),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: dots,
    );
  }

  Widget _buildAudioNoteControls() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha((255 * 0.2).round()),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withAlpha((255 * 0.1).round())),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _playAudioNote,
                  icon: Icon(
                    _isAudioNotePlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.memoryViewAudioNote,
                    style: TextStyle(
                      color: Colors.white.withAlpha((255 * 0.9).round()),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaViewerPopup extends StatefulWidget {
  final List<String> allMedia;
  final List<String> allThumbnails;
  final int initialIndex;
  final Map<String, VideoPlayerController> videoControllers;
  final int displayImagePathsCount;

  const _MediaViewerPopup({
    required this.allMedia,
    required this.allThumbnails,
    required this.initialIndex,
    required this.videoControllers,
    required this.displayImagePathsCount,
  });

  @override
  State<_MediaViewerPopup> createState() => _MediaViewerPopupState();
}

class _MediaViewerPopupState extends State<_MediaViewerPopup> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isZoomedIn = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex % widget.allMedia.length;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            controller: _pageController,
            physics: _isZoomedIn
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index % widget.allMedia.length;
              });
            },
            itemBuilder: (context, index) {
              final realIndex = index % widget.allMedia.length;
              final path = widget.allMedia[realIndex];
              final isImage = realIndex < widget.displayImagePathsCount;
              final thumbPath = widget.allThumbnails[realIndex];

              if (isImage) {
                return _ZoomableImage(
                  key: ValueKey(path),
                  imagePath: path,
                  thumbnailPath: thumbPath,
                  onScaleChanged: (scale) {
                    if (mounted) {
                      setState(() {
                        _isZoomedIn = scale > 1.0;
                      });
                    }
                  },
                );
              } else {
                final controller = widget.videoControllers[path];
                if (controller != null && controller.value.isInitialized) {
                  return Center(
                    child: _VideoPlayerItem(
                      key: ValueKey(path),
                      controller: controller,
                      onPlayStateChanged: (c) {},
                    ),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }
            },
          ),
          Positioned(
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.5).round()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentIndex + 1} / ${widget.allMedia.length}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withAlpha((255 * 0.3).round())),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  final String imagePath;
  final String thumbnailPath;
  final ValueChanged<double> onScaleChanged;

  const _ZoomableImage({
    super.key,
    required this.imagePath,
    required this.thumbnailPath,
    required this.onScaleChanged,
  });

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    widget.onScaleChanged(scale);
  }

  @override
  Widget build(BuildContext context) {
    final thumbProvider = widget.thumbnailPath.startsWith('http')
        ? CachedNetworkImageProvider(widget.thumbnailPath)
        : FileImage(File(widget.thumbnailPath)) as ImageProvider;

    return InteractiveViewer(
      transformationController: _transformationController,
      panEnabled: true,
      scaleEnabled: true,
      minScale: 1.0,
      maxScale: 5.0,
      child: Center(
        child: widget.imagePath.startsWith('http')
            ? CachedNetworkImage(
                imageUrl: widget.imagePath,
                fit: BoxFit.contain,
                placeholder: (context, url) => Image(
                  image: thumbProvider,
                  fit: BoxFit.contain,
                ),
                errorWidget: (context, url, error) =>
                    const Center(child: Icon(Icons.error)),
              )
            : Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.error)),
              ),
      ),
    );
  }
}

class _VideoPlayerItem extends StatefulWidget {
  final VideoPlayerController controller;
  final ValueChanged<VideoPlayerController?> onPlayStateChanged;

  const _VideoPlayerItem(
      {super.key, required this.controller, required this.onPlayStateChanged});

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  bool _showControls = true;
  Timer? _controlsTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    _startControlsTimer();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    _controlsTimer?.cancel();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
      widget.onPlayStateChanged(null);
    } else {
      if (widget.controller.value.position ==
          widget.controller.value.duration) {
        widget.controller.seekTo(Duration.zero);
      }
      widget.controller.play();
      widget.onPlayStateChanged(widget.controller);
    }
    _startControlsTimer();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) {
        _startControlsTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: widget.controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(widget.controller),
            GestureDetector(
              onTap: _toggleControls,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withAlpha((255 * 0.3).round()),
                  child: Center(
                    child: IconButton(
                      iconSize: 64,
                      icon: Icon(
                        widget.controller.value.isPlaying
                            ? Icons.pause_circle_outline
                            : Icons.play_circle_outline,
                        color: Colors.white,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InTheWorldTabs extends StatelessWidget {
  final EmotionalAnchorBundle bundle;
  final AppLocalizations l10n;

  const _InTheWorldTabs({required this.bundle, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final hasNews = bundle.worldNews.isNotEmpty;
    final hasMusic = bundle.musicChart.isNotEmpty;

    final tabs = <Tab>[];
    final tabViews = <Widget>[];

    if (hasNews) {
      tabs.add(Tab(text: l10n.memoryViewTabNews));
      tabViews.add(_NewsPage(news: bundle.worldNews, l10n: l10n));
    }
    if (hasMusic) {
      tabs.add(Tab(text: l10n.memoryViewTabMusic));
      tabViews.add(_MusicChart(tracks: bundle.musicChart));
    }

    if (tabs.isEmpty) {
      return Center(child: Text(l10n.memoryViewNoDataForDay));
    }

    return DefaultTabController(
      length: tabs.length,
      child: Column(
        children: [
          TabBar(
            tabs: tabs,
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withAlpha((255 * 0.6).round()),
          ),
          Expanded(
            child: TabBarView(
              children: tabViews,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewsPage extends StatelessWidget {
  final List<NewsAnchor> news;
  final AppLocalizations l10n;
  const _NewsPage({required this.news, required this.l10n});

  @override
  Widget build(BuildContext context) {
    if (news.isEmpty) {
      return Center(
          child: Text(l10n.memoryViewNoNewsForDay,
              style: const TextStyle(color: Colors.white70)));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: news.map((item) => _NewsCard(item: item, l10n: l10n)).toList(),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsAnchor item;
  final AppLocalizations l10n;
  const _NewsCard({required this.item, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withAlpha((255 * 0.05).round()),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const SizedBox(
                    height: 150,
                    child: Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white30, size: 40)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(item.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(item.description,
                style: TextStyle(color: Colors.white.withAlpha((255 * 0.8).round()))),
            const SizedBox(height: 8),
            Text(l10n.memoryViewNewsSource(item.source),
                style: const TextStyle(
                    color: Colors.white54, fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}

class _MusicChart extends StatelessWidget {
  final List<MusicAnchor> tracks;
  const _MusicChart({required this.tracks});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: tracks.map((track) {
        return InkWell(
          onTap: () async {
            if (track.spotifyUrl != null) {
              final uri = Uri.parse(track.spotifyUrl!);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("#${track.rank}",
                    style: GoogleFonts.oswald(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 16),
                if (track.albumArtUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CachedNetworkImage(
                      imageUrl: track.albumArtUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.white10,
                          child: const Icon(Icons.music_note,
                              color: Colors.white54),
                        );
                      },
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      Text(track.artist,
                          style: const TextStyle(color: Colors.white70),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (track.spotifyUrl != null)
                  const Icon(Icons.open_in_new,
                      color: Colors.white54, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _HoldToDeleteDialog extends StatefulWidget {
  final AppLocalizations l10n;
  const _HoldToDeleteDialog({required this.l10n});

  @override
  State<_HoldToDeleteDialog> createState() => _HoldToDeleteDialogState();
}

class _HoldToDeleteDialogState extends State<_HoldToDeleteDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  Timer? _deleteTimer;
  static const int _holdDurationSeconds = 5;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _holdDurationSeconds),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _deleteTimer?.cancel();
    super.dispose();
  }

  void _startHold() {
    _deleteTimer?.cancel();
    _progressController.forward();
    _deleteTimer = Timer(const Duration(seconds: _holdDurationSeconds), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  void _cancelHold() {
    _deleteTimer?.cancel();
    _progressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.l10n.memoryViewConfirmDeleteTitle),
      content: Text(widget.l10n.memoryViewConfirmDeleteContent),
      actions: <Widget>[
        TextButton(
          child: Text(widget.l10n.profileCancel),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        Listener(
          onPointerDown: (_) => _startHold(),
          onPointerUp: (_) => _cancelHold(),
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return SizedBox(
                width: 100,
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.red.withAlpha((255 * 0.2).round()),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                    ),
                    Text(
                      widget.l10n.memoryViewDeleteButton,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// --- WIDGETS FOR LOADING/ERROR/EMPTY STATES ---

class _SpotifyTrackLoadingSkeleton extends StatelessWidget {
  const _SpotifyTrackLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          color: Colors.white.withAlpha((255 * 0.1).round()),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                color: Colors.white.withAlpha((255 * 0.1).round()),
              ),
              const SizedBox(height: 8),
              Container(
                width: 100,
                height: 12,
                color: Colors.white.withAlpha((255 * 0.1).round()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpotifyTrackError extends StatelessWidget {
  final VoidCallback onRetry;
  final AppLocalizations l10n;
  const _SpotifyTrackError({required this.onRetry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.redAccent),
        const SizedBox(width: 12),
        Expanded(
            child: Text(l10n.memoryViewErrorCouldNotLoadTrack,
                style: const TextStyle(color: Colors.white70))),
        TextButton(onPressed: onRetry, child: Text(l10n.authGateTryAgain)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: Text(l10n.authGateTryAgain)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, color: Colors.white38, size: 48),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ShareMenu extends StatelessWidget {
  final VoidCallback onExport;
  final AppLocalizations l10n;
  const _ShareMenu({required this.onExport, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.picture_as_pdf),
            title: Text(l10n.memoryViewExportPdf),
            onTap: onExport,
          ),
        ],
      ),
    );
  }
}

