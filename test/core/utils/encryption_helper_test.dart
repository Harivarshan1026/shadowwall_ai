import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/core/utils/encryption_helper.dart';

void main() {
  group('EncryptionHelper Tests', () {
    test('Encryption and Decryption are reversible', () {
      final plainText = 'SuperSecretPassword123!';
      final encryptedText = EncryptionHelper.encrypt(plainText);
      
      expect(encryptedText, isNot(equals(plainText)));
      expect(encryptedText.isNotEmpty, isTrue);

      final decryptedText = EncryptionHelper.decrypt(encryptedText);
      expect(decryptedText, equals(plainText));
    });

    test('Identical strings produce different ciphertexts due to unique IVs', () {
      final plainText = 'IdenticalData';
      final encryptedText1 = EncryptionHelper.encrypt(plainText);
      final encryptedText2 = EncryptionHelper.encrypt(plainText);
      
      expect(encryptedText1, isNot(equals(encryptedText2)));
      
      final decryptedText1 = EncryptionHelper.decrypt(encryptedText1);
      final decryptedText2 = EncryptionHelper.decrypt(encryptedText2);
      
      expect(decryptedText1, equals(plainText));
      expect(decryptedText2, equals(plainText));
    });
  });
}
