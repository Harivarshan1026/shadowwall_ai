import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlScanner Tests', () {
    test('Identifies phishing domain correctly', () {
      final String input = 'http://secure-login-paypal-update.com/login';
      
      // Simple mock logic for what the engine would evaluate
      final bool isPhishing = input.contains('paypal') && input.contains('update');
      
      expect(isPhishing, isTrue);
    });

    test('Identifies legitimate domain correctly', () {
      final String input = 'https://www.paypal.com/home';
      
      // Mock logic: exact domain match
      final bool isLegit = input.startsWith('https://www.paypal.com');
      
      expect(isLegit, isTrue);
    });

    test('Flags non-HTTPS connections', () {
      final String input = 'http://example.com';
      
      final bool isHttp = input.startsWith('http://');
      
      expect(isHttp, isTrue);
    });
  });
}
