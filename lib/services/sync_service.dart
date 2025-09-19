import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/services/firestore_service.dart';
import 'package:lifeline/services/memory_repository.dart';

@immutable
class SyncState {
  final int pendingJobs;
  final bool isSyncing;
  final String currentStatus;
  final double? progress;

  const SyncState({
    this.pendingJobs = 0,
    this.isSyncing = false,
    this.currentStatus = "Idle",
    this.progress,
  });

  SyncState copyWith({
    int? pendingJobs,
    bool? isSyncing,
    String? currentStatus,
    double? progress,
  }) {
    return SyncState(
      pendingJobs: pendingJobs ?? this.pendingJobs,
      isSyncing: isSyncing ?? this.isSyncing,
      currentStatus: currentStatus ?? this.currentStatus,
      progress: progress ?? this.progress,
    );
  }
}

class SyncService {
  final Ref _ref;
  final List<int> _syncQueue = [];
  bool _isProcessing = false;

  SyncService(this._ref) {
    _checkForUnsyncedMemories();
  }

  Future<void> syncFromCloudToLocal({bool isInitialSync = false}) async {
    final notifier = _ref.read(syncNotifierProvider.notifier);
    if (!isInitialSync && notifier.state.isSyncing) return;

    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null) return;

    if (!isInitialSync) {
        notifier.updateState(isSyncing: true, currentStatus: "Fetching from cloud...");
    }

    try {
      final cloudMemories = await firestore.fetchAllMemoriesOnce(userId);
      if (cloudMemories != null) {
        if (!isInitialSync) {
            notifier.updateState(currentStatus: "Updating local database...");
        }
        await repo!.replaceAll(cloudMemories);
      }
      if (!isInitialSync) {
        notifier.updateState(isSyncing: false, currentStatus: "Sync complete!");
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: "SyncService: syncFromCloudToLocal failed");
      if (!isInitialSync) {
        notifier.updateState(isSyncing: false, currentStatus: "Sync from cloud failed.");
      } else {
        rethrow;
      }
    } finally {
        if (!isInitialSync) {
            _checkForUnsyncedMemories();
        }
    }
  }

  void queueSync(int memoryId) {
    if (!_syncQueue.contains(memoryId)) {
      _syncQueue.add(memoryId);
      _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Queued...",
          );
      _processQueue();
    }
  }

  Future<void> _checkForUnsyncedMemories() async {
    final repo = _ref.read(memoryRepositoryProvider);
    if (repo == null) return;
    
    final toSync = await repo.getMemoriesToSync();
    if (toSync.isNotEmpty) {
      if (kDebugMode) {
        print("[SyncService] Found ${toSync.length} memories to sync.");
      }
      for (final memory in toSync) {
        queueSync(memory.id);
      }
    }
  }

  Future<void> _processQueue() async {
    if (_isProcessing || _syncQueue.isEmpty) {
      if (_syncQueue.isEmpty) {
         _ref.read(syncNotifierProvider.notifier).updateState(pendingJobs: 0, isSyncing: false, currentStatus: "Idle", progress: null);
      }
      return;
    }

    _isProcessing = true;
    final memoryId = _syncQueue.first;

    _ref.read(syncNotifierProvider.notifier).updateState(
          isSyncing: true,
          pendingJobs: _syncQueue.length,
          currentStatus: "Syncing memory...",
          progress: 0.0,
        );
        
    await _updateLocalStatus(memoryId, 'syncing');
    final success = await _syncMemoryWithRetries(memoryId);

    _syncQueue.removeAt(0);
    _isProcessing = false;
    
    if (success) {
      _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Sync complete!",
            progress: 1.0
          );
    } else {
       _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Sync failed. Will retry later.",
            progress: null
          );
    }
    
    await Future.delayed(const Duration(seconds: 1));
    _processQueue();
  }

  Future<void> _updateLocalStatus(int memoryId, String status) async {
      final repo = _ref.read(memoryRepositoryProvider);
      final memory = await repo?.getById(memoryId);
      if (memory != null) {
          memory.syncStatus = status;
          await repo!.updateAfterSync(memory);
      }
  }

  Future<bool> _syncMemoryWithRetries(int memoryId, {int maxRetries = 3}) async {
    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null || repo == null) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      Memory? memory = await repo.getDecryptedById(memoryId);
      if (memory == null) return true;

      try {
        final notifier = _ref.read(syncNotifierProvider.notifier);
        notifier.updateState(currentStatus: "Uploading photos...", progress: 0.2);
        
        final newPhotoUrls = await firestore.uploadFiles(userId, memory.universalId, memory.mediaPaths, 'photos');
        
        notifier.updateState(currentStatus: "Uploading videos...", progress: 0.5);
        final newVideoUrls = await firestore.uploadFiles(userId, memory.universalId, memory.videoPaths, 'videos');
        
        notifier.updateState(currentStatus: "Uploading audio...", progress: 0.8);
        final newAudioUrls = await firestore.uploadFiles(userId, memory.universalId, memory.audioNotePaths, 'audio');
        
        Memory memoryToSaveInCloud = (await repo.getById(memoryId))!;

        memoryToSaveInCloud
          ..mediaUrls = [...memory.mediaUrls, ...newPhotoUrls].toSet().toList()
          ..mediaPaths = []
          ..videoUrls = [...memory.videoUrls, ...newVideoUrls].toSet().toList()
          ..videoPaths = []
          ..audioUrls = [...memory.audioUrls, ...newAudioUrls].toSet().toList()
          ..audioNotePaths = []
          ..syncStatus = 'synced'
          ..touch();
        
        notifier.updateState(currentStatus: "Saving to cloud...", progress: 0.9);
        await firestore.setMemory(userId, memoryToSaveInCloud);
        
        await repo.updateAfterSync(memoryToSaveInCloud);

        return true;

      } catch (e, stackTrace) {
        if (kDebugMode) print("[SyncService] Attempt $attempt failed for memory ${memory.id}: $e");
        FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'SyncService: _syncMemoryWithRetries failed on attempt $attempt');

        if (attempt < maxRetries) {
          final delay = Duration(seconds: 5 * attempt);
           _ref.read(syncNotifierProvider.notifier).updateState(currentStatus: "Sync failed. Retrying in ${delay.inSeconds}s...");
          await Future.delayed(delay);
        }
      }
    }
    await _updateLocalStatus(memoryId, 'failed');
    return false;
  }
}
