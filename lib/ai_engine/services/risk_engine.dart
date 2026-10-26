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

    // 1. Fake News & Viral Hoaxes indicators
    final fakeNewsKeywords = [
      'forward to all', 'forward this message', 'forward this to', 'share to 10',
      'share to all your contacts', 'share before deleted', 'share before it is deleted',
      'share before it\'s deleted', 'media won\'t show', 'media wont show',
      'secret leaked', 'warning from police', 'warning from cyber crime',
      'unesco declared', 'nasa confirmed', 'miracle cure', 'cure for cancer',
      'doctors don\'t want you to know', 'free laptop', 'free recharge',
      'free mobile', 'free smartphone', 'pm yojana', 'pm scholarship',
      'modi giveaway', 'govt offering free', 'claim free subsidy',
      'free solar panel', 'lockdown announced', 'curfew from tomorrow',
      'schools closed indefinitely', 'currency notes invalid',
      '500 note discontinued', 'breaking news: whatsapp will be paid',
    ];

    // 2. Fake Banking & UPI Receipt indicators
    final bankingKeywords = [
      'account blocked', 'verify your account', 'bank account',
      'credit card', 'debit card', 'cvv', 'pin number',
      'otp', 'one time password', 'transfer failed', 'kyc expired',
      'kyc pending', 'electricity will be disconnected', 'sim card blocked',
    ];

    final receiptKeywords = [
      'payment successful', 'transaction successful', 'paid to',
      'transferred successfully', 'upi ref no', 'upi reference',
      'utr number', 'debited from account', 'fake payment',
      'spoof paytm', 'fakepay', 'money transferred',
    ];

    // 3. Scam & Phishing indicators
    final scamKeywords = [
      'congratulations', 'you have won', 'lottery', 'prize',
      'claim now', 'limited time', 'act now', 'urgent action',
      'investment opportunity', 'guaranteed returns', 'work from home',
      'earn money', 'job offer', 'like youtube videos', 'telegram task',
      'daily income', 'crypto trading bot', 'double your money',
    ];

    final phishingKeywords = [
      'verify your identity', 'click here to login',
      'update your password', 'security alert',
      'suspicious activity', 'confirm your details',
      'pan card update', 'apk file attached', 'download to verify',
    ];

    // 4. Authentic Press / Official Source indicators
    final authenticSources = [
      'reuters', 'associated press', 'press trust of india', 'pti',
      'pib fact check', 'press information bureau', 'bbc news',
      'the hindu', 'indian express', 'official gazette', 'ministry of',
      'reserve bank of india', 'supreme court', 'high court',
    ];

    int fakeNewsHits = 0;
    for (final kw in fakeNewsKeywords) {
      if (lowerText.contains(kw)) {
        fakeNewsHits++;
        reasons.add('Detected viral hoax / fake news phrase: "$kw"');
      }
    }
    score += fakeNewsHits * 25;

    int bankingHits = 0;
    for (final kw in bankingKeywords) {
      if (lowerText.contains(kw)) {
        bankingHits++;
        reasons.add('Detected sensitive banking / credential indicator: "$kw"');
      }
    }
    score += bankingHits * 20;

    int receiptHits = 0;
    for (final kw in receiptKeywords) {
      if (lowerText.contains(kw)) {
        receiptHits++;
        reasons.add('Detected payment receipt pattern: "$kw"');
      }
    }
    score += receiptHits * 15;

    int scamHits = 0;
    for (final kw in scamKeywords) {
      if (lowerText.contains(kw)) {
        scamHits++;
        reasons.add('Detected scam / lure keyword: "$kw"');
      }
    }
    score += scamHits * 20;

    int phishingHits = 0;
    for (final kw in phishingKeywords) {
      if (lowerText.contains(kw)) {
        phishingHits++;
        reasons.add('Detected phishing trigger: "$kw"');
      }
    }
    score += phishingHits * 22;

    int authenticHits = 0;
    for (final kw in authenticSources) {
      if (lowerText.contains(kw)) {
        authenticHits++;
      }
    }

    // Determine category and verdict
    String category = 'Real / Authentic Content';
    if (fakeNewsHits >= 1) {
      category = 'Fake News / Fabricated Hoax';
      actions.add('Do not share or forward this image on messaging platforms');
      actions.add('Check official fact-check portals like PIB Fact Check (pib.gov.in)');
    } else if (bankingHits >= 2 || (bankingHits >= 1 && phishingHits >= 1)) {
      category = 'Fake Banking / Phishing Alert';
      actions.add('Never enter credentials, passwords, or OTPs on unverified screens');
      actions.add('Call your bank\'s official customer care number immediately');
    } else if (receiptHits >= 2) {
      category = 'Fake / Forged Payment Receipt';
      actions.add('Verify transaction credit in your official banking or UPI app statement');
      actions.add('Do not release goods or cash based solely on payment screenshot proof');
    } else if (scamHits >= 2) {
      category = 'Scam / Deceptive Scheme';
      actions.add('Block the sender and do not transfer any advance processing fees');
      actions.add('Report fraudulent numbers and links to the National Cyber Crime Portal (1930)');
    } else if (phishingHits >= 2) {
      category = 'Phishing / Malicious Lure';
      actions.add('Do not click any embedded links or download attached APK files');
      actions.add('Access services directly via their official app or website');
    }

    final bool isFake = fakeNewsHits > 0 ||
        scamHits >= 2 ||
        phishingHits >= 2 ||
        (bankingHits >= 1 && phishingHits >= 1) ||
        receiptHits >= 2;

    if (isFake) {
      score = score.clamp(75, 98);
    } else {
      if (reasons.isEmpty) {
        if (authenticHits > 0) {
          reasons.add('Attributed to recognized official or accredited news publishers');
        }
        reasons.add('No viral hoax keywords, fake payment signatures, or phishing lures detected');
        actions.add('Content appears authentic; cross-check on official portals when in doubt');
      }
      score = (score - (authenticHits * 15)).clamp(5, 20);
    }

    return CyberRiskOutput(
      riskScore: score,
      threatCategory: category,
      confidence: (isFake || authenticHits > 0) ? 'High' : 'Medium',
      reasons: reasons,
      recommendedActions: actions,
    );
  }
}
