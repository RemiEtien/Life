import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Monthly Pattern Card Widget
/// Displays AI-generated monthly pattern analysis in Monthly Cluster Bottom Sheet
class MonthlyPatternCard extends StatelessWidget {
  final String userId;
  final String monthKey; // Format: "2025-01"
  final Map<String, int> emotionCounts;

  const MonthlyPatternCard({
    super.key,
    required this.userId,
    required this.monthKey,
    required this.emotionCounts,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .doc('users/$userId/monthlyPatterns/$monthKey')
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox.shrink();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;
        if (data == null) return const SizedBox.shrink();

        final topThemes = (data['topThemes'] as List?)
                ?.map((t) => t.toString())
                .toList() ??
            [];
        final triggers = (data['triggers'] as List?)
                ?.map((t) => t.toString())
                .toList() ??
            [];
        final whatHelped = (data['whatHelped'] as List?)
                ?.map((t) => t.toString())
                .toList() ??
            [];

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.indigo.shade50.withOpacity(0.3),
                Colors.purple.shade50.withOpacity(0.3),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.purple.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.insights,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly AI Insight',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          'Pattern analysis for this month',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PREMIUM',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Top Themes
              if (topThemes.isNotEmpty) ...[
                _buildSection(
                  icon: Icons.category,
                  title: 'Key Themes',
                  items: topThemes,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
              ],

              // Triggers
              if (triggers.isNotEmpty) ...[
                _buildSection(
                  icon: Icons.warning_amber,
                  title: 'Common Triggers',
                  items: triggers,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
              ],

              // What Helped
              if (whatHelped.isNotEmpty) ...[
                _buildSection(
                  icon: Icons.lightbulb,
                  title: 'What Helped Most',
                  items: whatHelped,
                  color: Colors.green,
                ),
              ],

              // Emotion Summary
              const SizedBox(height: 16),
              _buildEmotionSummary(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 22, top: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildEmotionSummary() {
    if (emotionCounts.isEmpty) return const SizedBox.shrink();

    // Sort by count
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topEmotion = sortedEmotions.first;
    final totalCount = emotionCounts.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_emotions, size: 16, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Most frequent: ${_capitalizeFirst(topEmotion.key)} (${topEmotion.value}/$totalCount memories)',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
