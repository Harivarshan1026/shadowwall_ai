/// Loading overlay widget.
///
/// Full-screen translucent overlay with a pulsing animation
/// shown during scan operations and AI analysis.
library;

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;
  final bool isVisible;
  final Widget child;

  const LoadingOverlay({
    super.key,
    this.message,
    required this.isVisible,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isVisible)
          Container(
            color: Colors.black.withValues(alpha: 0.6),
            child: Center(
              child: _LoadingContent(message: message),
            ),
          ),
      ],
    );
  }
}

class _LoadingContent extends StatefulWidget {
  final String? message;

  const _LoadingContent({this.message});

  @override
  State<_LoadingContent> createState() => _LoadingContentState();
}

class _LoadingContentState extends State<_LoadingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primaryCyan.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: AppColors.primaryCyan,
                  size: 36,
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 24),
          Text(
            widget.message!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkOnSurface,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 16),
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.primaryCyan.withValues(alpha: 0.15),
            color: AppColors.primaryCyan,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

/// Simple scanning animation widget.
class ScanningIndicator extends StatefulWidget {
  final String label;
  final Color color;

  const ScanningIndicator({
    super.key,
    this.label = 'Scanning...',
    this.color = AppColors.primaryCyan,
  });

  @override
  State<ScanningIndicator> createState() => _ScanningIndicatorState();
}

class _ScanningIndicatorState extends State<ScanningIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RotationTransition(
          turns: _controller,
          child: Icon(
            Icons.radar_rounded,
            color: widget.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.label,
          style: AppTypography.labelMedium.copyWith(
            color: widget.color,
          ),
        ),
      ],
    );
  }
}
