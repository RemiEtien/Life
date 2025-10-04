import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import '../l10n/app_localizations.dart';
import '../memory.dart';
import '../utils/error_handler.dart';
import '../providers/application_providers.dart';
import '../services/encryption_service.dart';
import 'memory_edit_screen.dart'; // For MediaItem
import '../services/message_service.dart';

/// A screen to select an existing memory to add media to.
class SelectMemoryScreen extends ConsumerStatefulWidget {
  // ИЗМЕНЕНО: Списки теперь могут быть null
  final List<MediaItem>? mediaToAdd;
  final List<VideoMediaItem>? videosToAdd;
  final List<SharedMediaFile>? sharedFiles; // NEW: Raw files from Share intent

  const SelectMemoryScreen({super.key, this.mediaToAdd, this.videosToAdd, this.sharedFiles});

  @override
  ConsumerState<SelectMemoryScreen> createState() => _SelectMemoryScreenState();
}

class _SelectMemoryScreenState extends ConsumerState<SelectMemoryScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addMediaToMemory(Memory memory) async {
    final l10n = AppLocalizations.of(context)!;
    // Show loading indicator
    unawaited(showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    ));

    try {
      final repo = ref.read(memoryRepositoryProvider);
      if (repo == null) {
        throw Exception('Memory repository is not available.');
      }

      // CRITICAL FIX: Use copyWith to avoid double encryption
      // The memory object from provider contains already encrypted fields
      // We must only update media fields, not modify the original object

      // NEW: Process shared files if present (from Share intent)
      final List<MediaItem> processedMedia = widget.mediaToAdd != null ? List.from(widget.mediaToAdd!) : [];
      final List<VideoMediaItem> processedVideos = widget.videosToAdd != null ? List.from(widget.videosToAdd!) : [];

      if (widget.sharedFiles != null && widget.sharedFiles!.isNotEmpty) {
        final imageProcessor = ref.read(imageProcessingServiceProvider);

        for (var file in widget.sharedFiles!) {
          if (file.type == SharedMediaType.image) {
            final result = await imageProcessor.processPickedImage(XFile(file.path));
            if (result != null) {
              processedMedia.add(MediaItem(
                path: result.compressedImagePath,
                thumbPath: result.thumbnailPath,
                isLocal: true,
              ));
            }
          } else if (file.type == SharedMediaType.video) {
            processedVideos.add(VideoMediaItem(path: file.path, isLocal: true));
          }
        }
      }

      final newMediaPaths = List<String>.from(memory.mediaPaths);
      final newMediaUrls = List<String>.from(memory.mediaUrls);
      final newMediaThumbPaths = List<String>.from(memory.mediaThumbPaths);
      final newMediaThumbUrls = List<String>.from(memory.mediaThumbUrls);
      final newMediaKeysOrder = List<String>.from(memory.mediaKeysOrder);

      if (processedMedia.isNotEmpty) {
        newMediaPaths.addAll(processedMedia.where((i) => i.isLocal).map((i) => i.path));
        newMediaUrls.addAll(processedMedia.where((i) => !i.isLocal).map((i) => i.path));
        newMediaThumbPaths.addAll(processedMedia
            .where((i) => i.isLocal)
            .map((i) => i.thumbPath));
        newMediaThumbUrls.addAll(processedMedia
            .where((i) => !i.isLocal)
            .map((i) => i.thumbPath));
        newMediaKeysOrder.addAll(processedMedia.map((item) => _getFileKey(item.path)));
      }

      final newVideoPaths = List<String>.from(memory.videoPaths);
      final newVideoUrls = List<String>.from(memory.videoUrls);
      final newVideoKeysOrder = List<String>.from(memory.videoKeysOrder);

      if (processedVideos.isNotEmpty) {
        newVideoPaths.addAll(
            processedVideos.where((i) => i.isLocal).map((i) => i.path));
        newVideoUrls.addAll(
            processedVideos.where((i) => !i.isLocal).map((i) => i.path));
        newVideoKeysOrder.addAll(processedVideos.map((item) => _getFileKey(item.path)));
      }

      // Create a new memory object with updated media fields only
      final updatedMemory = memory.copyWith(
        mediaPaths: newMediaPaths,
        mediaUrls: newMediaUrls,
        mediaThumbPaths: newMediaThumbPaths,
        mediaThumbUrls: newMediaThumbUrls,
        mediaKeysOrder: newMediaKeysOrder,
        videoPaths: newVideoPaths,
        videoUrls: newVideoUrls,
        videoKeysOrder: newVideoKeysOrder,
      );

      await repo.update(updatedMemory);
      unawaited(ref.read(syncServiceProvider).queueSync(memory.id));

      if (mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
        Navigator.of(context)
            .popUntil((route) => route.isFirst); // Go back to timeline
        ref
            .read(messageProvider.notifier)
            .addMessage(l10n.memoryUpdatedSuccess, type: MessageType.success);
      }
    } on PerMemoryAuthenticationRequiredException catch (e) {
      // FIX: Handle per-memory authentication requirement
      if (mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
        await _handlePerMemoryAuth(e.memoryId, memory);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        ErrorHandler.logError(e, stack, reason: 'Error adding media to memory');
      }
      if (mounted) {
        Navigator.of(context).pop(); // Pop loading dialog on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getUserFriendlyMessage(e,
            fallback: 'Failed to add media. Please try again.'))));
      }
    }
  }

  Future<void> _handlePerMemoryAuth(int memoryId, Memory memory) async {
    final l10n = AppLocalizations.of(context)!;
    final biometricService = ref.read(biometricServiceProvider);
    final encryptionNotifier = ref.read(encryptionServiceProvider.notifier);

    try {
      // Attempt biometric authentication for this specific memory
      final didAuthenticate = await biometricService.authenticate(
        l10n.memoryViewUnlockDialogTitle,
      );

      if (didAuthenticate) {
        // Mark this memory as unlocked for the session
        encryptionNotifier.markMemoryAsUnlocked(memoryId);

        // Retry adding media
        await _addMediaToMemory(memory);
      } else {
        // User cancelled authentication
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.profileCancel)),
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SelectMemoryScreen] Per-memory auth failed: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper to get file key from path
  String _getFileKey(String path) {
    final String filename = path.split('/').last.split('?').first;
    return filename.replaceAll(RegExp(r'^\d{13}_'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final memoriesAsync = ref.watch(memoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectMemoryTitle),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.selectMemorySearchHint,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: memoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (memories) {
                final filteredMemories = memories.where((memory) {
                  if (_searchQuery.isEmpty) return true;
                  return memory.title.toLowerCase().contains(_searchQuery) ||
                      (memory.content?.toLowerCase().contains(_searchQuery) ??
                          false);
                }).toList();

                if (filteredMemories.isEmpty) {
                  return Center(child: Text(l10n.selectMemoryEmpty));
                }

                return ListView.builder(
                  itemCount: filteredMemories.length,
                  itemBuilder: (context, index) {
                    final memory = filteredMemories[index];
                    return ListTile(
                      title: Text(memory.title),
                      subtitle: Text(DateFormat.yMMMMd().format(memory.date)),
                      trailing: memory.isEncrypted
                          ? const Icon(Icons.lock_outline, size: 20)
                          : null,
                      onTap: () => _addMediaToMemory(memory),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
