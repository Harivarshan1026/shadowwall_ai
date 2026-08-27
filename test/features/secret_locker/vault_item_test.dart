import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/features/secret_locker/presentation/screens/secret_locker_screen.dart';

void main() {
  group('VaultItem Model Tests', () {
    test('VaultItem serialization and deserialization', () {
      final now = DateTime.now();
      final item = VaultItem(
        id: '12345',
        originalName: 'confidential_report.pdf',
        encryptedPath: '/app/documents/secret_vault/12345.enc',
        fileType: 'PDFs',
        fileExtension: 'pdf',
        sizeBytes: 1024 * 500, // 500 KB
        dateAdded: now,
        integrityHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );

      final json = item.toJson();
      expect(json['id'], equals('12345'));
      expect(json['originalName'], equals('confidential_report.pdf'));
      expect(json['fileType'], equals('PDFs'));
      expect(json['fileExtension'], equals('pdf'));
      expect(json['sizeBytes'], equals(512000));
      expect(json['integrityHash'], contains('e3b0c442'));

      final restored = VaultItem.fromJson(json);
      expect(restored.id, equals(item.id));
      expect(restored.originalName, equals(item.originalName));
      expect(restored.fileType, equals(item.fileType));
      expect(restored.fileExtension, equals(item.fileExtension));
      expect(restored.sizeBytes, equals(item.sizeBytes));
      expect(restored.integrityHash, equals(item.integrityHash));
    });
  });
}
