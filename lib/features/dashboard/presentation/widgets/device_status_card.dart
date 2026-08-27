/// Device status card for dashboard.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class DeviceStatusCard extends StatelessWidget {
  final Map<String, dynamic> status;

  const DeviceStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final checks = [
      _Check('Screen Lock', status['screenLock'] == true, Icons.lock_rounded),
      _Check('Encryption', status['encryption'] == true, Icons.enhanced_encryption_rounded),
      _Check('Dev Options', status['developerOptions'] != true, Icons.developer_mode_rounded),
      _Check('USB Debug', status['usbDebugging'] != true, Icons.usb_rounded),
      _Check('Play Protect', status['playProtect'] == true, Icons.verified_user_rounded),
      _Check('Unknown Sources', status['unknownSources'] != true, Icons.block_rounded),
    ];

    final passed = checks.where((c) => c.isSecure).length;
    final total = checks.length;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$passed/$total',
                style: AppTypography.headlineMedium.copyWith(
                  color: passed == total
                      ? AppColors.neonGreen
                      : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'security checks passed',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.darkOnSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: checks.map((check) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (check.isSecure ? AppColors.neonGreen : AppColors.danger)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: (check.isSecure ? AppColors.neonGreen : AppColors.danger)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      check.isSecure
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: check.isSecure ? AppColors.neonGreen : AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      check.label,
                      style: AppTypography.labelSmall.copyWith(
                        color: check.isSecure
                            ? AppColors.neonGreen
                            : AppColors.danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Check {
  final String label;
  final bool isSecure;
  final IconData icon;

  const _Check(this.label, this.isSecure, this.icon);
}
