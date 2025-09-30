import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/application_providers.dart';
import 'isar_service.dart';
import 'user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final Ref _ref;
  bool _isInitialized = false;
  GoogleSignInAccount? _currentUser;
  Completer<GoogleSignInAccount?>? _signInCompleter;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventSubscription;

  AuthService(this._ref);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  UserService get _userService => _ref.read(userServiceProvider);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ИСПРАВЛЕНО: Правильная инициализация для v7.2.0 с ожиданием событий
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isInitialized) {
      try {
        await GoogleSignIn.instance.initialize();

        // ИСПРАВЛЕНО: Подписываемся на события и правильно обрабатываем состояние
        _authEventSubscription =
            GoogleSignIn.instance.authenticationEvents.listen((event) {
          switch (event) {
            case GoogleSignInAuthenticationEventSignIn():
              _currentUser = event.user;
              // Завершаем Completer если ждем результата
              if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
                _signInCompleter!.complete(event.user);
              }
              break;
            case GoogleSignInAuthenticationEventSignOut():
              _currentUser = null;
              // Завершаем Completer если ждем результата выхода
              if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
                _signInCompleter!.complete(null);
              }
              break;
          }
        });

        // Обрабатываем ошибки отдельно
        _authEventSubscription!.onError((error) {
          if (kDebugMode) {
            debugPrint('Google Sign-In error: $error');
          }
          // Завершаем Completer с ошибкой
          if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
            _signInCompleter!.completeError(error);
          }
        });

        _isInitialized = true;
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Failed to initialize Google Sign-In: $e');
        }
        throw Exception('Failed to initialize Google Sign-In: $e');
      }
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (context.mounted) {
        await _userService.ensureUserProfileExists(
            userCredential.user!, context);
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.sendEmailVerification();
      if (context.mounted) {
        await _userService.createUserProfile(userCredential.user!, context);
      }
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // *** КЛЮЧЕВОЕ ИСПРАВЛЕНИЕ: Вызываем полный сброс состояния шифрования ***
    // Это гарантирует, что при следующем запуске приложение не будет считать
    // себя заблокированным, а перейдет в состояние "notConfigured".
    _ref.read(encryptionServiceProvider.notifier).resetOnSignOut();

    _currentUser = null;
    if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
      _signInCompleter!.complete(null);
      _signInCompleter = null;
    }

    // Запускаем остальные операции по очистке параллельно для ускорения
    final futures = <Future>[];

    if (_isInitialized) {
      futures.add(GoogleSignIn.instance.signOut().catchError((e) {
        if (kDebugMode) debugPrint('Google signOut error (ignored): $e');
      }));
    }

    futures.add(_firebaseAuth.signOut());

    unawaited(IsarService.close().catchError((e) {
      if (kDebugMode) debugPrint('IsarService close error (ignored): $e');
    }));

    try {
      await Future.wait(futures, eagerError: false);
    } catch (e) {
      if (kDebugMode) debugPrint('SignOut cleanup error (continuing): $e');
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      await _ensureGoogleSignInInitialized();

      // ИСПРАВЛЕНО: Создаем Completer для ожидания результата аутентификации
      _signInCompleter = Completer<GoogleSignInAccount?>();

      // Запускаем аутентификацию
      if (GoogleSignIn.instance.supportsAuthenticate()) {
        await GoogleSignIn.instance.authenticate();
      } else {
        throw UnsupportedError(
            'Google Sign-In authentication not supported on this platform');
      }

      // ИСПРАВЛЕНО: Ждем событие аутентификации с таймаутом
      final GoogleSignInAccount? googleUser =
          await _signInCompleter!.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (kDebugMode) {
            debugPrint('Google Sign-In timeout');
          }
          return null;
        },
      );

      _signInCompleter = null;

      if (googleUser == null) {
        return null; // Пользователь отменил вход или таймаут
      }

      // ИСПРАВЛЕНО: Получаем токены через новый API authorizationClient
      const scopes = ['email', 'profile', 'openid'];

      // Пробуем получить существующую авторизацию
      var authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes);

      // Если нет существующей авторизации, запрашиваем новую
      authorization ??=
          await googleUser.authorizationClient.authorizeScopes(scopes);

      // Создаем credential только с accessToken (idToken недоступен в v7.2.0)
      final credential = GoogleAuthProvider.credential(
        accessToken: authorization.accessToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (context.mounted) {
        await _userService.ensureUserProfileExists(
            userCredential.user!, context);
      }

      return userCredential;
    } catch (e, stackTrace) {
      _signInCompleter = null;
      if (kDebugMode) {
        debugPrint('Error during Google sign-in: $e');
      }
      FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Google Sign-In Failed');
      throw Exception(
          'An error occurred during Google Sign-In. Please try again.');
    }
  }

  Future<UserCredential?> signInWithApple(BuildContext context) async {
    if (defaultTargetPlatform != TargetPlatform.iOS &&
        defaultTargetPlatform != TargetPlatform.macOS) {
      throw UnsupportedError(
          'Apple Sign-In is not supported on this platform.');
    }

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      final oAuthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      if (context.mounted) {
        await _userService.ensureUserProfileExists(userCredential.user!, context);
      }

      return userCredential;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Apple sign-in failed: $e');
      }
      FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Apple Sign-In Failed');
      throw Exception(
          'An error occurred during Apple Sign-In. Please try again.');
    }
  }

  /// Attempts to delete the current user account.
  /// Returns 'success', 'requires-recent-login', or an error message.
  Future<String> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return 'No user is currently signed in.';
    }
    // Capture the UID before the user object becomes invalid.
    final uid = user.uid;

    try {
      await user.delete();

      // --- ИСПРАВЛЕНИЕ: Принудительный выход из Google Sign-In v7.x ---
      await _ensureGoogleSignInInitialized();
      if (_currentUser != null) {
        try {
          await GoogleSignIn.instance.signOut();
        } catch (e, stackTrace) {
          FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'Google Sign-Out failed after account deletion');
        }
      }

      // --- NEW: Clean up local data after successful deletion ---
      await IsarService.close();

      // Delete the local database file to prevent conflicts on re-registration.
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/lifeline_$uid.isar');
      if (await dbFile.exists()) {
        await dbFile.delete();
        if (kDebugMode) {
          debugPrint('[AuthService] Deleted local database file for user $uid.');
        }
      }

      return 'success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'requires-recent-login';
      }
      return e.message ?? 'An unknown error occurred.';
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: 'Account Deletion Failed');
      return 'Failed to delete account: $e';
    }
  }

  /// Re-authenticates the user with their password. Throws on failure.
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No user with email found to reauthenticate.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticates the user with Google. Throws on failure or cancellation.
  Future<void> reauthenticateWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user to reauthenticate.');

    await _ensureGoogleSignInInitialized();

    // ИСПРАВЛЕНО: Используем тот же механизм ожидания событий
    _signInCompleter = Completer<GoogleSignInAccount?>();

    if (GoogleSignIn.instance.supportsAuthenticate()) {
      await GoogleSignIn.instance.authenticate();
    } else {
      throw UnsupportedError('Google authentication not supported');
    }

    final GoogleSignInAccount? googleUser =
        await _signInCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Google reauthentication timeout'),
    );

    _signInCompleter = null;

    if (googleUser == null) throw Exception('User cancelled sign in.');

    // Получаем токены
    const scopes = ['email', 'profile', 'openid'];
    var authorization =
        await googleUser.authorizationClient.authorizationForScopes(scopes);

    authorization ??=
        await googleUser.authorizationClient.authorizeScopes(scopes);

    final credential = GoogleAuthProvider.credential(
      accessToken: authorization.accessToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticates the user with Apple. Throws on failure or cancellation.
  Future<void> reauthenticateWithApple() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user to reauthenticate.');

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName
      ],
    );
    final credential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await user.reauthenticateWithCredential(credential);
  }

  // ВАЖНО: Освобождаем ресурсы при уничтожении сервиса
  void dispose() {
    _authEventSubscription?.cancel();
    if (_signInCompleter != null && !_signInCompleter!.isCompleted) {
      _signInCompleter!.complete(null);
    }
  }
}

