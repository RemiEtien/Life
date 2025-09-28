import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import '../memory.dart';
import 'package:path_provider/path_provider.dart';

class IsarService {
  static Isar? _isar;

  /// **ИСПРАВЛЕНО:** Метод теперь требует `userId` для создания
  /// уникального файла базы данных для каждого пользователя (например, lifeline_user123.isar).
  /// Это ключевое изменение для изоляции данных.
  static Future<Isar> instance(String userId) async {
    // Используем префикс для большей надежности
    final dbName = 'lifeline_$userId';

    if (_isar != null && _isar!.isOpen) {
      // Если инстанс уже открыт, проверяем, что он для нужного пользователя.
      if (_isar!.name == dbName) {
        return _isar!;
      } else {
        // Если открыта БД другого пользователя, сначала закрываем ее.
        if (kDebugMode) {
          print(
              "[IsarService] Closing DB for user '${_isar?.name}' to open for '$dbName'.");
        }
        await close();
      }
    }

    if (kDebugMode) {
      print("[IsarService] Opening DB for user '$dbName'.");
    }
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [MemorySchema],
      directory: dir.path,
      name: dbName, // Используем уникальное имя для файла БД
      inspector: false,
    );
    return _isar!;
  }

  /// **ИСПРАВЛЕНО:** Метод теперь просто закрывает соединение с БД,
  /// НЕ удаляя файл с диска. Данные пользователя сохраняются для следующего входа.
  static Future<void> close() async {
    if (_isar != null && _isar!.isOpen) {
      if (kDebugMode) {
        print("[IsarService] Closing DB instance for user '${_isar?.name}'.");
      }
      await _isar!.close();
      _isar = null;
    }
  }
}
