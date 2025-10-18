import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Predictive Insight Card Widget
/// Displays AI predictions based on similar past memories
class PredictiveInsightCard extends StatelessWidget {
  final String userId;
  final String? memoryId;
  final bool compact;

  const PredictiveInsightCard({
    super.key,
    required this.userId,
    this.memoryId,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (memoryId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/$userId/insights')
          .where('type', isEqualTo: 'predictive')
          .where('relatedMemories', arrayContains: memoryId)
          .where('dismissed', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final insight = snapshot.data!.docs.first;
        final data = insight.data() as Map<String, dynamic>;
        final content = data['content']?.toString() ?? '';
        final prediction = data['prediction'] as Map<String, dynamic>?;
        final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.5;
        final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

        if (content.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Colors.amber.shade50.withOpacity(0.4),
                  Colors.orange.shade50.withOpacity(0.3),
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
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.wb_twilight,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'AI Prediction',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            if (prediction != null)
                              Text(
                                'Based on ${prediction['similarPastCount'] ?? 0} similar memories',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Confidence indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConfidenceColor(confidence).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getConfidenceColor(confidence),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics,
                              size: 12,
                              color: _getConfidenceColor(confidence),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(confidence * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _getConfidenceColor(confidence),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
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
                  const SizedBox(height: 12),

                  // Content
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      content,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),

                  // Timestamp
                  if (createdAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Generated ${_formatRelativeTime(createdAt)}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],

                  // View similar memories button
                  if (!compact && (data['relatedMemories'] as List?)?.length != null) ...[
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        _showSimilarMemoriesDialog(context, data);
                      },
                      icon: const Icon(Icons.history, size: 16),
                      label: Text(
                        'View ${((data['relatedMemories'] as List).length - 1)} Similar Memories',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.orange;
    return Colors.grey;
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  void _showSimilarMemoriesDialog(
    BuildContext context,
    Map<String, dynamic> data,
  ) {
    final relatedMemories = (data['relatedMemories'] as List?)
            ?.map((id) => id.toString())
            .toList() ??
        [];

    // Remove current memory ID (first one)
    if (relatedMemories.isNotEmpty) {
      relatedMemories.removeAt(0);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.orange),
            SizedBox(width: 8),
            Text('Similar Past Memories'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI found ${relatedMemories.length} similar memories in your history.',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              'These memories helped inform the prediction above.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            // TODO: Add list of memory links when navigation is implemented
          ],
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
