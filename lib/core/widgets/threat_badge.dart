/// Threat level badge widget.
///
/// Displays a colored badge indicating the threat level
/// with an icon and label. Used across scan results.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ThreatLevel {
  safe,
  low,
  medium,
  high,
  critical,
}

class ThreatBadge extends StatelessWidget {
  final ThreatLevel level;
  final bool showIcon;
  final bool isCompact;

  const ThreatBadge({
    super.key,
    required this.level,
    this.showIcon = true,
    this.isCompact = false,
  });

  /// Create from a risk score (0-100).
  factory ThreatBadge.fromScore(double score, {bool showIcon = true}) {
    ThreatLevel level;
    if (score <= 20) {
      level = ThreatLevel.safe;
    } else if (score <= 40) {
      level = ThreatLevel.low;
    } else if (score <= 60) {
      level = ThreatLevel.medium;
    } else if (score <= 80) {
      level = ThreatLevel.high;
    } else {
      level = ThreatLevel.critical;
    }
    return ThreatBadge(level: level, showIcon: showIcon);
  }

  Color get _color {
    switch (level) {
      case ThreatLevel.safe:
        return AppColors.safe;
      case ThreatLevel.low:
        return AppColors.primaryCyan;
      case ThreatLevel.medium:
        return AppColors.warning;
      case ThreatLevel.high:
        return AppColors.danger;
      case ThreatLevel.critical:
        return AppColors.critical;
    }
  }

  IconData get _icon {
    switch (level) {
      case ThreatLevel.safe:
        return Icons.verified_rounded;
      case ThreatLevel.low:
        return Icons.info_rounded;
      case ThreatLevel.medium:
        return Icons.warning_amber_rounded;
      case ThreatLevel.high:
        return Icons.dangerous_rounded;
      case ThreatLevel.critical:
        return Icons.gpp_bad_rounded;
    }
  }

  String get _label {
    switch (level) {
      case ThreatLevel.safe:
        return 'SAFE';
      case ThreatLevel.low:
        return 'LOW RISK';
      case ThreatLevel.medium:
        return 'MEDIUM RISK';
      case ThreatLevel.high:
        return 'HIGH RISK';
      case ThreatLevel.critical:
        return 'CRITICAL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Threat level: $_label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 8 : 14,
          vertical: isCompact ? 4 : 8,
        ),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(isCompact ? 6 : 10),
          border: Border.all(
            color: _color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              Icon(
                _icon,
                size: isCompact ? 14 : 18,
                color: _color,
              ),
              SizedBox(width: isCompact ? 4 : 6),
            ],
            Text(
              _label,
              style: (isCompact
                      ? AppTypography.labelSmall
                      : AppTypography.scoreBadge)
                  .copyWith(
                color: _color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
