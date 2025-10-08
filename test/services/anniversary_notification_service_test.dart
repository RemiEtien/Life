import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:lifeline/services/anniversary_notification_service.dart';
import 'package:lifeline/memory.dart';

void main() {
  group('AnniversaryNotificationService', () {
    late Isar isar;
    late AnniversaryNotificationService service;

    setUp(() async {
      // Initialize Isar in memory for testing
      isar = await Isar.open(
        [MemorySchema],
        directory: '',
        name: 'test_anniversary',
      );
      service = AnniversaryNotificationService(isar);
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
    });

    test('should return null when no memories exist', () async {
      final result = await service.checkForAnniversaries('user123');
      expect(result, isNull);
    });

    test('should return null when no anniversaries today', () async {
      // Create memory from 3 months ago (not a significant anniversary)
      final memory = Memory()
        ..userId = 'user123'
        ..date = DateTime.now().subtract(const Duration(days: 90))
        ..lastModified = DateTime.now()
        ..content = 'Test memory'
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNull);
    });

    test('should detect 1 year anniversary', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = oneYearAgo
        ..lastModified = DateTime.now()
        ..content = 'This is a special moment from a year ago!'
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.title, equals('A Year Ago Today...'));
      expect(result.body, contains('This is a special moment'));
    });

    test('should detect 5 year anniversary', () async {
      final now = DateTime.now();
      final fiveYearsAgo = DateTime(now.year - 5, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = fiveYearsAgo
        ..lastModified = DateTime.now()
        ..content = 'Five years ago moment'
        ..emotions = {'gratitude': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.title, equals('5 Years Ago...'));
    });

    test('should detect 10 year anniversary', () async {
      final now = DateTime.now();
      final tenYearsAgo = DateTime(now.year - 10, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = tenYearsAgo
        ..lastModified = DateTime.now()
        ..content = 'A decade ago'
        ..emotions = {'reflection': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.title, equals('A Decade Ago...'));
    });

    test('should return only one anniversary when multiple exist', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);
      final twoYearsAgo = DateTime(now.year - 2, now.month, now.day);

      final memory1 = Memory()
        ..userId = 'user123'
        ..date = oneYearAgo
        ..lastModified = DateTime.now()
        ..content = 'One year ago'
        ..emotions = {'joy': 50};

      final memory2 = Memory()
        ..userId = 'user123'
        ..date = twoYearsAgo
        ..lastModified = DateTime.now()
        ..content = 'Two years ago'
        ..emotions = {'peace': 50};

      await isar.writeTxn(() async {
        await isar.memorys.putAll([memory1, memory2]);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      // Should return the first anniversary found
    });

    test('should include payload with memory ID', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = oneYearAgo
        ..lastModified = DateTime.now()
        ..content = 'Test'
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.payload, startsWith('memory:'));
    });

    test('should truncate long content to 100 characters', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final longContent = 'A' * 150; // 150 characters

      final memory = Memory()
        ..userId = 'user123'
        ..date = oneYearAgo
        ..lastModified = DateTime.now()
        ..content = longContent
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.body.length, lessThanOrEqualTo(103)); // 100 + '...'
      expect(result.body, endsWith('...'));
    });

    test('should use default message for empty content', () async {
      final now = DateTime.now();
      final oneYearAgo = DateTime(now.year - 1, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = oneYearAgo
        ..lastModified = DateTime.now()
        ..content = ''
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      final result = await service.checkForAnniversaries('user123');
      expect(result, isNotNull);
      expect(result!.body, equals('A meaningful moment from your life'));
    });

    test('should only match exact day and month, not year', () async {
      final now = DateTime.now();
      // Different year, same day/month
      final differentYear = DateTime(now.year - 3, now.month, now.day);

      final memory = Memory()
        ..userId = 'user123'
        ..date = differentYear
        ..lastModified = DateTime.now()
        ..content = 'Test'
        ..emotions = {'joy': 50};

      await isar.writeTxn(() async {
        await isar.memorys.put(memory);
      });

      // 3 years is not a significant anniversary
      final result = await service.checkForAnniversaries('user123');
      expect(result, isNull);
    });
  });
}
