import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shadowwall_ai/core/services/apk_inspection_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApkInspectionService Tests', () {
    test('inspects in-memory mock APK without errors', () async {
      final mockBytes = Uint8List.fromList(
        'PK\x03\x04AndroidManifest.xml package="com.test.sampleapp" '
        'android.permission.INTERNET android.permission.CAMERA '
        'DexClassLoader /system/bin/su'
        .codeUnits,
      );

      final platformFile = PlatformFile(
        name: 'sample_threat.apk',
        size: mockBytes.length,
        bytes: mockBytes,
      );

      final result = await ApkInspectionService.inspectApk(platformFile);

      expect(result['fileName'], equals('sample_threat.apk'));
      expect(result['packageName'], contains('sampleapp'));
      expect(result['permissions'], contains('android.permission.INTERNET'));
      expect(result['permissions'], contains('android.permission.CAMERA'));
      expect(result['sha256'], isNot('Unavailable'));
      expect(result['riskScore'], isNotNull);
    });

    test('inspects file from disk without loading full bytes into memory', () async {
      final tempDir = await Directory.systemTemp.createTemp('apk_test');
      final testFile = File('${tempDir.path}/test_app.apk');
      await testFile.writeAsString('PK\x03\x04 package="com.example.fileapp" android.permission.INTERNET');

      final platformFile = PlatformFile(
        name: 'test_app.apk',
        path: testFile.path,
        size: testFile.lengthSync(),
      );

      final result = await ApkInspectionService.inspectApk(platformFile);

      expect(result['fileName'], equals('test_app.apk'));
      expect(result['sha256'], isNot('Unavailable'));
      expect(result['riskScore'], isNotNull);

      await tempDir.delete(recursive: true);
    });
  });
}
