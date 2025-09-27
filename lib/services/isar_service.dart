import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:lifeline/memory.dart';
import 'package:path_provider/path_provider.dart';

// ИСПРАВЛЕНИЕ: Функция для очистки userId от недопустимых символов в имени файла.
String _sanitizeUserIdForFilename(String userId) {
  // Заменяем все символы, не являющиеся буквами, цифрами, дефисом или подчеркиванием, на '_'
  return userId.replaceAll(RegExp(r'[^\w\-]'), '_');
}

class IsarService {
  static Isar? _isar;

  /// **ИСПРАВЛЕНО:** Метод теперь требует `userId` для создания
  /// уникального файла базы данных для каждого пользователя и включает логику миграции.
  static Future<Isar> instance(String userId) async {
    final sanitizedUserId = _sanitizeUserIdForFilename(userId);
    final dbName = 'lifeline_$sanitizedUserId';

    if (_isar != null && _isar!.isOpen) {
      if (_isar!.name == dbName) {
        return _isar!;
      } else {
        if (kDebugMode) {
          print(
              "[IsarService] Closing DB for user '${_isar?.name}' to open for '$dbName'.");
        }
        await close();
      }
    }
    
    final dir = await getApplicationDocumentsDirectory();
    
    // **НОВОЕ: Логика миграции для существующих пользователей**
    // Проверяем, существует ли старый файл с "грязным" именем
    final oldDbName = 'lifeline_$userId';
    final oldDbFile = File('${dir.path}/$oldDbName.isar');
    final newDbFile = File('${dir.path}/$dbName.isar');

    if (await oldDbFile.exists() && !await newDbFile.exists()) {
       if (kDebugMode) {
        print("[IsarService] Migrating DB file from '$oldDbName' to '$dbName'.");
      }
      try {
        await oldDbFile.rename(newDbFile.path);
        // Также переименовываем lock-файл
        final oldLockFile = File('${dir.path}/$oldDbName.isar.lock');
        if (await oldLockFile.exists()) {
            await oldLockFile.rename('${dir.path}/$dbName.isar.lock');
        }
      } catch (e) {
         if (kDebugMode) {
            print("[IsarService] Failed to migrate DB file: $e. Data may be lost.");
         }
      }
    }


    if (kDebugMode) {
      print("[IsarService] Opening DB for user '$dbName'.");
    }
    
    _isar = await Isar.open(
      [MemorySchema],
      directory: dir.path,
      name: dbName, 
      inspector: false,
    );
    return _isar!;
  }

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

