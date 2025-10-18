import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Smart Prompts Card Widget
/// Displays AI-generated follow-up questions in MemoryEditScreen
class SmartPromptsCard extends StatelessWidget {
  final String userId;
  final String? memoryId;

  const SmartPromptsCard({
    super.key,
    required this.userId,
    this.memoryId,
  });

  @override
  Widget build(BuildContext context) {
    if (memoryId == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users/$userId/insights')
          .where('type', isEqualTo: 'smart_prompt')
          .where('relatedMemories', arrayContains: memoryId)
          .where('dismissed', isEqualTo: false)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final insight = snapshot.data!.docs.first;
        final questions = (insight['questions'] as List<dynamic>?)
                ?.map((q) => q.toString())
                .toList() ??
            [];

        if (questions.isEmpty) return const SizedBox.shrink();

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.blue.shade50.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'AI suggests:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await insight.reference.update({'dismissed': true});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...questions.map((q) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text('• $q', style: const TextStyle(fontSize: 13)),
                    )),
              ],
            ),
          ),
        );
      },
    );
  }
}
