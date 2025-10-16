import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../memory.dart';
import 'notification_scheduler.dart';
import '../utils/safe_logger.dart';

/// Service for sending emotional insight notifications
/// Analyzes emotional patterns and sends reflective notifications
class InsightNotificationService {
  final Isar _isar;

  static const String _lastInsightKey = 'last_insight_notification';
  static const Duration _minTimeBetweenInsights = Duration(days: 60); // 2 months

  InsightNotificationService(this._isar);

  /// Check if an insight notification should be sent
  /// Returns notification content if appropriate, null otherwise
  Future<NotificationContent?> checkForInsight(String userId) async {
    try {
      // Check if enough time has passed since last insight notification
      final prefs = await SharedPreferences.getInstance();
      final lastInsightTimestamp = prefs.getInt(_lastInsightKey);

      if (lastInsightTimestamp != null) {
        final lastInsight = DateTime.fromMillisecondsSinceEpoch(lastInsightTimestamp);
        final timeSinceLastInsight = DateTime.now().difference(lastInsight);

        if (timeSinceLastInsight < _minTimeBetweenInsights) {
          SafeLogger.debug('Too soon since last insight notification', tag: 'Insight');
          return null;
        }
      }

      // Get user's memories for analysis
      final memories = await _isar.memorys
          .filter()
          .userIdEqualTo(userId)
          .findAll();

      // Need at least 10 memories for meaningful insights
      if (memories.length < 10) {
        SafeLogger.debug('Not enough memories for insight analysis', tag: 'Insight');
        return null;
      }

      // Analyze memories from last 3 months
      final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));
      final recentMemories = memories.where((m) => m.lastModified.isAfter(threeMonthsAgo)).toList();

      if (recentMemories.length < 5) {
        SafeLogger.debug('Not enough recent memories for insight', tag: 'Insight');
        return null;
      }

      // Analyze emotional patterns
      final emotionCounts = <String, int>{};
      for (final memory in recentMemories) {
        for (final emotion in memory.emotions.keys) {
          emotionCounts[emotion] = (emotionCounts[emotion] ?? 0) + 1;
        }
      }

      if (emotionCounts.isEmpty) {
        return null; // No emotions recorded
      }

      // Find dominant emotion
      final dominantEmotion = emotionCounts.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final totalEmotions = emotionCounts.values.reduce((a, b) => a + b);
      final dominantPercentage = (emotionCounts[dominantEmotion]! / totalEmotions * 100).round();

      SafeLogger.debug('Dominant emotion: $dominantEmotion ($dominantPercentage%)', tag: 'Insight');

      // Record that we sent this insight notification
      await prefs.setInt(_lastInsightKey, DateTime.now().millisecondsSinceEpoch);

      return NotificationContent(
        title: _getInsightTitle(),
        body: _getInsightBody(dominantEmotion, recentMemories.length, dominantPercentage),
      );
    } catch (e, stack) {
      SafeLogger.error('Error generating insight', error: e, stackTrace: stack, tag: 'Insight');
      return null;
    }
  }

  String _getInsightTitle() {
    return 'Your Emotional Journey';
  }

  String _getInsightBody(String dominantEmotion, int memoryCount, int percentage) {
    // Map emotions to positive messages
    final emotionMessages = {
      'joy': 'These past months have been filled with joy. $memoryCount moments captured, with happiness at the heart of your journey.',
      'gratitude': 'Gratitude has been your companion lately. You\'ve captured $memoryCount meaningful moments of appreciation.',
      'peace': 'You\'ve found moments of peace. $memoryCount memories reflect a journey toward tranquility.',
      'love': 'Love has been woven through your recent memories. $memoryCount moments of connection and warmth.',
      'hope': 'Hope shines through your recent journey. $memoryCount memories showing resilience and optimism.',
      'reflection': 'You\'ve been deeply reflective lately. $memoryCount moments of thoughtful introspection.',
      'growth': 'Your journey shows personal growth. $memoryCount memories capturing your evolution.',
      'sadness': 'Life has had its challenging moments. You\'ve had the courage to capture $memoryCount memories, even through difficulty.',
      'anxiety': 'You\'ve been navigating uncertain times. Remember, you\'ve captured $memoryCount moments - each one a testament to your strength.',
      'anger': 'Strong emotions have marked your recent path. Processing these $memoryCount memories is part of your growth.',
    };

    return emotionMessages[dominantEmotion.toLowerCase()] ??
        'You\'ve captured $memoryCount meaningful moments. Each one tells part of your story.';
  }
}
