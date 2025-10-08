import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lifeline/services/engagement_notification_service.dart';
import 'package:lifeline/memory.dart';

void main() {
  group('EngagementNotificationService', () {
    late Isar isar;
    late EngagementNotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      isar = await Isar.open(
        [MemorySchema],
        directory: '',
        name: 'test_engagement',
      );
      service = EngagementNotificationService(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('should return null when less than 3 memories exist', () async {
      // Add only 2 memories
      final memory1 = Memory()
        ..userId = 'user123'
        ..date = DateTime.now().subtract(const Duration(days: 30))
        ..lastModified = DateTime.now().subtract(const Duration(days: 30))
        ..content = 'Memory 1'
        ..emotions = {'joy': 50};

      final memory2 = Memory()
        ..userId = 'user123'
        ..date = DateTime.now().subtract(const Duration(days: 60))
        ..lastModified = DateTime.now().subtract(const Duration(days: 60))
        ..content = 'Memory 2'
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.putAll([memory1, memory2]);
      });

      final result = await service.checkForEngagement('user123');
      expect(result, isNull);
    });

    test('should return null when last engagement notification was recent', () async {
      // Set last engagement notification to 10 days ago
      final prefs = await SharedPreferences.getInstance();
      final tenDaysAgo = DateTime.now().subtract(const Duration(days: 10));
      await prefs.setInt('last_engagement_notification', tenDaysAgo.millisecondsSinceEpoch);

      // Add memories
      final memories = List.generate(5, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = DateTime.now().subtract(Duration(days: i * 30))
          ..lastModified = DateTime.now().subtract(Duration(days: i * 30))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForEngagement('user123');
      // Should be null because last engagement was less than 21 days ago
      expect(result, isNull);
    });

    test('should detect inactivity and send notification', () async {
      // User typically creates memory every 10 days
      // Last memory was 35 days ago (>3x10 = 30 days threshold)
      final now = DateTime.now();
      final memories = [
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 35))
          ..lastModified = now.subtract(const Duration(days: 35))
          ..content = 'Recent'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 45))
          ..lastModified = now.subtract(const Duration(days: 45))
          ..content = 'Memory 2'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 55))
          ..lastModified = now.subtract(const Duration(days: 55))
          ..content = 'Memory 3'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 65))
          ..lastModified = now.subtract(const Duration(days: 65))
          ..content = 'Memory 4'
          ..emotions = {'joy': 50},
      ];

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForEngagement('user123');
      expect(result, isNotNull);
      expect(result!.title, isNotEmpty);
      expect(result.body, isNotEmpty);
    });

    test('should return null when user is still active', () async {
      // User creates memories every 10 days, last one was 5 days ago
      final now = DateTime.now();
      final memories = List.generate(5, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: 5 + (i * 10)))
          ..lastModified = now.subtract(Duration(days: 5 + (i * 10)))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForEngagement('user123');
      // 5 days < 3x average (30 days), so no notification
      expect(result, isNull);
    });

    test('should enforce minimum 21-day threshold', () async {
      // User creates memories very frequently (every 2 days)
      // Even if 3x average = 6 days, minimum threshold is 21 days
      final now = DateTime.now();
      final memories = List.generate(10, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: 25 + (i * 2)))
          ..lastModified = now.subtract(Duration(days: 25 + (i * 2)))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForEngagement('user123');
      // Last memory was 25 days ago, threshold clamped to 21 days minimum
      expect(result, isNotNull);
    });

    test('should cap inactivity threshold at 90 days', () async {
      // User creates memories very infrequently (every 40 days)
      // 3x40 = 120 days, but capped at 90 days
      final now = DateTime.now();
      final memories = [
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 95))
          ..lastModified = now.subtract(const Duration(days: 95))
          ..content = 'Memory 1'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 135))
          ..lastModified = now.subtract(const Duration(days: 135))
          ..content = 'Memory 2'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 175))
          ..lastModified = now.subtract(const Duration(days: 175))
          ..content = 'Memory 3'
          ..emotions = {'joy': 50},
      ];

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      final result = await service.checkForEngagement('user123');
      // 95 days > 90 day cap, should send notification
      expect(result, isNotNull);
    });

    test('should use different message for different inactivity levels', () async {
      final now = DateTime.now();

      // Test short inactivity (30 days)
      final shortInactivityMemories = [
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 30))
          ..lastModified = now.subtract(const Duration(days: 30))
          ..content = 'Memory 1'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 40))
          ..lastModified = now.subtract(const Duration(days: 40))
          ..content = 'Memory 2'
          ..emotions = {'joy': 50},
        Memory()
          ..userId = 'user123'
          ..date = now.subtract(const Duration(days: 50))
          ..lastModified = now.subtract(const Duration(days: 50))
          ..content = 'Memory 3'
          ..emotions = {'joy': 50},
      ];

      await isar.writeTxn(() async {
        await isar.memorys.putAll(shortInactivityMemories);
      });

      final result = await service.checkForEngagement('user123');
      expect(result, isNotNull);
      expect(result!.body, contains('recently'));
    });

    test('should record engagement notification timestamp', () async {
      final now = DateTime.now();
      final memories = List.generate(5, (i) {
        return Memory()
          ..userId = 'user123'
          ..date = now.subtract(Duration(days: 30 + (i * 10)))
          ..lastModified = now.subtract(Duration(days: 30 + (i * 10)))
          ..content = 'Memory $i'
          ..emotions = {'joy': 50};
      });

      await isar.writeTxn(() async {
        await isar.memorys.putAll(memories);
      });

      await service.checkForEngagement('user123');

      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('last_engagement_notification');
      expect(timestamp, isNotNull);
      expect(timestamp, greaterThan(0));
    });
  });
}
