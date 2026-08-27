/// Dart extension methods for common operations.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// ──────────────── String Extensions ────────────────

extension StringX on String {
  /// Capitalize the first letter.
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';

  /// Check if the string is a valid URL.
  bool get isValidUrl {
    final uri = Uri.tryParse(this);
    return uri != null && (uri.hasScheme) && uri.host.isNotEmpty;
  }

  /// Check if the string is a valid email.
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Extract domain from URL.
  String? get extractDomain {
    try {
      final uri = Uri.parse(this);
      return uri.host;
    } catch (_) {
      return null;
    }
  }

  /// Mask sensitive data (email, phone).
  String get masked {
    if (isValidEmail) {
      final parts = split('@');
      final name = parts[0];
      final maskedName =
          name.length > 2 ? '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}' : name;
      return '$maskedName@${parts[1]}';
    }
    if (length > 4) {
      return '${substring(0, 2)}${'*' * (length - 4)}${substring(length - 2)}';
    }
    return this;
  }
}

// ──────────────── DateTime Extensions ────────────────

extension DateTimeX on DateTime {
  /// Relative time string (e.g., "2h ago", "yesterday").
  String get timeAgo {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  /// Formatted date string.
  String get formatted => '$day/${month.toString().padLeft(2, '0')}/$year';

  /// Formatted with time.
  String get formattedWithTime =>
      '$formatted ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

// ──────────────── Double Extensions ────────────────

extension DoubleX on double {
  /// Get risk level label from score.
  String get riskLabel {
    if (this <= 20) return 'Safe';
    if (this <= 40) return 'Low Risk';
    if (this <= 60) return 'Medium Risk';
    if (this <= 80) return 'High Risk';
    return 'Critical';
  }

  /// Get risk color from score.
  Color get riskColor => AppColors.getRiskColor(this);

  /// Get health score label.
  String get healthLabel {
    if (this >= 80) return 'Excellent';
    if (this >= 60) return 'Good';
    if (this >= 40) return 'Fair';
    if (this >= 20) return 'Poor';
    return 'Critical';
  }

  /// Get score color (higher is better).
  Color get scoreColor => AppColors.getScoreColor(this);
}

// ──────────────── BuildContext Extensions ────────────────

extension ContextX on BuildContext {
  /// Access theme data.
  ThemeData get theme => Theme.of(this);

  /// Access color scheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access text theme.
  TextTheme get textTheme => theme.textTheme;

  /// Access screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Access screen width.
  double get screenWidth => screenSize.width;

  /// Access screen height.
  double get screenHeight => screenSize.height;

  /// Check if dark mode.
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Show a snackbar.
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

// ──────────────── Widget Extensions ────────────────

extension WidgetX on Widget {
  /// Wrap widget with padding.
  Widget padded([EdgeInsets padding = const EdgeInsets.all(16)]) {
    return Padding(padding: padding, child: this);
  }

  /// Wrap widget with horizontal padding.
  Widget paddedH([double value = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: value),
      child: this,
    );
  }

  /// Wrap widget with vertical padding.
  Widget paddedV([double value = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: value),
      child: this,
    );
  }
}
