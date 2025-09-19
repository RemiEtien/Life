import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/models/user_profile.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/digests/sha256.dart';

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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const _dekStorageKey = 'lifeline_unlocked_dek';

  Key? _unlockedDEK; // Data Encryption Key, cached in memory for the session.

  EncryptionService(this._ref) : super(EncryptionState.notConfigured) {
    // Listen to the user profile to initialize and update state reactively.
    _ref.listen(userProfileProvider, (previous, next) {
      _initializeState(next.asData?.value);
    }, fireImmediately: true);
  }

  Future<void> _initializeState(UserProfile? userProfile) async {
    if (userProfile == null || !userProfile.isEncryptionEnabled) {
      await _secureStorage.delete(key: _dekStorageKey);
      _unlockedDEK = null;
      state = EncryptionState.notConfigured;
      return;
    }

    // Check if the DEK was cached from a previous session unlock.
    final cachedDEK = await _secureStorage.read(key: _dekStorageKey);
    if (cachedDEK != null) {
      _unlockedDEK = Key.fromBase64(cachedDEK);
      state = EncryptionState.unlocked;
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

    // 4. "Wrap" (encrypt) the DEK with the KEK.
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(kek));
    final encryptedDEK = encrypter.encrypt(newDEK.base64, iv: iv);
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
    await _secureStorage.write(key: _dekStorageKey, value: _unlockedDEK!.base64);
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
      final encrypter = Encrypter(AES(kek));

      final decryptedDEKString = encrypter.decrypt(encryptedDEK, iv: iv);
      _unlockedDEK = Key.fromBase64(decryptedDEKString);

      await _secureStorage.write(
          key: _dekStorageKey, value: _unlockedDEK!.base64);
      state = EncryptionState.unlocked;
      return true;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to unlock session (likely wrong password): $e");
      }
      return false;
    }
  }
  
  // --- НОВЫЙ МЕТОД ---
  /// Changes the user's master password.
  Future<bool> changeMasterPassword(String oldPassword, String newPassword) async {
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

    // 4. Re-wrap (encrypt) the existing DEK with the NEW KEK.
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(newKek));
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
    _unlockedDEK = null;
    await _secureStorage.delete(key: _dekStorageKey);

    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile?.isEncryptionEnabled == true) {
      state = EncryptionState.locked;
    } else {
      state = EncryptionState.notConfigured;
    }
  }

  String? encrypt(String? plainText) {
    if (plainText == null ||
        plainText.isEmpty ||
        state != EncryptionState.unlocked ||
        _unlockedDEK == null) {
      return plainText;
    }
    final iv = IV.fromSecureRandom(16);
    final encrypter = Encrypter(AES(_unlockedDEK!));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String? decrypt(String? encryptedText) {
    if (encryptedText == null ||
        encryptedText.isEmpty ||
        !isValueEncrypted(encryptedText)) {
      return encryptedText;
    }
    if (state != EncryptionState.unlocked || _unlockedDEK == null) {
      return null;
    }
    try {
      final parts = encryptedText.split(':');
      final iv = IV.fromBase64(parts[0]);
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encrypter = Encrypter(AES(_unlockedDEK!));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      if (kDebugMode) print("Decryption failed: $e");
      return "[Decryption Error]";
    }
  }

  Memory decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    final decryptedMemory = m;
    decryptedMemory.content = decrypt(m.content);
    decryptedMemory.reflectionImpact = decrypt(m.reflectionImpact);
    decryptedMemory.reflectionLesson = decrypt(m.reflectionLesson);
    decryptedMemory.reflectionAutoThought = decrypt(m.reflectionAutoThought);
    decryptedMemory.reflectionEvidenceFor = decrypt(m.reflectionEvidenceFor);
    decryptedMemory.reflectionEvidenceAgainst = decrypt(m.reflectionEvidenceAgainst);
    decryptedMemory.reflectionReframe = decrypt(m.reflectionReframe);
    decryptedMemory.reflectionAction = decrypt(m.reflectionAction);
    
    return decryptedMemory;
  }

  bool isValueEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;
    final parts = value.split(':');
    if (parts.length != 2) return false;
    try {
      base64.decode(parts[0]);
      base64.decode(parts[1]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Key _deriveKey(String password, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, 100000,
          32)); 
    return Key(derivator.process(Uint8List.fromList(utf8.encode(password))));
  }

  Uint8List _generateRandomBytes(int length) {
    return IV.fromSecureRandom(length).bytes;
  }
}

