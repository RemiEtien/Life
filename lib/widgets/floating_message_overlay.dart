import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/message_service.dart';

/// Виджет, который отображает всплывающие сообщения поверх основного контента.
class FloatingMessageOverlay extends ConsumerWidget {
  const FloatingMessageOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Слушаем изменения в списке сообщений
    final messages = ref.watch(messageProvider);

    // ИЗМЕНЕНО: Позиционирование перенесено в нижнюю часть экрана.
    // Отступ 88.0 подобран, чтобы быть выше кнопки "+" и карточки статистики.
    return Positioned(
      bottom: 130.0,
      left: 16,
      right: 16,
      child: IgnorePointer(
        child: Center(
          child: Column(
            children: [
              // AnimatedSwitcher плавно показывает/скрывает самое новое сообщение
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      // ИЗМЕНЕНО: Анимация теперь происходит снизу вверх.
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: messages.isNotEmpty
                    ? _MessageCard(key: ValueKey(messages.first.id), message: messages.first)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Карточка для отображения одного сообщения.
class _MessageCard extends StatelessWidget {
  final FloatingMessage message;
  const _MessageCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: message.color.withOpacity(0.6),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(message.icon, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

