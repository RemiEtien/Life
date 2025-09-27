import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:path/path.dart' as p;

class FirestoreService {
  final Ref _ref;
  FirestoreService(this._ref);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
            print(
                "[FirestoreService] Persisted ${memoriesToUpdateLocally.length} migrated memories back to local Isar DB.");
          }
        }
      }

      return memoriesFromCloud;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error fetching from Firestore: $e");
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace,
          reason: "Firestore: fetchAllMemoriesOnce failed");
      return null;
    }
  }

  /// Sets or overwrites a memory document in Firestore using a transaction
  /// to prevent race conditions and resolve sync conflicts.
  Future<void> setMemory(String userId, Memory memory) async {
    if (memory.firestoreId == null) {
      throw Exception("Firestore ID is null, but it should have been generated before saving.");
    }
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('memories')
        .doc(memory.firestoreId);

    try {
      // ИСПРАВЛЕНИЕ: Возвращаем транзакционную логику
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final dataForFirestore = memory.toFirestore();
        dataForFirestore['lastModified'] = FieldValue.serverTimestamp();

        if (!snapshot.exists) {
          transaction.set(docRef, dataForFirestore);
        } else {
          final remoteData = snapshot.data();
          if (remoteData != null) {
            final remoteLastModified = (remoteData['lastModified'] as Timestamp?)?.toDate();
            // Записываем, только если локальные данные новее или на сервере нет временной метки
            if (remoteLastModified == null || memory.lastModified.isAfter(remoteLastModified)) {
              transaction.set(docRef, dataForFirestore);
            }
          } else {
             transaction.set(docRef, dataForFirestore);
          }
        }
      });
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: setMemory transaction failed');
      rethrow;
    }
  }


  /// Updates a memory document in Firestore using a transaction
  /// to prevent race conditions and resolve sync conflicts.
  Future<void> updateMemory(String userId, Memory memory) async {
    if (memory.firestoreId == null) return;
    final docRef = _db
        .collection('users')
        .doc(userId)
        .collection('memories')
        .doc(memory.firestoreId);

    try {
      // ИСПРАВЛЕНИЕ: Возвращаем транзакционную логику
      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        final dataForFirestore = memory.toFirestore();
        dataForFirestore['lastModified'] = FieldValue.serverTimestamp();

        if (snapshot.exists) {
            final remoteData = snapshot.data();
            if (remoteData != null) {
                 final remoteLastModified = (remoteData['lastModified'] as Timestamp?)?.toDate();
                 if (remoteLastModified == null || memory.lastModified.isAfter(remoteLastModified)) {
                    transaction.update(docRef, dataForFirestore);
                 }
            } else {
                // Если документ существует, но пустой, можно его просто обновить
                transaction.update(docRef, dataForFirestore);
            }
        } else {
            // Если документа нет, создаем его
            transaction.set(docRef, dataForFirestore);
        }
      });
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: updateMemory transaction failed');
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
        FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Firestore: deleteMemory failed');
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
            print("Could not delete file from Storage: $e");
          }
          // Log non-fatal error to Crashlytics, as the main memory doc might be deleted already
          FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: "Storage: Failed to delete file at $url");
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
            await ref.putFile(file);
            final url = await ref.getDownloadURL();
            uploadedUrls.add(url);
          } catch(e, stackTrace) {
             FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'Storage: uploadFiles failed for type $type');
             rethrow;
          }
        }
      }
    }
    return uploadedUrls;
  }
}

