/// Quick actions grid on the dashboard.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/router/app_router.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QuickAction('URL Scanner', Icons.link_rounded, AppColors.primaryCyan,
          RoutePaths.urlScanner),
      _QuickAction('QR Guardian', Icons.qr_code_scanner_rounded,
          AppColors.accentPurple, RoutePaths.qrScanner),
      _QuickAction('APK Analyzer', Icons.android_rounded,
          AppColors.neonGreen, RoutePaths.apkAnalyzer),
      _QuickAction('Permissions', Icons.admin_panel_settings_rounded,
          AppColors.warning, RoutePaths.permissionDoctor),
      _QuickAction('Device Check', Icons.security_rounded,
          AppColors.info, RoutePaths.deviceSecurity),
      _QuickAction('Screenshot AI', Icons.screenshot_rounded,
          AppColors.danger, RoutePaths.screenshotAnalyzer),
      _QuickAction('AI Assistant', Icons.smart_toy_rounded,
          AppColors.accentPurpleLight, RoutePaths.aiAssistant),
      _QuickAction('Wi-Fi Guard', Icons.wifi_lock_rounded,
          AppColors.primaryCyan, RoutePaths.wifiGuardian),
      _QuickAction('Secret Locker', Icons.lock_rounded,
          AppColors.warning, RoutePaths.secretLocker),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _QuickActionTile(action: action);
      },
    );
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickAction(this.label, this.icon, this.color, this.route);
}

class _QuickActionTile extends StatefulWidget {
  final _QuickAction action;

  const _QuickActionTile({required this.action});

  @override
  State<_QuickActionTile> createState() => _QuickActionTileState();
}

class _QuickActionTileState extends State<_QuickActionTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        context.push(widget.action.route);
      },
      onTapCancel: () => _controller.forward(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Transform.scale(
          scale: _controller.value,
          child: child,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.action.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.action.color.withValues(alpha: 0.2),
                ),
              ),
              child: Icon(
                widget.action.icon,
                color: widget.action.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.action.label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.darkOnSurfaceVariant,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
