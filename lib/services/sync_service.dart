import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:synchronized/synchronized.dart';
import '../memory.dart';
import '../providers/application_providers.dart';
import 'encryption_service.dart';

@immutable
class SyncState {
  final int pendingJobs;
  final bool isSyncing;
  final String currentStatus;
  final double? progress;

  const SyncState({
    this.pendingJobs = 0,
    this.isSyncing = false,
    this.currentStatus = 'Idle',
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
  bool _isPausedForUnlock = false;
  bool _isReconciling = false;

  // RACE CONDITION FIX: Use proper Lock from synchronized package instead of manual mutex
  // This prevents race conditions in queue operations with proper synchronization primitives
  final Lock _queueLock = Lock();

  SyncService(this._ref) {
    _checkForUnsyncedMemories();
  }

  Future<void> syncFromCloudToLocal({bool isInitialSync = false}) async {
    final notifier = _ref.read(syncNotifierProvider.notifier);
    if (_isReconciling || (!isInitialSync && _ref.read(syncNotifierProvider).isSyncing)) return;

    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null || repo == null) return;

    _isReconciling = true;

    if (!isInitialSync) {
      notifier.updateState(
          isSyncing: true, currentStatus: 'Reconciling with cloud...');
    }

    try {
      final cloudMemories = await firestore.fetchAllMemoriesOnce(userId);
      if (cloudMemories == null) {
        throw Exception('Could not fetch memories from cloud.');
      }
      final cloudIds =
          cloudMemories.map((m) => m.firestoreId).nonNulls.toSet();

      final allLocalMemories = await repo.getAllMemories();
      
      // ИСПРАВЛЕНИЕ 1: Исключаем все несинхронизированные статусы из сверки
      final Set<String> unsyncedStatuses = {'pending', 'draft', 'syncing', 'failed'};
      final localMemoriesToReconcile = allLocalMemories.where((mem) => !unsyncedStatuses.contains(mem.syncStatus)).toList();
      
      final List<int> idsToDelete = [];
      for (final localMemory in localMemoriesToReconcile) {
        if (localMemory.firestoreId != null &&
            !cloudIds.contains(localMemory.firestoreId)) {
          idsToDelete.add(localMemory.id);
        }
      }

      if (idsToDelete.isNotEmpty) {
        final deletedCount = await repo.deleteAllByIds(idsToDelete);
        if (kDebugMode) {
          debugPrint(
              '[SyncService] Deleted $deletedCount ghost memories from local DB.');
        }
      }

      // ИСПРАВЛЕНИЕ 2: Оптимизация. Создаем карту из уже загруженных данных.
      final localMemoriesMap = {
        for (var m in allLocalMemories)
          if (m.firestoreId != null) m.firestoreId!: m
      };
      
      final memoriesToUpsert = <Memory>[];

      for (final cloudMemory in cloudMemories) {
        final localMemory = localMemoriesMap[cloudMemory.firestoreId];

        if (localMemory == null) {
          memoriesToUpsert.add(cloudMemory);
        } else if (cloudMemory.lastModified.isAfter(localMemory.lastModified) &&
            !unsyncedStatuses.contains(localMemory.syncStatus)) { // ИСПРАВЛЕНИЕ 1 (повторно)
          cloudMemory.id = localMemory.id;
          memoriesToUpsert.add(cloudMemory);
        }
      }

      if (memoriesToUpsert.isNotEmpty) {
        if (kDebugMode) {
          debugPrint(
              '[SyncService] Upserting ${memoriesToUpsert.length} memories from cloud.');
        }
        await repo.upsertMemories(memoriesToUpsert);
      }
      
      await repo.repairOrphanedUserIds();

      if (!isInitialSync) {
        notifier.updateState(isSyncing: false, currentStatus: 'Sync complete!');
      }
    } catch (e, stackTrace) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'SyncService: syncFromCloudToLocal reconciliation failed'));
      if (!isInitialSync) {
        notifier.updateState(
            isSyncing: false, currentStatus: 'Sync from cloud failed.');
      } else {
        rethrow;
      }
    } finally {
      _isReconciling = false;
      if (!isInitialSync) {
        unawaited(_checkForUnsyncedMemories().catchError((e, stackTrace) {
          FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'SyncService: _checkForUnsyncedMemories failed');
        }));
      }
    }
  }

  Future<void> resumeSync() async {
    final hasWork = await _queueLock.synchronized(() => _syncQueue.isNotEmpty);

    if (_isPausedForUnlock && !_isProcessing && hasWork) {
      if (kDebugMode) {
        debugPrint('[SyncService] Resuming sync queue processing after unlock.');
      }
      _isPausedForUnlock = false;
      unawaited(_processQueue());
    }
  }

  Future<void> queueSync(int memoryId) async {
    await _queueLock.synchronized(() {
      if (!_syncQueue.contains(memoryId)) {
        _syncQueue.add(memoryId);
        _ref.read(syncNotifierProvider.notifier).updateState(
              pendingJobs: _syncQueue.length,
              currentStatus: 'Queued...',
            );
      }
    });
    // Don't await _processQueue to avoid deadlock
    unawaited(_processQueue());
  }

  Future<void> _checkForUnsyncedMemories() async {
    final repo = _ref.read(memoryRepositoryProvider);
    if (repo == null) return;

    final toSync = await repo.getMemoriesToSync();
    if (toSync.isNotEmpty) {
      if (kDebugMode) {
        debugPrint('[SyncService] Found ${toSync.length} memories to sync.');
      }
      for (final memory in toSync) {
        unawaited(queueSync(memory.id).catchError((e, stackTrace) {
          FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'SyncService: queueSync failed for memory ${memory.id}');
        }));
      }
    }
  }

  Future<void> _processQueue() async {
    // RACE CONDITION FIX: Double-check locking pattern with proper Lock
    if (_isProcessing || _isPausedForUnlock || _isReconciling) {
      return;
    }

    final memoryId = await _queueLock.synchronized(() {
      // Check again after acquiring lock
      if (_isProcessing || _syncQueue.isEmpty || _isPausedForUnlock || _isReconciling) {
        if (_syncQueue.isEmpty) {
          _ref.read(syncNotifierProvider.notifier).updateState(
              pendingJobs: 0,
              isSyncing: false,
              currentStatus: 'Idle',
              progress: null);
        }
        return null;
      }

      _isProcessing = true;
      final id = _syncQueue.first;

      _ref.read(syncNotifierProvider.notifier).updateState(
            isSyncing: true,
            pendingJobs: _syncQueue.length,
            currentStatus: 'Syncing memory...',
            progress: 0.0,
          );

      return id;
    });

    if (memoryId == null) return;

    await _updateLocalStatus(memoryId, 'syncing');

    try {
      final success = await _syncMemoryWithRetries(memoryId);

      // RACE CONDITION FIX: Safe removal from queue
      await _queueLock.synchronized(() {
        if (_syncQueue.isNotEmpty && _syncQueue.first == memoryId) {
          _syncQueue.removeAt(0);
        }
      });
      _isProcessing = false;

      // RACE CONDITION FIX: Safe access to queue length
      final queueLength = await _queueLock.synchronized(() => _syncQueue.length);

      if (success) {
        _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: queueLength,
            currentStatus: 'Sync complete!',
            progress: 1.0);
      } else {
        _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: queueLength,
            currentStatus: 'Sync failed. Will retry later.',
            progress: null);
      }

      await Future.delayed(const Duration(seconds: 1));
      unawaited(_processQueue());
    } on EncryptionLockedException {
      if (kDebugMode) {
        debugPrint('[SyncService] Queue processing paused. Waiting for unlock.');
      }
      _isProcessing = false;
      _isPausedForUnlock = true;
      _ref.read(syncNotifierProvider.notifier).updateState(
          isSyncing: true,
          currentStatus: 'Sync paused - unlock needed',
          progress: null);
    }
  }

  Future<void> _updateLocalStatus(int memoryId, String status) async {
    final repo = _ref.read(memoryRepositoryProvider);
    final memory = await repo?.getById(memoryId);
    if (memory != null) {
      final updatedMemory = memory.copyWith(syncStatus: status)..touch();
      await repo!.updateAfterSync(updatedMemory);
    }
  }

  Future<bool> _syncMemoryWithRetries(int memoryId,
      {int maxRetries = 3}) async {
    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null || repo == null) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      final initialMemoryState = await repo.getById(memoryId);
      if (initialMemoryState == null) {
        return true;
      }

      try {
        final notifier = _ref.read(syncNotifierProvider.notifier);

        notifier.updateState(
            currentStatus: 'Uploading thumbnails...', progress: 0.1);
        final newThumbUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.mediaThumbPaths,
            'thumbs');

        notifier.updateState(
            currentStatus: 'Uploading photos...', progress: 0.3);
        final newPhotoUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.mediaPaths,
            'photos');

        notifier.updateState(
            currentStatus: 'Uploading videos...', progress: 0.6);
        final newVideoUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.videoPaths,
            'videos');

        notifier.updateState(
            currentStatus: 'Uploading audio...', progress: 0.8);
        final newAudioUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.audioNotePaths,
            'audio');

        final memoryForCloud = _buildCloudReadyMemory(
          initialState: initialMemoryState,
          newPhotoUrls: newPhotoUrls,
          newThumbUrls: newThumbUrls,
          newVideoUrls: newVideoUrls,
          newAudioUrls: newAudioUrls,
        );

        notifier.updateState(
            currentStatus: 'Saving to cloud...', progress: 0.9);
        await firestore.setMemory(userId, memoryForCloud);

        await repo.updateAfterSync(memoryForCloud);

        return true;
      } catch (e, stackTrace) {
        if (e is EncryptionLockedException) {
          rethrow;
        }

        if (kDebugMode) {
          debugPrint(
              '[SyncService] Attempt $attempt failed for memory $memoryId: $e');
        }
        unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason:
                'SyncService: _syncMemoryWithRetries failed on attempt $attempt'));

        if (attempt < maxRetries) {
          final delay = Duration(seconds: 5 * attempt);
          _ref.read(syncNotifierProvider.notifier).updateState(
              currentStatus: 'Sync failed. Retrying in ${delay.inSeconds}s...');
          await Future.delayed(delay);
        }
      }
    }
    await _updateLocalStatus(memoryId, 'failed');
    return false;
  }

  Memory _buildCloudReadyMemory({
    required Memory initialState,
    required List<String> newPhotoUrls,
    required List<String> newThumbUrls,
    required List<String> newVideoUrls,
    required List<String> newAudioUrls,
  }) {
    final allPhotoUrls = {...initialState.mediaUrls, ...newPhotoUrls}.toList();
    final allThumbUrls =
        {...initialState.mediaThumbUrls, ...newThumbUrls}.toList();
    final allVideoUrls = {...initialState.videoUrls, ...newVideoUrls}.toList();
    final allAudioUrls = {...initialState.audioUrls, ...newAudioUrls}.toList();

    final allMediaKeys = allPhotoUrls.map(getFileKey).toSet().toList();
    final allVideoKeys = allVideoUrls.map(getFileKey).toSet().toList();
    final allAudioKeys = allAudioUrls.map(getFileKey).toSet().toList();

    return initialState.copyWith(
      mediaUrls: allPhotoUrls,
      mediaThumbUrls: allThumbUrls,
      videoUrls: allVideoUrls,
      audioUrls: allAudioUrls,
      mediaKeysOrder: allMediaKeys,
      videoKeysOrder: allVideoKeys,
      audioKeysOrder: allAudioKeys,
      mediaPaths: [],
      mediaThumbPaths: [],
      videoPaths: [],
      audioNotePaths: [],
      syncStatus: 'synced',
    )
      ..touch();
  }
}

