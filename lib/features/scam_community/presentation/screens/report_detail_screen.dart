/// Report Detail screen.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class ReportDetailScreen extends StatelessWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Report Details',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Phishing', style: AppTypography.labelSmall.copyWith(color: AppColors.danger)),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 16),
                            const SizedBox(width: 4),
                            Text('AI Verified', style: AppTypography.labelSmall.copyWith(color: AppColors.neonGreen)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Fake Banking SMS with malicious link pretending to be account blocked alert',
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.account_circle_rounded, color: AppColors.primaryCyan, size: 24),
                        const SizedBox(width: 8),
                        Text('CyberHero_99', style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface)),
                        const SizedBox(width: 16),
                        Text('• 45 mins ago', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'I received an SMS claiming my bank account was temporarily blocked due to suspicious activity. It asked me to click a link to verify my identity. The URL looked like "secure-bank-update.xyz" which is obviously fake. Do not click!',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 24),
                    // Indicators
                    Text('Indicators of Compromise (IoC)', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _iocRow('Sender', '+1 (555) 019-2834'),
                          _iocRow('URL', 'secure-bank-update.xyz (Malicious)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _actionButton(Icons.arrow_upward_rounded, '124', AppColors.primaryCyan),
                        _actionButton(Icons.share_rounded, 'Share', AppColors.darkOnSurfaceVariant),
                        _actionButton(Icons.bookmark_outline_rounded, 'Save', AppColors.darkOnSurfaceVariant),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iocRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 60, child: Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant))),
          Expanded(child: Text(value, style: AppTypography.mono.copyWith(color: AppColors.danger, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelMedium.copyWith(color: color)),
      ],
    );
  }
}
