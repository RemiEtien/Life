import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../memory.dart';
import '../utils/emotion_colors.dart';
import '../screens/memory_view_screen.dart';

/// BottomSheet для отображения информации о месячном кластере
class MonthlyClusterBottomSheet extends ConsumerStatefulWidget {
  final String monthKey;
  final DateTime month;
  final List<Memory> memories;
  final VoidCallback onZoomToMonth;
  final String userId;
  final Map<String, ui.Image> images;
  final ScrollController scrollController;

  const MonthlyClusterBottomSheet({
    super.key,
    required this.monthKey,
    required this.month,
    required this.memories,
    required this.onZoomToMonth,
    required this.userId,
    required this.images,
    required this.scrollController,
  });

  @override
  ConsumerState<MonthlyClusterBottomSheet> createState() => _MonthlyClusterBottomSheetState();
}

class _MonthlyClusterBottomSheetState extends ConsumerState<MonthlyClusterBottomSheet> {
  Memory? selectedCoverMemory;

  @override
  Widget build(BuildContext context) {
    final monthName = DateFormat.yMMMM().format(widget.month); // "January 2024"

    // Подсчитываем статистику эмоций
    final emotionCounts = <String, int>{};
    for (final memory in widget.memories) {
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
        color: const Color(0xFF1a1a2a).withAlpha(242),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: Colors.white.withAlpha(51)),
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

          // Строка поиска
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(color: Colors.white.withAlpha(128)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withAlpha(178)),
                filled: true,
                fillColor: Colors.black.withAlpha(76),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                // TODO: Implement search filtering
              },
            ),
          ),

          // Заголовок месяца и количество
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  monthName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.memories.length}',
                  style: TextStyle(
                    color: Colors.white.withAlpha(179),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Статистика эмоций
          if (sortedEmotions.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
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
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: color.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Сетка воспоминаний
          Expanded(
            child: GridView.builder(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1,
              ),
              itemCount: widget.memories.length,
              itemBuilder: (context, index) {
                final memory = widget.memories[index];
                final dateStr = DateFormat('d MMM').format(memory.date);
                final isSelected = selectedCoverMemory?.id == memory.id;

                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(context);
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => MemoryViewScreen(
                        memory: memory,
                        userId: widget.userId,
                      ),
                    ));
                  },
                  onLongPress: () {
                    setState(() {
                      selectedCoverMemory = memory;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Выбрана обложка кластера: ${memory.title.isEmpty ? "Без названия" : memory.title}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.blue, width: 3)
                          : memory.primaryEmotion != null
                              ? Border.all(color: EmotionColors.getColor(memory.primaryEmotion), width: 2)
                              : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Image or placeholder
                          memory.coverPath != null && memory.coverPath!.isNotEmpty && widget.images[memory.coverPath] != null
                              ? RawImage(image: widget.images[memory.coverPath], fit: BoxFit.cover)
                              : _buildPlaceholder(memory),

                          // Selected cover indicator
                          if (isSelected)
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                                child: const Icon(Icons.star, color: Colors.white, size: 16),
                              ),
                            ),

                          // Gradient overlay for text readability
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (memory.title.isNotEmpty)
                                    Text(
                                      memory.title,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 9)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                widget.onZoomToMonth();
              },
              icon: const Icon(Icons.zoom_in),
              label: const Text('Перейти к месяцу'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
