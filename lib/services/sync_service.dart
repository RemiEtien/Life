import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/services/encryption_service.dart';

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
  // НОВОЕ: Флаг для отслеживания паузы из-за шифрования
  bool _isPausedForUnlock = false;

  SyncService(this._ref) {
    _checkForUnsyncedMemories();
  }

  Future<void> syncFromCloudToLocal({bool isInitialSync = false}) async {
    final notifier = _ref.read(syncNotifierProvider.notifier);
    if (!isInitialSync && _ref.read(syncNotifierProvider).isSyncing) return;

    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null) return;

    if (!isInitialSync) {
      notifier.updateState(
          isSyncing: true, currentStatus: "Fetching from cloud...");
    }

    try {
      final cloudMemories = await firestore.fetchAllMemoriesOnce(userId);
      // **КЛЮЧЕВОЕ ИЗМЕНЕНИЕ №2: Получаем локальные данные в виде карты для сопоставления**
      final localMemoriesMap = await repo!.getMemoriesMapByFirestoreId();

      if (cloudMemories != null) {
        if (!isInitialSync) {
          notifier.updateState(currentStatus: "Merging with local data...");
        }

        final memoriesToUpsert = <Memory>[];
        for (final cloudMemory in cloudMemories) {
          final localMemory = localMemoriesMap[cloudMemory.firestoreId];

          // **КЛЮЧЕВОЕ ИЗМЕНЕНИЕ №3: Логика слияния**
          if (localMemory == null) {
            // Если локальной записи нет - это новая запись с другого устройства, добавляем ее.
            memoriesToUpsert.add(cloudMemory);
          } else if (cloudMemory.lastModified
                  .isAfter(localMemory.lastModified) &&
              localMemory.syncStatus != 'pending') {
            // Если облачная запись новее и локальная не ожидает синхронизации, обновляем локальную.
            // **КРИТИЧЕСКИ ВАЖНО: Сохраняем локальный ID!**
            // Это говорит Isar, какую именно запись нужно обновить.
            cloudMemory.id = localMemory.id;
            memoriesToUpsert.add(cloudMemory);
          }
        }

        if (memoriesToUpsert.isNotEmpty) {
          // **КЛЮЧЕВОЕ ИЗМЕНЕНИЕ №4: Используем новый метод `upsert`**
          await repo.upsertMemories(memoriesToUpsert);
        }
      }
      if (!isInitialSync) {
        notifier.updateState(isSyncing: false, currentStatus: "Sync complete!");
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: "SyncService: syncFromCloudToLocal failed");
      if (!isInitialSync) {
        notifier.updateState(
            isSyncing: false, currentStatus: "Sync from cloud failed.");
      } else {
        rethrow;
      }
    } finally {
      if (!isInitialSync) {
        _checkForUnsyncedMemories();
      }
    }
  }

  // НОВЫЙ МЕТОД: Возобновляет очередь после разблокировки шифрования
  void resumeSync() {
    if (_isPausedForUnlock && !_isProcessing && _syncQueue.isNotEmpty) {
      if (kDebugMode) {
        print("[SyncService] Resuming sync queue processing after unlock.");
      }
      _isPausedForUnlock = false;
      _processQueue();
    }
  }

  void queueSync(int memoryId) {
    if (!_syncQueue.contains(memoryId)) {
      _syncQueue.add(memoryId);
      _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Queued...",
          );
      // ИЗМЕНЕНИЕ: Оборачиваем вызов в Future(), чтобы дать UI время
      // отреагировать на локальное сохранение до начала синхронизации.
      // Это гарантирует мгновенное появление узла на линии жизни.
      Future(_processQueue);
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
    if (_isProcessing || _syncQueue.isEmpty || _isPausedForUnlock) {
      if (_syncQueue.isEmpty) {
        _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: 0,
            isSyncing: false,
            currentStatus: "Idle",
            progress: null);
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

    // ИЗМЕНЕНО: Обработка исключения EncryptionLockedException
    try {
      final success = await _syncMemoryWithRetries(memoryId);

      _syncQueue.removeAt(0);
      _isProcessing = false;

      if (success) {
        _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Sync complete!",
            progress: 1.0);
      } else {
        _ref.read(syncNotifierProvider.notifier).updateState(
            pendingJobs: _syncQueue.length,
            currentStatus: "Sync failed. Will retry later.",
            progress: null);
      }

      await Future.delayed(const Duration(seconds: 1));
      _processQueue();
    } on EncryptionLockedException {
      if (kDebugMode) {
        print("[SyncService] Queue processing paused. Waiting for unlock.");
      }
      // Пауза обработки очереди
      _isProcessing = false;
      _isPausedForUnlock = true;
      _ref.read(syncNotifierProvider.notifier).updateState(
          isSyncing: true, // Keep showing sync indicator
          currentStatus: "Sync paused - unlock needed",
          progress: null);
      // Не вызываем _processQueue() снова, ждем resumeSync()
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

  Future<bool> _syncMemoryWithRetries(int memoryId, {int maxRetries = 3}) async {
    final repo = _ref.read(memoryRepositoryProvider);
    final firestore = _ref.read(firestoreServiceProvider);
    final userId = repo?.userId;

    if (userId == null || repo == null) return false;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      // ИЗМЕНЕНО: getDecryptedById теперь может выбросить исключение,
      // которое будет поймано в _processQueue
      final initialMemoryState = await repo.getDecryptedById(memoryId);
      if (initialMemoryState == null) {
        return true;
      }

      try {
        final notifier = _ref.read(syncNotifierProvider.notifier);

        notifier.updateState(
            currentStatus: "Uploading thumbnails...", progress: 0.1);
        final newThumbUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.mediaThumbPaths,
            'thumbs');

        notifier.updateState(
            currentStatus: "Uploading photos...", progress: 0.3);
        final newPhotoUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.mediaPaths,
            'photos');

        notifier.updateState(
            currentStatus: "Uploading videos...", progress: 0.6);
        final newVideoUrls = await firestore.uploadFiles(
            userId,
            initialMemoryState.universalId,
            initialMemoryState.videoPaths,
            'videos');

        notifier.updateState(
            currentStatus: "Uploading audio...", progress: 0.8);
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
            currentStatus: "Saving to cloud...", progress: 0.9);
        await firestore.setMemory(userId, memoryForCloud);

        await repo.updateAfterSync(memoryForCloud);

        return true;
      } catch (e, stackTrace) {
        if (kDebugMode) {
          print(
              "[SyncService] Attempt $attempt failed for memory $memoryId: $e");
        }
        FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason:
                'SyncService: _syncMemoryWithRetries failed on attempt $attempt');

        if (attempt < maxRetries) {
          final delay = Duration(seconds: 5 * attempt);
          _ref.read(syncNotifierProvider.notifier).updateState(
              currentStatus:
                  "Sync failed. Retrying in ${delay.inSeconds}s...");
          await Future.delayed(delay);
        }
      }
    }
    await _updateLocalStatus(memoryId, 'failed');
    return false;
  }

  /// **ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ:** Эта функция теперь безопасно объединяет списки URL,
  /// предотвращая потерю данных.
  Memory _buildCloudReadyMemory({
    required Memory initialState,
    required List<String> newPhotoUrls,
    required List<String> newThumbUrls,
    required List<String> newVideoUrls,
    required List<String> newAudioUrls,
  }) {
    // Используем Set для автоматического объединения и удаления дубликатов
    final allPhotoUrls = {...initialState.mediaUrls, ...newPhotoUrls}.toList();
    final allThumbUrls =
        {...initialState.mediaThumbUrls, ...newThumbUrls}.toList();
    final allVideoUrls = {...initialState.videoUrls, ...newVideoUrls}.toList();
    final allAudioUrls = {...initialState.audioUrls, ...newAudioUrls}.toList();

    // Генерируем ключи из ОБЪЕДИНЕННЫХ списков URL
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
      // Очищаем локальные пути, так как они теперь загружены
      mediaPaths: [],
      mediaThumbPaths: [],
      videoPaths: [],
      audioNotePaths: [],
      syncStatus: 'synced',
    )..touch();
  }
}

