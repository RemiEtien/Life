import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// Тип сообщения для разного визуального представления.
enum MessageType { success, info, error }

/// Модель данных для одного всплывающего сообщения.
@immutable
class FloatingMessage {
  final String id;
  final String message;
  final MessageType type;
  final IconData icon;
  final Duration duration;

  const FloatingMessage({
    required this.id,
    required this.message,
    required this.type,
    required this.icon,
    this.duration = const Duration(seconds: 4),
  });

  /// Возвращает цвет в зависимости от типа сообщения.
  Color get color {
    switch (type) {
      case MessageType.success:
        return Colors.green.shade400;
      case MessageType.info:
        return Colors.blue.shade400;
      case MessageType.error:
        return Colors.red.shade400;
    }
  }
}

/// Notifier для управления состоянием списка сообщений.
class MessageNotifier extends StateNotifier<List<FloatingMessage>> {
  MessageNotifier() : super([]);

  /// Добавляет новое сообщение в очередь.
  /// Старые сообщения автоматически удаляются через 4 секунды.
  void addMessage(String message, {MessageType type = MessageType.info}) {
    final icon = _getIconForType(type);
    final id = const Uuid().v4();

    state = [FloatingMessage(id: id, message: message, type: type, icon: icon), ...state];

    Timer(const Duration(seconds: 4), () {
      _removeMessage(id);
    });
  }

  void _removeMessage(String id) {
    state = state.where((m) => m.id != id).toList();
  }

  IconData _getIconForType(MessageType type) {
    switch (type) {
      case MessageType.success:
        return Icons.check_circle_outline;
      case MessageType.info:
        return Icons.info_outline;
      case MessageType.error:
        return Icons.error_outline;
    }
  }
}

/// Провайдер для доступа к сервису сообщений из любого места в приложении.
final messageProvider = StateNotifierProvider<MessageNotifier, List<FloatingMessage>>(
  (ref) => MessageNotifier(),
);
