import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import '../memory.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class IsarService {
  static Isar? _isar;

  /// **ИСПРАВЛЕНО:** Метод теперь требует `userId` для создания
  /// уникального файла базы данных для каждого пользователя (например, lifeline_user123.isar).
  /// Это ключевое изменение для изоляции данных.
  static Future<Isar> instance(String userId) async {
    try {
      // Используем префикс для большей надежности
      final dbName = 'lifeline_$userId';

      // Log isar_community migration tracking
      FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Requesting DB instance for user: $dbName');

      if (_isar != null && _isar!.isOpen) {
        // Если инстанс уже открыт, проверяем, что он для нужного пользователя.
        if (_isar!.name == dbName) {
          FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Reusing existing DB instance: $dbName');
          return _isar!;
        } else {
          // Если открыта БД другого пользователя, сначала закрываем ее.
          if (kDebugMode) {
            debugPrint(
                "[IsarService] Closing DB for user '${_isar?.name}' to open for '$dbName'.");
          }
          FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Switching DB from ${_isar?.name} to $dbName');
          await close();
        }
      }

      if (kDebugMode) {
        debugPrint("[IsarService] Opening DB for user '$dbName'.");
      }

      FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Opening new DB instance: $dbName');
      final dir = await getApplicationDocumentsDirectory();

      _isar = await Isar.open(
        [MemorySchema],
        directory: dir.path,
        name: dbName, // Используем уникальное имя для файла БД
        inspector: false,
      );

      FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] ✅ Successfully opened DB: $dbName, isOpen: ${_isar!.isOpen}');
      FirebaseCrashlytics.instance.setCustomKey('isar_db_name', dbName);
      FirebaseCrashlytics.instance.setCustomKey('isar_is_open', _isar!.isOpen);

      return _isar!;
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] ❌ CRITICAL ERROR opening DB for user: $userId');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'isar_community database open failed',
        fatal: true,
      );
      rethrow;
    }
  }

  /// **ИСПРАВЛЕНО:** Метод теперь просто закрывает соединение с БД,
  /// НЕ удаляя файл с диска. Данные пользователя сохраняются для следующего входа.
  static Future<void> close() async {
    try {
      if (_isar != null && _isar!.isOpen) {
        if (kDebugMode) {
          debugPrint("[IsarService] Closing DB instance for user '${_isar?.name}'.");
        }
        FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] Closing DB instance: ${_isar?.name}');
        await _isar!.close();
        _isar = null;
        FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] ✅ Successfully closed DB');
      }
    } catch (e, stack) {
      FirebaseCrashlytics.instance.log('[ISAR_COMMUNITY] ❌ ERROR closing DB');
      FirebaseCrashlytics.instance.recordError(
        e,
        stack,
        reason: 'isar_community database close failed',
        fatal: false,
      );
      rethrow;
    }
  }
}
