import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';
import 'package:lifeline/memory.dart';
import 'package:path_provider/path_provider.dart';

/// Helper class for setting up integration tests with Firebase Emulator
class TestHelpers {
  static const String emulatorHost = 'localhost';
  static const int firestorePort = 8080;
  static const int authPort = 9099;
  static const int storagePort = 9199;

  static bool _initialized = false;
  static Isar? _testIsar;

  /// Initialize Firebase with emulator settings
  static Future<void> initializeFirebase() async {
    if (_initialized) return;

    TestWidgetsFlutterBinding.ensureInitialized();

    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'lifeline-11615',
        storageBucket: 'lifeline-11615.appspot.com',
      ),
    );

    // Connect to Firebase Emulators
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, firestorePort);
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, authPort);
    await FirebaseStorage.instance.useStorageEmulator(emulatorHost, storagePort);

    // Disable network persistence for tests
    await FirebaseFirestore.instance.clearPersistence();
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    _initialized = true;
  }

  /// Create a test Isar instance
  static Future<Isar> createTestIsar() async {
    if (_testIsar != null && _testIsar!.isOpen) {
      return _testIsar!;
    }

    final dir = await getTemporaryDirectory();
    final testDir = Directory('${dir.path}/test_${DateTime.now().millisecondsSinceEpoch}');
    await testDir.create(recursive: true);

    _testIsar = await Isar.open(
      [MemorySchema],
      directory: testDir.path,
      name: 'test_db',
    );

    return _testIsar!;
  }

  /// Clean up test Isar instance
  static Future<void> cleanupTestIsar() async {
    if (_testIsar != null && _testIsar!.isOpen) {
      await _testIsar!.writeTxn(() async {
        await _testIsar!.clear();
      });
      await _testIsar!.close();
      _testIsar = null;
    }
  }

  /// Create a test user with email/password
  static Future<UserCredential> createTestUser({
    required String email,
    required String password,
  }) async {
    try {
      return await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      // If user already exists, sign in instead
      return await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    }
  }

  /// Create a test user profile in Firestore
  static Future<void> createTestUserProfile({
    required String uid,
    String? name,
    String? email,
    bool isPremium = false,
    DateTime? premiumExpiresAt,
    bool isEncryptionEnabled = false,
  }) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name ?? 'Test User',
      'email': email ?? 'test@example.com',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isPremium': isPremium,
      if (premiumExpiresAt != null) 'premiumExpiresAt': Timestamp.fromDate(premiumExpiresAt),
      'isEncryptionEnabled': isEncryptionEnabled,
    });
  }

  /// Create a test memory in Firestore
  static Future<DocumentReference> createTestMemory({
    required String userId,
    required String title,
    String? content,
    DateTime? date,
    bool isEncrypted = false,
    Map<String, int>? emotions,
    List<String>? mediaPaths,
  }) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('memories')
        .add({
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date ?? DateTime.now()),
      'isEncrypted': isEncrypted,
      'emotions': emotions ?? {},
      'mediaPaths': mediaPaths ?? [],
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Clean up test user and all their data
  static Future<void> deleteTestUser(String uid) async {
    // Delete user's memories
    final memories = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('memories')
        .get();

    for (final doc in memories.docs) {
      await doc.reference.delete();
    }

    // Delete user profile
    await FirebaseFirestore.instance.collection('users').doc(uid).delete();

    // Delete auth user
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user?.uid == uid) {
        await user?.delete();
      }
    } catch (e) {
      // User might already be deleted
    }
  }

  /// Clean up all test data from Firestore
  static Future<void> cleanupFirestore() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    for (final doc in users.docs) {
      await deleteTestUser(doc.id);
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  /// Wait for a condition with timeout
  static Future<void> waitFor(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (!condition()) {
      if (stopwatch.elapsed > timeout) {
        throw TimeoutException('Condition not met within $timeout');
      }
      await Future.delayed(pollInterval);
    }
  }

  /// Create a test file for upload
  static Future<File> createTestFile({
    required String name,
    required String content,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsString(content);
    return file;
  }

  /// Create a test image file
  static Future<File> createTestImage({String name = 'test_image.jpg'}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');

    // Create a simple 1x1 pixel JPEG (smallest valid JPEG)
    final bytes = Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
      0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xC0, 0x00, 0x0B,
      0x08, 0x00, 0x01, 0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0xFF, 0xC4, 0x00,
      0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x08, 0x01,
      0x01, 0x00, 0x00, 0x3F, 0x00, 0x7F, 0xFF, 0xD9,
    ]);

    await file.writeAsBytes(bytes);
    return file;
  }

  /// Verify Firestore document exists
  static Future<bool> firestoreDocumentExists(String path) async {
    final doc = await FirebaseFirestore.instance.doc(path).get();
    return doc.exists;
  }

  /// Get Firestore document data
  static Future<Map<String, dynamic>?> getFirestoreDocument(String path) async {
    final doc = await FirebaseFirestore.instance.doc(path).get();
    return doc.data();
  }
}

/// Exception thrown when a timeout occurs
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => 'TimeoutException: $message';
}
