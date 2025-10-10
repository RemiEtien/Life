import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' hide Key;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

import '../memory.dart';
import '../models/user_profile.dart';
import '../providers/application_providers.dart';
import 'crypto_isolate.dart';

// --- NEW KEYS FOR SECURE STORAGE ---
const String _kEncryptedDekKey = 'lifeline_encrypted_dek_v2';
const String _kSessionKey = 'lifeline_session_key_v2';

/// Exception thrown when trying to encrypt/decrypt while the service is locked.
class EncryptionLockedException implements Exception {
  final String message =
      'Encryption service is locked. Unlock with master password before proceeding.';
  @override
  String toString() => message;
}

/// NEW: Exception for when per-memory auth is needed.
class PerMemoryAuthenticationRequiredException implements Exception {
  final int memoryId;
  const PerMemoryAuthenticationRequiredException(this.memoryId);
  @override
  String toString() => 'This memory requires individual authentication.';
}

/// Exception for unlock errors, including brute-force protection.
class EncryptionUnlockException implements Exception {
  final String message;
  const EncryptionUnlockException(this.message);
  @override
  String toString() => message;
}

/// Exception thrown when decryption fails (wrong key, corrupted data, etc.)
class DecryptionFailedException implements Exception {
  final String message;
  final dynamic originalError;
  const DecryptionFailedException(this.message, {this.originalError});
  @override
  String toString() => 'DecryptionFailedException: $message${originalError != null ? ' (${originalError.toString()})' : ''}';
}

// Represents the state of encryption for the current user session.
enum EncryptionState {
  notConfigured,
  locked,
  unlocked,
}

/// A service to handle client-side AES-256 end-to-end encryption.
class EncryptionService extends StateNotifier<EncryptionState> {
  final Ref _ref;
  final _secureStorage = const FlutterSecureStorage();
  Key? _unlockedDEK; // Data Encryption Key, cached in memory for the session.
  final Set<int> _unlockedMemoryIdsInSession = {};

  // --- Brute-force protection fields ---
  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationSeconds = 30;
  String? _currentUserId;

  bool _isAttemptingUnlock = false;

  EncryptionService(this._ref) : super(EncryptionState.notConfigured) {
    _ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (previous, next) {
      final prevProfile = previous?.asData?.value;
      final nextProfile = next.asData?.value;
      _initializeState(prevProfile, nextProfile);
    }, fireImmediately: true);
  }

  /// NEW: Resets the entire service to its initial state upon user sign-out.
  ///
  /// SECURITY NOTE: Quick Unlock keys remain in secure storage after logout.
  /// This is intentional for better UX (matches industry standard: WhatsApp,
  /// Telegram, 1Password, Signal). Keys are protected by device biometrics,
  /// making cross-user attacks practically impossible.
  ///
  /// TODO v1.1: Add user preference "Clear Quick Unlock on logout" for
  /// paranoid users or shared devices.
  void resetOnSignOut() {
    state = EncryptionState.notConfigured;
    _unlockedDEK = null;
    _currentUserId = null;
    _isAttemptingUnlock = false;
    _unlockedMemoryIdsInSession.clear();
    _failedAttempts = 0;
    _lockoutEndTime = null;
    if (kDebugMode) {
      debugPrint('[EncryptionService] Service state has been completely reset for sign-out.');
    }
  }

  /// Signals the start of an unlock attempt to prevent auto-locking.
  void prepareForUnlockAttempt() {
    _isAttemptingUnlock = true;
    if (kDebugMode) {
      debugPrint(
          '[EncryptionService] Preparing for unlock attempt. Auto-lock disabled.');
    }
  }

  /// Signals the end of an unlock attempt to re-enable auto-locking.
  void finishUnlockAttempt() {
    _isAttemptingUnlock = false;
    if (kDebugMode) {
      debugPrint(
          '[EncryptionService] Finished unlock attempt. Auto-lock re-enabled.');
    }
  }

  /// Checks if a specific memory has been unlocked during this session.
  bool isMemoryUnlocked(int memoryId) =>
      _unlockedMemoryIdsInSession.contains(memoryId);

  /// Marks a memory as unlocked for the current session.
  void markMemoryAsUnlocked(int memoryId) {
    _unlockedMemoryIdsInSession.add(memoryId);
  }

  void _initializeState(UserProfile? previousProfile, UserProfile? newProfile) {
    // Condition 1: User logged out. Reset everything.
    if (newProfile == null) {
      if (state != EncryptionState.notConfigured) {
        _unlockedDEK = null;
        _currentUserId = null;
        _isAttemptingUnlock = false;
        state = EncryptionState.notConfigured;
      }
      return;
    }

    // FIX: Verify user is actually authenticated before switching to locked state
    // This prevents showing biometric prompt after sign-out when stale profile data arrives
    final currentUser = _ref.read(authStateChangesProvider).asData?.value;
    if (currentUser == null || currentUser.uid != newProfile.uid) {
      // Profile data doesn't match current auth state - ignore it
      if (kDebugMode) {
        debugPrint('[EncryptionService] Profile data for ${newProfile.uid} ignored - no matching authenticated user');
      }
      return;
    }

    // Condition 2: User has changed. Reset everything for the new user.
    if (_currentUserId != newProfile.uid) {
      _unlockedDEK = null;
      _currentUserId = newProfile.uid;
      _isAttemptingUnlock = false;
      state = newProfile.isEncryptionEnabled
          ? EncryptionState.locked
          : EncryptionState.notConfigured;
      return;
    }

    // Condition 3: Encryption was just disabled for the current user.
    if ((previousProfile?.isEncryptionEnabled ?? false) &&
        !newProfile.isEncryptionEnabled) {
      _unlockedDEK = null;
      state = EncryptionState.notConfigured;
      disableQuickUnlock(); // Also disable quick unlock as a safety measure.
      return;
    }

    // Condition 4: Encryption was just enabled for the current user.
    if (!(previousProfile?.isEncryptionEnabled ?? false) &&
        newProfile.isEncryptionEnabled) {
      _unlockedDEK = null;
      state = EncryptionState.locked;
      return;
    }
  }

  /// Sets up encryption for the first time.
  Future<void> setupEncryption(String masterPassword) async {
    debugPrint('[EncryptionService] setupEncryption started');
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null) {
      debugPrint('[EncryptionService] ERROR: User profile not found');
      throw Exception('User profile not found.');
    }
    debugPrint('[EncryptionService] User profile loaded: ${userProfile.uid}');

    debugPrint('[EncryptionService] Generating encryption keys');
    final newDEK = Key.fromSecureRandom(32);
    final salt = _generateRandomBytes(16);
    final kek = await _deriveKey(masterPassword, salt, useIsolate: true);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(kek, mode: AESMode.gcm));
    final encryptedDEK = encrypter.encrypt(newDEK.base64, iv: iv);
    final wrappedDEK = '${iv.base64}:${encryptedDEK.base64}';
    debugPrint('[EncryptionService] Keys generated successfully');

    final updatedProfile = userProfile.copyWith(
      isEncryptionEnabled: true,
      salt: base64.encode(salt),
      wrappedDEK: wrappedDEK,
    );

    // Update internal state first (no rebuild)
    debugPrint('[EncryptionService] Updating internal DEK state');
    _unlockedDEK = newDEK;

    // Update Firestore (may take time, no rebuild yet)
    debugPrint('[EncryptionService] Updating Firestore profile');
    await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);
    debugPrint('[EncryptionService] Firestore profile updated');

    // Finally update state (triggers rebuild after Firestore update completes)
    debugPrint('[EncryptionService] Setting state to unlocked');
    state = EncryptionState.unlocked;
    debugPrint('[EncryptionService] setupEncryption completed successfully');
  }

  /// Attempts to unlock the session with the master password.
  Future<void> unlockSession(String masterPassword) async {
    if (_lockoutEndTime != null && _lockoutEndTime!.isAfter(DateTime.now())) {
      final remainingSeconds =
          _lockoutEndTime!.difference(DateTime.now()).inSeconds;
      throw EncryptionUnlockException(
          'Too many attempts. Please try again in $remainingSeconds seconds.');
    }

    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile?.wrappedDEK == null || userProfile?.salt == null) {
      _handleFailedAttempt();
      throw const EncryptionUnlockException('Incorrect password.');
    }

    try {
      final dek = await _unwrapDek(masterPassword, userProfile!.salt!,
          userProfile.wrappedDEK!, true);
      _unlockedDEK = dek;
      state = EncryptionState.unlocked;
      _failedAttempts = 0;
      _lockoutEndTime = null;

      // Auto-enable quick unlock if it was enabled but keys are missing (after reinstall)
      await _autoEnableQuickUnlockIfNeeded(masterPassword, userProfile);
    } catch (e) {
      try {
        final dek = await _unwrapDek(masterPassword, userProfile!.salt!,
            userProfile.wrappedDEK!, false);
        _unlockedDEK = dek;
        await _migrateEncryption(masterPassword, dek);
        state = EncryptionState.unlocked;
        _failedAttempts = 0;
        _lockoutEndTime = null;

        // Auto-enable quick unlock if it was enabled but keys are missing (after reinstall)
        await _autoEnableQuickUnlockIfNeeded(masterPassword, userProfile);
      } catch (finalError) {
        _handleFailedAttempt();
        final remaining = _maxFailedAttempts - _failedAttempts;
        if (remaining > 0) {
          throw EncryptionUnlockException(
              'Incorrect password. $remaining attempts remaining.');
        } else {
          throw const EncryptionUnlockException('Incorrect password.');
        }
      }
    }
  }

  /// Auto-enables quick unlock if it was previously enabled but keys are missing
  Future<void> _autoEnableQuickUnlockIfNeeded(String masterPassword, UserProfile profile) async {
    // Check if quick unlock is enabled in profile but keys are missing (after reinstall)
    if (profile.isQuickUnlockEnabled) {
      const aOptions = AndroidOptions(encryptedSharedPreferences: true);
      final sessionKeyB64 = await _secureStorage.read(key: _kSessionKey, aOptions: aOptions);

      // If profile says quick unlock is enabled but keys are missing, re-enable it
      if (sessionKeyB64 == null) {
        if (kDebugMode) {
          debugPrint('[EncryptionService] Auto-enabling quick unlock after reinstall');
        }
        await enableQuickUnlock(masterPassword);
      }
    }
  }

  /// Attempts to unlock using biometrics/PIN.
  Future<bool> attemptQuickUnlock() async {
    try {
      const aOptions = AndroidOptions(encryptedSharedPreferences: true);
      final sessionKeyB64 =
          await _secureStorage.read(key: _kSessionKey, aOptions: aOptions);
      final encryptedDekB64 = await _secureStorage.read(
          key: _kEncryptedDekKey, aOptions: aOptions);

      if (sessionKeyB64 == null || encryptedDekB64 == null) {
        // FIX as per friend's analysis
        if (kDebugMode) {
          debugPrint(
              '[EncryptionService] Quick Unlock keys not found. Disabling feature.');
        }
        await disableQuickUnlock();
        return false;
      }

      final sessionKey = Key.fromBase64(sessionKeyB64);
      final encryptedDekParts = encryptedDekB64.split(':');
      final iv = IV.fromBase64(encryptedDekParts[0]);
      final encrypted = Encrypted.fromBase64(encryptedDekParts[1]);

      final encrypter = Encrypter(AES(sessionKey, mode: AESMode.gcm));
      final dekBase64 = encrypter.decrypt(encrypted, iv: iv);

      _unlockedDEK = Key.fromBase64(dekBase64);
      state = EncryptionState.unlocked;
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EncryptionService] Error during quick unlock, disabling: $e');
      }
      await disableQuickUnlock();
      return false;
    }
  }

  /// Enables Quick Unlock after verifying master password.
  Future<bool> enableQuickUnlock(String masterPassword) async {
    if (_unlockedDEK == null) {
      try {
        await unlockSession(masterPassword);
      } catch (e) {
        return false;
      }
    }

    if (_unlockedDEK == null) return false;

    final sessionKey = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(sessionKey, mode: AESMode.gcm));
    final encryptedDEK = encrypter.encrypt(_unlockedDEK!.base64, iv: iv);
    final encryptedDEKB64 = '${iv.base64}:${encryptedDEK.base64}';

    const aOptions = AndroidOptions(encryptedSharedPreferences: true);
    await _secureStorage.write(
        key: _kSessionKey, value: sessionKey.base64, aOptions: aOptions);
    await _secureStorage.write(
        key: _kEncryptedDekKey, value: encryptedDEKB64, aOptions: aOptions);

    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile != null) {
      await _ref
          .read(userServiceProvider)
          .updateUserProfile(userProfile.copyWith(isQuickUnlockEnabled: true));
    }
    return true;
  }

  /// Disables Quick Unlock.
  Future<void> disableQuickUnlock() async {
    const aOptions = AndroidOptions(encryptedSharedPreferences: true);
    await _secureStorage.delete(key: _kSessionKey, aOptions: aOptions);
    await _secureStorage.delete(key: _kEncryptedDekKey, aOptions: aOptions);
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile != null && userProfile.isQuickUnlockEnabled) {
      await _ref
          .read(userServiceProvider)
          .updateUserProfile(userProfile.copyWith(
            isQuickUnlockEnabled: false,
            requireBiometricForMemory: false, // Also disable per-memory unlock
          ));
    }
  }

  /// Resets encryption completely:
  /// - Deletes all encrypted memories from local database and cloud
  /// - Removes encryption keys from secure storage
  /// - Disables encryption in user profile
  /// - Unlocks the session (since encryption is now disabled)
  ///
  /// This is a destructive operation that cannot be undone.
  /// Use this when the user forgets their master password.
  Future<void> resetEncryption() async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null) {
      throw Exception('User profile not found.');
    }

    try {
      // Step 1: Get all encrypted memories from local database
      final repo = _ref.read(memoryRepositoryProvider);
      if (repo != null) {
        final allMemories = await repo.getAllMemories();
        final encryptedMemories = allMemories.where((m) => m.isEncrypted).toList();

        if (encryptedMemories.isNotEmpty) {
          if (kDebugMode) {
            debugPrint('[EncryptionService] Found ${encryptedMemories.length} encrypted memories to delete');
          }

          // Step 2: Delete from Firestore
          final firestore = _ref.read(firestoreServiceProvider);
          for (final memory in encryptedMemories) {
            if (memory.firestoreId != null) {
              try {
                await firestore.deleteMemory(userProfile.uid, memory);
              } catch (e) {
                if (kDebugMode) {
                  debugPrint('[EncryptionService] Failed to delete memory ${memory.firestoreId} from Firestore: $e');
                }
                // Continue deleting other memories even if one fails
              }
            }
          }

          // Step 3: Delete from local database
          final encryptedIds = encryptedMemories.map((m) => m.id).toList();
          await repo.deleteAllByIds(encryptedIds);

          if (kDebugMode) {
            debugPrint('[EncryptionService] Deleted ${encryptedIds.length} encrypted memories from local database');
          }
        }
      }

      // Step 4: Clear Quick Unlock keys
      await disableQuickUnlock();

      // Step 5: Update user profile to disable encryption
      final updatedProfile = userProfile.copyWith(
        isEncryptionEnabled: false,
        isQuickUnlockEnabled: false,
        requireBiometricForMemory: false,
        salt: null,
        wrappedDEK: null,
      );
      await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);

      // Step 6: Clear in-memory state
      _unlockedDEK = null;
      _unlockedMemoryIdsInSession.clear();
      _failedAttempts = 0;
      _lockoutEndTime = null;

      // Step 7: Set state to notConfigured (unlocked since encryption is disabled)
      state = EncryptionState.notConfigured;

      if (kDebugMode) {
        debugPrint('[EncryptionService] Encryption reset completed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[EncryptionService] Error during encryption reset: $e');
      }
      rethrow;
    }
  }

  void _handleFailedAttempt() {
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      _lockoutEndTime =
          DateTime.now().add(const Duration(seconds: _lockoutDurationSeconds));
      _failedAttempts = 0;
    }
  }

  Future<Key> _unwrapDek(String password, String saltB64, String wrappedDek,
      bool useIsolate) async {
    final salt = base64.decode(saltB64);
    final wrappedDEKParts = wrappedDek.split(':');
    final iv = IV.fromBase64(wrappedDEKParts[0]);
    final encryptedDEK = Encrypted.fromBase64(wrappedDEKParts[1]);

    final kek = await _deriveKey(password, salt, useIsolate: useIsolate);
    final gcmEncrypter = Encrypter(AES(kek, mode: AESMode.gcm));
    String decryptedDEKString;
    try {
      decryptedDEKString = gcmEncrypter.decrypt(encryptedDEK, iv: iv);
    } catch (error) {
      final legacyEncrypter = Encrypter(AES(kek));
      decryptedDEKString = legacyEncrypter.decrypt(encryptedDEK, iv: iv);
    }
    return Key.fromBase64(decryptedDEKString);
  }

  Future<void> _migrateEncryption(String password, Key dek) async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null) return;

    final newSalt = _generateRandomBytes(16);
    final newKek = await _deriveKey(password, newSalt, useIsolate: true);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(newKek, mode: AESMode.gcm));
    final newEncryptedDEK = encrypter.encrypt(dek.base64, iv: iv);
    final newWrappedDEK = '${iv.base64}:${newEncryptedDEK.base64}';

    final updatedProfile = userProfile.copyWith(
      salt: base64.encode(newSalt),
      wrappedDEK: newWrappedDEK,
    );
    await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);
    if (kDebugMode) {
      debugPrint('[EncryptionService] User key migrated to stronger parameters.');
    }
  }

  /// Changes the user's master password.
  Future<bool> changeMasterPassword(
      String oldPassword, String newPassword) async {
    final userProfile = _ref.read(userProfileProvider).value;
    if (userProfile == null || !userProfile.isEncryptionEnabled) {
      return false;
    }
    try {
      await unlockSession(oldPassword);
      if (_unlockedDEK == null) return false;
    } catch (e) {
      return false;
    }

    final newSalt = _generateRandomBytes(16);
    final newKek = await _deriveKey(newPassword, newSalt, useIsolate: true);
    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(newKek, mode: AESMode.gcm));
    final encryptedDEK = encrypter.encrypt(_unlockedDEK!.base64, iv: iv);
    final newWrappedDEK = '${iv.base64}:${encryptedDEK.base64}';

    final updatedProfile = userProfile.copyWith(
      salt: base64.encode(newSalt),
      wrappedDEK: newWrappedDEK,
      isQuickUnlockEnabled:
          false, // Force disable quick unlock on password change
    );
    await _ref.read(userServiceProvider).updateUserProfile(updatedProfile);
    await disableQuickUnlock(); // Clear secure storage

    return true;
  }

  /// Locks the session by clearing the cached DEK.
  Future<void> lockSession() async {
    if (_isAttemptingUnlock) {
      if (kDebugMode) {
        debugPrint('[EncryptionService] Ignoring auto-lock during unlock attempt.');
      }
      return;
    }
    if (state == EncryptionState.unlocked) {
      _unlockedDEK = null;
      _unlockedMemoryIdsInSession.clear(); // NEW: Clear the set on lock
      state = EncryptionState.locked;
      if (kDebugMode) {
        debugPrint('[EncryptionService] Session locked.');
      }
    }
  }

  String? encrypt(String? plainText, {int? memoryId}) {
    if (plainText == null || plainText.isEmpty) {
      return plainText;
    }
    if (state != EncryptionState.unlocked || _unlockedDEK == null) {
      throw EncryptionLockedException();
    }

    // NEW: Check for per-memory authentication requirement
    final profile = _ref.read(userProfileProvider).value;
    if (memoryId != null && (profile?.requireBiometricForMemory ?? false)) {
      if (!isMemoryUnlocked(memoryId)) {
        throw PerMemoryAuthenticationRequiredException(memoryId);
      }
    }

    final iv = IV.fromSecureRandom(12);
    final encrypter = Encrypter(AES(_unlockedDEK!, mode: AESMode.gcm));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return 'gcm_v1:${iv.base64}:${encrypted.base64}';
  }

  String? decrypt(String? encryptedText, {int? memoryId}) {
    if (encryptedText == null ||
        encryptedText.isEmpty ||
        !isValueEncrypted(encryptedText)) {
      return encryptedText;
    }
    if (state != EncryptionState.unlocked || _unlockedDEK == null) {
      throw EncryptionLockedException();
    }

    // Check for per-memory authentication requirement
    final profile = _ref.read(userProfileProvider).value;
    if (memoryId != null && (profile?.requireBiometricForMemory ?? false)) {
      if (!isMemoryUnlocked(memoryId)) {
        throw PerMemoryAuthenticationRequiredException(memoryId);
      }
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
      throw const DecryptionFailedException('Unsupported encrypted payload format');
    } catch (e) {
      if (kDebugMode) debugPrint('Decryption failed: $e');
      // Re-throw as DecryptionFailedException if it's not already
      if (e is DecryptionFailedException) {
        rethrow;
      }
      throw DecryptionFailedException('Failed to decrypt content', originalError: e);
    }
  }

  Memory decryptMemory(Memory m) {
    if (!m.isEncrypted) return m;

    final memoryCopy = m.copyWith();

    return memoryCopy.copyWith(
      content: decrypt(m.content),
      reflectionImpact: decrypt(m.reflectionImpact),
      reflectionLesson: decrypt(m.reflectionLesson),
      reflectionAutoThought: decrypt(m.reflectionAutoThought),
      reflectionEvidenceFor: decrypt(m.reflectionEvidenceFor),
      reflectionEvidenceAgainst: decrypt(m.reflectionEvidenceAgainst),
      reflectionReframe: decrypt(m.reflectionReframe),
      reflectionAction: decrypt(m.reflectionAction),
    );
  }

  bool isValueEncrypted(String? value) {
    if (value == null || value.isEmpty) return false;
    if (value.startsWith('gcm_v1:')) {
      final parts = value.split(':');
      if (parts.length != 3) return false;
      try {
        base64.decode(parts[1]);
        base64.decode(parts[2]);
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
      } catch (_) {}
    }
    return false;
  }

  Future<Key> _deriveKey(String password, Uint8List salt,
      {required bool useIsolate}) async {
    if (useIsolate && !kIsWeb) {
      final port = ReceivePort();
      final isolateData = IsolateDeriveKeyRequest(
        password: password,
        salt: salt,
        sendPort: port.sendPort,
      );
      await Isolate.spawn(deriveKeyIsolateEntry, isolateData);
      final keyBytes = await port.first as Uint8List;
      return Key(keyBytes);
    } else {
      final iterations = useIsolate ? 310000 : 100000;
      final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
        ..init(Pbkdf2Parameters(salt, iterations, 32));
      return Key(derivator.process(Uint8List.fromList(utf8.encode(password))));
    }
  }

  Uint8List _generateRandomBytes(int length) {
    return IV.fromSecureRandom(length).bytes;
  }
}

