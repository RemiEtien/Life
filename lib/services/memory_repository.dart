import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/services/encryption_service.dart';
import 'package:lifeline/services/isar_service.dart';

class MemoryRepository {
  final String userId;
  final EncryptionService encryptionService;

  MemoryRepository({required this.userId, required this.encryptionService});

  Future<Isar> get _db async => IsarService.instance(userId);

  Memory _encryptMemoryIfNeeded(Memory m) {
    if (!m.isEncrypted) return m;

    return m.copyWith(
      content: encryptionService.encrypt(m.content),
      reflectionImpact: encryptionService.encrypt(m.reflectionImpact),
      reflectionLesson: encryptionService.encrypt(m.reflectionLesson),
      reflectionAutoThought: encryptionService.encrypt(m.reflectionAutoThought),
      reflectionEvidenceFor: encryptionService.encrypt(m.reflectionEvidenceFor),
      reflectionEvidenceAgainst:
          encryptionService.encrypt(m.reflectionEvidenceAgainst),
      reflectionReframe: encryptionService.encrypt(m.reflectionReframe),
      reflectionAction: encryptionService.encrypt(m.reflectionAction),
    );
  }

  Memory _decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    final memoryCopy = m.copyWith();

    return memoryCopy.copyWith(
      content: encryptionService.decrypt(m.content),
      reflectionImpact: encryptionService.decrypt(m.reflectionImpact),
      reflectionLesson: encryptionService.decrypt(m.reflectionLesson),
      reflectionAutoThought: encryptionService.decrypt(m.reflectionAutoThought),
      reflectionEvidenceFor: encryptionService.decrypt(m.reflectionEvidenceFor),
      reflectionEvidenceAgainst:
          encryptionService.decrypt(m.reflectionEvidenceAgainst),
      reflectionReframe: encryptionService.decrypt(m.reflectionReframe),
      reflectionAction: encryptionService.decrypt(m.reflectionAction),
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
      print("[DIAGNOSTIC] Subscribing to memories for userId: $userId");
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
      print(
          "[DIAGNOSTIC] Initial fetch for userId: $userId found ${initialResults.length} memories.");
    }

    yield* query.watch(fireImmediately: true).map((results) {
      if (kDebugMode) {
        print(
            "[DIAGNOSTIC] Stream update for userId: $userId delivered ${results.length} memories.");
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
        syncStatus: m.syncStatus == 'synced' ? 'pending' : m.syncStatus,
        lastModified: DateTime.now().toUtc());

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
