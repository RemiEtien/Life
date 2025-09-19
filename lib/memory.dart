import 'package:isar/isar.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Index;
import 'dart:io';

part 'memory.g.dart';

// ---------------------------------------------------------------------------
// ВАЖНО: После изменения этого файла запустите команду в терминале:
// flutter pub run build_runner build --delete-conflicting-outputs
// ---------------------------------------------------------------------------

/// Helper function to de-duplicate media files, prioritizing local paths.
Map<String, String> _getUniqueMediaMap(List<String> localPaths, List<String> remoteUrls) {
    final mediaMap = <String, String>{};
    
    String getKey(String path) {
        String filename = path.split('/').last.split('?').first;
        // Removes timestamp like '1725798993883_' from synced files
        return filename.replaceAll(RegExp(r'^\d{13}_'), ''); 
    }

    // Prioritize local, valid files
    for (var path in localPaths) {
        if (File(path).existsSync()) {
            mediaMap[getKey(path)] = path;
        }
    }
    
    // Add remote urls if no local file with the same key exists
    for (var url in remoteUrls) {
        mediaMap.putIfAbsent(getKey(url), () => url);
    }
    
    return mediaMap;
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
  
  @ignore
  bool get isSynced => syncStatus == 'synced';
  
  @Index()
  String syncStatus = 'pending';

  // NEW: Changed to a list
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

  // NEW: Changed to lists
  List<String> audioNotePaths = [];
  List<String> audioUrls = [];

  @ignore
  Map<String, int> emotions = {};

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
    return _getUniqueMediaMap(mediaPaths, mediaUrls).values.toList();
  }

  @ignore
  List<String> get displayableVideoPaths {
    return _getUniqueMediaMap(videoPaths, videoUrls).values.toList();
  }
  
  @ignore
  List<String> get displayableAudioPaths {
    return _getUniqueMediaMap(audioNotePaths, audioUrls).values.toList();
  }

  @ignore
  String? get coverPath {
    final paths = displayableMediaPaths;
    return paths.isNotEmpty ? paths.first : null;
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
      // Deprecated fields for backward compatibility if needed, but not written for new memories
      // 'spotifyTrackId': spotifyTrackIds.isNotEmpty ? spotifyTrackIds.first : null,
      // 'audioUrl': audioUrls.isNotEmpty ? audioUrls.first : null,
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
      ..audioUrls = List<String>.from(data['audioUrls'] ?? (data['audioUrl'] != null ? [data['audioUrl']] : [])) // Backward compatibility for audio
      ..syncStatus = data['syncStatus'] ?? 'synced'
      ..spotifyTrackIds = List<String>.from(data['spotifyTrackIds'] ?? (data['spotifyTrackId'] != null ? [data['spotifyTrackId']] : [])) // Backward compatibility for spotify
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
      ..reflectionActionCompleted = data['reflectionActionCompleted'] ?? false
      ..emotions = Map<String, int>.from(data['emotions'] ?? {});
      
      // Manually handle old single audio path fields for backward compatibility
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

