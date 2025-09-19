import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lifeline/providers/application_providers.dart';
import 'package:lifeline/services/isar_service.dart';
import 'package:lifeline/services/user_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  UserService get _userService => _ref.read(userServiceProvider);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _userService.ensureUserProfileExists(userCredential.user!, context);
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
      await _userService.createUserProfile(userCredential.user!, context);
      return userCredential;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<void> signOut() async {
    // ИСПРАВЛЕНИЕ: Заменяем disconnect() на signOut() для более мягкого выхода.
    // Это предотвращает требование повторного запроса разрешений.
    if (await GoogleSignIn().isSignedIn()) {
      try {
        await GoogleSignIn().signOut();
      } catch (e, stackTrace) {
        FirebaseCrashlytics.instance.recordError(e, stackTrace,
            reason: 'Google Sign-Out failed during general sign-out');
        if (kDebugMode) {
          print("Error during Google Sign-Out: $e");
        }
      }
    }

    await _firebaseAuth.signOut();
    await IsarService.close();
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      await _userService.ensureUserProfileExists(userCredential.user!, context);

      return userCredential;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error during Google sign-in: $e');
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
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oAuthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(oAuthCredential);

      await _userService.ensureUserProfileExists(userCredential.user!, context);

      return userCredential;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Apple sign-in failed: $e");
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

      // --- ИСПРАВЛЕНИЕ: Принудительный выход из Google Sign-In ---
      // Это необходимо, чтобы при следующем входе Google предложил выбор аккаунта,
      // а не входил автоматически в только что удаленный.
      if (await GoogleSignIn().isSignedIn()) {
        try {
          await GoogleSignIn().signOut();
        } catch (e, stackTrace) {
          FirebaseCrashlytics.instance.recordError(e, stackTrace,
              reason: 'Google Sign-Out failed after account deletion');
        }
      }
      // --- КОНЕЦ ИСПРАВЛЕНИЯ ---


      // --- NEW: Clean up local data after successful deletion ---
      // Close any open database connection immediately.
      await IsarService.close();

      // Delete the local database file to prevent conflicts on re-registration.
      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/lifeline_$uid.isar');
      if (await dbFile.exists()) {
        await dbFile.delete();
        if (kDebugMode) {
          print("[AuthService] Deleted local database file for user $uid.");
        }
      }
      // --- END OF NEW CODE ---

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
    
    // This will throw FirebaseAuthException on failure (e.g. wrong password)
    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticates the user with Google. Throws on failure or cancellation.
  Future<void> reauthenticateWithGoogle() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user to reauthenticate.');

    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('User cancelled sign in.');

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    await user.reauthenticateWithCredential(credential);
  }

  /// Re-authenticates the user with Apple. Throws on failure or cancellation.
  Future<void> reauthenticateWithApple() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user to reauthenticate.');
    
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final credential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );
    await user.reauthenticateWithCredential(credential);
  }
}

