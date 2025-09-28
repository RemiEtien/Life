import 'dart:isolate';
import 'dart:typed_data';
import 'dart:convert';

import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

/// Модель данных для передачи в изолят.
class IsolateDeriveKeyRequest {
  final String password;
  final Uint8List salt;
  final SendPort sendPort;

  IsolateDeriveKeyRequest({
    required this.password,
    required this.salt,
    required this.sendPort,
  });
}

/// Точка входа для изолята. Эта функция выполняется в фоновом потоке.
void deriveKeyIsolateEntry(IsolateDeriveKeyRequest request) {
  // ИСПРАВЛЕНО: Количество итераций увеличено до 310,000.
  const iterations = 310000;
  const keyLength = 32; // 32 байта для AES-256

  final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
    ..init(Pbkdf2Parameters(request.salt, iterations, keyLength));

  final keyBytes =
      derivator.process(Uint8List.fromList(utf8.encode(request.password)));

  request.sendPort.send(keyBytes);
}

