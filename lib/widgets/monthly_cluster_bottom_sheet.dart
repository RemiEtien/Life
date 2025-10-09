import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../memory.dart';
import '../utils/emotion_colors.dart';

/// BottomSheet для отображения информации о месячном кластере
class MonthlyClusterBottomSheet extends ConsumerWidget {
  final String monthKey;
  final DateTime month;
  final List<Memory> memories;
  final VoidCallback onZoomToMonth;

  const MonthlyClusterBottomSheet({
    super.key,
    required this.monthKey,
    required this.month,
    required this.memories,
    required this.onZoomToMonth,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthName = DateFormat.yMMMM().format(month); // "January 2024"

    // Подсчитываем статистику эмоций
    final emotionCounts = <String, int>{};
    for (final memory in memories) {
      if (memory.primaryEmotion != null) {
        emotionCounts[memory.primaryEmotion!] =
            (emotionCounts[memory.primaryEmotion!] ?? 0) + 1;
      }
    }

    // Сортируем эмоции по частоте
    final sortedEmotions = emotionCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ручка для свайпа
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Заголовок
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.calendar_month, size: 28, color: Theme.of(context).primaryColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        monthName,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${memories.length} ${memories.length == 1 ? 'воспоминание' : memories.length < 5 ? 'воспоминания' : 'воспоминаний'}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Статистика эмоций
          if (sortedEmotions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Преобладающие эмоции:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: sortedEmotions.take(5).map((entry) {
                      final emotionName = entry.key;
                      final count = entry.value;
                      final color = EmotionColors.getColor(emotionName);

                      return Chip(
                        avatar: CircleAvatar(
                          backgroundColor: color,
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        label: Text(
                          emotionName[0].toUpperCase() + emotionName.substring(1),
                        ),
                        backgroundColor: color.withOpacity(0.1),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
          ],

          // Сетка воспоминаний
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Открыть memory_view_screen с этим воспоминанием
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: memory.primaryEmotion != null
                          ? Border.all(
                              color: EmotionColors.getColor(memory.primaryEmotion),
                              width: 2,
                            )
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: memory.coverPath != null && memory.coverPath!.isNotEmpty
                          ? Image.network(
                              memory.coverPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return _buildPlaceholder(memory);
                              },
                            )
                          : _buildPlaceholder(memory),
                    ),
                  ),
                );
              },
            ),
          ),

          // Кнопка "Перейти к месяцу"
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                onZoomToMonth();
              },
              icon: const Icon(Icons.zoom_in),
              label: const Text('Перейти к месяцу'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(Memory memory) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.photo,
          color: Colors.grey[400],
          size: 32,
        ),
      ),
    );
  }
}
