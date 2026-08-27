/// Device Security Check screen.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../ai_engine/services/risk_engine.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';
import '../../../../core/services/native_scanner_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;

class DeviceSecurityScreen extends StatefulWidget {
  const DeviceSecurityScreen({super.key});

  @override
  State<DeviceSecurityScreen> createState() => _DeviceSecurityScreenState();
}

class _DeviceSecurityScreenState extends State<DeviceSecurityScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _hasScanned = false;
  Map<String, dynamic>? _result;
  String? _aiReviewText;
  late AnimationController _scanAnimController;

  List<_DeviceCheck> _deviceChecks = [
    const _DeviceCheck('Screen Lock', Icons.lock_rounded, null, 'Pending scan...'),
    const _DeviceCheck('Developer Options', Icons.developer_mode_rounded, null, 'Pending scan...'),
    const _DeviceCheck('USB Debugging', Icons.usb_rounded, null, 'Pending scan...'),
    const _DeviceCheck('Android Version', Icons.android_rounded, null, 'Pending scan...'),
  ];

  @override
  void initState() {
    super.initState();
    _scanAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _scanAnimController.dispose();
    super.dispose();
  }

  Future<void> _runSecurityCheck() async {
    setState(() => _isScanning = true);
    _scanAnimController.repeat();

    // Option 1: Native Android Hardware Scan
    final status = await NativeScannerService.getDeviceSecurityStatus();
    
    String osVersion = 'Unknown';
    String securityPatch = 'Unknown';
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        osVersion = 'Android ${androidInfo.version.release}';
        securityPatch = androidInfo.version.securityPatch ?? 'Unknown';
      }
    } catch (_) {}

    _deviceChecks = [
      _DeviceCheck('Screen Lock', Icons.lock_rounded, status['screenLock'], status['screenLock'] == true ? 'Screen lock is active' : 'No screen lock detected'),
      _DeviceCheck('Developer Options', Icons.developer_mode_rounded, status['developerOptions'] == false, status['developerOptions'] == true ? 'Enabled — potential risk' : 'Disabled — good for security'),
      _DeviceCheck('USB Debugging', Icons.usb_rounded, status['usbDebugging'] == false, status['usbDebugging'] == true ? 'Enabled — potential risk' : 'Disabled — good for security'),
      _DeviceCheck('Android Version', Icons.android_rounded, null, osVersion),
      if (securityPatch != 'Unknown') _DeviceCheck('Security Patch', Icons.update_rounded, null, securityPatch),
    ];

    final Map<String, bool> deviceStatus = {
      'screenLock': status['screenLock'] ?? true,
      'encryption': true,
      'developerOptions': status['developerOptions'] == false,
      'usbDebugging': status['usbDebugging'] == false,
      'playProtect': true,
      'unknownSources': false,
    };

    final result = RiskEngine.instance.analyzeDevice(deviceStatus);

    // Option 2: Google Gemini AI Human-Like Detailed Review
    final aiResponse = await GeminiAiService.instance.analyzeDeviceWithAi({
      'screenLockActive': status['screenLock'],
      'developerOptionsEnabled': status['developerOptions'],
      'usbDebuggingEnabled': status['usbDebugging'],
      'osVersion': osVersion,
      'securityPatch': securityPatch,
    });

    if (!mounted) return;
    _scanAnimController.stop();
    setState(() {
      _isScanning = false;
      _hasScanned = true;
      _result = result.toMap();
      _aiReviewText = aiResponse?['aiReview'] ?? 'Option 1 Native Scan Complete. Your device hardware configurations have been audited for baseline vulnerabilities.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final riskScore = (_result?['riskScore'] as num?)?.toDouble() ?? 0;
    final reasons = (_result?['reasons'] as List?)?.cast<String>() ?? [];
    final actions = (_result?['recommendedActions'] as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Device Security',
        subtitle: 'Check your device security settings',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Score (after scan)
              if (_hasScanned) ...[
                GradientGlassCard(
                  accentColor: AppColors.getScoreColor(100 - riskScore),
                  child: Column(
                    children: [
                      AnimatedScoreRing(
                        score: 100 - riskScore,
                        size: 140,
                        strokeWidth: 10,
                        sublabel: 'Device Security Score',
                      ),
                      const SizedBox(height: 12),
                      ThreatBadge.fromScore(riskScore),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Security Checks Grid
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Security Checks',
                      style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 16),
                    ..._deviceChecks.map((check) => _buildCheckRow(check)),
                  ],
                ),
              ),

              if (!_hasScanned) ...[
                const SizedBox(height: 20),
                RotationTransition(
                  turns: _scanAnimController,
                  child: _isScanning
                      ? const Icon(Icons.radar_rounded, color: AppColors.primaryCyan, size: 40)
                      : const SizedBox.shrink(),
                ),
                if (_isScanning) const SizedBox(height: 12),
                GradientButton(
                  label: _isScanning ? 'Scanning Device...' : 'Run Security Check',
                  icon: Icons.security_rounded,
                  isLoading: _isScanning,
                  onPressed: _isScanning ? null : _runSecurityCheck,
                ),
              ],

              // Results
              if (_hasScanned) ...[
                // Option 2: Human-Like AI Detailed Review Card
                if (_aiReviewText != null) ...[
                  const SizedBox(height: 16),
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.smart_toy_rounded, color: AppColors.primaryCyan, size: 22),
                            const SizedBox(width: 8),
                            Text('Option 2: Human-Like AI Security Review', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _aiReviewText!,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (reasons.isNotEmpty)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology_rounded, color: AppColors.accentPurple, size: 20),
                            const SizedBox(width: 8),
                            Text('Analysis', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...reasons.map((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $r', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                        )),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                if (actions.isNotEmpty)
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.neonGreen.withValues(alpha: 0.2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_rounded, color: AppColors.neonGreen, size: 20),
                            const SizedBox(width: 8),
                            Text('Recommendations', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...actions.map((a) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('→ $a', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                        )),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckRow(_DeviceCheck check) {
    final Color statusColor;
    final IconData statusIcon;

    if (check.isSecure == null) {
      statusColor = AppColors.info;
      statusIcon = Icons.info_outline_rounded;
    } else if (check.label == 'Developer Options' || check.label == 'USB Debugging' || check.label == 'Unknown Sources') {
      // These are secure when FALSE (disabled)
      statusColor = check.isSecure == false ? AppColors.neonGreen : AppColors.danger;
      statusIcon = check.isSecure == false ? Icons.check_circle_rounded : Icons.cancel_rounded;
    } else {
      statusColor = check.isSecure == true ? AppColors.neonGreen : AppColors.danger;
      statusIcon = check.isSecure == true ? Icons.check_circle_rounded : Icons.cancel_rounded;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(check.icon, size: 18, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(check.label, style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                Text(check.detail, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
              ],
            ),
          ),
          Icon(statusIcon, size: 20, color: statusColor),
        ],
      ),
    );
  }
}

class _DeviceCheck {
  final String label;
  final IconData icon;
  final bool? isSecure;
  final String detail;

  const _DeviceCheck(this.label, this.icon, this.isSecure, this.detail);
}
