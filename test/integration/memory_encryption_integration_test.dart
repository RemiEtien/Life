import 'package:flutter_test/flutter_test.dart';
import 'package:encrypt/encrypt.dart';
import 'package:lifeline/memory.dart';
import 'package:lifeline/utils/input_validator.dart';

/// Integration tests for Memory creation with encryption and validation
///
/// These tests verify that multiple components work together correctly:
/// - Memory model
/// - Input validation
/// - Encryption service
void main() {
  group('Memory Creation with Encryption Integration', () {
    late Key encryptionKey;
    late IV iv;
    late Encrypter encrypter;

    setUp(() {
      encryptionKey = Key.fromSecureRandom(32);
      iv = IV.fromSecureRandom(12);
      encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));
    });

    test('creates memory with encrypted content and preserves structure', () {
      // Arrange: Create memory with sensitive content
      const sensitiveContent = 'This is my private memory\nWith multiple lines\nAnd emotions';
      final memory = Memory()
        ..title = 'Private Memory'
        ..date = DateTime(2025, 10, 3)
        ..isEncrypted = true;

      // Act: Encrypt the content
      final encrypted = encrypter.encrypt(sensitiveContent, iv: iv);
      final encryptedPayload = 'gcm_v1:${iv.base64}:${encrypted.base64}';
      memory.content = encryptedPayload;

      // Assert: Memory structure is intact
      expect(memory.title, equals('Private Memory'));
      expect(memory.isEncrypted, isTrue);
      expect(memory.content, startsWith('gcm_v1:'));
      expect(memory.content, isNot(contains('private memory')));

      // Verify we can decrypt it back
      final parts = memory.content!.split(':');
      final decryptedIV = IV.fromBase64(parts[1]);
      final encryptedText = Encrypted.fromBase64(parts[2]);
      final decrypted = encrypter.decrypt(encryptedText, iv: decryptedIV);

      expect(decrypted, equals(sensitiveContent));
      expect(decrypted.split('\n').length, equals(3)); // Newlines preserved
    });

    test('validates and encrypts memory content in correct order', () {
      const rawContent = 'My secret thoughts';

      // Step 1: Validate input first (before encryption)
      final validation = InputValidator.validateMemoryContent(rawContent);
      expect(validation.isValid, isTrue);

      // Step 2: Create memory with validated content
      final memory = Memory()
        ..title = 'Journal Entry'
        ..date = DateTime.now();

      // Step 3: Encrypt if user wants privacy
      final encrypted = encrypter.encrypt(validation.value!, iv: iv);
      memory.content = 'gcm_v1:${iv.base64}:${encrypted.base64}';
      memory.isEncrypted = true;

      // Verify final state
      expect(memory.isEncrypted, isTrue);
      expect(memory.content, isNot(contains('secret')));
    });

    test('handles memory with encrypted reflections', () {
      // Arrange: Encrypt multiple reflection fields
      const impactText = 'This event made me realize...';
      const lessonText = 'I learned that...';
      const reframeText = 'A better way to think about it...';

      final memory = Memory()
        ..title = 'Deep Reflection'
        ..date = DateTime.now()
        ..isEncrypted = true;

      // Encrypt each reflection field
      memory.reflectionImpact = 'gcm_v1:${iv.base64}:${encrypter.encrypt(impactText, iv: iv).base64}';
      memory.reflectionLesson = 'gcm_v1:${iv.base64}:${encrypter.encrypt(lessonText, iv: iv).base64}';
      memory.reflectionReframe = 'gcm_v1:${iv.base64}:${encrypter.encrypt(reframeText, iv: iv).base64}';

      // Verify all encrypted
      expect(memory.reflectionImpact, startsWith('gcm_v1:'));
      expect(memory.reflectionLesson, startsWith('gcm_v1:'));
      expect(memory.reflectionReframe, startsWith('gcm_v1:'));

      // Verify insight score still works (counts non-null fields)
      expect(memory.insightScore, equals(3));
    });

    test('copyWith preserves encryption state and re-encrypts if needed', () {
      // Original encrypted memory
      const originalContent = 'Original secret';
      final encrypted = encrypter.encrypt(originalContent, iv: iv);

      final originalMemory = Memory()
        ..title = 'Secret'
        ..content = 'gcm_v1:${iv.base64}:${encrypted.base64}'
        ..isEncrypted = true
        ..date = DateTime.now();

      // Update with new encrypted content
      const newContent = 'Updated secret';
      final newIV = IV.fromSecureRandom(12);
      final newEncrypted = encrypter.encrypt(newContent, iv: newIV);
      final newPayload = 'gcm_v1:${newIV.base64}:${newEncrypted.base64}';

      final updatedMemory = originalMemory.copyWith(
        content: newPayload,
        isEncrypted: true,
      );

      // Verify encryption state maintained
      expect(updatedMemory.isEncrypted, isTrue);
      expect(updatedMemory.content, startsWith('gcm_v1:'));
      expect(updatedMemory.content, isNot(equals(originalMemory.content))); // Different IV

      // Verify we can decrypt the new content
      final parts = updatedMemory.content!.split(':');
      final decrypted = encrypter.decrypt(
        Encrypted.fromBase64(parts[2]),
        iv: IV.fromBase64(parts[1]),
      );
      expect(decrypted, equals(newContent));
    });

    test('validates title and content together before encryption', () {
      // Invalid title (too long)
      final longTitle = 'A' * 201;
      final titleValidation = InputValidator.validateMemoryTitle(longTitle);
      expect(titleValidation.isValid, isFalse);

      // Valid content
      const content = 'Valid content';
      final contentValidation = InputValidator.validateMemoryContent(content);
      expect(contentValidation.isValid, isTrue);

      // Should not create memory if title is invalid
      expect(
        () => Memory()
          ..title = longTitle
          ..content = content
          ..date = DateTime.now(),
        returnsNormally, // Isar doesn't validate on assignment
      );

      // But copyWith should throw
      final memory = Memory()
        ..title = 'Short'
        ..date = DateTime.now();

      expect(
        () => memory.copyWith(title: longTitle),
        throwsArgumentError,
      );
    });

    test('encrypts memory with emotions and preserves emotional data', () {
      // Create memory with emotions
      final memory = Memory()
        ..title = 'Emotional Event'
        ..date = DateTime.now()
        ..emotions = {'Joy': 80, 'Gratitude': 90}
        ..isEncrypted = true;

      // Encrypt content
      const content = 'A wonderful day with friends';
      final encrypted = encrypter.encrypt(content, iv: iv);
      memory.content = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      // Verify emotions remain accessible (not encrypted)
      expect(memory.emotions['Joy'], equals(80));
      expect(memory.emotions['Gratitude'], equals(90));
      expect(memory.valence, greaterThan(0)); // Positive valence

      // Content is encrypted
      expect(memory.content, startsWith('gcm_v1:'));
      expect(memory.content, isNot(contains('wonderful')));
    });

    test('handles edge case: empty content encryption', () {
      final memory = Memory()
        ..title = 'Empty Memory'
        ..date = DateTime.now()
        ..isEncrypted = true;

      // Encrypt empty string
      final encrypted = encrypter.encrypt('', iv: iv);
      memory.content = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      expect(memory.content, startsWith('gcm_v1:'));

      // Decrypt back
      final parts = memory.content!.split(':');
      final decrypted = encrypter.decrypt(
        Encrypted.fromBase64(parts[2]),
        iv: IV.fromBase64(parts[1]),
      );
      expect(decrypted, equals(''));
    });

    test('encryption workflow: validate → sanitize → encrypt → store', () {
      // Step 1: Raw user input (potentially dangerous)
      const rawInput = '  My memory with    extra spaces\n\nAnd paragraphs  ';

      // Step 2: Validate (checks length, content)
      final validation = InputValidator.validateMemoryContent(rawInput);
      expect(validation.isValid, isTrue);

      // Step 3: Use validated value (trimmed by validator)
      final sanitized = validation.value!;

      // Step 4: Encrypt the sanitized content
      final encrypted = encrypter.encrypt(sanitized, iv: iv);
      final payload = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      // Step 5: Store in memory
      final memory = Memory()
        ..title = 'Test'
        ..content = payload
        ..isEncrypted = true
        ..date = DateTime.now();

      // Verify stored correctly
      expect(memory.content, startsWith('gcm_v1:'));

      // Verify decryption returns sanitized version
      final parts = memory.content!.split(':');
      final decrypted = encrypter.decrypt(
        Encrypted.fromBase64(parts[2]),
        iv: IV.fromBase64(parts[1]),
      );
      expect(decrypted, equals(sanitized));
      expect(decrypted, isNot(equals(rawInput))); // Spaces trimmed
    });
  });

  group('Memory Media Encryption Integration', () {
    late Key encryptionKey;

    setUp(() {
      encryptionKey = Key.fromSecureRandom(32);
    });

    test('validates media paths before adding to memory', () {
      final memory = Memory()
        ..title = 'Photo Memory'
        ..date = DateTime.now();

      // Valid image path
      const validImagePath = '/storage/photos/image.jpg';
      final imageValidation = InputValidator.validateMediaFile(validImagePath, MediaType.image);
      expect(imageValidation.isValid, isTrue);

      // Valid video path
      const validVideoPath = '/storage/videos/clip.mp4';
      final videoValidation = InputValidator.validateMediaFile(validVideoPath, MediaType.video);
      expect(videoValidation.isValid, isTrue);

      // Add using copyWith (validates automatically)
      final updated = memory.copyWith(
        mediaPaths: [validImagePath],
        videoPaths: [validVideoPath],
      );

      expect(updated.mediaPaths, contains(validImagePath));
      expect(updated.videoPaths, contains(validVideoPath));
    });

    test('maintains media order with encrypted content', () {
      final memory = Memory()
        ..title = 'Album'
        ..date = DateTime.now()
        ..mediaPaths = ['photo1.jpg', 'photo2.jpg', 'photo3.jpg']
        ..mediaKeysOrder = ['photo2.jpg', 'photo1.jpg', 'photo3.jpg']
        ..isEncrypted = true;

      // Encrypt description
      final encrypter = Encrypter(AES(encryptionKey, mode: AESMode.gcm));
      final iv = IV.fromSecureRandom(12);
      final encrypted = encrypter.encrypt('My photo album', iv: iv);
      memory.content = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      // Media order should be respected
      final orderedPaths = memory.displayableMediaPaths;
      expect(orderedPaths[0], equals('photo2.jpg'));
      expect(orderedPaths[1], equals('photo1.jpg'));
      expect(orderedPaths[2], equals('photo3.jpg'));

      // Content is encrypted
      expect(memory.content, startsWith('gcm_v1:'));
    });
  });

  group('Error Handling Integration', () {
    test('validation fails prevent memory creation via copyWith', () {
      final memory = Memory()
        ..title = 'Test'
        ..date = DateTime.now();

      // Try to update with invalid data
      expect(
        () => memory.copyWith(title: ''), // Empty title
        throwsArgumentError,
      );

      expect(
        () => memory.copyWith(content: 'x' * 100001), // Too long
        throwsArgumentError,
      );

      // Original memory unchanged
      expect(memory.title, equals('Test'));
    });

    test('encryption with wrong key produces unreadable data', () {
      final key1 = Key.fromSecureRandom(32);
      final key2 = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);

      final encrypter1 = Encrypter(AES(key1, mode: AESMode.gcm));
      final encrypter2 = Encrypter(AES(key2, mode: AESMode.gcm));

      final memory = Memory()
        ..title = 'Secret'
        ..date = DateTime.now();

      // Encrypt with key1
      final encrypted = encrypter1.encrypt('Secret data', iv: iv);
      memory.content = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      // Try decrypt with key2 (wrong key)
      final parts = memory.content!.split(':');
      expect(
        () => encrypter2.decrypt(
          Encrypted.fromBase64(parts[2]),
          iv: IV.fromBase64(parts[1]),
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
