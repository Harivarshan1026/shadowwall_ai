/// Context-Aware Cyber Risk Engine.
///
/// The core AI engine that aggregates signals from all modules
/// and produces a unified risk assessment with explanations.
library;

import '../models/cyber_risk_input.dart';
import '../models/cyber_risk_output.dart';
import '../rules/url_rules.dart';
import '../rules/permission_rules.dart';
import '../rules/device_rules.dart';
import '../../core/utils/logger.dart';

class RiskEngine {
  RiskEngine._();
  static final instance = RiskEngine._();

  /// Analyze a URL and return a risk assessment.
  CyberRiskOutput analyzeUrl(String url) {
    AppLogger.scan('url', url);
    final urlAnalysis = UrlRules.analyze(url);
    return _buildOutput(urlAnalysis);
  }

  /// Analyze device security settings.
  CyberRiskOutput analyzeDevice(Map<String, bool> deviceStatus) {
    AppLogger.scan('device', 'Device security check');
    final deviceAnalysis = DeviceRules.analyze(deviceStatus);
    return _buildOutput(deviceAnalysis);
  }

  /// Analyze app permissions.
  CyberRiskOutput analyzePermissions(List<String> permissions, String appName) {
    AppLogger.scan('permission', appName);
    final permAnalysis = PermissionRules.analyze(permissions, appName);
    return _buildOutput(permAnalysis);
  }

  /// Analyze text extracted from a screenshot.
  CyberRiskOutput analyzeScreenshotText(String extractedText) {
    AppLogger.scan('screenshot', 'Screenshot text analysis');
    return _analyzeScreenshotContent(extractedText);
  }

  /// Aggregate multiple risk signals into a composite score.
  CyberRiskOutput aggregateRisks(List<CyberRiskOutput> signals) {
    if (signals.isEmpty) {
      return CyberRiskOutput.safe();
    }

    // Weighted average based on confidence
    double totalWeight = 0;
    double totalScore = 0;
    final allReasons = <String>[];
    final allActions = <String>[];
    String worstCategory = 'Safe';
    double worstScore = 0;

    for (final signal in signals) {
      final weight = signal.confidence == 'High'
          ? 3.0
          : signal.confidence == 'Medium'
              ? 2.0
              : 1.0;
      totalWeight += weight;
      totalScore += signal.riskScore * weight;
      allReasons.addAll(signal.reasons);
      allActions.addAll(signal.recommendedActions);

      if (signal.riskScore > worstScore) {
        worstScore = signal.riskScore;
        worstCategory = signal.threatCategory;
      }
    }

    final compositeScore = totalScore / totalWeight;

    return CyberRiskOutput(
      riskScore: compositeScore,
      threatCategory: worstCategory,
      confidence: compositeScore > 60 ? 'High' : compositeScore > 30 ? 'Medium' : 'Low',
      reasons: allReasons.toSet().toList(),
      recommendedActions: allActions.toSet().toList(),
    );
  }

  CyberRiskOutput _buildOutput(Map<String, dynamic> analysis) {
    final score = (analysis['score'] as num).toDouble();
    final reasons = (analysis['reasons'] as List<dynamic>).cast<String>();
    final category = analysis['category'] as String;
    final actions = (analysis['actions'] as List<dynamic>).cast<String>();

    final confidence = score > 70
        ? 'High'
        : score > 40
            ? 'Medium'
            : 'Low';

    AppLogger.ai(category, score: score, category: category);

    return CyberRiskOutput(
      riskScore: score,
      threatCategory: category,
      confidence: confidence,
      reasons: reasons,
      recommendedActions: actions,
    );
  }

  CyberRiskOutput _analyzeScreenshotContent(String text) {
    final lowerText = text.toLowerCase();
    double score = 0;
    final reasons = <String>[];
    final actions = <String>[];

    // Banking/financial indicators
    final bankingKeywords = [
      'account blocked', 'verify your account', 'bank account',
      'credit card', 'debit card', 'cvv', 'pin number',
      'otp', 'one time password', 'transfer failed',
    ];

    // Scam indicators
    final scamKeywords = [
      'congratulations', 'you have won', 'lottery', 'prize',
      'claim now', 'limited time', 'act now', 'urgent',
      'investment opportunity', 'guaranteed returns',
      'work from home', 'earn money', 'job offer',
    ];

    // Phishing indicators
    final phishingKeywords = [
      'verify your identity', 'click here to login',
      'update your password', 'security alert',
      'suspicious activity', 'confirm your details',
    ];

    int bankingHits = 0;
    for (final keyword in bankingKeywords) {
      if (lowerText.contains(keyword)) {
        bankingHits++;
        reasons.add('Detected banking keyword: "$keyword"');
      }
    }
    score += bankingHits * 12;

    int scamHits = 0;
    for (final keyword in scamKeywords) {
      if (lowerText.contains(keyword)) {
        scamHits++;
        reasons.add('Detected scam keyword: "$keyword"');
      }
    }
    score += scamHits * 15;

    int phishingHits = 0;
    for (final keyword in phishingKeywords) {
      if (lowerText.contains(keyword)) {
        phishingHits++;
        reasons.add('Detected phishing keyword: "$keyword"');
      }
    }
    score += phishingHits * 14;

    // Determine category
    String category = 'Safe';
    if (bankingHits >= 2) {
      category = 'Fake Banking Screen';
      actions.add('Do not enter any banking credentials');
      actions.add('Report this to your bank immediately');
    }
    if (scamHits >= 2) {
      category = 'Scam';
      actions.add('Do not provide any personal information');
      actions.add('Block the sender and report');
    }
    if (phishingHits >= 2) {
      category = 'Phishing';
      actions.add('Do not click any links');
      actions.add('Verify the sender through official channels');
    }

    if (reasons.isEmpty) {
      reasons.add('No suspicious indicators detected in the screenshot');
      actions.add('Content appears safe, but always verify independently');
    }

    score = score.clamp(0, 100);

    return CyberRiskOutput(
      riskScore: score,
      threatCategory: category,
      confidence: score > 60 ? 'High' : score > 30 ? 'Medium' : 'Low',
      reasons: reasons,
      recommendedActions: actions,
    );
  }
}
