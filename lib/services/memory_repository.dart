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

  Memory _encryptMemoryIfNeeded(Memory m) {
    if (!m.isEncrypted) return m;

    final memoryCopy = m.copyWith();

    bool isEncrypted(String? val) => encryptionService.isValueEncrypted(val);

    return memoryCopy.copyWith(
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

  Memory _decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;
    
    final memoryCopy = m.copyWith();

    return memoryCopy.copyWith(
      content: encryptionService.decrypt(m.content),
      reflectionImpact: encryptionService.decrypt(m.reflectionImpact),
      reflectionLesson: encryptionService.decrypt(m.reflectionLesson),
      reflectionAutoThought: encryptionService.decrypt(m.reflectionAutoThought),
      reflectionEvidenceFor: encryptionService.decrypt(m.reflectionEvidenceFor),
      reflectionEvidenceAgainst: encryptionService.decrypt(m.reflectionEvidenceAgainst),
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
      firestoreId: m.firestoreId ?? FirebaseFirestore.instance.collection('users').doc(userId).collection('memories').doc().id
    );
    
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
    
    draft.firestoreId = FirebaseFirestore.instance.collection('users').doc(userId).collection('memories').doc().id;

    await isar.writeTxn(() => isar.memorys.put(draft));
    return draft;
  }

  Future<Memory?> findDraft() async {
    final isar = await _db;
    return isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .syncStatusEqualTo('draft')
      .sortByLastModifiedDesc()
      .findFirst();
  }

  /// **УСТАРЕВШИЙ МЕТОД:** Больше не используется, заменен на 'upsertMemories'
  // Future<void> replaceAll(List<Memory> memories) async {
  //   final isar = await _db;
  //   await isar.writeTxn(() async {
  //     await isar.memorys.where().filter().userIdEqualTo(userId).deleteAll();
  //     for (var m in memories) {
  //       m.userId = userId;
  //     }
  //     await isar.memorys.putAll(memories);
  //   });
  // }
  
  /// **НОВЫЙ МЕТОД:** Вставляет или обновляет список воспоминаний.
  /// Благодаря уникальному индексу `firestoreId` в модели `Memory`,
  /// `putAll` будет автоматически обновлять записи, если они уже существуют.
  Future<void> upsertMemories(List<Memory> memories) async {
    final isar = await _db;
    await isar.writeTxn(() async {
      await isar.memorys.putAll(memories);
    });
  }

  /// **НОВЫЙ МЕТОД:** Получает локальные воспоминания в виде карты для быстрого поиска по firestoreId.
  Future<Map<String, Memory>> getMemoriesMapByFirestoreId() async {
    final isar = await _db;
    final memories = await isar.memorys.where().filter().userIdEqualTo(userId).findAll();
    return { for (var m in memories) if (m.firestoreId != null) m.firestoreId! : m };
  }


  Stream<List<Memory>> watchAllSortedByDate() async* {
    final isar = await _db;
    yield* isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .not()
      .syncStatusEqualTo('draft') 
      .sortByDateDesc()
      .watch(fireImmediately: true);
  }

  Future<List<Memory>> getMemoriesToSync() async {
    final isar = await _db;
    return isar.memorys.where()
      .filter()
      .userIdEqualTo(userId)
      .group((q) => q.syncStatusEqualTo('pending').or().syncStatusEqualTo('failed'))
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

  /// **ИСПРАВЛЕНО:** Метод теперь возвращает обновленный объект Memory.
  Future<Memory?> update(Memory m) async {
    final isar = await _db;
    
    final memoryToSave = m.copyWith(
      userId: userId,
      syncStatus: m.syncStatus == 'synced' ? 'pending' : m.syncStatus,
      lastModified: DateTime.now().toUtc()
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
