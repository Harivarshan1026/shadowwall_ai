/// Cyber Health Score card widget.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_score_ring.dart';

class CyberHealthCard extends StatelessWidget {
  final double score;
  final String trend;

  const CyberHealthCard({
    super.key,
    required this.score,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final trendIcon = trend == 'up'
        ? Icons.trending_up_rounded
        : trend == 'down'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;
    final trendColor = trend == 'up'
        ? AppColors.neonGreen
        : trend == 'down'
            ? AppColors.danger
            : AppColors.warning;

    return GradientGlassCard(
      accentColor: AppColors.getScoreColor(score),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cyber Health',
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(trendIcon, size: 16, color: trendColor),
                        const SizedBox(width: 4),
                        Text(
                          trend == 'up'
                              ? 'Improving'
                              : trend == 'down'
                                  ? 'Declining'
                                  : 'Stable',
                          style: AppTypography.labelSmall.copyWith(
                            color: trendColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Your overall security posture based on scans, device settings, and online behavior.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              AnimatedScoreRing(
                score: score,
                size: 120,
                strokeWidth: 8,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
