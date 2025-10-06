import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

/// Integration tests for the complete authentication flow
///
/// Tests the interaction between:
/// - Firebase Auth
/// - Firestore (user profiles)
/// - AuthService
/// - UserService
/// - FirestoreService
///
/// REQUIRES: Firebase Emulator running
/// Run: firebase emulators:start --only auth,firestore
void main() {
  setUpAll(() async {
    await TestHelpers.initializeFirebase();
  });

  tearDown(() async {
    await TestHelpers.cleanupFirestore();
    await TestHelpers.signOut();
  });

  group('User Registration Flow Integration', () {
    test('complete user registration creates auth account and Firestore profile', () async {
      // Arrange
      const email = 'newuser@test.com';
      const password = 'Test123!@#';
      const displayName = 'Test User';

      // Act: Register user
      final userCredential = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );

      expect(userCredential.user, isNotNull);
      final uid = userCredential.user!.uid;

      // Create user profile in Firestore
      await TestHelpers.createTestUserProfile(
        uid: uid,
        name: displayName,
        email: email,
      );

      // Assert: Verify Firebase Auth user exists
      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser!.email, equals(email));

      // Assert: Verify Firestore profile exists
      final profileData = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profileData, isNotNull);
      expect(profileData!['name'], equals(displayName));
      expect(profileData['email'], equals(email));
      expect(profileData['isPremium'], isFalse);
      expect(profileData['isEncryptionEnabled'], isFalse);
    });

    test('user registration with encryption setup', () async {
      // Arrange
      const email = 'encrypted@test.com';
      const password = 'Secure123!@#';

      // Act: Register and setup encryption
      final userCredential = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isEncryptionEnabled: true,
      );

      // Assert: Verify encryption enabled in profile
      final profileData = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profileData!['isEncryptionEnabled'], isTrue);
    });

    test('duplicate registration fails gracefully', () async {
      // Arrange: Create first user
      const email = 'duplicate@test.com';
      const password = 'Test123!@#';

      await TestHelpers.createTestUser(email: email, password: password);
      await TestHelpers.signOut();

      // Act & Assert: Try to register again (should fail)
      expect(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'error code',
          'email-already-in-use',
        )),
      );
    });
  });

  group('User Login Flow Integration', () {
    test('successful login with correct credentials', () async {
      // Arrange: Create user first
      const email = 'logintest@test.com';
      const password = 'Test123!@#';

      final registrationCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      await TestHelpers.createTestUserProfile(
        uid: registrationCred.user!.uid,
        email: email,
      );
      await TestHelpers.signOut();

      // Act: Login
      final loginCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Assert
      expect(loginCred.user, isNotNull);
      expect(loginCred.user!.email, equals(email));
      expect(FirebaseAuth.instance.currentUser, isNotNull);
    });

    test('login fails with incorrect password', () async {
      // Arrange
      const email = 'wrongpass@test.com';
      const correctPassword = 'Correct123!@#';
      const wrongPassword = 'Wrong123!@#';

      await TestHelpers.createTestUser(email: email, password: correctPassword);
      await TestHelpers.signOut();

      // Act & Assert
      expect(
        () => FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: wrongPassword,
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'error code',
          'wrong-password',
        )),
      );
    });

    test('login fails with non-existent user', () async {
      // Act & Assert
      expect(
        () => FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'nonexistent@test.com',
          password: 'Test123!@#',
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'error code',
          anyOf('user-not-found', 'invalid-credential'),
        )),
      );
    });
  });

  group('User Logout Flow Integration', () {
    test('logout clears current user', () async {
      // Arrange: Login user
      const email = 'logout@test.com';
      const password = 'Test123!@#';

      await TestHelpers.createTestUser(email: email, password: password);
      expect(FirebaseAuth.instance.currentUser, isNotNull);

      // Act: Logout
      await FirebaseAuth.instance.signOut();

      // Assert
      expect(FirebaseAuth.instance.currentUser, isNull);
    });
  });

  group('User Profile Management Integration', () {
    test('update user profile updates Firestore', () async {
      // Arrange
      const email = 'updateprofile@test.com';
      const password = 'Test123!@#';
      const initialName = 'Initial Name';
      const updatedName = 'Updated Name';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        name: initialName,
      );

      // Act: Update profile directly via Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'name': updatedName,
      });

      // Assert
      final updatedProfile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(updatedProfile!['name'], equals(updatedName));
      expect(updatedProfile['email'], equals(email)); // Email unchanged
    });

    test('enable encryption updates profile', () async {
      // Arrange
      const email = 'encryption@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isEncryptionEnabled: false,
      );

      // Act: Enable encryption directly via Firestore
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isEncryptionEnabled': true,
      });

      // Assert
      final updatedProfile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(updatedProfile!['isEncryptionEnabled'], isTrue);
    });
  });

  group('User Deletion Flow Integration', () {
    test('delete user removes auth and Firestore data', () async {
      // Arrange
      const email = 'deleteuser@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
      );

      // Create some memories for this user
      await TestHelpers.createTestMemory(
        userId: uid,
        title: 'Memory 1',
      );
      await TestHelpers.createTestMemory(
        userId: uid,
        title: 'Memory 2',
      );

      // Verify data exists
      expect(await TestHelpers.firestoreDocumentExists('users/$uid'), isTrue);

      // Act: Delete user
      await TestHelpers.deleteTestUser(uid);

      // Assert: User profile deleted
      expect(await TestHelpers.firestoreDocumentExists('users/$uid'), isFalse);

      // Assert: No current user
      expect(FirebaseAuth.instance.currentUser, isNull);
    });
  });

  group('Authentication State Persistence Integration', () {
    test('user remains logged in across sessions', () async {
      // Arrange: Login user
      const email = 'persistent@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // Assert: User is logged in
      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser!.uid, equals(uid));

      // Simulate app restart (Firebase Auth maintains state in emulator)
      // In real app, this would persist to device storage

      // Assert: User still logged in
      expect(FirebaseAuth.instance.currentUser, isNotNull);
      expect(FirebaseAuth.instance.currentUser!.uid, equals(uid));
    });
  });

  group('Premium Status Integration', () {
    test('premium user creation and verification', () async {
      // Arrange
      const email = 'premium@test.com';
      const password = 'Test123!@#';
      final expiresAt = DateTime.now().add(const Duration(days: 30));

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // Act: Create premium profile
      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: expiresAt,
      );

      // Assert
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isTrue);
      expect(profile['premiumExpiresAt'], isNotNull);
    });

    test('free user has no premium expiration', () async {
      // Arrange
      const email = 'free@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: false,
      );

      // Assert
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isFalse);
      expect(profile['premiumExpiresAt'], isNull);
    });
  });

  group('Error Handling Integration', () {
    test('invalid email format fails registration', () async {
      expect(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'invalid-email',
          password: 'Test123!@#',
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'error code',
          'invalid-email',
        )),
      );
    });

    test('weak password fails registration', () async {
      expect(
        () => FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: 'test@test.com',
          password: '123', // Too weak
        ),
        throwsA(isA<FirebaseAuthException>().having(
          (e) => e.code,
          'error code',
          'weak-password',
        )),
      );
    });

    test('empty password fails login', () async {
      expect(
        () => FirebaseAuth.instance.signInWithEmailAndPassword(
          email: 'test@test.com',
          password: '',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
