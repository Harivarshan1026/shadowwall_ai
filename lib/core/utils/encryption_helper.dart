/// Encryption helper for securing local sensitive data.
///
/// Uses flutter_secure_storage for credential storage
/// and dart:crypto for hashing operations.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionHelper {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Store a value securely.
  static Future<void> secureWrite(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read a value securely.
  static Future<String?> secureRead(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete a value securely.
  static Future<void> secureDelete(String key) async {
    await _storage.delete(key: key);
  }

  /// Delete all secured values.
  static Future<void> secureDeleteAll() async {
    await _storage.deleteAll();
  }

  /// Check if a key exists.
  static Future<bool> secureContains(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Compute SHA-256 hash of input.
  static String sha256Hash(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Compute HMAC-SHA256 with a key.
  static String hmacSha256(String input, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(input));
    return digest.toString();
  }

  /// Encrypt string with dynamic IV
  static String encrypt(String input) {
    if (input.isEmpty) return '';
    final rawBytes = utf8.encode(input);
    final keyBytes = utf8.encode('ShadowWallMasterKey2026!#Secure');
    final iv = DateTime.now().microsecondsSinceEpoch % 256;
    
    final encrypted = List<int>.generate(
      rawBytes.length + 1,
      (i) => i == 0 ? iv : (rawBytes[i - 1] ^ keyBytes[(i - 1) % keyBytes.length] ^ iv),
    );
    return base64.encode(encrypted);
  }

  /// Decrypt string
  static String decrypt(String input) {
    if (input.isEmpty) return '';
    try {
      final bytes = base64.decode(input);
      if (bytes.isEmpty) return '';
      final iv = bytes[0];
      final keyBytes = utf8.encode('ShadowWallMasterKey2026!#Secure');
      
      final decrypted = List<int>.generate(
        bytes.length - 1,
        (i) => bytes[i + 1] ^ iv ^ keyBytes[i % keyBytes.length],
      );
      return utf8.decode(decrypted);
    } catch (_) {
      return '';
    }
  }

  /// Obfuscate sensitive string for logging.
  static String obfuscate(String input) {
    if (input.length <= 4) return '****';
    return '${input.substring(0, 2)}${'*' * (input.length - 4)}${input.substring(input.length - 2)}';
  }
}
