/// ShadowWall AI color palette.
///
/// Cyber-themed color system with neon accents on dark surfaces.
/// Designed for both dark and light themes with accessibility in mind.
library;

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ──────────────── Primary Palette (Cyber Neon) ────────────────

  /// Primary neon cyan — used for primary actions, highlights, and scores
  static const Color primaryCyan = Color(0xFF00D4FF);
  static const Color primaryCyanDark = Color(0xFF0099CC);
  static const Color primaryCyanLight = Color(0xFF66E5FF);

  /// Secondary neon green — used for safe/success states
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonGreenDark = Color(0xFF00CC6A);

  /// Accent neon purple — used for AI features and premium elements
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentPurpleDark = Color(0xFF6D28D9);
  static const Color accentPurpleLight = Color(0xFFA78BFA);

  // ──────────────── Semantic Colors ────────────────

  /// Safe / Low Risk
  static const Color safe = Color(0xFF00FF88);
  static const Color safeBackground = Color(0xFF0A2A1A);

  /// Warning / Medium Risk
  static const Color warning = Color(0xFFFFB800);
  static const Color warningBackground = Color(0xFF2A2000);

  /// Danger / High Risk
  static const Color danger = Color(0xFFFF3B5C);
  static const Color dangerBackground = Color(0xFF2A0A10);

  /// Critical
  static const Color critical = Color(0xFFFF0040);
  static const Color criticalBackground = Color(0xFF330010);

  /// Info
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBackground = Color(0xFF0A1A2A);

  // ──────────────── Dark Theme Surfaces ────────────────

  /// Background — deepest layer
  static const Color darkBackground = Color(0xFF0A0E21);

  /// Surface — card backgrounds
  static const Color darkSurface = Color(0xFF111633);

  /// Surface variant — slightly elevated elements
  static const Color darkSurfaceVariant = Color(0xFF1A1F44);

  /// Surface container — for nested containers
  static const Color darkSurfaceContainer = Color(0xFF141836);

  /// On-surface text
  static const Color darkOnSurface = Color(0xFFE8EAED);
  static const Color darkOnSurfaceVariant = Color(0xFF9AA0B8);

  // ──────────────── Light Theme Surfaces ────────────────

  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF0F2F5);
  static const Color lightOnSurface = Color(0xFF1A1C2E);
  static const Color lightOnSurfaceVariant = Color(0xFF5A5E78);

  // ──────────────── Glassmorphism ────────────────

  /// Glass overlay color for dark theme
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  /// Glass overlay color for light theme
  static const Color glassBlack = Color(0x0D000000);
  static const Color glassBorderLight = Color(0x1A000000);

  // ──────────────── Gradient Definitions ────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryCyan, accentPurple],
  );

  static const LinearGradient safeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonGreen, Color(0xFF00C9DB)],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [warning, Color(0xFFFF8C00)],
  );

  static const LinearGradient dangerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [danger, Color(0xFFFF0040)],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A0E21),
      Color(0xFF111633),
      Color(0xFF0A0E21),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1F44),
      Color(0xFF111633),
    ],
  );

  /// Returns a color based on a risk score (0-100).
  static Color getScoreColor(double score) {
    if (score >= 80) return safe;
    if (score >= 60) return primaryCyan;
    if (score >= 40) return warning;
    if (score >= 20) return danger;
    return critical;
  }

  /// Returns a color based on a risk level (inverted — lower is safer).
  static Color getRiskColor(double risk) {
    if (risk <= 20) return safe;
    if (risk <= 40) return primaryCyan;
    if (risk <= 60) return warning;
    if (risk <= 80) return danger;
    return critical;
  }
}
