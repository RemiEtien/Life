import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import 'package:path_provider/path_provider.dart';

class UserService {
  UserService(Ref ref);

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');

  Future<void> ensureUserProfileExists(User user, BuildContext context) async {
    FirebaseCrashlytics.instance.log('UserService: Checking if profile exists for user ${user.uid}');
    try {
      final doc = _usersCollection.doc(user.uid);
      final snapshot = await doc.get();

      if (!context.mounted) return;

      if (!snapshot.exists) {
        FirebaseCrashlytics.instance.log('UserService: Profile not found for ${user.uid}. Creating new one.');
        await createUserProfile(user, context);
      } else {
         FirebaseCrashlytics.instance.log('UserService: Profile already exists for ${user.uid}.');
      }
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: ensureUserProfileExists failed');
    }
  }

  Future<void> createUserProfile(User user, BuildContext context) async {
    FirebaseCrashlytics.instance.log('UserService: Attempting to create profile for user ${user.uid}');
    try {
      final currentLocale = Localizations.localeOf(context);

      if (kDebugMode) {
        print('[UserService] Creating profile with locale from context: ${currentLocale.languageCode}');
      }
      FirebaseCrashlytics.instance.setCustomKey('user_language_on_creation', currentLocale.languageCode);

      final userEmail = user.email;
      if (userEmail == null) {
        FirebaseCrashlytics.instance.recordError(
          Exception('User tried to register without an email.'),
          null,
          reason: 'UserService:createUserProfile user.email is null',
          fatal: true,
        );
        throw Exception('Email is required for registration.');
      }

      final userProfile = UserProfile(
        uid: user.uid,
        displayName: user.displayName ?? 'New User',
        email: userEmail,
        photoUrl: user.photoURL,
        languageCode: currentLocale.languageCode,
      );
      await _usersCollection.doc(user.uid).set(userProfile.toJson());
      FirebaseCrashlytics.instance.log('UserService: Successfully created profile for user ${user.uid}');
    } catch (e, stackTrace) {
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: createUserProfile failed');
       rethrow;
    }
  }

  Stream<UserProfile?> getUserProfileStream(String uid) {
    return _usersCollection.doc(uid).snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromJson(uid, snapshot.data()!);
      }
      return null;
    });
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final snapshot = await _usersCollection.doc(uid).get();
      if (snapshot.exists && snapshot.data() != null) {
        return UserProfile.fromJson(uid, snapshot.data()!);
      }
      return null;
    } catch (e, stackTrace) {
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: getUserProfile failed');
       return null;
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _usersCollection.doc(profile.uid).update(profile.toJson());
    } catch (e, stackTrace) {
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: updateUserProfile failed');
       rethrow;
    }
  }

  Future<String?> uploadAvatar(String uid, File imageFile) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[UserService] uploadAvatar: Current user is null. Aborting.');
        return null;
      }
      
      debugPrint('[UserService] uploadAvatar: Forcing token refresh...');
      await currentUser.getIdToken(true);
      debugPrint('[UserService] uploadAvatar: Token refreshed. Proceeding with upload.');

      final ref = _storage.ref().child('users').child(uid).child('avatar.jpg');

      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Error uploading avatar: $e');
      }
      FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: uploadAvatar failed');
      return null;
    }
  }

  Future<void> deleteUserAccountData(String uid) async {
    FirebaseCrashlytics.instance.log('UserService: Deleting all data for user $uid.');
    try {
      final userFolderRef = _storage.ref('users/$uid');
      await _deleteFolderContents(userFolderRef);
    } catch (e) {
      // Ignore errors if folder doesn't exist
    }

    try {
      final ref = _storage.ref().child('avatars').child('$uid.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore errors if avatar doesn't exist
    }
    
    try {
      final memoriesCollection = _usersCollection.doc(uid).collection('memories');
      final WriteBatch batch = _db.batch();
      final memoriesSnapshot = await memoriesCollection.get();
      for (var doc in memoriesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      await _usersCollection.doc(uid).delete();

      final dir = await getApplicationDocumentsDirectory();
      final dbFile = File('${dir.path}/lifeline_$uid.isar');
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      FirebaseCrashlytics.instance.log('UserService: Successfully deleted data for user $uid.');
    } catch(e, stackTrace) {
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: deleteUserAccountData failed');
       rethrow;
    }
  }

  Future<void> _deleteFolderContents(Reference ref) async {
    try {
      final listResult = await ref.listAll();

      for (final item in listResult.items) {
        await item.delete();
      }

      for (final prefix in listResult.prefixes) {
        await _deleteFolderContents(prefix);
      }
    } catch (e, stackTrace) {
       FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: 'UserService: _deleteFolderContents failed');
    }
  }
}

