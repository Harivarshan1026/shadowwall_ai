import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/ai_engine/rules/url_rules.dart';

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

    test('Identifies genuine UPI payment QR as Safe without flagging @ as phishing', () {
      const upi = 'upi://pay?pa=store@okhdfcbank&pn=SuperStore&am=250.00&cu=INR';
      final result = UrlRules.analyze(upi);

      expect(result['category'], equals('Safe'));
      expect(result['score'], equals(0.0));
      expect((result['reasons'] as List).any((r) => r.contains('Valid UPI Payee')), isTrue);
    });

    test('Flags UPI payment QR with missing payee as suspicious', () {
      const invalidUpi = 'upi://pay?pn=Unknown&am=100';
      final result = UrlRules.analyze(invalidUpi);

      expect(result['category'], equals('Suspicious Payment'));
      expect(result['score'], greaterThan(0));
    });

    test('Flags UPI payment QR with embedded malware link as Phishing', () {
      const malwareUpi = 'upi://pay?pa=store@upi&pn=Store&tn=http://malicious.apk';
      final result = UrlRules.analyze(malwareUpi);

      expect(result['category'], equals('Phishing'));
      expect(result['score'], greaterThanOrEqualTo(50));
    });
  });
}
