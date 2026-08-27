/// URL scan result screen with detailed, user-friendly risk breakdown.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class UrlResultScreen extends StatelessWidget {
  final Map<String, dynamic>? scanResult;

  const UrlResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context) {
    final url = scanResult?['url'] ?? 'Unknown URL';
    final riskScore = (scanResult?['riskScore'] as num?)?.toDouble() ?? 0;
    final category = scanResult?['threatCategory'] ?? 'Safe';
    final confidence = scanResult?['confidence'] ?? 'Low';
    final reasons = (scanResult?['reasons'] as List<dynamic>?)?.cast<String>() ?? [];
    final actions = (scanResult?['recommendedActions'] as List<dynamic>?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'URL Threat Review',
        subtitle: 'Full Security Analysis',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score Ring
              GradientGlassCard(
                accentColor: AppColors.getRiskColor(riskScore),
                child: Column(
                  children: [
                    AnimatedScoreRing(
                      score: riskScore,
                      size: 140,
                      strokeWidth: 10,
                      label: category,
                      sublabel: 'Risk Score',
                      overrideColor: AppColors.getRiskColor(riskScore),
                    ),
                    const SizedBox(height: 16),
                    ThreatBadge.fromScore(riskScore),
                    const SizedBox(height: 8),
                    Text(
                      'AI Model Confidence: $confidence',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.darkOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Target URL Card
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.language_rounded, color: AppColors.primaryCyan, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        url,
                        style: AppTypography.mono.copyWith(
                          color: AppColors.darkOnSurface,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // How Risk Score Was Calculated (AI Explanation)
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calculate_rounded, color: AppColors.primaryCyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'How Risk Score Was Calculated',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ShadowWall AI scans domain age, SSL protocols, brand typosquatting, and host reputation:',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    _scoreBreakdownItem('Clean Domain Base', '0/100', AppColors.neonGreen),
                    if (reasons.isNotEmpty)
                      _scoreBreakdownItem(
                        'Identified Risk Factors',
                        '+${(reasons.length * 25).clamp(0, 85)} Points',
                        AppColors.danger,
                      ),
                    const Divider(color: Colors.white10, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calculated Threat Score:', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                        Text('${riskScore.toInt()}/100', style: AppTypography.titleMedium.copyWith(color: AppColors.getRiskColor(riskScore), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detailed Plain-English Reasons
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.danger.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology_rounded, color: AppColors.accentPurple, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Why This Link Was Flagged (Detailed Explanation)',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (reasons.isEmpty)
                      Text('No malicious or phishing indicators detected.', style: AppTypography.bodySmall.copyWith(color: AppColors.neonGreen))
                    else
                      ...reasons.map((reason) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.danger.withValues(alpha: 0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('⚠️ $reason', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getUrlReasonExplanation(reason),
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Recommended Actions Guide
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.neonGreen.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_rounded, color: AppColors.neonGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'What You Should Do (Safety Guide)',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...actions.map((action) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded,
                                  color: AppColors.neonGreen, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  action,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkOnSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreBreakdownItem(String label, String points, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
          Text(points, style: AppTypography.mono.copyWith(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  String _getUrlReasonExplanation(String reason) {
    final lower = reason.toLowerCase();
    if (lower.contains('typo') || lower.contains('impersonat')) {
      return 'What this means: This link mimics a legitimate brand (like PayPal, Google, or your Bank) by swapping letters or domain extensions to trick you into typing your login credentials.';
    }
    if (lower.contains('ssl') || lower.contains('http:')) {
      return 'What this means: The connection to this website is unencrypted. Any data you enter (passwords, credit card numbers) can be intercepted by hackers on the network.';
    }
    if (lower.contains('ip') || lower.contains('numerical')) {
      return 'What this means: The link uses a raw IP address instead of a domain name. Legitimate businesses rarely use raw IP addresses for public web portals.';
    }
    if (lower.contains('tld') || lower.contains('extension')) {
      return 'What this means: The website uses a suspicious top-level domain frequently associated with automated scam networks.';
    }
    return 'What this means: The URL structure exhibits characteristics commonly seen in phishing and social engineering attacks.';
  }
}
