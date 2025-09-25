import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
import 'dart:io';

part 'memory.g.dart';

// ---------------------------------------------------------------------------
// ВАЖНО: После изменения этого файла запустите команду в терминале:
// flutter pub run build_runner build --delete-conflicting-outputs
// ---------------------------------------------------------------------------

// Вспомогательный метод для получения ключа файла (имя файла без временной метки)
String _getFileKey(String path) {
  String filename = path.split('/').last.split('?').first;
  // Removes timestamp like '1725798993883_' from synced files
  return filename.replaceAll(RegExp(r'^\d{13}_'), '');
}

// Вспомогательный метод для получения ключа миниатюры
String _getThumbKey(String path) {
  String filename = _getFileKey(path);
  if (filename.startsWith('thumb_')) {
    return filename;
  }
  return 'thumb_$filename';
}

@collection
class Memory {
  Id id = Isar.autoIncrement;
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

  // Isar не поддерживает Map, поэтому используем обходной путь:
  // храним данные как List<String> в формате "key:value"
  List<String> emotionsData = [];

  // Геттер и сеттер для удобной работы с эмоциями как с Map
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
    if (mediaKeysOrder.isEmpty) {
      final combinedPaths =
          mediaPaths.where((path) => File(path).existsSync()).toList();
      final localKeys = combinedPaths.map((path) => _getFileKey(path)).toSet();
      for (var url in mediaUrls) {
        final key = _getFileKey(url);
        if (!localKeys.contains(key)) {
          combinedPaths.add(url);
        }
      }
      return combinedPaths;
    }

    final allPaths = [...mediaPaths, ...mediaUrls];
    final pathMap = {for (var p in allPaths) _getFileKey(p): p};

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
    if (mediaKeysOrder.isEmpty) {
      return displayableMediaPaths; // Fallback для старых данных
    }

    final allThumbs = [...mediaThumbPaths, ...mediaThumbUrls];
    final thumbMap = {for (var p in allThumbs) _getThumbKey(p): p};

    final orderedThumbs = <String>[];
    for (var key in mediaKeysOrder) {
      final thumbKey = 'thumb_$key';
      if (thumbMap.containsKey(thumbKey)) {
        final path = thumbMap[thumbKey]!;
        if (path.startsWith('http') || File(path).existsSync()) {
          orderedThumbs.add(path);
        }
      }
    }
    return orderedThumbs;
  }

  @ignore
  List<String> get displayableVideoPaths {
    if (videoKeysOrder.isEmpty) {
      final combinedPaths =
          videoPaths.where((path) => File(path).existsSync()).toList();
      final localKeys = combinedPaths.map((path) => _getFileKey(path)).toSet();
      for (var url in videoUrls) {
        final key = _getFileKey(url);
        if (!localKeys.contains(key)) {
          combinedPaths.add(url);
        }
      }
      return combinedPaths;
    }

    final allPaths = [...videoPaths, ...videoUrls];
    final pathMap = {for (var p in allPaths) _getFileKey(p): p};

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
    if (audioKeysOrder.isEmpty) {
      final combinedPaths =
          audioNotePaths.where((path) => File(path).existsSync()).toList();
      final localKeys = combinedPaths.map((path) => _getFileKey(path)).toSet();
      for (var url in audioUrls) {
        final key = _getFileKey(url);
        if (!localKeys.contains(key)) {
          combinedPaths.add(url);
        }
      }
      return combinedPaths;
    }

    final allPaths = [...audioNotePaths, ...audioUrls];
    final pathMap = {for (var p in allPaths) _getFileKey(p): p};

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

  /// РЕАЛИЗАЦИЯ ПРИНЦИПА 1: Иммутабельность
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
      newMemory.emotionsData = List.from(this.emotionsData);
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
      'reflectionFollowUpAt':
          reflectionFollowUpAt != null ? Timestamp.fromDate(reflectionFollowUpAt!) : null,
      'isEncrypted': isEncrypted,
      'reflectionActionCompleted': reflectionActionCompleted,
      'emotions': emotions, // Firestore/JSON can handle maps directly
      'mediaKeysOrder': mediaKeysOrder,
      'videoKeysOrder': videoKeysOrder,
      'audioKeysOrder': audioKeysOrder,
    };
  }

  factory Memory.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data()!;
    final memory = Memory()
      ..firestoreId = snapshot.id
      ..userId = data['userId']
      ..title = data['title'] ?? ''
      ..content = data['content']
      ..date = (data['date'] as Timestamp).toDate()
      ..lastModified = (data['lastModified'] as Timestamp? ?? data['date'] as Timestamp).toDate()
      ..mediaUrls = List<String>.from(data['mediaUrls'] ?? [])
      ..videoUrls = List<String>.from(data['videoUrls'] ?? [])
      ..audioUrls = List<String>.from(data['audioUrls'] ?? (data['audioUrl'] != null ? [data['audioUrl']] : []))
      ..mediaThumbUrls = List<String>.from(data['mediaThumbUrls'] ?? [])
      ..syncStatus = data['syncStatus'] ?? 'synced'
      ..spotifyTrackIds = List<String>.from(data['spotifyTrackIds'] ?? (data['spotifyTrackId'] != null ? [data['spotifyTrackId']] : []))
      ..ambientSound = data['ambientSound']
      ..reflectionImpact = data['reflectionImpact']
      ..reflectionLesson = data['reflectionLesson']
      ..reflectionAutoThought = data['reflectionAutoThought']
      ..reflectionEvidenceFor = data['reflectionEvidenceFor']
      ..reflectionEvidenceAgainst = data['reflectionEvidenceAgainst']
      ..reflectionReframe = data['reflectionReframe']
      ..reflectionAction = data['reflectionAction']
      ..reflectionFollowUpAt = data['reflectionFollowUpAt'] != null ? (data['reflectionFollowUpAt'] as Timestamp).toDate() : null
      ..isEncrypted = data['isEncrypted'] ?? data['reflectionPrivate'] ?? false
      ..reflectionActionCompleted = data['reflectionActionCompleted'] ?? false
      ..mediaKeysOrder = List<String>.from(data['mediaKeysOrder'] ?? [])
      ..videoKeysOrder = List<String>.from(data['videoKeysOrder'] ?? [])
      ..audioKeysOrder = List<String>.from(data['audioKeysOrder'] ?? []);

    // РЕАЛИЗАЦИЯ ПРИНЦИПА 2: Обратная совместимость
    final emotionsData = data['emotions'];
    if (emotionsData is List) {
      // Старый формат: List<String> -> преобразуем в Map<String, int>
      memory.emotions = {for (var e in emotionsData.cast<String>()) e: 50}; // Интенсивность по умолчанию 50
    } else if (emotionsData is Map) {
      // Новый формат: Map<String, dynamic>
      memory.emotions = Map<String, int>.from(
          emotionsData.map((key, value) => MapEntry(key, (value as num).toInt())));
    } else {
      memory.emotions = {};
    }

    if (data.containsKey('audioNotePath') && data['audioNotePath'] != null) {
      memory.audioNotePaths.add(data['audioNotePath']);
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
