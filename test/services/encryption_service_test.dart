import 'dart:convert';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simplified encryption tests for Lifeline
///
/// Since EncryptionService requires complex setup (Riverpod, SecureStorage),
/// we test the core crypto logic separately here.
void main() {
  group('Basic AES-GCM Encryption', () {
    test('encrypts and decrypts text correctly', () {
      // Arrange - имитируем DEK ключ (32 байта для AES-256)
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12); // GCM uses 12-byte IV
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      const plainText = 'Secret memory content';

      // Act - шифруем
      final encrypted = encrypter.encrypt(plainText, iv: iv);

      // Assert - проверяем что зашифровалось
      expect(encrypted.base64, isNot(equals(plainText)));
      expect(encrypted.bytes, isNotEmpty);

      // Act - дешифруем
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      // Assert - проверяем что получили оригинал
      expect(decrypted, equals(plainText));
    });

    test('preserves newlines in encrypted text', () {
      // Arrange
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      const textWithNewlines = 'Paragraph 1\n\nParagraph 2\nLine 3';

      // Act
      final encrypted = encrypter.encrypt(textWithNewlines, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      // Assert - абзацы сохранились!
      expect(decrypted, equals(textWithNewlines));
      expect(decrypted.split('\n').length, equals(4)); // 4 lines total
    });

    test('different IVs produce different ciphertexts', () {
      // Arrange - одинаковый ключ, разные IV
      final key = Key.fromSecureRandom(32);
      final iv1 = IV.fromSecureRandom(12);
      final iv2 = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      const plainText = 'Same text';

      // Act - шифруем с разными IV
      final encrypted1 = encrypter.encrypt(plainText, iv: iv1);
      final encrypted2 = encrypter.encrypt(plainText, iv: iv2);

      // Assert - разные шифртексты (защита от анализа паттернов)
      expect(encrypted1.base64, isNot(equals(encrypted2.base64)));

      // Но оба дешифруются правильно
      expect(encrypter.decrypt(encrypted1, iv: iv1), equals(plainText));
      expect(encrypter.decrypt(encrypted2, iv: iv2), equals(plainText));
    });

    test('wrong key cannot decrypt', () {
      // Arrange
      final correctKey = Key.fromSecureRandom(32);
      final wrongKey = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);

      const plainText = 'Secret';

      // Act - шифруем с правильным ключом
      final encrypter1 = Encrypter(AES(correctKey, mode: AESMode.gcm));
      final encrypted = encrypter1.encrypt(plainText, iv: iv);

      // Assert - попытка расшифровать с неправильным ключом → ошибка
      final encrypter2 = Encrypter(AES(wrongKey, mode: AESMode.gcm));
      expect(
        () => encrypter2.decrypt(encrypted, iv: iv),
        throwsA(isA<Exception>()), // GCM выбросит ошибку при неверном ключе
      );
    });

    test('encrypts empty string as empty', () {
      // Arrange
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      // Act & Assert
      final encrypted = encrypter.encrypt('', iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      expect(decrypted, equals(''));
    });

    test('handles unicode characters correctly', () {
      // Arrange
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      const unicodeText = 'Привет 你好 🎉 émoji';

      // Act
      final encrypted = encrypter.encrypt(unicodeText, iv: iv);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);

      // Assert - юникод сохраняется
      expect(decrypted, equals(unicodeText));
    });
  });

  group('Encrypted Payload Format (gcm_v1)', () {
    test('matches expected format: gcm_v1:IV:CIPHER', () {
      // Arrange
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      const plainText = 'Test';

      // Act
      final encrypted = encrypter.encrypt(plainText, iv: iv);
      final payload = 'gcm_v1:${iv.base64}:${encrypted.base64}';

      // Assert - формат правильный
      expect(payload, startsWith('gcm_v1:'));
      final parts = payload.split(':');
      expect(parts.length, equals(3));
      expect(parts[0], equals('gcm_v1'));

      // Можем распарсить обратно
      final ivParsed = IV.fromBase64(parts[1]);
      final encryptedParsed = Encrypted.fromBase64(parts[2]);
      final decrypted = encrypter.decrypt(encryptedParsed, iv: ivParsed);
      expect(decrypted, equals(plainText));
    });

    test('can detect encrypted vs plain text', () {
      const plainText = 'This is not encrypted';
      const encryptedFormat = 'gcm_v1:dGVzdA==:YW5vdGhlcnRlc3Q=';

      // Plain text detection
      expect(plainText.startsWith('gcm_v1:'), isFalse);

      // Encrypted format detection
      expect(encryptedFormat.startsWith('gcm_v1:'), isTrue);
      expect(encryptedFormat.split(':').length, equals(3));
    });
  });

  group('Base64 Encoding', () {
    test('IV and cipher are valid base64', () {
      // Arrange
      final key = Key.fromSecureRandom(32);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));

      // Act
      final encrypted = encrypter.encrypt('Test', iv: iv);
      final ivBase64 = iv.base64;
      final cipherBase64 = encrypted.base64;

      // Assert - можно декодировать
      expect(() => base64.decode(ivBase64), returnsNormally);
      expect(() => base64.decode(cipherBase64), returnsNormally);

      // IV всегда 12 байт в GCM
      expect(base64.decode(ivBase64).length, equals(12));
    });
  });
}
