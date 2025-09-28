import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
import 'dart:io';
import 'package:flutter/foundation.dart';

part 'memory.g.dart';

// ---------------------------------------------------------------------------
// ВАЖНО: После изменения этого файла запустите команду в терминале:
// flutter pub run build_runner build --delete-conflicting-outputs
// ---------------------------------------------------------------------------

/// **ИСПРАВЛЕНО:** Надежно извлекает базовый ключ файла из любого типа пути.
String getFileKey(String path) {
  try {
    // Эта функция обрабатывает полные URL-адреса, URL-кодированные пути и локальные пути.
    final decodedPath = Uri.decodeComponent(path);
    // Получает последнюю часть после последнего '/'
    final lastSegment = decodedPath.split('/').last;
    // Имя файла - это часть до любых параметров запроса.
    final fileName = lastSegment.split('?').first;
    // Удаляет возможные временные метки, используемые при локальной обработке.
    final withoutTimestamp = fileName.replaceAll(RegExp(r'^\d{13}_'), '');
    // Нормализует имена миниатюр до их базового имени для консистентности ключей.
    return withoutTimestamp
        .replaceAll('_thumb.webp', '.webp')
        .replaceAll('thumb_', '');
  } catch (e) {
    // Запасной вариант для любых неожиданных форматов.
    return path.split('/').last.split('?').first;
  }
}

@collection
class Memory {
  Id id = Isar.autoIncrement;

  /// **КЛЮЧЕВОЕ ИЗМЕНЕНИЕ №1: Уникальный индекс для firestoreId**
  /// Это гарантирует, что в локальной базе Isar не может быть двух записей
  /// с одинаковым ID из Firestore.
  /// `replace: true` означает, что при попытке вставить дубликат, Isar
  /// автоматически заменит (обновит) существующую запись. Это и есть "Upsert".
  @Index(unique: true, replace: true)
  String? firestoreId;

  @Index()
  String? userId;

  late String title;

  String? content;

  @Index()
  late DateTime date;

  late DateTime lastModified;

  List<String> mediaPaths = [];
  List<String> videoPaths = [];

  List<String> mediaUrls = [];
  List<String> videoUrls = [];

  List<String> mediaThumbPaths = [];
  List<String> mediaThumbUrls = [];

  @ignore
  bool get isSynced => syncStatus == 'synced';

  @Index()
  String syncStatus = 'pending';

  List<String> spotifyTrackIds = [];
  String? ambientSound;

  String? reflectionImpact;
  String? reflectionLesson;
  String? reflectionAutoThought;
  String? reflectionEvidenceFor;
  String? reflectionEvidenceAgainst;
  String? reflectionReframe;
  String? reflectionAction;
  DateTime? reflectionFollowUpAt;
  bool reflectionActionCompleted = false;

  bool isEncrypted = false;

  List<String> audioNotePaths = [];
  List<String> audioUrls = [];

  List<String> mediaKeysOrder = [];
  List<String> videoKeysOrder = [];
  List<String> audioKeysOrder = [];

  List<String> emotionsData = [];

  /// **НОВОЕ ПОЛЕ:** Временное поле для отслеживания миграции данных на лету.
  @ignore
  bool wasMigrated = false;

  @ignore
  Map<String, int> get emotions {
    final map = <String, int>{};
    for (final entry in emotionsData) {
      final parts = entry.split(':');
      if (parts.length == 2) {
        final key = parts[0];
        final value = int.tryParse(parts[1]);
        if (value != null) {
          map[key] = value;
        }
      }
    }
    return map;
  }

  @ignore
  set emotions(Map<String, int> newEmotions) {
    emotionsData =
        newEmotions.entries.map((e) => '${e.key}:${e.value}').toList();
  }

  Memory() {
    lastModified = DateTime.now().toUtc();
  }

  void touch() {
    lastModified = DateTime.now().toUtc();
  }

  @ignore
  String get universalId => firestoreId ?? 'local_$id';

  @ignore
  List<String> get displayableMediaPaths {
    final allPaths = [...mediaPaths, ...mediaUrls];
    final pathMap = {for (var p in allPaths) getFileKey(p): p};

    final orderedPaths = <String>[];
    for (var key in mediaKeysOrder) {
      if (pathMap.containsKey(key)) {
        final path = pathMap[key]!;
        if (path.startsWith('http') || File(path).existsSync()) {
          orderedPaths.add(path);
        }
      }
    }
    return orderedPaths;
  }

  @ignore
  List<String> get displayableThumbPaths {
    final allThumbs = [...mediaThumbPaths, ...mediaThumbUrls];

    // Primary logic: Try to find ordered thumbnails
    if (allThumbs.isNotEmpty && mediaKeysOrder.isNotEmpty) {
      final thumbMap = {for (var p in allThumbs) getFileKey(p): p};
      final orderedThumbs = <String>[];
      for (var key in mediaKeysOrder) {
        if (thumbMap.containsKey(key)) {
          final path = thumbMap[key]!;
          if (path.startsWith('http') || File(path).existsSync()) {
            orderedThumbs.add(path);
          }
        }
      }

      if (orderedThumbs.isNotEmpty) {
        return orderedThumbs;
      }
    }

    // Fallback logic: If no thumbnails were found, use the main media paths.
    // This is crucial for old memories.
    final mainPaths = displayableMediaPaths;
    if (mainPaths.isNotEmpty) {
      return mainPaths;
    }

    return []; // Return empty list if nothing is found
  }

  @ignore
  List<String> get displayableVideoPaths {
    final allPaths = [...videoPaths, ...videoUrls];
    final pathMap = {for (var p in allPaths) getFileKey(p): p};

    final orderedPaths = <String>[];
    for (var key in videoKeysOrder) {
      if (pathMap.containsKey(key)) {
        final path = pathMap[key]!;
        if (path.startsWith('http') || File(path).existsSync()) {
          orderedPaths.add(path);
        }
      }
    }
    return orderedPaths;
  }

  @ignore
  List<String> get displayableAudioPaths {
    final allPaths = [...audioNotePaths, ...audioUrls];
    final pathMap = {for (var p in allPaths) getFileKey(p): p};

    final orderedPaths = <String>[];
    for (var key in audioKeysOrder) {
      if (pathMap.containsKey(key)) {
        final path = pathMap[key]!;
        if (path.startsWith('http') || File(path).existsSync()) {
          orderedPaths.add(path);
        }
      }
    }
    return orderedPaths;
  }

  @ignore
  String? get coverPath {
    final paths = displayableMediaPaths;
    return paths.isNotEmpty ? paths.first : null;
  }

  @ignore
  String? get coverThumbPath {
    final paths = displayableThumbPaths;
    return paths.isNotEmpty ? paths.first : null;
  }

  Memory copyWith({
    Id? id,
    String? firestoreId,
    String? userId,
    String? title,
    String? content,
    DateTime? date,
    DateTime? lastModified,
    List<String>? mediaPaths,
    List<String>? videoPaths,
    List<String>? mediaUrls,
    List<String>? videoUrls,
    List<String>? mediaThumbPaths,
    List<String>? mediaThumbUrls,
    String? syncStatus,
    List<String>? spotifyTrackIds,
    String? ambientSound,
    String? reflectionImpact,
    String? reflectionLesson,
    String? reflectionAutoThought,
    String? reflectionEvidenceFor,
    String? reflectionEvidenceAgainst,
    String? reflectionReframe,
    String? reflectionAction,
    DateTime? reflectionFollowUpAt,
    bool? reflectionActionCompleted,
    bool? isEncrypted,
    List<String>? audioNotePaths,
    List<String>? audioUrls,
    List<String>? mediaKeysOrder,
    List<String>? videoKeysOrder,
    List<String>? audioKeysOrder,
    Map<String, int>? emotions,
  }) {
    final newMemory = Memory()
      ..id = id ?? this.id
      ..firestoreId = firestoreId ?? this.firestoreId
      ..userId = userId ?? this.userId
      ..title = title ?? this.title
      ..content = content ?? this.content
      ..date = date ?? this.date
      ..lastModified = lastModified ?? this.lastModified
      ..mediaPaths = mediaPaths ?? List.from(this.mediaPaths)
      ..videoPaths = videoPaths ?? List.from(this.videoPaths)
      ..mediaUrls = mediaUrls ?? List.from(this.mediaUrls)
      ..videoUrls = videoUrls ?? List.from(this.videoUrls)
      ..mediaThumbPaths = mediaThumbPaths ?? List.from(this.mediaThumbPaths)
      ..mediaThumbUrls = mediaThumbUrls ?? List.from(this.mediaThumbUrls)
      ..syncStatus = syncStatus ?? this.syncStatus
      ..spotifyTrackIds = spotifyTrackIds ?? List.from(this.spotifyTrackIds)
      ..ambientSound = ambientSound ?? this.ambientSound
      ..reflectionImpact = reflectionImpact ?? this.reflectionImpact
      ..reflectionLesson = reflectionLesson ?? this.reflectionLesson
      ..reflectionAutoThought =
          reflectionAutoThought ?? this.reflectionAutoThought
      ..reflectionEvidenceFor =
          reflectionEvidenceFor ?? this.reflectionEvidenceFor
      ..reflectionEvidenceAgainst =
          reflectionEvidenceAgainst ?? this.reflectionEvidenceAgainst
      ..reflectionReframe = reflectionReframe ?? this.reflectionReframe
      ..reflectionAction = reflectionAction ?? this.reflectionAction
      ..reflectionFollowUpAt = reflectionFollowUpAt ?? this.reflectionFollowUpAt
      ..reflectionActionCompleted =
          reflectionActionCompleted ?? this.reflectionActionCompleted
      ..isEncrypted = isEncrypted ?? this.isEncrypted
      ..audioNotePaths = audioNotePaths ?? List.from(this.audioNotePaths)
      ..audioUrls = audioUrls ?? List.from(this.audioUrls)
      ..mediaKeysOrder = mediaKeysOrder ?? List.from(this.mediaKeysOrder)
      ..videoKeysOrder = videoKeysOrder ?? List.from(this.videoKeysOrder)
      ..audioKeysOrder = audioKeysOrder ?? List.from(this.audioKeysOrder);

    if (emotions != null) {
      newMemory.emotions = emotions;
    } else {
      newMemory.emotionsData = List.from(emotionsData);
    }

    return newMemory;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'lastModified': Timestamp.fromDate(lastModified),
      'mediaUrls': mediaUrls,
      'videoUrls': videoUrls,
      'audioUrls': audioUrls,
      'mediaThumbUrls': mediaThumbUrls,
      'syncStatus': syncStatus,
      'spotifyTrackIds': spotifyTrackIds,
      'ambientSound': ambientSound,
      'reflectionImpact': reflectionImpact,
      'reflectionLesson': reflectionLesson,
      'reflectionAutoThought': reflectionAutoThought,
      'reflectionEvidenceFor': reflectionEvidenceFor,
      'reflectionEvidenceAgainst': reflectionEvidenceAgainst,
      'reflectionReframe': reflectionReframe,
      'reflectionAction': reflectionAction,
      'reflectionFollowUpAt': reflectionFollowUpAt != null
          ? Timestamp.fromDate(reflectionFollowUpAt!)
          : null,
      'isEncrypted': isEncrypted,
      'reflectionActionCompleted': reflectionActionCompleted,
      'emotions': emotions,
      'mediaKeysOrder': mediaKeysOrder.map((key) => getFileKey(key)).toList(),
      'videoKeysOrder': videoKeysOrder.map((key) => getFileKey(key)).toList(),
      'audioKeysOrder': audioKeysOrder.map((key) => getFileKey(key)).toList(),
    };
  }

  factory Memory.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final memory = Memory()
      ..firestoreId = snapshot.id
      ..userId =
          (data['userId'] as String?) ?? snapshot.reference.parent.parent?.id
      ..title = data['title'] ?? ''
      ..content = data['content']
      ..date = (data['date'] as Timestamp).toDate()
      ..lastModified =
          (data['lastModified'] as Timestamp? ?? data['date'] as Timestamp)
              .toDate()
      ..mediaUrls = List<String>.from(data['mediaUrls'] ?? [])
      ..videoUrls = List<String>.from(data['videoUrls'] ?? [])
      ..audioUrls = List<String>.from(data['audioUrls'] ??
          (data['audioUrl'] != null ? [data['audioUrl']] : []))
      ..mediaThumbUrls = List<String>.from(data['mediaThumbUrls'] ?? [])
      ..syncStatus = data['syncStatus'] ?? 'synced'
      ..spotifyTrackIds = List<String>.from(data['spotifyTrackIds'] ??
          (data['spotifyTrackId'] != null ? [data['spotifyTrackId']] : []))
      ..ambientSound = data['ambientSound']
      ..reflectionImpact = data['reflectionImpact']
      ..reflectionLesson = data['reflectionLesson']
      ..reflectionAutoThought = data['reflectionAutoThought']
      ..reflectionEvidenceFor = data['reflectionEvidenceFor']
      ..reflectionEvidenceAgainst = data['reflectionEvidenceAgainst']
      ..reflectionReframe = data['reflectionReframe']
      ..reflectionAction = data['reflectionAction']
      ..reflectionFollowUpAt = data['reflectionFollowUpAt'] != null
          ? (data['reflectionFollowUpAt'] as Timestamp).toDate()
          : null
      ..isEncrypted = data['isEncrypted'] ?? data['reflectionPrivate'] ?? false
      ..reflectionActionCompleted = data['reflectionActionCompleted'] ?? false;

    memory.wasMigrated =
        false; // По умолчанию считаем, что миграция не требовалась

    final emotionsData = data['emotions'];
    if (emotionsData is List) {
      memory.emotions = {for (var e in emotionsData.cast<String>()) e: 50};
    } else if (emotionsData is Map) {
      memory.emotions = Map<String, int>.from(emotionsData
          .map((key, value) => MapEntry(key, (value as num).toInt())));
    } else {
      memory.emotions = {};
    }

    if (data.containsKey('audioNotePath') && data['audioNotePath'] != null) {
      memory.audioNotePaths.add(data['audioNotePath']);
    }

    // --- ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ: Миграция и нормализация ключей и миниатюр при загрузке ---

    // 1. Обработка КЛЮЧЕЙ МЕДИА
    final rawMediaKeysOrder = List<String>.from(data['mediaKeysOrder'] ?? []);
    if (rawMediaKeysOrder.isEmpty && memory.mediaUrls.isNotEmpty) {
      if (kDebugMode) {
        print(
            '[MIGRATION] Memory ${snapshot.id}: GENERATING ${memory.mediaUrls.length} media keys from mediaUrls.');
      }
      memory.mediaKeysOrder =
          memory.mediaUrls.map((url) => getFileKey(url)).toList();
      memory.wasMigrated = true;
    } else {
      memory.mediaKeysOrder =
          rawMediaKeysOrder.map((key) => getFileKey(key)).toList();
    }

    // 2. Обработка МИНИАТЮР
    // Если миниатюр нет, но есть основные фото, используем основные фото в качестве миниатюр.
    if (memory.mediaThumbUrls.isEmpty && memory.mediaUrls.isNotEmpty) {
      if (kDebugMode) {
        print(
            '[MIGRATION] Memory ${snapshot.id}: Using full images as thumbnails fallback.');
      }
      memory.mediaThumbUrls = List.from(memory.mediaUrls);
      memory.wasMigrated = true;
    }

    // 3. Обработка КЛЮЧЕЙ ВИДЕО
    final rawVideoKeysOrder = List<String>.from(data['videoKeysOrder'] ?? []);
    if (rawVideoKeysOrder.isEmpty && memory.videoUrls.isNotEmpty) {
      if (kDebugMode) {
        print(
            '[MIGRATION] Memory ${snapshot.id}: GENERATING ${memory.videoUrls.length} video keys from videoUrls.');
      }
      memory.videoKeysOrder =
          memory.videoUrls.map((url) => getFileKey(url)).toList();
      memory.wasMigrated = true;
    } else {
      memory.videoKeysOrder =
          rawVideoKeysOrder.map((key) => getFileKey(key)).toList();
    }

    // 4. Обработка КЛЮЧЕЙ АУДИО
    final rawAudioKeysOrder = List<String>.from(data['audioKeysOrder'] ?? []);
    if (rawAudioKeysOrder.isEmpty && memory.audioUrls.isNotEmpty) {
      if (kDebugMode) {
        print(
            '[MIGRATION] Memory ${snapshot.id}: GENERATING ${memory.audioUrls.length} audio keys from audioUrls.');
      }
      memory.audioKeysOrder =
          memory.audioUrls.map((url) => getFileKey(url)).toList();
      memory.wasMigrated = true;
    } else {
      memory.audioKeysOrder =
          rawAudioKeysOrder.map((key) => getFileKey(key)).toList();
    }

    return memory;
  }

  @ignore
  double get valence {
    if (emotions.isEmpty) return 0.0;
    double totalScore = 0;
    int count = 0;
    emotions.forEach((emotion, intensity) {
      if (['Joy', 'Pride', 'Gratitude', 'Love'].contains(emotion)) {
        totalScore += intensity;
      } else if (['Sadness', 'Fear', 'Anger'].contains(emotion)) {
        totalScore -= intensity;
      }
      count++;
    });
    return count > 0 ? totalScore / (count * 100) : 0.0;
  }

  @ignore
  int get insightScore {
    int score = 0;
    if (reflectionImpact != null && reflectionImpact!.isNotEmpty) score++;
    if (reflectionLesson != null && reflectionLesson!.isNotEmpty) score++;
    if (reflectionReframe != null && reflectionReframe!.isNotEmpty) score++;
    if (reflectionAction != null && reflectionAction!.isNotEmpty) score++;
    return score;
  }
}
