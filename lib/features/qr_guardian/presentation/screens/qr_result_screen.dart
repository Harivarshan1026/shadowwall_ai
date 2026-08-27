/// QR scan result screen — reuses URL result structure with QR-specific info.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class QrResultScreen extends StatelessWidget {
  final Map<String, dynamic>? scanResult;
  const QrResultScreen({super.key, this.scanResult});

  @override
  Widget build(BuildContext context) {
    final content = scanResult?['content'] ?? '';
    final riskScore = (scanResult?['riskScore'] as num?)?.toDouble() ?? 0;
    final category = scanResult?['threatCategory'] ?? 'Safe';
    final isPaymentQr = scanResult?['isPaymentQr'] == true;
    final reasons = (scanResult?['reasons'] as List?)?.cast<String>() ?? [];
    final actions = (scanResult?['recommendedActions'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: const CyberAppBar(title: 'QR Analysis', subtitle: 'Scan Results', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GradientGlassCard(
                accentColor: AppColors.getRiskColor(riskScore),
                child: Column(
                  children: [
                    if (isPaymentQr)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.payment_rounded, color: AppColors.warning, size: 16),
                              const SizedBox(width: 6),
                              Text('Payment QR Detected', style: AppTypography.labelSmall.copyWith(color: AppColors.warning, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    AnimatedScoreRing(score: riskScore, size: 130, strokeWidth: 9, label: category, overrideColor: AppColors.getRiskColor(riskScore)),
                    const SizedBox(height: 12),
                    ThreatBadge.fromScore(riskScore),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('QR Content', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    const SizedBox(height: 8),
                    Text(content, style: AppTypography.mono.copyWith(color: AppColors.darkOnSurface), maxLines: 5, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.psychology_rounded, color: AppColors.accentPurple, size: 20),
                      const SizedBox(width: 8),
                      Text('Analysis Details', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    ]),
                    const SizedBox(height: 12),
                    ...reasons.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $r', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.neonGreen.withValues(alpha: 0.2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Icon(Icons.lightbulb_rounded, color: AppColors.neonGreen, size: 20),
                      const SizedBox(width: 8),
                      Text('Recommendations', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    ]),
                    const SizedBox(height: 12),
                    ...actions.map((a) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('→ $a', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
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
}
