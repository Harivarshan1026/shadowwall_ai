import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/core/services/background_guard_service.dart';

void main() {
  group('BackgroundGuardService Tests', () {
    test('BackgroundGuardService singleton is initialized', () {
      final service = BackgroundGuardService.instance;
      expect(service, isNotNull);
      expect(service.recentInterceptions, isNotNull);
    });

    test('Recording vulnerable activity adds to recent interceptions', () async {
      final service = BackgroundGuardService.instance;
      final initialCount = service.recentInterceptions.length;

      await service.reportVulnerableAppActivity(
        appName: 'Test Suspicious Utility',
        activityDescription: 'Detected attempt to read device screen buffer.',
      );

      expect(service.recentInterceptions.length, equals(initialCount + 1));
      expect(service.recentInterceptions.first.title, contains('Test Suspicious Utility'));
    });

    test('Package scan audit correctly identifies high-threat accessibility + overlay', () async {
      final service = BackgroundGuardService.instance;
      
      await service.scanNewlyDownloadedApp(
        appName: 'CraxsRAT Dropper',
        packageName: 'com.dropper.rat',
        permissions: [
          'android.permission.BIND_ACCESSIBILITY_SERVICE',
          'android.permission.SYSTEM_ALERT_WINDOW',
          'android.permission.READ_SMS',
        ],
        isSystemApp: false,
      );

      expect(service.recentInterceptions.any((i) => i.title.contains('CraxsRAT Dropper')), isTrue);
    });
  });
}
