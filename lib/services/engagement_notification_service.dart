import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../memory.dart';
import 'notification_scheduler.dart';

/// Service for sending occasional motivational notifications
/// Uses smart logic based on user's activity patterns
class EngagementNotificationService {
  final Isar _isar;

  static const String _lastEngagementKey = 'last_engagement_notification';
  static const Duration _minTimeBetweenEngagement = Duration(days: 21); // 3 weeks

  EngagementNotificationService(this._isar);

  /// Check if an engagement notification should be sent
  /// Returns notification content if appropriate, null otherwise
  Future<NotificationContent?> checkForEngagement(String userId) async {
    try {
      // Check if enough time has passed since last engagement notification
      final prefs = await SharedPreferences.getInstance();
      final lastEngagementTimestamp = prefs.getInt(_lastEngagementKey);

      if (lastEngagementTimestamp != null) {
        final lastEngagement = DateTime.fromMillisecondsSinceEpoch(lastEngagementTimestamp);
        final timeSinceLastEngagement = DateTime.now().difference(lastEngagement);

        if (timeSinceLastEngagement < _minTimeBetweenEngagement) {
          debugPrint('[Engagement] Too soon since last engagement notification');
          return null;
        }
      }

      // Get user's memories to analyze patterns
      final memories = await _isar.memorys
          .filter()
          .userIdEqualTo(userId)
          .findAll();

      // Need at least 3 memories to establish a pattern
      if (memories.length < 3) {
        debugPrint('[Engagement] Not enough memories for pattern analysis');
        return null;
      }

      // Calculate average time between memories
      final sortedMemories = memories.toList()
        ..sort((a, b) => b.lastModified.compareTo(a.lastModified));

      final now = DateTime.now();
      final lastMemory = sortedMemories.first;
      final daysSinceLastMemory = now.difference(lastMemory.lastModified).inDays;

      // Calculate user's average frequency (in days)
      int totalDaysBetween = 0;
      for (int i = 0; i < sortedMemories.length - 1 && i < 10; i++) {
        final daysDiff = sortedMemories[i].lastModified
            .difference(sortedMemories[i + 1].lastModified)
            .inDays;
        totalDaysBetween += daysDiff;
      }
      final count = (sortedMemories.length - 1).clamp(1, 10);
      final avgDaysBetween = (totalDaysBetween / count).ceil();

      debugPrint('[Engagement] Avg days between memories: $avgDaysBetween');
      debugPrint('[Engagement] Days since last memory: $daysSinceLastMemory');

      // Send notification if user is inactive for 3x their average frequency
      // but only if at least 21 days have passed
      final inactivityThreshold = (avgDaysBetween * 3).clamp(21, 90);

      if (daysSinceLastMemory >= inactivityThreshold) {
        debugPrint('[Engagement] User inactive for $daysSinceLastMemory days (threshold: $inactivityThreshold)');

        // Record that we sent this engagement notification
        await prefs.setInt(_lastEngagementKey, now.millisecondsSinceEpoch);

        return NotificationContent(
          title: _getEngagementTitle(),
          body: _getEngagementBody(daysSinceLastMemory),
        );
      }

      return null;
    } catch (e, stack) {
      debugPrint('[Engagement] Error: $e');
      debugPrint('[Engagement] Stack: $stack');
      return null;
    }
  }

  String _getEngagementTitle() {
    final titles = [
      'Your Lifeline Awaits',
      'Moments Worth Remembering',
      'Time to Reflect',
      'Capture This Chapter',
    ];
    // Simple rotation based on day of year
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return titles[dayOfYear % titles.length];
  }

  String _getEngagementBody(int daysSinceLastMemory) {
    if (daysSinceLastMemory < 45) {
      return 'Has anything meaningful happened recently? Take a moment to capture it.';
    } else if (daysSinceLastMemory < 90) {
      return 'Life moves fast. What moments from the past few months deserve to be remembered?';
    } else {
      return 'It\'s been a while. What important moments have shaped your journey lately?';
    }
  }
}
