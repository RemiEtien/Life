import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:isar/isar.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/services/encryption_service.dart';
import 'package:lifeline/services/isar_service.dart';

class MemoryRepository {
  final String userId;
  final EncryptionService encryptionService;

  MemoryRepository({required this.userId, required this.encryptionService});

  Future<Isar> get _db async => IsarService.instance(userId);

  /// РЕАЛИЗАЦИЯ ПРИНЦИПА 1: Метод теперь возвращает новую, зашифрованную копию, не изменяя оригинал.
  Memory _encryptMemoryIfNeeded(Memory m) {
    if (!m.isEncrypted) return m;

    bool isEncrypted(String? val) => encryptionService.isValueEncrypted(val);
    // Используем copyWith для создания нового объекта с зашифрованными полями
    return m.copyWith(
      content: isEncrypted(m.content) ? m.content : encryptionService.encrypt(m.content),
      reflectionImpact: isEncrypted(m.reflectionImpact) ? m.reflectionImpact : encryptionService.encrypt(m.reflectionImpact),
      reflectionLesson: isEncrypted(m.reflectionLesson) ? m.reflectionLesson : encryptionService.encrypt(m.reflectionLesson),
      reflectionAutoThought: isEncrypted(m.reflectionAutoThought) ? m.reflectionAutoThought : encryptionService.encrypt(m.reflectionAutoThought),
      reflectionEvidenceFor: isEncrypted(m.reflectionEvidenceFor) ? m.reflectionEvidenceFor : encryptionService.encrypt(m.reflectionEvidenceFor),
      reflectionEvidenceAgainst: isEncrypted(m.reflectionEvidenceAgainst) ? m.reflectionEvidenceAgainst : encryptionService.encrypt(m.reflectionEvidenceAgainst),
      reflectionReframe: isEncrypted(m.reflectionReframe) ? m.reflectionReframe : encryptionService.encrypt(m.reflectionReframe),
      reflectionAction: isEncrypted(m.reflectionAction) ? m.reflectionAction : encryptionService.encrypt(m.reflectionAction),
    );
  }

  // РЕАЛИЗАЦИЯ ПРИНЦИПА 1: Метод возвращает новую, расшифрованную копию.
  Memory _decryptMemory(Memory m) {
    return encryptionService.decryptMemory(m);
  }

  /// Creates a new memory, ready for cloud sync.
  Future<int> create(Memory m) async {
    final isar = await _db;
    final memoryToSave = m.copyWith(
      userId: userId,
      syncStatus: 'pending',
      lastModified: DateTime.now().toUtc(),
      // Generate Firestore ID if it doesn't exist
      firestoreId: m.firestoreId ?? FirebaseFirestore.instance.collection('users').doc(userId).collection('memories').doc().id,
    );
    
    final encryptedMemory = _encryptMemoryIfNeeded(memoryToSave);
    
    return isar.writeTxn(() => isar.memorys.put(encryptedMemory));
  }

  /// [NEW] Creates a local draft of a memory that is not yet ready for syncing.
  Future<Memory> createDraft() async {
    final isar = await _db;
    final draft = Memory()
      ..userId = userId
      ..syncStatus = 'draft' // New status for drafts
      ..title = ''
      ..date = DateTime.now();
    draft.touch();
    
    // Generate Firestore ID upfront so it's consistent during saves
    draft.firestoreId = FirebaseFirestore.instance.collection('users').doc(userId).collection('memories').doc().id;

    await isar.writeTxn(() => isar.memorys.put(draft));
    return draft;
  }

  /// [NEW] Finds the most recent unsaved draft for the current user.
  Future<Memory?> findDraft() async {
    final isar = await _db;
    return isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .syncStatusEqualTo('draft')
      .sortByLastModifiedDesc()
      .findFirst();
  }
  
  /// [NEW for Principle 4] Fetches all memories for a user as a map for efficient merging.
  Future<Map<String, Memory>> getMemoriesMap() async {
    final isar = await _db;
    final allMemories = await isar.memorys.where().filter().userIdEqualTo(userId).findAll();
    return { for (var m in allMemories) if (m.firestoreId != null) m.firestoreId! : m };
  }

  /// [NEW for Principle 4] Batch inserts or updates memories.
  Future<void> upsertMemories(List<Memory> memories) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.memorys.putAll(memories);
    });
  }

  /// [DEPRECATED in favor of merge logic]
  Future<void> replaceAll(List<Memory> memories) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.memorys.where().filter().userIdEqualTo(userId).deleteAll();
      for (var m in memories) {
        m.userId = userId;
      }
      await isar.memorys.putAll(memories);
    });
  }

  Stream<List<Memory>> watchAllSortedByDate() async* {
    final isar = await _db;
    yield* isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .not()
      .syncStatusEqualTo('draft') // Don't show drafts on timeline
      .sortByDateDesc()
      .watch(fireImmediately: true);
  }

  // Returns raw (potentially encrypted) memories for sync.
  Future<List<Memory>> getMemoriesToSync() async {
    final isar = await _db;
    return isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .group((q) => q.syncStatusEqualTo('pending').or().syncStatusEqualTo('failed'))
      .findAll();
  }
  
  // Gets a single memory by ID and returns it raw (potentially encrypted).
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

  /// [REFACTORED with Principle 1] Updates a memory. If it's a synced memory, marks it for re-sync.
  Future<bool> update(Memory m) async {
    final isar = await _db;
    final status = (m.syncStatus == 'synced') ? 'pending' : m.syncStatus;

    final memoryToSave = m.copyWith(
      userId: userId,
      syncStatus: status,
      lastModified: DateTime.now().toUtc(),
    );

    final encryptedMemory = _encryptMemoryIfNeeded(memoryToSave);

    return isar.writeTxn(() async {
      await isar.memorys.put(encryptedMemory);
      return true;
    });
  }

  /// [NEW] Specifically for the SyncService to update status without triggering re-sync logic.
  Future<void> updateAfterSync(Memory m) async {
    final isar = await _db;
    final finalMemory = m.copyWith(lastModified: DateTime.now().toUtc());
    await isar.writeTxn(() => isar.memorys.put(finalMemory));
  }
  
  Future<bool> delete(int id) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.memorys.delete(id));
  }
}
