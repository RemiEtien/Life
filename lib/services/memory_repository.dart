import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../memory.dart';
import 'encryption_service.dart';
import 'isar_service.dart';

class MemoryRepository {
  final String userId;
  final EncryptionService encryptionService;

  MemoryRepository({required this.userId, required this.encryptionService});

  Future<Isar> get _db async => IsarService.instance(userId);

  Memory _encryptMemoryIfNeeded(Memory m) {
    // CRITICAL FIX: If memory is NOT encrypted, return as is (no encryption needed)
    // If memory IS encrypted, check if fields are already encrypted to avoid double encryption
    if (!m.isEncrypted) return m;

    // Check if ANY field is already encrypted (starts with gcm_v1: prefix)
    // This prevents data loss when content is null but reflections are encrypted
    final isAlreadyEncrypted = (m.content != null &&
            encryptionService.isValueEncrypted(m.content!)) ||
        (m.reflectionImpact != null &&
            encryptionService.isValueEncrypted(m.reflectionImpact!)) ||
        (m.reflectionLesson != null &&
            encryptionService.isValueEncrypted(m.reflectionLesson!)) ||
        (m.reflectionAutoThought != null &&
            encryptionService.isValueEncrypted(m.reflectionAutoThought!));

    if (isAlreadyEncrypted) {
      // Fields are already encrypted, return as is to avoid double encryption
      return m;
    }

    // Pass the memory's local ID to the encryption service
    final memoryId = m.id;

    // Encrypt plaintext fields
    return m.copyWith(
      content: encryptionService.encrypt(m.content, memoryId: memoryId),
      reflectionImpact: encryptionService.encrypt(m.reflectionImpact, memoryId: memoryId),
      reflectionLesson: encryptionService.encrypt(m.reflectionLesson, memoryId: memoryId),
      reflectionAutoThought: encryptionService.encrypt(m.reflectionAutoThought, memoryId: memoryId),
      reflectionEvidenceFor: encryptionService.encrypt(m.reflectionEvidenceFor, memoryId: memoryId),
      reflectionEvidenceAgainst:
          encryptionService.encrypt(m.reflectionEvidenceAgainst, memoryId: memoryId),
      reflectionReframe: encryptionService.encrypt(m.reflectionReframe, memoryId: memoryId),
      reflectionAction: encryptionService.encrypt(m.reflectionAction, memoryId: memoryId),
    );
  }

  Memory _decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    final memoryCopy = m.copyWith();

    return memoryCopy.copyWith(
      content: encryptionService.decrypt(m.content, memoryId: m.id),
      reflectionImpact: encryptionService.decrypt(m.reflectionImpact, memoryId: m.id),
      reflectionLesson: encryptionService.decrypt(m.reflectionLesson, memoryId: m.id),
      reflectionAutoThought: encryptionService.decrypt(m.reflectionAutoThought, memoryId: m.id),
      reflectionEvidenceFor: encryptionService.decrypt(m.reflectionEvidenceFor, memoryId: m.id),
      reflectionEvidenceAgainst:
          encryptionService.decrypt(m.reflectionEvidenceAgainst, memoryId: m.id),
      reflectionReframe: encryptionService.decrypt(m.reflectionReframe, memoryId: m.id),
      reflectionAction: encryptionService.decrypt(m.reflectionAction, memoryId: m.id),
    );
  }

  Future<int> create(Memory m) async {
    final isar = await _db;
    final memoryToSave = m.copyWith(
        userId: userId,
        syncStatus: 'pending',
        lastModified: DateTime.now().toUtc(),
        firestoreId: m.firestoreId ??
            FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('memories')
                .doc()
                .id);

    final encryptedMemory = _encryptMemoryIfNeeded(memoryToSave);

    return isar.writeTxn(() => isar.memorys.put(encryptedMemory));
  }

  Future<Memory> createDraft() async {
    final isar = await _db;
    final draft = Memory()
      ..userId = userId
      ..syncStatus = 'draft'
      ..title = ''
      ..date = DateTime.now();
    draft.touch();

    draft.firestoreId = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('memories')
        .doc()
        .id;

    await isar.writeTxn(() => isar.memorys.put(draft));
    return draft;
  }

  Future<Memory?> findDraft() async {
    final isar = await _db;
    return isar.memorys
        .where()
        .filter()
        .userIdEqualTo(userId)
        .syncStatusEqualTo('draft')
        .sortByLastModifiedDesc()
        .findFirst();
  }

  /// Watch all drafts sorted by last modified date (most recent first)
  /// Returns a stream of all draft memories for the current user
  Stream<List<Memory>> watchAllDrafts() async* {
    final isar = await _db;
    yield* isar.memorys
        .where()
        .filter()
        .userIdEqualTo(userId)
        .syncStatusEqualTo('draft')
        .sortByLastModifiedDesc()
        .watch(fireImmediately: true);
  }

  Future<void> upsertMemories(List<Memory> memories) async {
    if (memories.isEmpty) return;

    final normalized = memories.map((memory) {
      final owner = memory.userId;
      final needsNormalization = owner == null || owner.isEmpty;
      return needsNormalization ? memory.copyWith(userId: userId) : memory;
    }).toList();

    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.memorys.putAll(normalized);
    });
  }

  Future<int> repairOrphanedUserIds() async {
    final isar = await _db;
    final orphaned = await isar.memorys.filter().userIdIsNull().findAll();
    final withoutOwner =
        await isar.memorys.filter().userIdEqualTo('').findAll();

    final combined = <Memory>[
      ...orphaned,
      ...withoutOwner,
    ];

    if (combined.isEmpty) {
      return 0;
    }

    final deduped = <Id, Memory>{
      for (final memory in combined) memory.id: memory
    };

    for (final memory in deduped.values) {
      memory.userId = userId;
    }

    final toPersist = deduped.values.toList();

    await isar.writeTxn(() async {
      await isar.memorys.putAll(toPersist);
    });

    return toPersist.length;
  }

  Future<Map<String, Memory>> getMemoriesMapByFirestoreId() async {
    final isar = await _db;
    final memories = await isar.memorys.where().userIdEqualTo(userId).findAll();
    return {
      for (var m in memories)
        if (m.firestoreId != null) m.firestoreId!: m
    };
  }
  
  // НОВЫЙ МЕТОД: Получает все воспоминания пользователя одним запросом.
  Future<List<Memory>> getAllMemories() async {
    final isar = await _db;
    return isar.memorys.where().userIdEqualTo(userId).findAll();
  }

  // НОВЫЙ МЕТОД: Удаляет список воспоминаний по их локальным ID Isar.
  Future<int> deleteAllByIds(List<int> ids) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.memorys.deleteAll(ids));
  }


  Stream<List<Memory>> watchAllSortedByDate() async* {
    if (kDebugMode) {
      debugPrint('[DIAGNOSTIC] Subscribing to memories for userId: $userId');
    }
    final isar = await _db;

    final query = isar.memorys
        .where()
        .userIdEqualTo(userId) 
        .filter()
        .not()
        .syncStatusEqualTo('draft') 
        .sortByDateDesc();

    if (kDebugMode) {
      final initialResults = await query.findAll();
      debugPrint(
          '[DIAGNOSTIC] Initial fetch for userId: $userId found ${initialResults.length} memories.');
    }

    yield* query.watch(fireImmediately: true).map((results) {
      if (kDebugMode) {
        debugPrint(
            '[DIAGNOSTIC] Stream update for userId: $userId delivered ${results.length} memories.');
      }
      return results;
    });
  }

  Future<List<Memory>> getMemoriesToSync() async {
    final isar = await _db;
    return isar.memorys
        .where()
        .filter()
        .userIdEqualTo(userId)
        .group((q) =>
            q.syncStatusEqualTo('pending').or().syncStatusEqualTo('failed'))
        .findAll();
  }

  Future<Memory?> getById(int id) async {
    final isar = await _db;
    return await isar.memorys.get(id);
  }

  Future<Memory?> getDecryptedById(int id) async {
    final isar = await _db;
    final memory = await isar.memorys.get(id);
    if (memory == null) return null;
    return _decryptMemory(memory);
  }

  Future<Memory?> update(Memory m) async {
    final isar = await _db;

    final memoryToSave = m.copyWith(
      userId: userId,
      lastModified: DateTime.now().toUtc(),
    );

    final encryptedMemory = _encryptMemoryIfNeeded(memoryToSave);

    await isar.writeTxn(() async {
      await isar.memorys.put(encryptedMemory);
    });

    return encryptedMemory;
  }

  Future<void> updateAfterSync(Memory m) async {
    final isar = await _db;
    final memoryToSave = m.copyWith(lastModified: DateTime.now().toUtc());
    await isar.writeTxn(() => isar.memorys.put(memoryToSave));
  }

  Future<bool> delete(int id) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.memorys.delete(id));
  }
}

