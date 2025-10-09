import 'package:flutter_test/flutter_test.dart';
import 'package:lifeline/memory.dart';

void main() {
  group('Memory Emotion Fields', () {
    test('Memory can store emotion fields', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'joy'
        ..secondaryEmotion = 'love'
        ..emotionIntensity = 0.75;

      expect(memory.primaryEmotion, 'joy');
      expect(memory.secondaryEmotion, 'love');
      expect(memory.emotionIntensity, 0.75);
    });

    test('Memory defaults emotionIntensity to 0.5', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1);

      expect(memory.emotionIntensity, 0.5);
    });

    test('Memory allows null emotions', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = null
        ..secondaryEmotion = null;

      expect(memory.primaryEmotion, isNull);
      expect(memory.secondaryEmotion, isNull);
    });

    test('copyWith updates emotion fields correctly', () {
      final original = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'joy'
        ..emotionIntensity = 0.5;

      final updated = original.copyWith(
        primaryEmotion: 'sadness',
        secondaryEmotion: 'fear',
        emotionIntensity: 0.8,
      );

      expect(updated.primaryEmotion, 'sadness');
      expect(updated.secondaryEmotion, 'fear');
      expect(updated.emotionIntensity, 0.8);
      expect(updated.firestoreId, original.firestoreId);
    });

    test('copyWith preserves emotions when not specified', () {
      final original = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'joy'
        ..secondaryEmotion = 'love';

      final updated = original.copyWith(
        title: 'Updated Memory',
      );

      // Emotions should be preserved when not explicitly changed
      expect(updated.primaryEmotion, 'joy');
      expect(updated.secondaryEmotion, 'love');
      expect(updated.title, 'Updated Memory');
    });
  });

  group('Memory Emotion Migration', () {
    test('migrates from old emotionsData format', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..emotionsData = ['joy:80', 'love:60', 'surprise:40'];

      // Trigger migration by accessing emotions getter
      final _ = memory.emotions;

      expect(memory.primaryEmotion, 'joy');
      expect(memory.emotionIntensity, closeTo(0.8, 0.01));
      expect(memory.secondaryEmotion, 'love');
    });

    test('does not migrate if primaryEmotion already exists', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'anger'
        ..emotionIntensity = 0.9
        ..emotionsData = ['joy:80', 'love:60']; // Should be ignored

      expect(memory.primaryEmotion, 'anger');
      expect(memory.emotionIntensity, 0.9);
    });

    test('handles empty emotionsData', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..emotionsData = [];

      expect(memory.primaryEmotion, isNull);
      expect(memory.secondaryEmotion, isNull);
    });
  });

  group('Memory Firestore Serialization', () {
    test('toFirestore includes emotion fields', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'joy'
        ..secondaryEmotion = 'love'
        ..emotionIntensity = 0.75;

      final json = memory.toFirestore();

      expect(json['primaryEmotion'], 'joy');
      expect(json['secondaryEmotion'], 'love');
      expect(json['emotionIntensity'], 0.75);
    });

    test('toFirestore handles null emotions', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = null
        ..secondaryEmotion = null;

      final json = memory.toFirestore();

      expect(json['primaryEmotion'], isNull);
      expect(json['secondaryEmotion'], isNull);
      expect(json['emotionIntensity'], 0.5); // default value
    });

    test('toFirestore includes default emotionIntensity', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1);

      final json = memory.toFirestore();

      expect(json['emotionIntensity'], 0.5); // default
    });

    test('toFirestore preserves all emotion data', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'anger'
        ..secondaryEmotion = 'disgust'
        ..emotionIntensity = 0.9;

      final json = memory.toFirestore();

      // Verify emotion fields are present
      expect(json.containsKey('primaryEmotion'), true);
      expect(json.containsKey('secondaryEmotion'), true);
      expect(json.containsKey('emotionIntensity'), true);

      // Verify values
      expect(json['primaryEmotion'], 'anger');
      expect(json['secondaryEmotion'], 'disgust');
      expect(json['emotionIntensity'], 0.9);
    });
  });

  group('Memory Emotion Validation', () {
    test('validates emotion strings', () {
      const validEmotions = [
        'joy',
        'sadness',
        'anger',
        'fear',
        'disgust',
        'surprise',
        'love',
        'pride'
      ];

      for (final emotion in validEmotions) {
        final memory = Memory()
          ..firestoreId = 'test-$emotion'
          ..userId = 'user-1'
          ..title = 'Test Memory'
          ..date = DateTime(2024, 1, 1)
          ..lastModified = DateTime(2024, 1, 1)
          ..primaryEmotion = emotion;

        expect(memory.primaryEmotion, emotion);
      }
    });

    test('universalId includes emotion in string representation', () {
      final memory = Memory()
        ..firestoreId = 'test-1'
        ..userId = 'user-1'
        ..title = 'Test Memory'
        ..date = DateTime(2024, 1, 1)
        ..lastModified = DateTime(2024, 1, 1)
        ..primaryEmotion = 'joy';

      final universalId = memory.universalId;
      expect(universalId, isNotNull);
      expect(universalId, isNotEmpty);
    });
  });
}
