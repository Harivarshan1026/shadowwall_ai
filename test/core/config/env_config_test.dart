import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadowwall_ai/core/config/env_config.dart';

void main() {
  group('EnvConfig Tests', () {
    test('Default model name fallback is valid', () {
      final model = EnvConfig.geminiModel;
      expect(model.isNotEmpty, isTrue);
      expect(model, contains('gemini'));
    });

    test('Masking helper masks long API keys safely', () {
      const sampleKey = 'AIzaSyMockTestKey0123456789abcdefLEc';
      final masked = EnvConfig.maskKey(sampleKey);
      expect(masked, startsWith('AIza'));
      expect(masked, endsWith('fLEc'));
      expect(masked, contains('****'));
    });

    test('Masking helper handles empty keys', () {
      final masked = EnvConfig.maskKey('');
      expect(masked, equals('Not Configured'));
    });

    test('Session persistence saves and clears login state on device', () async {
      SharedPreferences.setMockInitialValues({});
      
      await EnvConfig.saveUserSession(
        uid: 'test-user-123',
        email: 'tester@shadowwall.ai',
        displayName: 'Test Defender',
      );

      expect(EnvConfig.isUserLoggedIn, isTrue);
      expect(EnvConfig.userEmail, equals('tester@shadowwall.ai'));
      expect(EnvConfig.userDisplayName, equals('Test Defender'));
      expect(EnvConfig.authListenable.value, isTrue);

      await EnvConfig.clearUserSession();

      expect(EnvConfig.isUserLoggedIn, isFalse);
      expect(EnvConfig.userEmail, isNull);
      expect(EnvConfig.authListenable.value, isFalse);
    });
  });
}
