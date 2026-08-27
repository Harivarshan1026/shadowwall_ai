import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/core/config/env_config.dart';

void main() {
  group('EnvConfig Tests', () {
    test('Default model name fallback is valid', () {
      final model = EnvConfig.geminiModel;
      expect(model.isNotEmpty, isTrue);
      expect(model, contains('gemini'));
    });

    test('Masking helper masks long API keys safely', () {
      const sampleKey = 'AIzaSyA0PVI4d5wByDaksY7jr3S-fox08SNfLEc';
      final masked = EnvConfig.maskKey(sampleKey);
      expect(masked, startsWith('AIza'));
      expect(masked, endsWith('fLEc'));
      expect(masked, contains('****'));
    });

    test('Masking helper handles empty keys', () {
      final masked = EnvConfig.maskKey('');
      expect(masked, equals('Not Configured'));
    });
  });
}
