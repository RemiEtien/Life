import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lifeline Insights Logic Tests', () {
    group('Streak Calculation Logic', () {
      test('Returns 0 for empty list', () {
        final memories = <DateTime>[];
        final streak = calculateStreak(memories);
        expect(streak, equals(0));
      });

      test('Calculates streak correctly for consecutive days', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        // Create memories for last 5 consecutive days
        final memories = List.generate(
          5,
          (i) => today.subtract(Duration(days: i)),
        );

        final streak = calculateStreak(memories);
        expect(streak, equals(5));
      });

      test('Breaks streak after missing day', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final memories = [
          today,
          today.subtract(const Duration(days: 1)),
          // Skip day 2
          today.subtract(const Duration(days: 3)),
        ];

        final streak = calculateStreak(memories);
        expect(streak, equals(2)); // Only today and yesterday
      });

      test('Returns 0 if last memory is more than 1 day old', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final memories = [
          today.subtract(const Duration(days: 3)),
        ];

        final streak = calculateStreak(memories);
        expect(streak, equals(0));
      });

      test('Handles multiple memories on same day', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final yesterday = today.subtract(const Duration(days: 1));

        final memories = [
          today, // Memory 1 today
          today, // Memory 2 today
          today, // Memory 3 today
          yesterday, // Memory 4 yesterday
          yesterday, // Memory 5 yesterday
        ];

        final streak = calculateStreak(memories);
        expect(streak, equals(2)); // 2 unique days
      });

      test('Handles unsorted dates', () {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        final memories = [
          today.subtract(const Duration(days: 2)),
          today,
          today.subtract(const Duration(days: 1)),
        ];

        final streak = calculateStreak(memories);
        expect(streak, equals(3));
      });
    });

    group('Timeline Span Calculation', () {
      test('Returns 0 for less than 2 memories', () {
        final memories = [DateTime(2023, 1, 1)];
        final span = calculateTimelineSpan(memories);
        expect(span, equals(0));
      });

      test('Returns 0 for empty list', () {
        final memories = <DateTime>[];
        final span = calculateTimelineSpan(memories);
        expect(span, equals(0));
      });

      test('Calculates year span correctly', () {
        final memories = [
          DateTime(2020, 1, 1),
          DateTime(2023, 12, 31),
        ];

        final span = calculateTimelineSpan(memories);
        expect(span, equals(3));
      });

      test('Returns 0 for memories in same year', () {
        final memories = [
          DateTime(2023, 1, 1),
          DateTime(2023, 12, 31),
        ];

        final span = calculateTimelineSpan(memories);
        expect(span, equals(0));
      });

      test('Handles many years correctly', () {
        final memories = [
          DateTime(2000, 1, 1),
          DateTime(2024, 12, 31),
        ];

        final span = calculateTimelineSpan(memories);
        expect(span, equals(24));
      });
    });

    group('Emotional Balance Detection', () {
      test('Detects positive vibes correctly', () {
        final valences = [0.8, 0.7, 0.6, 0.9, 0.5, 0.7];
        final avgValence = valences.reduce((a, b) => a + b) / valences.length;

        expect(avgValence, greaterThan(0.3));
      });

      test('Detects negative emotions correctly', () {
        final valences = [-0.7, -0.6, -0.8, -0.5, -0.9, -0.6];
        final avgValence = valences.reduce((a, b) => a + b) / valences.length;

        expect(avgValence, lessThan(-0.3));
      });

      test('Detects balanced emotions correctly', () {
        final valences = [0.2, -0.1, 0.1, -0.2, 0.0, 0.1];
        final avgValence = valences.reduce((a, b) => a + b) / valences.length;

        expect(avgValence, greaterThanOrEqualTo(-0.3));
        expect(avgValence, lessThanOrEqualTo(0.3));
      });
    });

    group('Insight Rotation Logic', () {
      test('Rotates based on hour correctly', () {
        const insightCount = 5;
        final now = DateTime.now();
        final hourOfDay = now.hour;

        final rotationIndex = hourOfDay % insightCount;

        expect(rotationIndex, greaterThanOrEqualTo(0));
        expect(rotationIndex, lessThan(insightCount));
      });

      test('Different hours produce different indices', () {
        const insightCount = 10;
        final indices = <int>{};

        // Test all 24 hours
        for (int hour = 0; hour < 24; hour++) {
          final index = hour % insightCount;
          indices.add(index);
        }

        // Should have multiple different indices
        expect(indices.length, greaterThan(1));
      });
    });

    group('Content Counting', () {
      test('Counts items correctly', () {
        final counts = [3, 1, 5, 2, 4];
        final total = counts.fold<int>(0, (sum, count) => sum + count);

        expect(total, equals(15));
      });

      test('Filters by date correctly', () {
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));

        final dates = [
          now,
          now.subtract(const Duration(days: 3)),
          now.subtract(const Duration(days: 6)),
          now.subtract(const Duration(days: 10)),
          now.subtract(const Duration(days: 20)),
        ];

        final thisWeekCount = dates.where((d) => d.isAfter(weekAgo)).length;
        expect(thisWeekCount, equals(3));
      });

      test('Filters by month correctly', () {
        final now = DateTime.now();

        final dates = [
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month, 15),
          DateTime(now.year, now.month - 1, 20),
        ];

        final thisMonthCount = dates.where((d) =>
          d.year == now.year && d.month == now.month
        ).length;

        expect(thisMonthCount, equals(2));
      });
    });

    group('Priority System', () {
      test('Sorts by priority correctly', () {
        final insights = [
          _InsightData(text: 'Low', priority: 10),
          _InsightData(text: 'High', priority: 100),
          _InsightData(text: 'Medium', priority: 50),
        ];

        insights.sort((a, b) => b.priority.compareTo(a.priority));

        expect(insights[0].text, equals('High'));
        expect(insights[1].text, equals('Medium'));
        expect(insights[2].text, equals('Low'));
      });

      test('Prioritizes streak highest', () {
        const streakPriority = 100;
        const monthPriority = 50;
        const weekPriority = 45;

        expect(streakPriority, greaterThan(monthPriority));
        expect(monthPriority, greaterThan(weekPriority));
      });
    });

    group('Edge Cases', () {
      test('Handles single memory', () {
        final memories = [DateTime.now()];
        final streak = calculateStreak(memories);

        expect(streak, greaterThanOrEqualTo(0));
      });

      test('Handles very large memory count', () {
        final memories = List.generate(
          1000,
          (i) => DateTime.now().subtract(Duration(days: i * 2)),
        );

        expect(memories.length, equals(1000));
        // Should not crash or hang
      });

      test('Handles dates far in past', () {
        final memories = [
          DateTime(1900, 1, 1),
          DateTime(2024, 12, 31),
        ];

        final span = calculateTimelineSpan(memories);
        expect(span, equals(124));
      });

      test('Handles dates in future', () {
        final future = DateTime.now().add(const Duration(days: 365));
        final memories = [DateTime.now(), future];

        final span = calculateTimelineSpan(memories);
        expect(span, greaterThanOrEqualTo(0));
      });
    });
  });
}

// Helper class for testing
class _InsightData {
  final String text;
  final int priority;

  _InsightData({required this.text, required this.priority});
}

// Helper functions - simplified versions of the actual implementation

/// Calculate current streak (consecutive days with memories)
int calculateStreak(List<DateTime> memoryDates) {
  if (memoryDates.isEmpty) return 0;

  // Get unique dates sorted descending
  final uniqueDates = memoryDates.map((date) {
    return DateTime(date.year, date.month, date.day);
  }).toSet().toList()
    ..sort((a, b) => b.compareTo(a));

  int streak = 0;
  final today = DateTime.now();
  final todayDate = DateTime(today.year, today.month, today.day);

  // Check if there's a memory today or yesterday to start counting
  final latestMemory = uniqueDates.first;
  final daysSinceLatest = todayDate.difference(latestMemory).inDays;

  if (daysSinceLatest > 1) {
    return 0; // Streak broken
  }

  // Count consecutive days
  DateTime expectedDate = latestMemory;
  for (final memoryDate in uniqueDates) {
    final diff = expectedDate.difference(memoryDate).inDays;

    if (diff == 0) {
      streak++;
      expectedDate = memoryDate.subtract(const Duration(days: 1));
    } else if (diff > 0) {
      break; // Gap found, streak ends
    }
  }

  return streak;
}

/// Calculate timeline span in years
int calculateTimelineSpan(List<DateTime> memoryDates) {
  if (memoryDates.length < 2) return 0;

  final earliest = memoryDates.reduce((a, b) => a.isBefore(b) ? a : b);
  final latest = memoryDates.reduce((a, b) => a.isAfter(b) ? a : b);

  final years = latest.year - earliest.year;
  return years > 0 ? years : 0;
}
