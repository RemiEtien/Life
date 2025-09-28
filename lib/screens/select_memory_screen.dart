import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../memory.dart';
import '../providers/application_providers.dart';
import 'memory_edit_screen.dart'; // For MediaItem
import '../services/message_service.dart';

/// A screen to select an existing memory to add media to.
class SelectMemoryScreen extends ConsumerStatefulWidget {
  // ИЗМЕНЕНО: Списки теперь могут быть null
  final List<MediaItem>? mediaToAdd;
  final List<VideoMediaItem>? videosToAdd;

  const SelectMemoryScreen({super.key, this.mediaToAdd, this.videosToAdd});

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final repo = ref.read(memoryRepositoryProvider);
      if (repo == null) {
        throw Exception('Memory repository is not available.');
      }

      // ИЗМЕНЕНО: Обработка и фото, и видео
      if (widget.mediaToAdd != null && widget.mediaToAdd!.isNotEmpty) {
        memory.mediaPaths = List.from(memory.mediaPaths)
          ..addAll(widget.mediaToAdd!.where((i) => i.isLocal).map((i) => i.path));
        memory.mediaUrls = List.from(memory.mediaUrls)
          ..addAll(widget.mediaToAdd!.where((i) => !i.isLocal).map((i) => i.path));
        memory.mediaThumbPaths = List.from(memory.mediaThumbPaths)
          ..addAll(widget.mediaToAdd!
              .where((i) => i.isLocal)
              .map((i) => i.thumbPath));
        memory.mediaThumbUrls = List.from(memory.mediaThumbUrls)
          ..addAll(widget.mediaToAdd!
              .where((i) => !i.isLocal)
              .map((i) => i.thumbPath));
        memory.mediaKeysOrder = List.from(memory.mediaKeysOrder)
          ..addAll(widget.mediaToAdd!.map((item) => _getFileKey(item.path)));
      }

      if (widget.videosToAdd != null && widget.videosToAdd!.isNotEmpty) {
        memory.videoPaths = List.from(memory.videoPaths)
          ..addAll(
              widget.videosToAdd!.where((i) => i.isLocal).map((i) => i.path));
        memory.videoUrls = List.from(memory.videoUrls)
          ..addAll(
              widget.videosToAdd!.where((i) => !i.isLocal).map((i) => i.path));
        memory.videoKeysOrder = List.from(memory.videoKeysOrder)
          ..addAll(widget.videosToAdd!.map((item) => _getFileKey(item.path)));
      }

      await repo.update(memory);
      ref.read(syncServiceProvider).queueSync(memory.id);

      if (mounted) {
        Navigator.of(context).pop(); // Pop loading dialog
        Navigator.of(context)
            .popUntil((route) => route.isFirst); // Go back to timeline
        ref
            .read(messageProvider.notifier)
            .addMessage(l10n.memoryUpdatedSuccess, type: MessageType.success);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        print('Error adding media to memory: $e\n$stack');
      }
      if (mounted) {
        Navigator.of(context).pop(); // Pop loading dialog on error
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add media: $e')));
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
