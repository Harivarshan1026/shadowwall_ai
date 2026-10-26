/// Recent scans list widget.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/utils/extensions.dart';

class RecentScansList extends StatelessWidget {
  final List<Map<String, dynamic>> scans;

  const RecentScansList({super.key, required this.scans});

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'url': return Icons.link_rounded;
      case 'qr': return Icons.qr_code_rounded;
      case 'apk': return Icons.android_rounded;
      case 'screenshot': return Icons.screenshot_rounded;
      case 'device': return Icons.phone_android_rounded;
      case 'permission': return Icons.admin_panel_settings_rounded;
      default: return Icons.radar_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) {
      return GlassCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.radar_rounded,
                  size: 48, color: AppColors.darkOnSurfaceVariant),
              const SizedBox(height: 12),
              Text(
                'No scans yet',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.darkOnSurfaceVariant,
                ),
              ),
              Text(
                'Start scanning to see your history here',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkOnSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: scans.map((scan) {
        final type = scan['type'] as String;
        final input = scan['input'] as String;
        final riskScore = (scan['riskScore'] as num).toDouble();
        final time = scan['time'] as DateTime;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            onTap: () {},
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: riskScore.riskColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getTypeIcon(type),
                    color: riskScore.riskColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        input.truncate(30),
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.darkOnSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time.timeAgo,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.darkOnSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                ThreatBadge.fromScore(riskScore, showIcon: false),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
