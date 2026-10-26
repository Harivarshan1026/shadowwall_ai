/// APK analysis result screen with in-depth, user-friendly risk breakdown.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class ApkResultScreen extends StatelessWidget {
  final Map<String, dynamic>? analysisResult;
  const ApkResultScreen({super.key, this.analysisResult});

  @override
  Widget build(BuildContext context) {
    final r = analysisResult ?? {};
    final riskScore = (r['riskScore'] as num?)?.toDouble() ?? 0;
    final permissions = (r['permissions'] as List?)?.cast<String>() ?? [];
    final indicators = (r['riskIndicators'] as List?)?.cast<String>() ?? [];
    final actions = (r['recommendedActions'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: const CyberAppBar(title: 'APK Full Safety Review', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Risk Score Card
              GradientGlassCard(
                accentColor: AppColors.getRiskColor(riskScore),
                child: Column(
                  children: [
                    AnimatedScoreRing(
                      score: riskScore,
                      size: 130,
                      strokeWidth: 9,
                      overrideColor: AppColors.getRiskColor(riskScore),
                    ),
                    const SizedBox(height: 12),
                    ThreatBadge.fromScore(riskScore),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // APK File Metadata
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _infoRow('File Name', r['fileName'] ?? 'Unknown.apk'),
                    _infoRow('File Size', r['fileSize'] ?? 'Inspected'),
                    _infoRow('Package ID', r['packageName'] ?? 'com.unknown.app'),
                    _infoRow('Developer', r['developer'] ?? 'Unverified / Third-Party'),
                    _infoRow('SHA-256 Hash', r['sha256'] ?? (r['signature'] ?? 'Available')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Score Breakdown (Explainable AI Engine)
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
                      'ShadowWall AI evaluates APK safety on a scale from 0 (Completely Safe) to 100 (Critical Threat):',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    _scoreBreakdownItem('Base Safety Score', '0/100', AppColors.neonGreen),
                    if (indicators.isNotEmpty)
                      _scoreBreakdownItem(
                        'Risk Factors & Sideloading',
                        '+${(indicators.length * 20).clamp(0, 50)} Points',
                        AppColors.danger,
                      ),
                    if (permissions.isNotEmpty)
                      _scoreBreakdownItem(
                        'Dangerous Permissions Requested',
                        '+${(permissions.length * 10).clamp(0, 50)} Points',
                        AppColors.warning,
                      ),
                    const Divider(color: Colors.white10, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Final Composite Risk Score:', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                        Text('${riskScore.toInt()}/100', style: AppTypography.titleMedium.copyWith(color: AppColors.getRiskColor(riskScore), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Detailed Risk Indicators & Plain English Explanation
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.danger.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.smart_toy_rounded, color: AppColors.primaryCyan, size: 22),
                        const SizedBox(width: 8),
                        Text('Malware & Heuristic Threat Indicators', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCyan)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (indicators.isEmpty)
                      Text('No suspicious behavior indicators found in this APK package.', style: AppTypography.bodySmall.copyWith(color: AppColors.neonGreen))
                    else
                      ...indicators.map((ind) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                                  Text('⚠️ $ind', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(
                                    _getIndicatorExplanation(ind),
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

              // Requested Permissions & Layperson Explanations
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.admin_panel_settings_rounded, color: AppColors.warning, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Requested Permissions Explained (${permissions.length})',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (permissions.isEmpty)
                      Text('No sensitive permissions requested.', style: AppTypography.bodySmall.copyWith(color: AppColors.neonGreen))
                    else
                      ...permissions.map((perm) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.darkSurfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.security_rounded, size: 14, color: AppColors.warning),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          perm.split('.').last,
                                          style: AppTypography.mono.copyWith(color: AppColors.darkOnSurface, fontSize: 12, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getPermissionExplanation(perm),
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

              // Step-by-Step Recommendations for Unaware Users
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
                        Text('What You Should Do (Safety Guide)', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...actions.map((act) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: AppColors.neonGreen, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  act,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface),
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

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
          ),
          Expanded(child: Text(value, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.w500))),
        ],
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

  String _getIndicatorExplanation(String indicator) {
    final lower = indicator.toLowerCase();
    if (lower.contains('sideload') || lower.contains('unknown source')) {
      return 'Why it is dangerous: This application was downloaded from an external website rather than Google Play Store. Unverified APKs can carry hidden trojans.';
    }
    if (lower.contains('signature') || lower.contains('debug')) {
      return 'Why it is dangerous: The digital signature certificate is untrusted or missing, meaning the app developer cannot be officially verified.';
    }
    if (lower.contains('sms') || lower.contains('otp')) {
      return 'Why it is dangerous: The app contains code to read incoming SMS messages. Malicious apps use this to steal bank OTPs and log into your financial accounts.';
    }
    return 'Why it is dangerous: This behavior exceeds standard app requirements and introduces potential privacy or system security vulnerabilities.';
  }

  String _getPermissionExplanation(String permission) {
    final lower = permission.toLowerCase();
    if (lower.contains('sms') || lower.contains('receive_sms') || lower.contains('read_sms')) {
      return 'Reads your personal text messages and banking OTP codes.';
    }
    if (lower.contains('camera')) {
      return 'Can take photos or record videos using device cameras.';
    }
    if (lower.contains('location') || lower.contains('fine_location')) {
      return 'Tracks your exact real-time GPS location.';
    }
    if (lower.contains('contacts') || lower.contains('read_contacts')) {
      return 'Accesses your full address book and friend contact list.';
    }
    if (lower.contains('record_audio') || lower.contains('microphone')) {
      return 'Can record audio clips using the background microphone.';
    }
    if (lower.contains('system_alert_window')) {
      return 'Draws fake popups over other apps to capture passwords (Overlay Attack).';
    }
    if (lower.contains('install_packages')) {
      return 'Can silently install additional unknown software applications on your device.';
    }
    return 'Allows background access to hardware or sensitive device data.';
  }
}
