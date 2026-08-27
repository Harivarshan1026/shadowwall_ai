/// Glassmorphism decoration helpers.
///
/// Provides reusable frosted-glass effects for cards and containers,
/// optimized with [RepaintBoundary] for smooth 60fps rendering.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassmorphismDecoration {
  GlassmorphismDecoration._();

  /// Standard glass decoration for dark theme cards.
  static BoxDecoration darkGlass({
    double borderRadius = 20,
    double opacity = 0.08,
    double borderOpacity = 0.12,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderOpacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Glass decoration for light theme.
  static BoxDecoration lightGlass({
    double borderRadius = 20,
    double opacity = 0.6,
    double borderOpacity = 0.1,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.black.withValues(alpha: borderOpacity),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 15,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  /// Gradient glass decoration with a subtle color tint.
  static BoxDecoration gradientGlass({
    required Color accentColor,
    double borderRadius = 20,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          accentColor.withValues(alpha: 0.15),
          accentColor.withValues(alpha: 0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: accentColor.withValues(alpha: 0.2),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  /// Elevated neon glow decoration for highlighted cards.
  static BoxDecoration neonGlow({
    required Color glowColor,
    double borderRadius = 20,
    double glowIntensity = 0.3,
  }) {
    return BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glowColor.withValues(alpha: 0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity),
          blurRadius: 24,
          spreadRadius: -4,
        ),
        BoxShadow(
          color: glowColor.withValues(alpha: glowIntensity * 0.5),
          blurRadius: 40,
          spreadRadius: -8,
        ),
      ],
    );
  }

  /// The standard blur filter applied behind glass elements.
  static ImageFilter blurFilter({double sigma = 10}) {
    return ImageFilter.blur(sigmaX: sigma, sigmaY: sigma);
  }
}
