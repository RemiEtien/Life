import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../memory.dart';
import '../providers/application_providers.dart';
import 'package:path/path.dart' as p;

class FirestoreService {
  final Ref _ref;
  FirestoreService(this._ref);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// TRANSACTION RETRY LOGIC: Executes a Firestore transaction with exponential backoff
  /// Firestore transactions can fail due to write conflicts, network issues, etc.
  /// This method retries up to maxAttempts times with exponential backoff
  Future<T> _runTransactionWithRetry<T>(
    Future<T> Function(Transaction) transactionHandler, {
    int maxAttempts = 5,
    Duration initialDelay = const Duration(milliseconds: 100),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      attempt++;
      try {
        return await _db.runTransaction(transactionHandler);
      } catch (e) {
        final isRetryable = e is FirebaseException &&
            (e.code == 'aborted' ||
                e.code == 'unavailable' ||
                e.code == 'deadline-exceeded' ||
                e.code == 'resource-exhausted');

        if (attempt >= maxAttempts || !isRetryable) {
          if (kDebugMode) {
            debugPrint('[FirestoreService] Transaction failed after $attempt attempts: $e');
          }
          rethrow;
        }

        if (kDebugMode) {
          debugPrint('[FirestoreService] Transaction attempt $attempt failed: $e. Retrying in ${delay.inMilliseconds}ms...');
        }

        await Future.delayed(delay);
        // Exponential backoff: double the delay each time, max 10 seconds
        delay = Duration(milliseconds: (delay.inMilliseconds * 2).clamp(0, 10000));
      }
    }
  }

  /// Fetches all memories once from Firestore.
  /// Returns null on error and logs to Crashlytics.
  Future<List<Memory>?> fetchAllMemoriesOnce(String userId) async {
    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('memories')
          .orderBy('date', descending: true)
          .get();

      final memoriesFromCloud = snapshot.docs
          .map((doc) =>
              Memory.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      // **ИСПРАВЛЕННАЯ ЛОГИКА**: Теперь мы проверяем флаг `wasMigrated`, 
      // который устанавливается внутри конструктора Memory.fromFirestore.
      final memoriesToUpdateLocally =
          memoriesFromCloud.where((m) => m.wasMigrated).toList();

      if (memoriesToUpdateLocally.isNotEmpty) {
        // Получаем доступ к репозиторию через ref
        final repo = _ref.read(memoryRepositoryProvider);
        if (repo != null) {
          await repo.upsertMemories(memoriesToUpdateLocally);
          if (kDebugMode) {
            debugPrint(
                '[FirestoreService] Persisted ${memoriesToUpdateLocally.length} migrated memories back to local Isar DB.');
          }
        }
      }

      return memoriesFromCloud;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error fetching from Firestore: $e');
      }
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: 'Firestore: fetchAllMemoriesOnce failed'));
      return null;
    }
  }

  /// Sets or overwrites a memory document in Firestore using a transaction
  /// to prevent race conditions and resolve sync conflicts.
  /// The memory object is expected to be ALREADY encrypted if needed.
  Future<void> setMemory(String userId, Memory memory) async {
    if (memory.firestoreId == null) {
      throw Exception('Firestore ID is null, but it should have been generated before saving.');
    }
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('memories')
        .doc(memory.firestoreId);

    try {
      await _runTransactionWithRetry((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // Document doesn't exist, so we can safely create it.
          transaction.set(docRef, memory.toFirestore());
          if (kDebugMode) {
            debugPrint('[Sync Conflict] Remote doc ${memory.firestoreId} does not exist. Creating.');
          }
        } else {
          // Document exists, we must check timestamps to resolve conflict.
          final remoteData = snapshot.data();
          if (remoteData == null) {
            // Data is null, which is unexpected but we can treat it as non-existent.
            transaction.set(docRef, memory.toFirestore());
            return;
          }

          // --- ИСПРАВЛЕНИЕ: Добавлена проверка на null ---
          final remoteLastModified = (remoteData['lastModified'] as Timestamp?)?.toDate() ?? (remoteData['date'] as Timestamp).toDate();

          if (memory.lastModified.isAfter(remoteLastModified)) {
            // Local version is newer, so we overwrite the remote document.
            transaction.set(docRef, memory.toFirestore());
            if (kDebugMode) {
              debugPrint('[Sync Conflict] Local is newer for ${memory.firestoreId}. Overwriting remote.');
            }
          } else {
            // Remote version is newer or the same. Do nothing.
            // The outdated local version will be corrected on the next sync from cloud.
            if (kDebugMode) {
              debugPrint('[Sync Conflict] Remote is newer for ${memory.firestoreId}. Skipping upload.');
            }
          }
        }
      });
    } catch (e, stackTrace) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: setMemory transaction failed'));
      rethrow;
    }
  }


  /// Updates a memory document in Firestore using a transaction
  /// to prevent race conditions and resolve sync conflicts.
  /// The memory object is expected to be ALREADY encrypted if needed.
  Future<void> updateMemory(String userId, Memory memory) async {
    if (memory.firestoreId == null) return;
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('memories')
        .doc(memory.firestoreId);

    try {
      await _runTransactionWithRetry((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          // If we are trying to update a doc that doesn't exist, create it.
          transaction.set(docRef, memory.toFirestore());
           if (kDebugMode) {
            debugPrint('[Sync Conflict] Trying to update non-existent doc ${memory.firestoreId}. Creating instead.');
          }
        } else {
          final remoteData = snapshot.data();
           if (remoteData == null) {
            transaction.set(docRef, memory.toFirestore());
            return;
          }
          // --- ИСПРАВЛЕНИЕ: Добавлена проверка на null ---
          final remoteLastModified = (remoteData['lastModified'] as Timestamp?)?.toDate() ?? (remoteData['date'] as Timestamp).toDate();

          if (memory.lastModified.isAfter(remoteLastModified)) {
            // Local changes are newer, so apply the update.
            transaction.update(docRef, memory.toFirestore());
             if (kDebugMode) {
              debugPrint('[Sync Conflict] Local is newer for ${memory.firestoreId}. Updating remote.');
            }
          } else {
            // Remote is newer, discard local changes by doing nothing.
             if (kDebugMode) {
              debugPrint('[Sync Conflict] Remote is newer for ${memory.firestoreId}. Skipping update.');
            }
          }
        }
      });
    } catch (e, stackTrace) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: updateMemory transaction failed'));
      rethrow;
    }
  }

  Future<void> deleteMemory(String userId, Memory memory) async {
    try {
        final firestoreId = memory.firestoreId;
        if (firestoreId != null) {
        await _db
            .collection('users')
            .doc(userId)
            .collection('memories')
            .doc(firestoreId)
            .delete();
        await _deleteMemoryFilesFromStorage(userId, firestoreId, memory);
        }
    } catch(e, stackTrace) {
        unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: deleteMemory failed'));
        rethrow;
    }
  }

  /// Batch delete multiple memories at once using Firestore batched writes.
  /// This is more efficient than deleting one-by-one when deleting many memories.
  /// Firestore batch limit is 500 operations, so we chunk if needed.
  Future<void> batchDeleteMemories(String userId, List<Memory> memories) async {
    if (memories.isEmpty) return;

    try {
      const batchSize = 500; // Firestore batch write limit
      final memoriesWithFirestoreId = memories.where((m) => m.firestoreId != null).toList();

      // Process in chunks of 500
      for (int i = 0; i < memoriesWithFirestoreId.length; i += batchSize) {
        final chunk = memoriesWithFirestoreId.skip(i).take(batchSize).toList();
        final batch = _db.batch();

        for (final memory in chunk) {
          final docRef = _db
              .collection('users')
              .doc(userId)
              .collection('memories')
              .doc(memory.firestoreId!);
          batch.delete(docRef);
        }

        await batch.commit();

        if (kDebugMode) {
          debugPrint('[FirestoreService] Batch deleted ${chunk.length} memories from Firestore');
        }
      }

      // Delete associated files from storage
      for (final memory in memoriesWithFirestoreId) {
        await _deleteMemoryFilesFromStorage(userId, memory.firestoreId!, memory);
      }

      if (kDebugMode) {
        debugPrint('[FirestoreService] Completed batch delete of ${memoriesWithFirestoreId.length} memories');
      }
    } catch (e, stackTrace) {
      unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: batchDeleteMemories failed'));
      rethrow;
    }
  }

  Future<void> _deleteMemoryFilesFromStorage(
      String userId, String memoryId, Memory memory) async {
    final List<String> urlsToDelete = [
      ...memory.mediaUrls,
      ...memory.videoUrls,
      ...memory.audioUrls,
      ...memory.mediaThumbUrls, // ДОБАВЛЕНО: Удаление миниатюр
    ];

    for (final url in urlsToDelete) {
      if (url.contains('firebasestorage.googleapis.com')) {
        try {
          final ref = _storage.refFromURL(url);
          await ref.delete();
        } catch (e, stackTrace) {
          if (kDebugMode) {
            debugPrint('Could not delete file from Storage: $e');
          }
          // Log non-fatal error to Crashlytics, as the main memory doc might be deleted already
          unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'Storage: Failed to delete file at $url'));
        }
      }
    }
  }

  Future<List<String>> uploadFiles(
      String userId, String memoryId, List<String> paths, String type) async {
    final uploadedUrls = <String>[];
    for (final path in paths) {
      if (path.startsWith('http')) {
        uploadedUrls.add(path);
      } else {
        final file = File(path);
        if (await file.exists()) {
          try {
            final fileName =
                '${DateTime.now().millisecondsSinceEpoch}_${p.basename(path)}';
            final ref =
                _storage.ref('users/$userId/memories/$memoryId/$type/$fileName');

            // Upload with timeout and retry logic
            await ref.putFile(file).timeout(
              const Duration(seconds: 60),
              onTimeout: () {
                throw FirebaseException(
                  plugin: 'firebase_storage',
                  code: 'timeout',
                  message: 'Upload timeout exceeded for $type',
                );
              },
            );

            final url = await ref.getDownloadURL();
            uploadedUrls.add(url);
          } on FirebaseException catch(e, stackTrace) {
            if (kDebugMode) {
              debugPrint('Firebase Storage upload failed for $type: ${e.code} - ${e.message}');
            }
            unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Storage: uploadFiles failed for type $type'));
            rethrow;
          } catch(e, stackTrace) {
            if (kDebugMode) {
              debugPrint('Unknown error uploading $type: $e');
            }
            unawaited(FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Storage: uploadFiles unknown error for type $type'));
            rethrow;
          }
        }
      }
    }
    return uploadedUrls;
  }
}

