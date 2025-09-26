import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lifeline/l10n/app_localizations.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/models/anchors/anchor_models.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/screens/profile_screen.dart';
import 'package:lifeline/screens/spotify_search_screen.dart';
import 'package:lifeline/services/audio_service.dart';
import 'package:lifeline/services/encryption_service.dart';
import 'package:lifeline/services/image_processing_service.dart';
import 'package:lifeline/services/message_service.dart';
import 'package:lifeline/widgets/premium_upsell_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

// Helper class to distinguish between local files and network URLs
class MediaItem {
  final String path;
  final String thumbPath; // Путь к миниатюре
  final bool isLocal;

  MediaItem(
      {required this.path, required this.thumbPath, required this.isLocal});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaItem && runtimeType == other.runtimeType && path == other.path;

  @override
  int get hashCode => path.hashCode;
}

class AudioMediaItem {
  final String path;
  final bool isLocal;
  AudioMediaItem({required this.path, required this.isLocal});
}

class VideoMediaItem {
  final String path;
  final bool isLocal;
  VideoMediaItem({required this.path, required this.isLocal});
}

class MemoryEditScreen extends ConsumerStatefulWidget {
  final Memory? initial;
  final String userId;
  final List<MediaItem>? initialMedia;
  final List<VideoMediaItem>? initialVideos;

  const MemoryEditScreen({
    super.key,
    this.initial,
    required this.userId,
    this.initialMedia,
    this.initialVideos,
  });

  @override
  ConsumerState<MemoryEditScreen> createState() => _MemoryEditScreenState();
}

class _MemoryEditScreenState extends ConsumerState<MemoryEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late TextEditingController _titleCtrl,
      _contentCtrl,
      _impactCtrl,
      _lessonCtrl,
      _autoThoughtCtrl,
      _evidenceForCtrl,
      _evidenceAgainstCtrl,
      _reframeCtrl,
      _actionCtrl;

  DateTime _date = DateTime.now();

  final List<MediaItem> _mediaItems = [];
  final List<VideoMediaItem> _videoItems = [];
  final List<AudioMediaItem> _audioNoteItems = [];

  List<String> _spotifyTrackIds = [];
  final Map<String, SpotifyTrackDetails> _spotifyTrackDetailsMap = {};
  String _ambientSound = 'None';

  late Map<String, int> _selectedEmotionsWithIntensity;

  final List<String> _availableEmotionKeys = [
    'joy',
    'nostalgia',
    'pride',
    'sadness',
    'gratitude',
    'love',
    'fear',
    'anger'
  ];

  bool _isEncrypted = false;
  late DateTime? _followUpDate;

  final _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isSaving = false;
  bool _isProcessingImages = false;

  Timer? _autosaveTimer;
  Memory? _draftMemory;

  static const int _freePhotoLimit = 3;
  static const int _freeVideoLimit = 1;
  static const int _freeAudioLimit = 1;
  static const int _freeSpotifyLimit = 1;

  @override
  void initState() {
    super.initState();

    _draftMemory = widget.initial;

    _titleCtrl = TextEditingController(text: _draftMemory?.title ?? '');
    _contentCtrl = TextEditingController(text: _draftMemory?.content ?? '');
    _impactCtrl =
        TextEditingController(text: _draftMemory?.reflectionImpact ?? '');
    _lessonCtrl =
        TextEditingController(text: _draftMemory?.reflectionLesson ?? '');
    _autoThoughtCtrl =
        TextEditingController(text: _draftMemory?.reflectionAutoThought ?? '');
    _evidenceForCtrl =
        TextEditingController(text: _draftMemory?.reflectionEvidenceFor ?? '');
    _evidenceAgainstCtrl = TextEditingController(
        text: _draftMemory?.reflectionEvidenceAgainst ?? '');
    _reframeCtrl =
        TextEditingController(text: _draftMemory?.reflectionReframe ?? '');
    _actionCtrl =
        TextEditingController(text: _draftMemory?.reflectionAction ?? '');

    _date = _draftMemory?.date ?? DateTime.now();
    _spotifyTrackIds = List<String>.from(_draftMemory?.spotifyTrackIds ?? []);
    _ambientSound = _draftMemory?.ambientSound ?? 'None';
    _isEncrypted = _draftMemory?.isEncrypted ?? false;
    _followUpDate = _draftMemory?.reflectionFollowUpAt;

    _selectedEmotionsWithIntensity = Map.from(_draftMemory?.emotions ?? {});

    if (_draftMemory != null) {
      final fullImages = _draftMemory!.displayableMediaPaths;
      final thumbnails = _draftMemory!.displayableThumbPaths;
      for (int i = 0; i < fullImages.length; i++) {
        final fullPath = fullImages[i];
        final thumbPath = i < thumbnails.length ? thumbnails[i] : fullPath;
        _mediaItems.add(MediaItem(
            path: fullPath, thumbPath: thumbPath, isLocal: !fullPath.startsWith('http')));
      }

      _videoItems.addAll(_draftMemory!.displayableVideoPaths
          .map((p) => VideoMediaItem(path: p, isLocal: !p.startsWith('http'))));
      _audioNoteItems.addAll(_draftMemory!.displayableAudioPaths
          .map((p) => AudioMediaItem(path: p, isLocal: !p.startsWith('http'))));
    }

    if (widget.initialMedia != null) {
      _mediaItems.insertAll(0, widget.initialMedia!);
    }
    if (widget.initialVideos != null) {
      _videoItems.insertAll(0, widget.initialVideos!);
    }

    _initializeAutosave();

    if (_spotifyTrackIds.isNotEmpty) {
      _loadAllTrackDetails();
    }
  }

  String _getTranslatedEmotion(String key, AppLocalizations l10n) {
    switch (key) {
      case 'joy':
        return l10n.emotionJoy;
      case 'nostalgia':
        return l10n.emotionNostalgia;
      case 'pride':
        return l10n.emotionPride;
      case 'sadness':
        return l10n.emotionSadness;
      case 'gratitude':
        return l10n.emotionGratitude;
      case 'love':
        return l10n.emotionLove;
      case 'fear':
        return l10n.emotionFear;
      case 'anger':
        return l10n.emotionAnger;
      default:
        return key;
    }
  }

  Future<void> _initializeAutosave() async {
    if (_draftMemory == null) {
      if (!mounted) return;
      final repo = ref.read(memoryRepositoryProvider);
      if (repo != null) {
        final newDraft = await repo.createDraft();
        if (mounted) {
          setState(() {
            _draftMemory = newDraft;
          });
        }
      }
    }
    _autosaveTimer =
        Timer.periodic(const Duration(seconds: 20), (_) => _autoSaveDraft(isTimerBased: true));
  }
  
  Memory _buildMemoryFromState() {
    final baseMemory = _draftMemory ?? Memory();

    return baseMemory.copyWith(
      userId: widget.userId,
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim().isEmpty ? null : _contentCtrl.text.trim(),
      date: _date,
      mediaPaths: _mediaItems.where((i) => i.isLocal).map((i) => i.path).toList(),
      mediaUrls: _mediaItems.where((i) => !i.isLocal).map((i) => i.path).toList(),
      mediaThumbPaths: _mediaItems.where((i) => i.isLocal).map((i) => i.thumbPath).toList(),
      mediaThumbUrls: _mediaItems.where((i) => !i.isLocal).map((i) => i.thumbPath).toList(),
      videoPaths: _videoItems.where((i) => i.isLocal).map((i) => i.path).toList(),
      videoUrls: _videoItems.where((i) => !i.isLocal).map((i) => i.path).toList(),
      audioNotePaths: _audioNoteItems.where((i) => i.isLocal).map((i) => i.path).toList(),
      audioUrls: _audioNoteItems.where((i) => !i.isLocal).map((i) => i.path).toList(),
      spotifyTrackIds: _spotifyTrackIds,
      ambientSound: _ambientSound == 'None' ? null : _ambientSound,
      reflectionImpact: _impactCtrl.text.trim().isEmpty ? null : _impactCtrl.text.trim(),
      reflectionLesson: _lessonCtrl.text.trim().isEmpty ? null : _lessonCtrl.text.trim(),
      reflectionAutoThought: _autoThoughtCtrl.text.trim().isEmpty ? null : _autoThoughtCtrl.text.trim(),
      reflectionEvidenceFor: _evidenceForCtrl.text.trim().isEmpty ? null : _evidenceForCtrl.text.trim(),
      reflectionEvidenceAgainst: _evidenceAgainstCtrl.text.trim().isEmpty ? null : _evidenceAgainstCtrl.text.trim(),
      reflectionReframe: _reframeCtrl.text.trim().isEmpty ? null : _reframeCtrl.text.trim(),
      reflectionAction: _actionCtrl.text.trim().isEmpty ? null : _actionCtrl.text.trim(),
      reflectionFollowUpAt: _followUpDate,
      isEncrypted: _isEncrypted,
      emotions: _selectedEmotionsWithIntensity,
      mediaKeysOrder: _mediaItems.map((item) => getFileKey(item.path)).toList(),
      videoKeysOrder: _videoItems.map((item) => getFileKey(item.path)).toList(),
      audioKeysOrder: _audioNoteItems.map((item) => getFileKey(item.path)).toList(),
    );
  }


  Future<void> _autoSaveDraft({bool isTimerBased = false}) async {
    if (!mounted || _draftMemory == null || !(_formKey.currentState?.validate() ?? true)) return;
    
    final l10n = AppLocalizations.of(context)!;
    final repo = ref.read(memoryRepositoryProvider);
    if (repo == null) return;
    
    final memoryToSave = _buildMemoryFromState().copyWith(syncStatus: 'draft');

    final updatedDraft = await repo.update(memoryToSave);
    if(mounted) {
       setState(() {
         _draftMemory = updatedDraft;
       });
    }

    if (mounted && isTimerBased) {
      ref
          .read(messageProvider.notifier)
          .addMessage(l10n.memoryEditDraftSavedMessage, type: MessageType.success);
    }
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _impactCtrl.dispose();
    _lessonCtrl.dispose();
    _autoThoughtCtrl.dispose();
    _evidenceForCtrl.dispose();
    _evidenceAgainstCtrl.dispose();
    _reframeCtrl.dispose();
    _actionCtrl.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _loadAllTrackDetails() async {
    for (final trackId in _spotifyTrackIds) {
      if (_spotifyTrackDetailsMap.containsKey(trackId)) continue;
      final details =
          await ref.read(spotifyServiceProvider).getTrackDetails(trackId);
      if (mounted && details != null) {
        setState(() => _spotifyTrackDetailsMap[trackId] = details);
      }
    }
  }
  
  Future<void> _pickImage() async {
    final isPremium = ref.read(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;

    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (!mounted || pickedFiles.isEmpty) return;
    
    if (!isPremium && (_mediaItems.length + pickedFiles.length) > _freePhotoLimit) {
      await showPremiumDialog(context, l10n.premiumFeaturePhotos);
      return;
    }
    
    setState(() => _isProcessingImages = true);

    try {
      final imageProcessor = ref.read(imageProcessingServiceProvider);
      
      final processingFutures = pickedFiles.map((file) => imageProcessor.processPickedImage(file)).toList();
      final results = await Future.wait(processingFutures);

      if (!mounted) return;

      final newMediaItems = results.whereType<ProcessedImageResult>().map((result) => MediaItem(
        path: result.compressedImagePath,
        thumbPath: result.thumbnailPath,
        isLocal: true,
      )).toList();
      
      setState(() {
        _mediaItems.addAll(newMediaItems);
      });
      
      await _autoSaveDraft();

    } catch (e) {
      // Handle errors if necessary
    } finally {
      if (mounted) {
        setState(() => _isProcessingImages = false);
      }
    }
  }

  Future<void> _pickVideo() async {
    final isPremium = ref.read(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;
    if (!isPremium && _videoItems.length >= _freeVideoLimit) {
      if (context.mounted) {
        await showPremiumDialog(context, l10n.premiumFeatureVideos);
      }
      return;
    }

    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(
            () => _videoItems.add(VideoMediaItem(path: pickedFile.path, isLocal: true)));
        _autoSaveDraft();
      }
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showPermissionDeniedSnackbar('videos');
    }
  }

  Future<void> _recordAudio() async {
    final isPremium = ref.read(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;
    if (!isPremium && _audioNoteItems.length >= _freeAudioLimit) {
      if (context.mounted) {
        await showPremiumDialog(context, l10n.premiumFeatureAudio);
      }
      return;
    }

    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await ref.read(audioPlayerProvider.notifier).pauseGlobalPlayer();
      if (_isRecording) {
        final path = await _audioRecorder.stop();
        if (path != null) {
          setState(() {
            _isRecording = false;
            _audioNoteItems.add(AudioMediaItem(path: path, isLocal: true));
          });
          _autoSaveDraft();
        }
      } else {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path);
        setState(() => _isRecording = true);
      }
    } else if (status.isPermanentlyDenied) {
      if (!mounted) return;
      _showPermissionDeniedSnackbar('microphone');
    }
  }

  void _showPermissionDeniedSnackbar(String permissionName) {
    final l10n = AppLocalizations.of(context)!;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.memoryEditPermissionDeniedSnackbar(permissionName)),
          action: SnackBarAction(
              label: l10n.memoryEditSettingsButton,
              onPressed: openAppSettings)));
    }
  }

  Future<void> _pickDate() async {
    final newDate = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(1900),
        lastDate: DateTime(2100));
    if (newDate != null) {
      setState(() => _date = newDate);
      _autoSaveDraft();
    }
  }

  Future<void> _pickFollowUpDate() async {
    final isPremium = ref.read(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;
    if (!isPremium) {
      if (context.mounted) {
        await showPremiumDialog(context, l10n.premiumFeatureActionReminders);
      }
      return;
    }

    final newDate = await showDatePicker(
        context: context,
        initialDate: _followUpDate ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (newDate != null) {
      if (!mounted) return;
      final newTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_followUpDate ?? DateTime.now()));
      if (newTime != null) {
        setState(() => _followUpDate =
            newDate.copyWith(hour: newTime.hour, minute: newTime.minute));
        _autoSaveDraft();
      }
    }
  }

  Future<void> _searchAndAttachTrack() async {
    final isPremium = ref.read(isPremiumProvider);
    final l10n = AppLocalizations.of(context)!;
    if (!isPremium && _spotifyTrackIds.length >= _freeSpotifyLimit) {
      if (context.mounted) {
        await showPremiumDialog(context, l10n.premiumFeatureSpotify);
      }
      return;
    }

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none) &&
        !connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.mobile)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.memoryEditNoInternetSnackbar)),
        );
      }
      return;
    }

    await ref.read(audioPlayerProvider.notifier).pauseGlobalPlayer();
    if (!mounted) return;
    final selectedTrackId = await Navigator.of(context)
        .push<String>(MaterialPageRoute(builder: (_) => const SpotifySearchScreen()));
    if (selectedTrackId != null) {
      setState(() {
        if (!_spotifyTrackIds.contains(selectedTrackId)) {
          _spotifyTrackIds.add(selectedTrackId);
        }
      });
      _loadAllTrackDetails();
      _autoSaveDraft();
    }
  }

  Future<void> _handleReflectionReminder(Memory memory) async {
    final notificationService = ref.read(notificationServiceProvider);
    await notificationService.cancelNotification(memory.id);
    if (memory.reflectionFollowUpAt != null &&
        memory.reflectionAction != null &&
        memory.reflectionAction!.isNotEmpty) {
      await notificationService.scheduleNotification(
          id: memory.id,
          title: memory.title,
          body: memory.reflectionAction!,
          scheduledDate: memory.reflectionFollowUpAt!,
          payload: memory.id.toString());
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate() || _isSaving) return;

    if (_isEncrypted &&
        ref.read(encryptionServiceProvider) == EncryptionState.locked) {
      final unlocked = await _showUnlockDialog();
      if (!unlocked) return;
    }

    setState(() => _isSaving = true);

    if (_draftMemory == null) {
      setState(() => _isSaving = false);
      return;
    }

    final memoryRepository = ref.read(memoryRepositoryProvider);
    if (memoryRepository == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.memoryEditErrorRepoUnavailable)));
        setState(() => _isSaving = false);
      }
      return;
    }
    
    final memoryToSave = _buildMemoryFromState().copyWith(syncStatus: 'pending');

    try {
      await memoryRepository.update(memoryToSave);
      ref.read(syncServiceProvider).queueSync(memoryToSave.id);
      await _handleReflectionReminder(memoryToSave);

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.memoryEditErrorSaving(e.toString()))));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _showUnlockDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.memoryEditUnlockDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.memoryEditUnlockDialogContent),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const CircularProgressIndicator()
                  else
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: l10n.memoryEditMasterPasswordHint,
                        errorText: errorText,
                      ),
                      onSubmitted: (_) => _performUnlock(
                          passwordController,
                          (err) => setState(() => errorText = err),
                          (loading) => setState(() => isLoading = loading)),
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
                      : () => _performUnlock(
                          passwordController,
                          (err) => setState(() => errorText = err),
                          (loading) => setState(() => isLoading = loading)),
                  child: Text(l10n.memoryEditUnlockButton),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  Future<void> _performUnlock(TextEditingController controller,
      Function(String?) onError, Function(bool) onLoading) async {
    final l10n = AppLocalizations.of(context)!;
    onLoading(true);
    onError(null);
    final success = await ref
        .read(encryptionServiceProvider.notifier)
        .unlockSession(controller.text);
    if (success) {
      if (mounted) Navigator.of(context).pop(true);
    } else {
      onError(l10n.memoryViewIncorrectPassword);
    }
    onLoading(false);
  }

  void _showEncryptionInfo() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.memoryEditEncryptionInfoDialogTitle),
          content: SingleChildScrollView(
            child: Text(
              l10n.memoryEditEncryptionInfoDialogContent,
              style: const TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.memoryEditOkButton),
            ),
          ],
        );
      },
    );
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProfile = ref.watch(userProfileProvider).value;
    final isEncryptionGloballyEnabled =
        userProfile?.isEncryptionEnabled ?? false;
    final isPremium = ref.watch(isPremiumProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        _autosaveTimer?.cancel();
        Navigator.of(context).pop(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.initial == null ||
                  widget.initial?.syncStatus == 'draft'
              ? l10n.memoryEditNewTitle
              : l10n.memoryEditEditTitle),
          actions: [
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white)),
                  )
                : IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: _isSaving || _isProcessingImages ? null : _save,
                    tooltip: l10n.memoryEditSave)
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _AutosavingTextField(
                controller: _titleCtrl,
                labelText: l10n.memoryEditTitleHint,
                onSave: _autoSaveDraft,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.memoryEditTitleValidator
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                        '${l10n.memoryEditDateLabel} ${DateFormat.yMMMMd().format(_date)}'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                      onPressed: _pickDate,
                      child: Text(l10n.memoryEditSelectDateButton)),
                ],
              ),
              const SizedBox(height: 16),
              _buildEncryptionControl(l10n, isEncryptionGloballyEnabled),
              const SizedBox(height: 16),
              _AutosavingTextField(
                controller: _contentCtrl,
                labelText: l10n.memoryEditDescriptionHint,
                onSave: _autoSaveDraft,
                minLines: 3,
                maxLines: 6,
              ),
              const SizedBox(height: 24),
              Text(l10n.memoryEditAmbientSoundLabel,
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              _buildAmbientSoundPicker(),
              const SizedBox(height: 24),
              _buildMediaSection(
                l10n: l10n,
                isPremium: isPremium,
                title: l10n.memoryEditMusicAnchorLabel,
                items: _spotifyTrackIds,
                limit: _freeSpotifyLimit,
                builder: _buildSpotifyControl,
              ),
              const SizedBox(height: 24),
              _buildMediaSection(
                l10n: l10n,
                isPremium: isPremium,
                title: l10n.memoryEditPhotosLabel,
                items: _mediaItems,
                limit: _freePhotoLimit,
                builder: _buildMediaGrid,
                button: ElevatedButton.icon(
                  onPressed: _isProcessingImages ? null : _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text(l10n.memoryEditAddPhotosButton),
                ),
              ),
              const SizedBox(height: 24),
              _buildMediaSection(
                l10n: l10n,
                isPremium: isPremium,
                title: l10n.memoryEditVideosLabel,
                items: _videoItems,
                limit: _freeVideoLimit,
                builder: _buildVideoGrid,
                button: ElevatedButton.icon(
                  onPressed: _pickVideo,
                  icon: const Icon(Icons.video_camera_back),
                  label: Text(l10n.memoryEditAddVideoButton),
                ),
              ),
              const SizedBox(height: 24),
              _buildMediaSection(
                l10n: l10n,
                isPremium: isPremium,
                title: l10n.memoryEditAudioNoteLabel,
                items: _audioNoteItems,
                limit: _freeAudioLimit,
                builder: _buildAudioNoteControls,
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Text(l10n.memoryEditReflectionSectionTitle,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildReflectionSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEncryptionControl(
      AppLocalizations l10n, bool isEncryptionGloballyEnabled) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(l10n.memoryEditEncryptMemory),
        value: _isEncrypted,
        onChanged: (value) =>
            _onEncryptionToggle(value, isEncryptionGloballyEnabled, l10n),
        secondary: IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.grey),
          onPressed: _showEncryptionInfo,
          tooltip: l10n.memoryEditEncryptionInfoTooltip,
        ),
      ),
    );
  }

  void _onEncryptionToggle(
      bool value, bool isEncryptionGloballyEnabled, AppLocalizations l10n) {
    if (isEncryptionGloballyEnabled) {
      setState(() => _isEncrypted = value);
      _autoSaveDraft();
    } else {
      _showSetupEncryptionDialog(l10n);
    }
  }

  Future<void> _showSetupEncryptionDialog(AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.memoryEditSetupEncryptionTitle),
        content: Text(l10n.memoryEditSetupEncryptionContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.profileCancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.memoryEditCreatePasswordButton),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await showCreateMasterPasswordDialog(context, ref);
      if (success) {
        setState(() => _isEncrypted = true);
        _autoSaveDraft();
      }
    }
  }

  Widget _buildMediaSection({
    required AppLocalizations l10n,
    required bool isPremium,
    required String title,
    required List<dynamic> items,
    required int limit,
    required Widget Function(AppLocalizations l10n) builder,
    Widget? button,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            if (!isPremium)
              Text(
                '${items.length} / $limit',
                style: TextStyle(
                  fontSize: 14,
                  color: items.length >= limit
                      ? Colors.red.shade300
                      : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        builder(l10n),
        if (button != null) ...[
          const SizedBox(height: 8),
          if (_isProcessingImages)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            button,
        ],
      ],
    );
  }

  Widget _buildReflectionSection() {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AutosavingTextField(
            controller: _impactCtrl,
            labelText: l10n.memoryEditImpactPrompt,
            onSave: _autoSaveDraft,
            minLines: 2,
            maxLines: 4),
        const SizedBox(height: 16),
        _AutosavingTextField(
            controller: _lessonCtrl,
            labelText: l10n.memoryEditLessonPrompt,
            onSave: _autoSaveDraft,
            minLines: 2,
            maxLines: 4),
        const SizedBox(height: 16),
        Text(l10n.memoryEditEmotionsLabel,
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        _buildEmotionChips(),
        const SizedBox(height: 16),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            l10n.memoryEditCbtHelperTitle,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary),
          ),
        ),
        if (isPremium) ...[
          _buildCbtStep(
            controller: _autoThoughtCtrl,
            step: 1,
            title: l10n.memoryEditCbtStep1Title,
            subtitle: l10n.memoryEditCbtStep1Subtitle,
            l10n: l10n,
          ),
          _buildCbtStep(
            controller: _evidenceForCtrl,
            step: 2,
            title: l10n.memoryEditCbtStep2Title,
            subtitle: l10n.memoryEditCbtStep2Subtitle,
            minLines: 2,
            l10n: l10n,
          ),
          _buildCbtStep(
            controller: _evidenceAgainstCtrl,
            step: 3,
            title: l10n.memoryEditCbtStep3Title,
            subtitle: l10n.memoryEditCbtStep3Subtitle,
            minLines: 2,
            l10n: l10n,
          ),
          _buildCbtStep(
            controller: _reframeCtrl,
            step: 4,
            title: l10n.memoryEditCbtStep4Title,
            subtitle: l10n.memoryEditCbtStep4Subtitle,
            minLines: 2,
            l10n: l10n,
          ),
        ] else
          PremiumFeatureLockTile(
            icon: Icons.psychology_outlined,
            text: l10n.premiumFeatureAdvancedCbt,
          ),
        const SizedBox(height: 16),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(l10n.memoryEditActionPlanTitle,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
        ),
        _AutosavingTextField(
            controller: _actionCtrl,
            labelText: l10n.memoryEditActionPrompt,
            onSave: _autoSaveDraft),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: Text(
                    '${l10n.memoryEditReminderLabel} ${_followUpDate != null ? DateFormat.yMd().add_jm().format(_followUpDate!) : l10n.memoryEditReminderNotSet}')),
            ElevatedButton(
                onPressed: _pickFollowUpDate,
                child: Text(l10n.memoryEditSetReminderButton)),
          ],
        ),
      ],
    );
  }

  Widget _buildCbtStep({
    required TextEditingController controller,
    required int step,
    required String title,
    required String subtitle,
    int minLines = 1,
    required AppLocalizations l10n,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(TextSpan(children: [
            TextSpan(
              text: l10n.memoryEditCbtStepLabel(step),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextSpan(
              text: title,
              style: const TextStyle(fontSize: 16),
            ),
          ])),
          const SizedBox(height: 4),
          Text(subtitle,
              style: TextStyle(
                  color: Colors.white.withAlpha((255 * 0.6).round()), fontSize: 12)),
          const SizedBox(height: 12),
          _AutosavingTextField(
            controller: controller,
            labelText: l10n.memoryEditYourThoughtsHint,
            onSave: _autoSaveDraft,
            minLines: minLines,
            maxLines: minLines + 2,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid(AppLocalizations l10n) {
    if (_mediaItems.isEmpty) {
      return Text(l10n.memoryEditNoPhotosSelected,
          style: TextStyle(color: Colors.white.withAlpha((255 * 0.6).round())));
    }
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((255 * 0.05).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _mediaItems.length,
        itemBuilder: (context, index) {
          final item = _mediaItems[index];
          final displayPath = item.thumbPath;
          return Card(
            key: ValueKey(item.path),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: SizedBox(
              width: 92,
              height: 92,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: item.isLocal
                        ? Image.file(File(displayPath), fit: BoxFit.cover)
                        : CachedNetworkImage(
                            imageUrl: displayPath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                          ),
                  ),
                  Positioned(
                    top: -8,
                    right: -8,
                    child: IconButton(
                      icon: const Icon(Icons.cancel,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                      onPressed: () {
                        setState(() => _mediaItems.remove(item));
                        _autoSaveDraft();
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _mediaItems.removeAt(oldIndex);
            _mediaItems.insert(newIndex, item);
          });
          _autoSaveDraft();
        },
      ),
    );
  }

  Widget _buildVideoGrid(AppLocalizations l10n) {
    if (_videoItems.isEmpty) {
      return Text(l10n.memoryEditNoVideosSelected,
          style: TextStyle(color: Colors.white.withAlpha((255 * 0.6).round())));
    }
    return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8),
        itemCount: _videoItems.length,
        itemBuilder: (context, index) {
          final item = _videoItems.elementAt(index);
          return Stack(fit: StackFit.expand, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                    color: Colors.black,
                    child: const Icon(Icons.videocam, color: Colors.white))),
            Positioned.fill(
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withAlpha((255 * 0.4).round()),
                        borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.play_circle_fill,
                        color: Colors.white, size: 36))),
            Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                    icon: const Icon(Icons.cancel,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                    onPressed: () {
                      setState(() => _videoItems.remove(item));
                      _autoSaveDraft();
                    }))
          ]);
        });
  }

  Widget _buildAudioNoteControls(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_audioNoteItems.isNotEmpty)
          ..._audioNoteItems.map((item) => ListTile(
                leading: const Icon(Icons.mic),
                title: Text(item.path.split('/').last,
                    overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() => _audioNoteItems.remove(item));
                      _autoSaveDraft();
                    }),
              )),
        const SizedBox(height: 8),
        ElevatedButton.icon(
            onPressed: _recordAudio,
            icon: Icon(_isRecording ? Icons.stop : Icons.mic),
            label: Text(_isRecording
                ? l10n.memoryEditStopRecordingButton
                : l10n.memoryEditRecordButton)),
        if (_isRecording)
          Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(l10n.memoryEditRecordingIndicator,
                  style: const TextStyle(color: Colors.red)))
      ],
    );
  }

  Widget _buildEmotionChips() {
    final l10n = AppLocalizations.of(context)!;
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: _availableEmotionKeys.map((key) {
        final translatedEmotion = _getTranslatedEmotion(key, l10n);
        final intensity = _selectedEmotionsWithIntensity[key];
        final isSelected = intensity != null;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(translatedEmotion),
              if (isSelected) ...[
                const SizedBox(width: 8),
                Text(intensity.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              _showEmotionIntensityDialog(key, translatedEmotion);
            } else {
              setState(() {
                _selectedEmotionsWithIntensity.remove(key);
              });
              _autoSaveDraft();
            }
          },
        );
      }).toList(),
    );
  }

  void _showEmotionIntensityDialog(String emotionKey, String translatedEmotion) {
    final l10n = AppLocalizations.of(context)!;
    int currentIntensity = _selectedEmotionsWithIntensity[emotionKey] ?? 50;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title:
                  Text(l10n.memoryEditEmotionIntensityDialogTitle(translatedEmotion)),
              content: StatefulBuilder(builder: (context, setStateInDialog) {
                return Column(mainAxisSize: MainAxisSize.min, children: [
                  Slider(
                      value: currentIntensity.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: currentIntensity.toString(),
                      onChanged: (newValue) =>
                          setStateInDialog(() => currentIntensity = newValue.round()))
                ]);
              }),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.profileCancel)),
                TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedEmotionsWithIntensity[emotionKey] =
                            currentIntensity;
                      });
                      _autoSaveDraft();
                      Navigator.of(context).pop();
                    },
                    child: Text(l10n.profileSave))
              ]);
        });
  }

  Widget _buildAmbientSoundPicker() {
    final l10n = AppLocalizations.of(context)!;
    final isPremium = ref.watch(isPremiumProvider);

    if (!isPremium) {
      return PremiumFeatureLockTile(
        icon: Icons.waves_outlined,
        text: l10n.premiumFeatureSoundLibrary,
      );
    }
    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: l10n.memoryEditAmbientSoundDropdownHint,
            border: const OutlineInputBorder()),
        initialValue: _ambientSound,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() => _ambientSound = newValue);
            _autoSaveDraft();
          }
        },
        items: AudioNotifier.availableSounds
            .map<DropdownMenuItem<String>>(
                (String value) => DropdownMenuItem<String>(value: value, child: Text(value)))
            .toList());
  }

  Widget _buildSpotifyControl(AppLocalizations l10n) {
    return Column(
      children: [
        ..._spotifyTrackIds.map((trackId) {
          final details = _spotifyTrackDetailsMap[trackId];
          if (details == null) {
            return const ListTile(title: Text("Loading track..."));
          }
          return ListTile(
            leading: details.albumArtUrl != null
                ? CachedNetworkImage(
                    imageUrl: details.albumArtUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.music_note),
            title: Text(details.name),
            subtitle: Text(details.artist),
            trailing: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _spotifyTrackIds.remove(trackId);
                  _spotifyTrackDetailsMap.remove(trackId);
                });
                _autoSaveDraft();
              },
            ),
          );
        }),
        const SizedBox(height: 8),
        ElevatedButton.icon(
            onPressed: _searchAndAttachTrack,
            icon: const Icon(Icons.music_note),
            label: Text(l10n.memoryEditAttachTrackButton)),
      ],
    );
  }
}

class _AutosavingTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final VoidCallback onSave;
  final String? Function(String?)? validator;
  final int minLines;
  final int maxLines;

  const _AutosavingTextField({
    required this.controller,
    required this.labelText,
    required this.onSave,
    this.validator,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  State<_AutosavingTextField> createState() => _AutosavingTextFieldState();
}

enum _SaveState { idle, saved }

class _AutosavingTextFieldState extends State<_AutosavingTextField> {
  final FocusNode _focusNode = FocusNode();
  _SaveState _saveState = _SaveState.idle;
  Timer? _resetTimer;
  late String _lastSavedValue;

  @override
  void initState() {
    super.initState();
    _lastSavedValue = widget.controller.text;
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _resetTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (widget.controller.text != _lastSavedValue) {
        widget.onSave();
        _lastSavedValue = widget.controller.text;
        if (mounted) {
          setState(() => _saveState = _SaveState.saved);
          _resetTimer?.cancel();
          _resetTimer = Timer(const Duration(seconds: 4), () {
            if (mounted) {
              setState(() => _saveState = _SaveState.idle);
            }
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSaved = _saveState == _SaveState.saved;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          validator: widget.validator,
          decoration: InputDecoration(
            labelText: widget.labelText,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: isSaved
                    ? Colors.green
                    : Theme.of(context).colorScheme.outline,
                width: isSaved ? 2.0 : 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2.0,
              ),
            ),
          ),
        ),
        Positioned(
          right: 12,
          child: AnimatedOpacity(
            opacity: isSaved ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child:
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
          ),
        )
      ],
    );
  }
}

