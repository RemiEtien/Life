import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifeline/services/insight_notification_service.dart';
import 'package:lifeline/memory.dart';

void main() {
  group('InsightNotificationService', () {
    late Isar isar;
    late InsightNotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      isar = await Isar.open(
        [MemorySchema],
        directory: '',
        name: 'test_insight',
      );
      service = InsightNotificationService(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('should return null when less than 10 memories exist', () async {
      final memories = List.generate(5, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = DateTime.now().subtract(Duration(days: i * 10))
          ..lastModified = DateTime.now().subtract(Duration(days: i * 10))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNull);
    });

    test('should return null when last insight notification was recent', () async {
      final prefs = await SharedPreferences.getInstance();
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      await prefs.setInt('last_insight_notification', thirtyDaysAgo.millisecondsSinceEpoch);

      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = DateTime.now().subtract(Duration(days: i * 5))
          ..lastModified = DateTime.now().subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      // Should be null because last insight was less than 60 days ago
      expect(result, isNull);
    });

    test('should return null when less than 5 recent memories', () async {
      // 10 total memories, but all older than 3 months
      final now = DateTime.now();
      final memories = List.generate(10, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: 100 + i))
          ..lastModified = now.subtract(Duration(days: 100 + i))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNull);
    });

    test('should detect dominant emotion (joy)', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = i < 10 ? {'joy': 50} : {'sadness': 50}; // 10 joy, 5 sadness
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('joy'));
    });

    test('should detect dominant emotion (gratitude)', () async {
      final now = DateTime.now();
      final memories = List.generate(12, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'gratitude': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('Gratitude'));
    });

    test('should provide supportive message for sadness', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'sadness': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('courage'));
    });

    test('should analyze only recent 3 months', () async {
      final now = DateTime.now();
      // 10 old memories with joy, 5 recent with gratitude
      final oldMemories = List.generate(10, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: 120 + i))
          ..lastModified = now.subtract(Duration(days: 120 + i))
          ..content = 'Old Memory $i'
          ..emotions = {'joy': 50};
      });

      final recentMemories = List.generate(5, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 10))
          ..lastModified = now.subtract(Duration(days: i * 10))
          ..content = 'Recent Memory $i'
          ..emotions = {'gratitude': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll([...oldMemories, ...recentMemories]);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      // Should analyze only recent memories (gratitude)
      expect(result!.body, contains('gratitude'));
    });

    test('should return null when no emotions recorded', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {}; // No emotions
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNull);
    });

    test('should include memory count in message', () async {
      final now = DateTime.now();
      final memories = List.generate(12, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'peace': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('12')); // Memory count
    });

    test('should have consistent title', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'love': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.title, equals('Your Emotional Journey'));
    });

    test('should handle mixed emotions and select dominant', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        final emotion = i % 3 == 0
            ? 'joy'
            : i % 3 == 1
                ? 'gratitude'
                : 'peace';
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {emotion: 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      // Should pick one of the emotions based on count
    });

    test('should record insight notification timestamp', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'hope': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      await service.checkForInsight('user123');

      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('last_insight_notification');
      expect(timestamp, isNotNull);
      expect(timestamp, greaterThan(0));
    });

    test('should use fallback message for unknown emotion', () async {
      final now = DateTime.now();
      final memories = List.generate(15, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: i * 5))
          ..lastModified = now.subtract(Duration(days: i * 5))
          ..content = 'Memory $i'
          ..emotions = {'unknown_emotion': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForInsight('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('meaningful moments'));
    });
  });
}
