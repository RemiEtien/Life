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
  
  // Encrypts fields of a memory object if it's marked as encrypted
  // and the fields are not already in encrypted format.
  Memory _encryptMemoryIfNeeded(Memory m) {
    if (!m.isEncrypted) return m;

    // A simple helper to avoid encrypting already encrypted data
    bool isEncrypted(String? val) => encryptionService.isValueEncrypted(val);

    m.content = isEncrypted(m.content) ? m.content : encryptionService.encrypt(m.content);
    m.reflectionImpact = isEncrypted(m.reflectionImpact) ? m.reflectionImpact : encryptionService.encrypt(m.reflectionImpact);
    m.reflectionLesson = isEncrypted(m.reflectionLesson) ? m.reflectionLesson : encryptionService.encrypt(m.reflectionLesson);
    m.reflectionAutoThought = isEncrypted(m.reflectionAutoThought) ? m.reflectionAutoThought : encryptionService.encrypt(m.reflectionAutoThought);
    m.reflectionEvidenceFor = isEncrypted(m.reflectionEvidenceFor) ? m.reflectionEvidenceFor : encryptionService.encrypt(m.reflectionEvidenceFor);
    m.reflectionEvidenceAgainst = isEncrypted(m.reflectionEvidenceAgainst) ? m.reflectionEvidenceAgainst : encryptionService.encrypt(m.reflectionEvidenceAgainst);
    m.reflectionReframe = isEncrypted(m.reflectionReframe) ? m.reflectionReframe : encryptionService.encrypt(m.reflectionReframe);
    m.reflectionAction = isEncrypted(m.reflectionAction) ? m.reflectionAction : encryptionService.encrypt(m.reflectionAction);

    return m;
  }

  // Decrypts fields of a memory object if it's marked as encrypted.
  Memory _decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    m.content = encryptionService.decrypt(m.content);
    m.reflectionImpact = encryptionService.decrypt(m.reflectionImpact);
    m.reflectionLesson = encryptionService.decrypt(m.reflectionLesson);
    m.reflectionAutoThought = encryptionService.decrypt(m.reflectionAutoThought);
    m.reflectionEvidenceFor = encryptionService.decrypt(m.reflectionEvidenceFor);
    m.reflectionEvidenceAgainst = encryptionService.decrypt(m.reflectionEvidenceAgainst);
    m.reflectionReframe = encryptionService.decrypt(m.reflectionReframe);
    m.reflectionAction = encryptionService.decrypt(m.reflectionAction);
    
    return m;
  }

  /// Creates a new memory, ready for cloud sync.
  Future<int> create(Memory m) async {
    final isar = await _db;
    m.userId = userId;
    m.syncStatus = 'pending';
    m.touch();

    // Generate Firestore ID if it doesn't exist
    m.firestoreId ??= FirebaseFirestore.instance.collection('users').doc(userId).collection('memories').doc().id;
    
    final memoryToSave = _encryptMemoryIfNeeded(m);
    
    return isar.writeTxn(() => isar.memorys.put(memoryToSave));
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

  /// [MODIFIED] Updates a memory. If it's a synced memory, marks it for re-sync.
  /// If it's a draft, it remains a draft. This is for USER EDITS.
  Future<bool> update(Memory m) async {
    final isar = await _db;
    m.userId = userId;
    
    // Only mark a fully synced memory as 'pending' on user change.
    // Drafts remain drafts until explicitly saved.
    if (m.syncStatus == 'synced') {
        m.syncStatus = 'pending';
    }
    m.touch();
    
    final memoryToSave = _encryptMemoryIfNeeded(m);

    return isar.writeTxn(() async {
      await isar.memorys.put(memoryToSave);
      return true;
    });
  }

  /// [NEW] Specifically for the SyncService to update status without triggering re-sync logic.
  Future<void> updateAfterSync(Memory m) async {
    final isar = await _db;
    m.touch(); // Update last modified time
    // NO other logic, just save the object as is.
    await isar.writeTxn(() => isar.memorys.put(m));
  }
  
  Future<bool> delete(int id) async {
    final isar = await _db;
    return isar.writeTxn(() => isar.memorys.delete(id));
  }
}

