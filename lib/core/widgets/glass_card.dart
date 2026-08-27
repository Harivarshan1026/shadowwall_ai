/// Glassmorphic card widget.
///
/// A reusable frosted-glass card used throughout the app for
/// scan results, dashboard tiles, and information panels.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final EdgeInsets padding;
  final EdgeInsets? margin;
  final Color? borderColor;
  final Color? glowColor;
  final Gradient? gradient;
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 10,
    this.opacity = 0.08,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderColor,
    this.glowColor,
    this.gradient,
    this.onTap,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: RepaintBoundary(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: padding,
                decoration: BoxDecoration(
                  gradient: gradient ??
                      LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isDark
                            ? [
                                Colors.white.withValues(alpha: opacity),
                                Colors.white.withValues(alpha: opacity * 0.5),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white.withValues(alpha: 0.5),
                              ],
                      ),
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor ??
                        (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.06)),
                    width: 1,
                  ),
                  boxShadow: glowColor != null
                      ? [
                          BoxShadow(
                            color: glowColor!.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: -4,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A smaller glass chip / badge variant.
class GlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const GlassBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient glass card for highlighted/featured content.
class GradientGlassCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const GradientGlassCard({
    super.key,
    required this.child,
    this.accentColor = AppColors.primaryCyan,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.15),
          accentColor.withValues(alpha: 0.05),
        ],
      ),
      borderColor: accentColor.withValues(alpha: 0.25),
      glowColor: accentColor,
      padding: padding,
      onTap: onTap,
      child: child,
    );
  }
}
