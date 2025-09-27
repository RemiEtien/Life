import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/models/user_profile.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';

/// **НОВОЕ:** Исключение, выбрасываемое при попытке шифрования/дешифрования
/// в заблокированном состоянии.
class EncryptionLockedException implements Exception {
  final String message =
      "Encryption service is locked. Unlock with master password before proceeding.";
  @override
  String toString() => message;
}

// Represents the state of encryption for the current user session.
enum EncryptionState {
  // Encryption has not been set up by the user.
  notConfigured,
  // Encryption is configured, but the master password hasn't been entered yet.
  locked,
  // The master password has been entered, and the app can encrypt/decrypt.
  unlocked,
}

/// A service to handle client-side AES-256 end-to-end encryption.
/// The encryption key is derived from a user's master password and stored
/// securely, encrypted, in their profile.
class EncryptionService extends StateNotifier<EncryptionState> {
  final Ref _ref;
  // **УДАЛЕНО:** Ключ больше не кэшируется в FlutterSecureStorage.

  Key? _unlockedDEK; // Data Encryption Key, cached in memory for the session.

  EncryptionService(this._ref) : super(EncryptionState.notConfigured) {
    // Listen to the user profile to initialize and update state reactively.
    _ref.listen(userProfileProvider, (previous, next) {
      _initializeState(next.asData?.value);
    }, fireImmediately: true);
  }

  Future<void> _initializeState(UserProfile? userProfile) async {
    // Если профиль пользователя отсутствует (например, при выходе из системы или при первом запуске)
    if (userProfile == null) {
      // Если состояние уже 'locked' (например, было установлено вручную при выходе), оставляем его.
      // В противном случае, считаем, что шифрование не настроено.
      if (state != EncryptionState.locked) {
        state = EncryptionState.notConfigured;
      }
      _unlockedDEK = null; // Всегда очищаем ключ
      return;
    }

    // Если профиль пользователя СУЩЕСТВУЕТ
    if (!userProfile.isEncryptionEnabled) {
      _unlockedDEK = null;
      state = EncryptionState.notConfigured;
    } else {
      _unlockedDEK = null;
      state = EncryptionState.locked;
    }
  }

  /// Sets up encryption for the first time for a user.
  /// Generates DEK, salt, and saves the wrapped DEK to the user's profile.
  Future<void> setupEncryption(String masterPassword) async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null) throw Exception("User profile not found.");

    // 1. Generate a new random Data Encryption Key (DEK).
    final newDEK = Key.fromSecureRandom(32); // 256-bit

    // 2. Generate a new random salt.
    final salt = _generateRandomBytes(16);

    // 3. Derive the Key Encryption Key (KEK) from the master password and salt.
    final kek = _deriveKey(masterPassword, salt);

    // 4. "Wrap" (encrypt) the DEK with the KEK using AES-GCM.
    final iv = IV.fromSecureRandom(12); // GCM standard is 12 bytes
    // **ИЗМЕНЕНО:** Используем AESMode.gcm
    final encrypter = Encrypter(AES(kek, mode: AESMode.gcm));
    final encryptedDEK = encrypter.encrypt(newDEK.base64, iv: iv);
    // Структура хранит IV и зашифрованные данные (которые включают auth tag)
    final wrappedDEK = '${iv.base64}:${encryptedDEK.base64}';

    // 5. Save the salt and wrapped DEK to Firestore.
    final updatedProfile = userProfile.copyWith(
      isEncryptionEnabled: true,
      salt: base64.encode(salt),
      wrappedDEK: wrappedDEK,
    );
    await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);

    // 6. Unlock the current session.
    _unlockedDEK = newDEK;
    // **УДАЛЕНО:** Больше не сохраняем ключ в хранилище.
    state = EncryptionState.unlocked;
  }

  /// Attempts to unlock the session by decrypting the stored DEK.
  Future<bool> unlockSession(String masterPassword) async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile?.wrappedDEK == null || userProfile?.salt == null) {
      return false; // Encryption not configured
    }

    try {
      final salt = base64.decode(userProfile!.salt!);
      final wrappedDEKParts = userProfile.wrappedDEK!.split(':');
      final iv = IV.fromBase64(wrappedDEKParts[0]);
      final encryptedDEK = Encrypted.fromBase64(wrappedDEKParts[1]);

      final kek = _deriveKey(masterPassword, salt);
      final gcmEncrypter = Encrypter(AES(kek, mode: AESMode.gcm));
      String decryptedDEKString;
      try {
        decryptedDEKString = gcmEncrypter.decrypt(encryptedDEK, iv: iv);
      } catch (error) {
        try {
          final legacyEncrypter = Encrypter(AES(kek));
          decryptedDEKString = legacyEncrypter.decrypt(encryptedDEK, iv: iv);
        } catch (legacyError) {
          if (kDebugMode) {
            print("Failed to unlock session (likely wrong password): $legacyError");
          }
          return false;
        }
      }
      _unlockedDEK = Key.fromBase64(decryptedDEKString);
      state = EncryptionState.unlocked;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to unlock session (likely wrong password): $e");
      }
      return false;
    }
  }

  /// Changes the user's master password.
  Future<bool> changeMasterPassword(
      String oldPassword, String newPassword) async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null || !userProfile.isEncryptionEnabled) {
      return false; // Encryption not enabled
    }

    // 1. Verify the old password by trying to unlock the session
    final unlocked = await unlockSession(oldPassword);
    if (!unlocked || _unlockedDEK == null) {
      // If unlock fails, the old password was incorrect.
      return false;
    }

    // At this point, _unlockedDEK contains the decrypted Data Encryption Key.

    // 2. Generate a NEW salt for the NEW password.
    final newSalt = _generateRandomBytes(16);

    // 3. Derive the new Key Encryption Key (KEK) from the new password and new salt.
    final newKek = _deriveKey(newPassword, newSalt);

    // 4. Re-wrap (encrypt) the existing DEK with the NEW KEK using AES-GCM.
    final iv = IV.fromSecureRandom(12);
    // **ИЗМЕНЕНО:** Используем AESMode.gcm
    final encrypter = Encrypter(AES(newKek, mode: AESMode.gcm));
    final encryptedDEK = encrypter.encrypt(_unlockedDEK!.base64, iv: iv);
    final newWrappedDEK = '${iv.base64}:${encryptedDEK.base64}';

    // 5. Update the user's profile with the new salt and new wrapped DEK.
    final updatedProfile = userProfile.copyWith(
      salt: base64.encode(newSalt),
      wrappedDEK: newWrappedDEK,
    );
    await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);

    // The session remains unlocked with the same DEK.
    return true;
  }

  /// Locks the session by clearing the cached DEK.
  Future<void> lockSession() async {
    // ИСПРАВЛЕНО: Состояние должно переходить в 'locked', если оно было 'unlocked',
    // независимо от текущего профиля пользователя. Это предотвращает
    // неправильный переход в 'notConfigured' во время выхода из системы.
    if (state == EncryptionState.unlocked) {
      _unlockedDEK = null;
      state = EncryptionState.locked;
      if (kDebugMode) {
        print("[EncryptionService] Session locked.");
      }
    }
  }

  String? encrypt(String? plainText) {
    if (plainText == null || plainText.isEmpty) {
      return plainText;
    }
    // **ИЗМЕНЕНО:** Выбрасываем исключение, если сервис заблокирован.
    if (state != EncryptionState.unlocked || _unlockedDEK == null) {
      throw EncryptionLockedException();
    }
    final iv = IV.fromSecureRandom(12); // GCM standard
    // **ИЗМЕНЕНО:** Используем AESMode.gcm
    final encrypter = Encrypter(AES(_unlockedDEK!, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // **ИЗМЕНЕНО:** Добавляем префикс для версионирования.
    return 'gcm_v1:${iv.base64}:${encrypted.base64}';
  }

  String? decrypt(String? encryptedText) {
    if (encryptedText == null ||
        encryptedText.isEmpty ||
        !isValueEncrypted(encryptedText)) {
      return encryptedText;
    }
    if (state != EncryptionState.unlocked || _unlockedDEK == null) {
      throw EncryptionLockedException();
    }
    try {
      final parts = encryptedText.split(':');
      if (parts.length == 3 && parts.first == 'gcm_v1') {
        final iv = IV.fromBase64(parts[1]);
        final encrypted = Encrypted.fromBase64(parts[2]);
        final encrypter = Encrypter(AES(_unlockedDEK!, mode: AESMode.gcm));
        return encrypter.decrypt(encrypted, iv: iv);
      } else if (parts.length == 2) {
        final iv = IV.fromBase64(parts[0]);
        final encrypted = Encrypted.fromBase64(parts[1]);
        final legacyEncrypter = Encrypter(AES(_unlockedDEK!));
        return legacyEncrypter.decrypt(encrypted, iv: iv);
      }
      throw Exception('Unsupported encrypted payload format');
    } catch (e) {
      if (kDebugMode) print('Decryption failed: $e');
      return '[Decryption Error]';
    }
  }

  /// РЕАЛИЗАЦИЯ ПРИНЦИПА 1: Возвращает новую, расшифрованную копию, не изменяя оригинал
  Memory decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    return m.copyWith(
        content: decrypt(m.content),
        reflectionImpact: decrypt(m.reflectionImpact),
        reflectionLesson: decrypt(m.reflectionLesson),
        reflectionAutoThought: decrypt(m.reflectionAutoThought),
        reflectionEvidenceFor: decrypt(m.reflectionEvidenceFor),
        reflectionEvidenceAgainst: decrypt(m.reflectionEvidenceAgainst),
        reflectionReframe: decrypt(m.reflectionReframe),
        reflectionAction: decrypt(m.reflectionAction));
  }

  bool isValueEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;

    if (value.startsWith('gcm_v1:')) {
      final parts = value.split(':');
      if (parts.length != 3) return false;
      try {
        base64.decode(parts[1]); // iv
        base64.decode(parts[2]); // encrypted data + tag
        return true;
      } catch (_) {
        return false;
      }
    }

    final legacyParts = value.split(':');
    if (legacyParts.length == 2) {
      try {
        final ivBytes = base64.decode(legacyParts[0]);
        final cipherBytes = base64.decode(legacyParts[1]);
        if (ivBytes.length == 16 && cipherBytes.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // fall through to return false
      }
    }

    return false;
  }

  Key _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 100000, 32)); // 32 bytes for AES-256
    return Key(derivator.process(Uint8List.fromList(utf8.encode(password))));
  }

  Uint8List _generateRandomBytes(int length) {
    return IV.fromSecureRandom(length).bytes;
  }
}

