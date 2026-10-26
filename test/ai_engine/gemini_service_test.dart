import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadowwall_ai/core/config/env_config.dart';
import 'package:shadowwall_ai/ai_engine/services/gemini_ai_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EnvConfig.init();
  });

  group('GeminiAiService Tests', () {
    test('GeminiAiService singleton instance is non-null', () {
      final service = GeminiAiService.instance;
      expect(service, isNotNull);
    });

    test('GeminiAiService default model is configured', () {
      expect(GeminiAiService.model, equals('gemini-flash-lite-latest'));
    });

    test('Gemini model getter is non-empty', () {
      expect(GeminiAiService.model.isNotEmpty, isTrue);
    });
  });
}
