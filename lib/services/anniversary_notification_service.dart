import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../memory.dart';
import 'notification_scheduler.dart';
import '../utils/safe_logger.dart';

/// Service for checking and creating anniversary notifications
/// Notifies users of significant past moments (1 year, 2 years, 5 years, etc.)
class AnniversaryNotificationService {
  final Isar _isar;

  AnniversaryNotificationService(this._isar);

  /// Check if there are any anniversaries today
  /// Returns notification content if found, null otherwise
  Future<NotificationContent?> checkForAnniversaries(String userId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Get all user memories
      final memories = await _isar.memorys
          .filter()
          .userIdEqualTo(userId)
          .findAll();

      if (memories.isEmpty) {
        return null;
      }

      // Check for anniversaries (1, 2, 5, 10, 15, 20, 25, 30, 40, 50 years)
      final significantYears = [1, 2, 5, 10, 15, 20, 25, 30, 40, 50];

      for (final memory in memories) {
        final memoryDate = DateTime(
          memory.date.year,
          memory.date.month,
          memory.date.day,
        );

        // Check if same day and month
        if (memoryDate.month != today.month || memoryDate.day != today.day) {
          continue;
        }

        // Check if it's a significant anniversary
        final yearsDifference = today.year - memoryDate.year;
        if (significantYears.contains(yearsDifference)) {
          SafeLogger.debug('Found ${yearsDifference}y anniversary: ${memory.id}', tag: 'Anniversary');

          // Create notification content
          final title = _getAnniversaryTitle(yearsDifference);
          final body = _getAnniversaryBody(yearsDifference, memory);

          return NotificationContent(
            title: title,
            body: body,
            payload: 'memory:${memory.id}',
          );
        }
      }

      return null;
    } catch (e, stack) {
      SafeLogger.error('Error checking anniversaries', error: e, stackTrace: stack, tag: 'Anniversary');
      return null;
    }
  }

  String _getAnniversaryTitle(int years) {
    if (years == 1) {
      return 'A Year Ago Today...';
    } else if (years == 5) {
      return '5 Years Ago...';
    } else if (years == 10) {
      return 'A Decade Ago...';
    } else {
      return '$years Years Ago...';
    }
  }

  String _getAnniversaryBody(int years, Memory memory) {
    // Get first 100 chars of content or a default message
    final preview = memory.content != null && memory.content!.isNotEmpty
        ? (memory.content!.length > 100
            ? '${memory.content!.substring(0, 100)}...'
            : memory.content!)
        : 'A meaningful moment from your life';

    return preview;
  }
}
