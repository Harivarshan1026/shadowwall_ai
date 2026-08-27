/// Security tips carousel widget.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';

class SecurityTipsCarousel extends StatefulWidget {
  const SecurityTipsCarousel({super.key});

  @override
  State<SecurityTipsCarousel> createState() => _SecurityTipsCarouselState();
}

class _SecurityTipsCarouselState extends State<SecurityTipsCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _currentPage = 0;

  static const _tips = [
    {
      'title': 'Verify Before You Click',
      'body': 'Always check the URL before entering credentials. Look for HTTPS and verify the domain spelling.',
      'icon': Icons.link_rounded,
      'color': AppColors.primaryCyan,
    },
    {
      'title': 'QR Code Caution',
      'body': 'Never scan QR codes from untrusted sources. They can redirect you to phishing pages or trigger downloads.',
      'icon': Icons.qr_code_scanner_rounded,
      'color': AppColors.accentPurple,
    },
    {
      'title': 'Strong Passwords Matter',
      'body': 'Use unique passwords for each account. Enable 2FA wherever possible for an extra layer of security.',
      'icon': Icons.password_rounded,
      'color': AppColors.neonGreen,
    },
    {
      'title': 'App Permissions',
      'body': 'Review app permissions regularly. Revoke access for apps that don\'t need camera, mic, or location.',
      'icon': Icons.admin_panel_settings_rounded,
      'color': AppColors.warning,
    },
    {
      'title': 'Keep Software Updated',
      'body': 'Install security patches promptly. Outdated software is a common attack vector for cybercriminals.',
      'icon': Icons.system_update_rounded,
      'color': AppColors.info,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _controller,
            itemCount: _tips.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GlassCard(
                  borderColor: (tip['color'] as Color).withValues(alpha: 0.2),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: (tip['color'] as Color).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          tip['icon'] as IconData,
                          color: tip['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              tip['title'] as String,
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip['body'] as String,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.darkOnSurfaceVariant,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Page indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _tips.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _currentPage ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _currentPage
                    ? AppColors.primaryCyan
                    : AppColors.darkOnSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
