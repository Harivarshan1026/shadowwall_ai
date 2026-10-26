import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/core/services/safe_browsing_service.dart';
import 'package:shadowwall_ai/core/services/virus_total_service.dart';

void main() {
  group('SafeBrowsingService Tests', () {
    test('Service instance is accessible as singleton', () {
      final instance1 = SafeBrowsingService.instance;
      final instance2 = SafeBrowsingService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('Query returns null gracefully on empty URL without API key', () async {
      final result = await SafeBrowsingService.instance.checkUrl('');
      expect(result, isNull);
    });
  });

  group('VirusTotalService Tests', () {
    test('Service instance is accessible as singleton', () {
      final instance1 = VirusTotalService.instance;
      final instance2 = VirusTotalService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('Query returns null gracefully on empty URL without API key', () async {
      final result = await VirusTotalService.instance.checkUrl('');
      expect(result, isNull);
    });

    test('Hash query returns null gracefully on empty hash without API key', () async {
      final result = await VirusTotalService.instance.checkFileHash('');
      expect(result, isNull);
    });
  });
}
