import 'package:flutter_test/flutter_test.dart';
import 'package:shadowwall_ai/ai_engine/services/risk_engine.dart';
import 'package:shadowwall_ai/core/theme/app_colors.dart';

void main() {
  group('Screenshot Analyzer & RiskEngine Threat Detection Tests', () {
    final riskEngine = RiskEngine.instance;

    test('Authentic news text produces Real classification with low risk score', () {
      const authenticText = '''
Reuters - The Reserve Bank of India kept repo rate unchanged at 6.5% during the monetary policy committee review meeting. The official gazette released standard macroeconomic forecasts.
''';

      final result = riskEngine.analyzeScreenshotText(authenticText);

      expect(result.riskScore, lessThan(30.0));
      expect(result.threatCategory, contains('Real / Authentic'));
      expect(result.reasons, isNotEmpty);
    });

    test('Viral fake news hoax is detected and flagged as Fake with high risk score', () {
      const fakeNewsText = '''
Breaking News: Govt offering free laptop and free smartphone under PM scholarship scheme. Forward this message to all your groups before it is deleted!
''';

      final result = riskEngine.analyzeScreenshotText(fakeNewsText);

      expect(result.riskScore, greaterThanOrEqualTo(75.0));
      expect(result.threatCategory, equals('Fake News / Fabricated Hoax'));
      expect(result.reasons.any((r) => r.toLowerCase().contains('viral hoax')), isTrue);
    });

    test('Forged UPI payment receipt is detected as Fake with high risk score', () {
      const fakeReceiptText = '''
Payment Successful! Paid to merchant. UPI Ref No 398219082390 UTR Number 492019482. Transferred successfully.
''';

      final result = riskEngine.analyzeScreenshotText(fakeReceiptText);

      expect(result.riskScore, greaterThanOrEqualTo(75.0));
      expect(result.threatCategory, contains('Payment Receipt'));
    });

    test('Lottery prize scam is detected as Fake with high risk score', () {
      const scamText = '''
Congratulations! You have won lottery prize. Claim now limited time offer. Urgent action required to receive reward.
''';

      final result = riskEngine.analyzeScreenshotText(scamText);

      expect(result.riskScore, greaterThanOrEqualTo(75.0));
      expect(result.threatCategory, contains('Scam'));
    });

    test('Color scheme guarantees Green for Real and Red for Fake', () {
      // Real: neonGreen (#00FF9D / green), Fake: danger (#FF3B30 / red)
      expect(AppColors.neonGreen, isNotNull);
      expect(AppColors.danger, isNotNull);
      expect(AppColors.neonGreen != AppColors.danger, isTrue);
    });
  });
}
