/// Custom AppBar for ShadowWall AI.
///
/// A consistent app bar with optional gradient background,
/// glass effect, and action buttons.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CyberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool isTransparent;

  const CyberAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.isTransparent = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          isTransparent ? Colors.transparent : AppColors.darkSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
              tooltip: 'Back',
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.darkOnSurface,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkOnSurfaceVariant,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }
}

/// Shield logo widget using official ShadowWall app branding.
class ShieldLogo extends StatelessWidget {
  final double size;

  const ShieldLogo({super.key, this.size = 36});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryCyan.withValues(alpha: 0.35),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.25),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
            child: Icon(Icons.shield_rounded, color: Colors.white, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}
