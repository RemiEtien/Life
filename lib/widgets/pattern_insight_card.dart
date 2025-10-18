import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Pattern Insight Card Widget
/// Displays AI-generated pattern analysis in various screens
class PatternInsightCard extends StatelessWidget {
  final String userId;
  final String? relatedMemoryId;
  final bool showDismiss;

  const PatternInsightCard({
    super.key,
    required this.userId,
    this.relatedMemoryId,
    this.showDismiss = true,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _buildQuery().snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final insight = snapshot.data!.docs.first;
        final data = insight.data() as Map<String, dynamic>;
        final patternData = data['pattern'] as Map<String, dynamic>?;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        if (patternData == null) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.purple.shade50.withOpacity(0.3),
                  Colors.blue.shade50.withOpacity(0.3),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Colors.purple,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pattern Analysis',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            if (createdAt != null)
                              Text(
                                DateFormat('MMM d, yyyy').format(createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (showDismiss)
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () async {
                            await insight.reference.update({'dismissed': true});
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Themes
                  if (patternData['themes'] != null &&
                      (patternData['themes'] as List).isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.category,
                      title: 'Themes',
                      items: (patternData['themes'] as List)
                          .map((t) => t.toString())
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Emotional Cycles
                  if (patternData['emotional_cycles'] != null) ...[
                    _buildTextSection(
                      icon: Icons.waves,
                      title: 'Emotional Patterns',
                      text: patternData['emotional_cycles'].toString(),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Triggers
                  if (patternData['triggers'] != null &&
                      (patternData['triggers'] as List).isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.warning_amber,
                      title: 'Triggers',
                      items: (patternData['triggers'] as List)
                          .map((t) => t.toString())
                          .toList(),
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // What Helped
                  if (patternData['what_helped'] != null &&
                      (patternData['what_helped'] as List).isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.lightbulb,
                      title: 'What Helped',
                      items: (patternData['what_helped'] as List)
                          .map((t) => t.toString())
                          .toList(),
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Progress Notes
                  if (patternData['progress_notes'] != null) ...[
                    _buildTextSection(
                      icon: Icons.trending_up,
                      title: 'Progress',
                      text: patternData['progress_notes'].toString(),
                      color: Colors.blue,
                    ),
                  ],

                  // View Details Button
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      _showFullInsightDialog(context, data);
                    },
                    icon: const Icon(Icons.info_outline, size: 16),
                    label: const Text('View Full Analysis'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Query<Map<String, dynamic>> _buildQuery() {
    var query = FirebaseFirestore.instance
        .collection('users/$userId/insights')
        .where('type', isEqualTo: 'pattern')
        .where('dismissed', isEqualTo: false)
        .orderBy('createdAt', descending: true);

    if (relatedMemoryId != null) {
      query = query.where('relatedMemories', arrayContains: relatedMemoryId);
    }

    return query.limit(1);
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.purple),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color ?? Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(left: 22, top: 2),
              child: Text(
                '• $item',
                style: const TextStyle(fontSize: 13),
              ),
            )),
      ],
    );
  }

  Widget _buildTextSection({
    required IconData icon,
    required String title,
    required String text,
    Color? color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.purple),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: color ?? Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _showFullInsightDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.purple),
            SizedBox(width: 8),
            Text('Full Pattern Analysis'),
          ],
        ),
        content: SingleChildScrollView(
          child: Text(
            data['content']?.toString() ?? 'No additional details',
            style: const TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
