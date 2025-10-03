import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lifeline/memory.dart';

void main() {
  group('Memory Model Tests', () {
    late Memory testMemory;

    setUp(() {
      testMemory = Memory()
        ..title = 'Test Memory'
        ..content = 'Test content'
        ..date = DateTime(2025, 1, 15);
    });

    group('Basic Properties', () {
      test('creates memory with default values', () {
        final memory = Memory();
        expect(memory.id, equals(Isar.autoIncrement)); // Isar assigns this special value
        expect(memory.syncStatus, equals('pending'));
        expect(memory.isEncrypted, isFalse);
        expect(memory.reflectionActionCompleted, isFalse);
        expect(memory.lastModified, isNotNull);
      });

      test('sets and retrieves title and content', () {
        expect(testMemory.title, equals('Test Memory'));
        expect(testMemory.content, equals('Test content'));
        expect(testMemory.date, equals(DateTime(2025, 1, 15)));
      });

      test('isSynced computed property works correctly', () {
        testMemory.syncStatus = 'synced';
        expect(testMemory.isSynced, isTrue);

        testMemory.syncStatus = 'pending';
        expect(testMemory.isSynced, isFalse);

        testMemory.syncStatus = 'error';
        expect(testMemory.isSynced, isFalse);
      });

      test('universalId returns firestoreId when available', () {
        testMemory.firestoreId = 'firebase_123';
        expect(testMemory.universalId, equals('firebase_123'));
      });

      test('universalId returns local id when firestoreId is null', () {
        testMemory.id = 42;
        testMemory.firestoreId = null;
        expect(testMemory.universalId, equals('local_42'));
      });

      test('touch updates lastModified timestamp', () async {
        final originalTime = testMemory.lastModified;
        await Future.delayed(const Duration(milliseconds: 10));
        testMemory.touch();
        expect(testMemory.lastModified.isAfter(originalTime), isTrue);
      });
    });

    group('Emotions Getter/Setter', () {
      test('converts emotionsData list to map correctly', () {
        testMemory.emotionsData = ['Joy:80', 'Sadness:30', 'Fear:50'];
        final emotions = testMemory.emotions;

        expect(emotions, isA<Map<String, int>>());
        expect(emotions['Joy'], equals(80));
        expect(emotions['Sadness'], equals(30));
        expect(emotions['Fear'], equals(50));
        expect(emotions.length, equals(3));
      });

      test('handles malformed emotion entries gracefully', () {
        testMemory.emotionsData = ['Joy:80', 'Invalid', 'Sadness:', ':50', 'Fear:abc'];
        final emotions = testMemory.emotions;

        // Valid entries: 'Joy:80' and ':50' (but :50 has empty key)
        // Current implementation allows empty keys
        // 'Invalid' - no ':', 'Sadness:' - int.tryParse('') is null, 'Fear:abc' - int.tryParse('abc') is null
        expect(emotions.length, equals(2));
        expect(emotions['Joy'], equals(80));
        expect(emotions[''], equals(50)); // Empty key is technically valid in current implementation
      });

      test('emotions setter converts map to emotionsData list', () {
        testMemory.emotions = {'Joy': 90, 'Anger': 20};

        expect(testMemory.emotionsData.length, equals(2));
        expect(testMemory.emotionsData, contains('Joy:90'));
        expect(testMemory.emotionsData, contains('Anger:20'));
      });

      test('emotions round-trip conversion works correctly', () {
        final originalEmotions = {'Joy': 75, 'Pride': 60, 'Sadness': 40};
        testMemory.emotions = originalEmotions;
        final retrievedEmotions = testMemory.emotions;

        expect(retrievedEmotions, equals(originalEmotions));
      });

      test('returns empty map for empty emotionsData', () {
        testMemory.emotionsData = [];
        expect(testMemory.emotions, isEmpty);
      });
    });

    group('Valence Calculation', () {
      test('calculates positive valence for positive emotions', () {
        testMemory.emotions = {'Joy': 100, 'Love': 80};
        // (100 + 80) / (2 * 100) = 0.9
        expect(testMemory.valence, closeTo(0.9, 0.01));
      });

      test('calculates negative valence for negative emotions', () {
        testMemory.emotions = {'Sadness': 60, 'Fear': 40};
        // (-60 - 40) / (2 * 100) = -0.5
        expect(testMemory.valence, closeTo(-0.5, 0.01));
      });

      test('calculates mixed valence for mixed emotions', () {
        testMemory.emotions = {'Joy': 100, 'Sadness': 50};
        // (100 - 50) / (2 * 100) = 0.25
        expect(testMemory.valence, closeTo(0.25, 0.01));
      });

      test('returns 0.0 for empty emotions', () {
        testMemory.emotions = {};
        expect(testMemory.valence, equals(0.0));
      });

      test('handles neutral emotions correctly', () {
        // Emotions not in the positive/negative lists are counted but don't affect score
        testMemory.emotions = {'Surprise': 100};
        expect(testMemory.valence, equals(0.0));
      });
    });

    group('Insight Score Calculation', () {
      test('returns 0 for memory with no reflections', () {
        expect(testMemory.insightScore, equals(0));
      });

      test('counts each non-empty reflection field', () {
        testMemory.reflectionImpact = 'Some impact';
        expect(testMemory.insightScore, equals(1));

        testMemory.reflectionLesson = 'Some lesson';
        expect(testMemory.insightScore, equals(2));

        testMemory.reflectionReframe = 'Reframed thought';
        expect(testMemory.insightScore, equals(3));

        testMemory.reflectionAction = 'Action to take';
        expect(testMemory.insightScore, equals(4));
      });

      test('ignores empty string reflections', () {
        testMemory.reflectionImpact = '';
        testMemory.reflectionLesson = 'Valid lesson';
        testMemory.reflectionReframe = '';
        testMemory.reflectionAction = 'Valid action';

        expect(testMemory.insightScore, equals(2));
      });

      test('maximum score is 4', () {
        testMemory.reflectionImpact = 'Impact';
        testMemory.reflectionLesson = 'Lesson';
        testMemory.reflectionReframe = 'Reframe';
        testMemory.reflectionAction = 'Action';

        expect(testMemory.insightScore, equals(4));
      });
    });

    group('Cover Path Helpers', () {
      test('coverPath returns first displayable media path', () {
        testMemory.mediaPaths = ['path1.jpg', 'path2.jpg'];
        testMemory.mediaKeysOrder = ['path1.jpg', 'path2.jpg'];

        expect(testMemory.coverPath, equals('path1.jpg'));
      });

      test('coverPath returns null when no media', () {
        expect(testMemory.coverPath, isNull);
      });

      test('coverThumbPath returns first displayable thumbnail', () {
        testMemory.mediaThumbPaths = ['thumb1.jpg', 'thumb2.jpg'];
        testMemory.mediaKeysOrder = ['thumb1.jpg', 'thumb2.jpg'];

        expect(testMemory.coverThumbPath, equals('thumb1.jpg'));
      });

      test('coverThumbPath returns null when no thumbnails', () {
        expect(testMemory.coverThumbPath, isNull);
      });
    });

    group('copyWith Method', () {
      test('creates new instance with same values when no params', () {
        final copied = testMemory.copyWith();

        expect(copied.title, equals(testMemory.title));
        expect(copied.content, equals(testMemory.content));
        expect(copied.date, equals(testMemory.date));
        expect(copied, isNot(same(testMemory)));
      });

      test('updates title when provided', () {
        final copied = testMemory.copyWith(title: 'New Title');
        expect(copied.title, equals('New Title'));
        expect(testMemory.title, equals('Test Memory')); // Original unchanged
      });

      test('updates content when provided', () {
        final copied = testMemory.copyWith(content: 'New content');
        expect(copied.content, equals('New content'));
      });

      test('updates date when provided', () {
        final newDate = DateTime(2025, 3, 1);
        final copied = testMemory.copyWith(date: newDate);
        expect(copied.date, equals(newDate));
      });

      test('creates deep copy of lists', () {
        testMemory.mediaPaths = ['path1.jpg'];
        final copied = testMemory.copyWith();

        copied.mediaPaths.add('path2.jpg');

        expect(testMemory.mediaPaths.length, equals(1));
        expect(copied.mediaPaths.length, equals(2));
      });

      test('updates emotions map correctly', () {
        testMemory.emotions = {'Joy': 50};
        final copied = testMemory.copyWith(emotions: {'Sadness': 30});

        expect(copied.emotions['Sadness'], equals(30));
        expect(testMemory.emotions['Joy'], equals(50));
      });

      test('throws error for invalid title', () {
        expect(
          () => testMemory.copyWith(title: ''),
          throwsArgumentError,
        );
      });

      test('throws error for excessively long title', () {
        final longTitle = 'a' * 201; // Assuming max is 200
        expect(
          () => testMemory.copyWith(title: longTitle),
          throwsArgumentError,
        );
      });

      test('throws error for excessively long content', () {
        final longContent = 'a' * 100001; // Assuming max is 100000
        expect(
          () => testMemory.copyWith(content: longContent),
          throwsArgumentError,
        );
      });
    });

    group('Displayable Paths Ordering', () {
      test('displayableMediaPaths returns empty list when no media', () {
        expect(testMemory.displayableMediaPaths, isEmpty);
      });

      test('displayableMediaPaths respects mediaKeysOrder', () {
        testMemory.mediaPaths = ['photo1.jpg', 'photo2.jpg', 'photo3.jpg'];
        testMemory.mediaKeysOrder = ['photo3.jpg', 'photo1.jpg', 'photo2.jpg'];

        final ordered = testMemory.displayableMediaPaths;

        expect(ordered.length, equals(3));
        expect(ordered[0], equals('photo3.jpg'));
        expect(ordered[1], equals('photo1.jpg'));
        expect(ordered[2], equals('photo2.jpg'));
      });

      test('displayableMediaPaths works with URLs', () {
        testMemory.mediaUrls = [
          'https://example.com/photo1.jpg',
          'https://example.com/photo2.jpg'
        ];
        testMemory.mediaKeysOrder = ['photo1.jpg', 'photo2.jpg'];

        final ordered = testMemory.displayableMediaPaths;
        expect(ordered.length, equals(2));
      });

      test('displayableVideoPaths respects videoKeysOrder', () {
        testMemory.videoPaths = ['video1.mp4', 'video2.mp4'];
        testMemory.videoKeysOrder = ['video2.mp4', 'video1.mp4'];

        final ordered = testMemory.displayableVideoPaths;

        expect(ordered[0], equals('video2.mp4'));
        expect(ordered[1], equals('video1.mp4'));
      });

      test('displayableAudioPaths respects audioKeysOrder', () {
        testMemory.audioNotePaths = ['audio1.mp3', 'audio2.mp3'];
        testMemory.audioKeysOrder = ['audio2.mp3', 'audio1.mp3'];

        final ordered = testMemory.displayableAudioPaths;

        expect(ordered[0], equals('audio2.mp3'));
        expect(ordered[1], equals('audio1.mp3'));
      });

      test('displayableThumbPaths falls back to main media when no thumbs', () {
        testMemory.mediaPaths = ['photo1.jpg', 'photo2.jpg'];
        testMemory.mediaKeysOrder = ['photo1.jpg', 'photo2.jpg'];

        final thumbs = testMemory.displayableThumbPaths;

        expect(thumbs.length, equals(2));
        expect(thumbs, equals(testMemory.displayableMediaPaths));
      });

      test('displayableThumbPaths uses actual thumbnails when available', () {
        testMemory.mediaThumbPaths = ['thumb1.jpg', 'thumb2.jpg'];
        testMemory.mediaKeysOrder = ['thumb1.jpg', 'thumb2.jpg'];

        final thumbs = testMemory.displayableThumbPaths;

        expect(thumbs[0], equals('thumb1.jpg'));
        expect(thumbs[1], equals('thumb2.jpg'));
      });
    });
  });

  group('getFileKey Helper Function', () {
    test('extracts filename from simple path', () {
      expect(getFileKey('photo.jpg'), equals('photo.jpg'));
      expect(getFileKey('folder/photo.jpg'), equals('photo.jpg'));
      expect(getFileKey('folder/subfolder/photo.jpg'), equals('photo.jpg'));
    });

    test('extracts filename from URL', () {
      expect(
        getFileKey('https://example.com/storage/photo.jpg'),
        equals('photo.jpg'),
      );
    });

    test('removes query parameters', () {
      expect(
        getFileKey('photo.jpg?token=abc123'),
        equals('photo.jpg'),
      );
      expect(
        getFileKey('https://example.com/photo.jpg?alt=media&token=xyz'),
        equals('photo.jpg'),
      );
    });

    test('handles URL encoding', () {
      expect(
        getFileKey('folder%2Fphoto.jpg'),
        equals('photo.jpg'),
      );
      expect(
        getFileKey('My%20Photos%2Fphoto.jpg'),
        equals('photo.jpg'),
      );
    });

    test('removes timestamp prefix', () {
      expect(
        getFileKey('1234567890123_photo.jpg'),
        equals('photo.jpg'),
      );
    });

    test('normalizes thumbnail names', () {
      expect(
        getFileKey('thumb_photo.jpg'),
        equals('photo.jpg'),
      );
      expect(
        getFileKey('photo_thumb.webp'),
        equals('photo.webp'),
      );
    });

    test('handles complex URL with all transformations', () {
      final complexUrl = 'https://storage.googleapis.com/bucket/users%2F123%2F1234567890123_thumb_photo.webp?alt=media&token=abc';
      expect(
        getFileKey(complexUrl),
        equals('photo.webp'),
      );
    });

    test('handles malformed paths gracefully', () {
      expect(getFileKey(''), equals(''));
      expect(getFileKey('no_extension'), equals('no_extension'));
    });
  });
}
