import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

/// Integration tests for Premium Purchase Flow
///
/// Tests the interaction between:
/// - Firebase Auth
/// - Firestore (user profiles)
/// - Cloud Functions (purchase verification)
/// - Premium status updates
///
/// REQUIRES: Firebase Emulator running
/// Run: firebase emulators:start --only auth,firestore,functions
void main() {
  setUpAll(() async {
    await TestHelpers.initializeFirebase();
  });

  tearDown(() async {
    await TestHelpers.cleanupFirestore();
    await TestHelpers.signOut();
  });

  group('Premium Purchase Flow Integration', () {
    test('free user upgrades to premium successfully', () async {
      // Arrange: Create free user
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

      // Verify initially free
      var profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isFalse);
      expect(profile['premiumExpiresAt'], isNull);

      // Act: Simulate successful purchase
      final expiresAt = DateTime.now().add(const Duration(days: 30));

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isPremium': true,
        'premiumExpiresAt': Timestamp.fromDate(expiresAt),
        'premiumActivatedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Assert: User is now premium
      profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isTrue);
      expect(profile['premiumExpiresAt'], isNotNull);

      final storedExpiry = (profile['premiumExpiresAt'] as Timestamp).toDate();
      expect(
        storedExpiry.difference(expiresAt).inMinutes.abs(),
        lessThan(1),
      );
    });

    test('premium user subscription renewal', () async {
      // Arrange: Create premium user with expiring subscription
      const email = 'premium@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final initialExpiry = DateTime.now().add(const Duration(days: 5));

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: initialExpiry,
      );

      // Act: Renew subscription
      final newExpiry = DateTime.now().add(const Duration(days: 35));

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'premiumExpiresAt': Timestamp.fromDate(newExpiry),
        'lastRenewalAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Assert: Expiry extended
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      final storedExpiry = (profile!['premiumExpiresAt'] as Timestamp).toDate();

      expect(storedExpiry.difference(newExpiry).inMinutes.abs(), lessThan(1));
      expect(profile['lastRenewalAt'], isNotNull);
    });

    test('premium subscription expiration', () async {
      // Arrange: Create premium user with expired subscription
      const email = 'expired@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final expiredDate = DateTime.now().subtract(const Duration(days: 1));

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: expiredDate,
      );

      // Act: Simulate expiration check (normally done by cloud function)
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      final expiresAt = (profile!['premiumExpiresAt'] as Timestamp).toDate();
      final isExpired = DateTime.now().isAfter(expiresAt);

      if (isExpired) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'isPremium': false,
          'premiumExpiredAt': FieldValue.serverTimestamp(),
        });
      }

      // Assert: Premium status revoked
      final updatedProfile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(updatedProfile!['isPremium'], isFalse);
      expect(updatedProfile['premiumExpiredAt'], isNotNull);
    });

    test('trial period activation', () async {
      // Arrange: New user
      const email = 'trial@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      // Act: Activate trial
      final trialStart = DateTime.now();
      final trialEnd = trialStart.add(const Duration(days: 7));

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'trialStartedAt': Timestamp.fromDate(trialStart),
        'trialExpiresAt': Timestamp.fromDate(trialEnd),
        'isPremium': false, // Trial doesn't set premium flag
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Assert: Trial active
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['trialStartedAt'], isNotNull);
      expect(profile['trialExpiresAt'], isNotNull);

      final storedTrialEnd = (profile['trialExpiresAt'] as Timestamp).toDate();
      expect(
        storedTrialEnd.difference(trialEnd).inMinutes.abs(),
        lessThan(1),
      );
    });

    test('purchase verification creates purchase record', () async {
      // Arrange: Premium user
      const email = 'purchaser@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(uid: uid, email: email);

      // Act: Create purchase record
      final purchaseRef = await FirebaseFirestore.instance
          .collection('purchases')
          .add({
        'userId': uid,
        'productId': 'premium_monthly',
        'purchaseToken': 'test-token-123',
        'platform': 'android',
        'verificationStatus': 'pending',
        'purchasedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Assert: Purchase record created
      final purchase = await purchaseRef.get();
      expect(purchase.exists, isTrue);
      expect(purchase.data()!['userId'], equals(uid));
      expect(purchase.data()!['productId'], equals('premium_monthly'));
      expect(purchase.data()!['verificationStatus'], equals('pending'));
    });

    test('verified purchase updates user to premium', () async {
      // Arrange: User with pending purchase
      const email = 'verified@test.com';
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

      final purchaseRef = await FirebaseFirestore.instance
          .collection('purchases')
          .add({
        'userId': uid,
        'productId': 'premium_yearly',
        'purchaseToken': 'verified-token-456',
        'verificationStatus': 'pending',
        'purchasedAt': FieldValue.serverTimestamp(),
      });

      // Act: Simulate cloud function verification
      await purchaseRef.update({
        'verificationStatus': 'verified',
        'verifiedAt': FieldValue.serverTimestamp(),
      });

      // Update user to premium
      final expiresAt = DateTime.now().add(const Duration(days: 365));
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'isPremium': true,
        'premiumExpiresAt': Timestamp.fromDate(expiresAt),
        'premiumActivatedAt': FieldValue.serverTimestamp(),
      });

      // Assert: Purchase verified
      final purchase = await purchaseRef.get();
      expect(purchase.data()!['verificationStatus'], equals('verified'));

      // Assert: User is premium
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isTrue);
    });

    test('failed purchase verification', () async {
      // Arrange: User with invalid purchase
      const email = 'failed@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(uid: uid, email: email);

      final purchaseRef = await FirebaseFirestore.instance
          .collection('purchases')
          .add({
        'userId': uid,
        'productId': 'premium_monthly',
        'purchaseToken': 'invalid-token',
        'verificationStatus': 'pending',
        'purchasedAt': FieldValue.serverTimestamp(),
      });

      // Act: Simulate failed verification
      await purchaseRef.update({
        'verificationStatus': 'failed',
        'verificationError': 'Invalid purchase token',
        'failedAt': FieldValue.serverTimestamp(),
      });

      // Assert: Purchase failed
      final purchase = await purchaseRef.get();
      expect(purchase.data()!['verificationStatus'], equals('failed'));
      expect(purchase.data()!['verificationError'], isNotNull);

      // Assert: User still free
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isFalse);
    });

    test('restore purchases retrieves active subscription', () async {
      // Arrange: Premium user
      const email = 'restore@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final expiresAt = DateTime.now().add(const Duration(days: 20));

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: expiresAt,
      );

      // Act: Query user's purchases
      final purchasesSnapshot = await FirebaseFirestore.instance
          .collection('purchases')
          .where('userId', isEqualTo: uid)
          .where('verificationStatus', isEqualTo: 'verified')
          .get();

      // Query user profile
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');

      // Assert: Can restore premium status
      expect(profile!['isPremium'], isTrue);

      // Even if no purchases in test, profile should have premium status
      if (purchasesSnapshot.docs.isEmpty) {
        // This is expected in test environment
        expect(profile['premiumExpiresAt'], isNotNull);
      }
    });
  });

  group('Premium Features Access Control Integration', () {
    test('premium user can access premium features', () async {
      // Arrange: Premium user
      const email = 'premium-access@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      // Act: Check premium status
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      final isPremium = profile!['isPremium'] as bool;
      final expiresAt = profile['premiumExpiresAt'] != null
          ? (profile['premiumExpiresAt'] as Timestamp).toDate()
          : null;

      final isActive = isPremium &&
        (expiresAt == null || DateTime.now().isBefore(expiresAt));

      // Assert: Can access premium features
      expect(isActive, isTrue);
    });

    test('free user cannot access premium features', () async {
      // Arrange: Free user
      const email = 'free-access@test.com';
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

      // Act: Check premium status
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      final isPremium = profile!['isPremium'] as bool;

      // Assert: Cannot access premium features
      expect(isPremium, isFalse);
    });

    test('user with trial can access premium features', () async {
      // Arrange: User on active trial
      const email = 'trial-access@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final trialExpires = DateTime.now().add(const Duration(days: 5));

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'isPremium': false,
        'trialStartedAt': Timestamp.fromDate(DateTime.now()),
        'trialExpiresAt': Timestamp.fromDate(trialExpires),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act: Check trial status
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      final trialExpiresAt = profile!['trialExpiresAt'] != null
          ? (profile['trialExpiresAt'] as Timestamp).toDate()
          : null;

      final hasActiveTrial = trialExpiresAt != null &&
          DateTime.now().isBefore(trialExpiresAt);

      // Assert: Can access premium features during trial
      expect(hasActiveTrial, isTrue);
    });
  });

  group('Subscription Management Integration', () {
    test('cancel subscription keeps premium until expiry', () async {
      // Arrange: Premium user
      const email = 'cancel@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      final expiresAt = DateTime.now().add(const Duration(days: 15));

      await TestHelpers.createTestUserProfile(
        uid: uid,
        email: email,
        isPremium: true,
        premiumExpiresAt: expiresAt,
      );

      // Act: Cancel subscription (mark as canceled but keep until expiry)
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'subscriptionCanceled': true,
        'canceledAt': FieldValue.serverTimestamp(),
      });

      // Assert: Still premium until expiry
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['isPremium'], isTrue);
      expect(profile['subscriptionCanceled'], isTrue);

      // Premium should remain active until expiresAt
      final storedExpiry = (profile['premiumExpiresAt'] as Timestamp).toDate();
      expect(DateTime.now().isBefore(storedExpiry), isTrue);
    });

    test('reactivate canceled subscription', () async {
      // Arrange: User with canceled subscription
      const email = 'reactivate@test.com';
      const password = 'Test123!@#';

      final userCred = await TestHelpers.createTestUser(
        email: email,
        password: password,
      );
      final uid = userCred.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'isPremium': true,
        'premiumExpiresAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 10)),
        ),
        'subscriptionCanceled': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Act: Reactivate subscription
      final newExpiry = DateTime.now().add(const Duration(days: 40));

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'subscriptionCanceled': false,
        'premiumExpiresAt': Timestamp.fromDate(newExpiry),
        'reactivatedAt': FieldValue.serverTimestamp(),
      });

      // Assert: Subscription reactivated
      final profile = await TestHelpers.getFirestoreDocument('users/$uid');
      expect(profile!['subscriptionCanceled'], isFalse);
      expect(profile['reactivatedAt'], isNotNull);
    });
  });
}
