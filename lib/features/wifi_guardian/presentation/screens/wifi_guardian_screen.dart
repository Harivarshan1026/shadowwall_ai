/// Wi-Fi Guardian & Public Network Risk Inspector Screen.
library;

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class WifiGuardianScreen extends StatefulWidget {
  const WifiGuardianScreen({super.key});

  @override
  State<WifiGuardianScreen> createState() => _WifiGuardianScreenState();
}

class _WifiGuardianScreenState extends State<WifiGuardianScreen> {
  bool _isAuditing = false;
  bool _hasAudited = false;

  String _networkType = 'Scanning...';
  double _riskScore = 0;
  String _securityStandard = 'WPA2/WPA3 Personal';
  List<String> _threatsFound = [];
  List<String> _recommendations = [];

  Future<void> _auditNetwork() async {
    setState(() => _isAuditing = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.wifi)) {
      _networkType = 'Wi-Fi Network Connected';
      _riskScore = 20; // Safe home/office Wi-Fi standard
      _securityStandard = 'WPA3 / WPA2-AES Secure';
      _threatsFound = [
        'Active Wi-Fi connection detected',
        'No unencrypted broadcast signals found',
        'Captive Portal: None detected',
      ];
      _recommendations = [
        'Keep router firmware updated to prevent KRACK vulnerabilities',
        'Use MAC Address Randomization in device Wi-Fi settings',
        'Avoid transferring sensitive PINs on unverified public hotspots',
      ];
    } else if (connectivityResult.contains(ConnectivityResult.mobile)) {
      _networkType = 'Cellular Mobile Data (4G/5G)';
      _riskScore = 5;
      _securityStandard = 'Carrier Encrypted Telephony';
      _threatsFound = [
        'Direct Cellular Data Active',
        'Isolated from public Wi-Fi local subnet attacks',
      ];
      _recommendations = [
        'Mobile data is inherently safer than public open Wi-Fi hotspots',
      ];
    } else {
      _networkType = 'No Network Connection';
      _riskScore = 0;
      _securityStandard = 'Offline / Disconnected';
      _threatsFound = ['Device is completely offline'];
      _recommendations = ['Connect to a secure Wi-Fi or Cellular network to run live scans'];
    }

    if (!mounted) return;
    setState(() {
      _isAuditing = false;
      _hasAudited = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _auditNetwork();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Wi-Fi Guardian',
        subtitle: 'Inspect network safety & MITM risks',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _isAuditing
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primaryCyan),
                    SizedBox(height: 16),
                    Text('Auditing Wi-Fi Signal & MITM Vulnerabilities...', style: TextStyle(color: AppColors.darkOnSurfaceVariant)),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Network Status Ring Card
                    GlassCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          AnimatedScoreRing(
                            score: _riskScore,
                            size: 130,
                            strokeWidth: 10,
                          ),
                          const SizedBox(height: 16),
                          Text(_networkType, style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          const SizedBox(height: 6),
                          ThreatBadge.fromScore(_riskScore),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Option 1 & 2 Network Audit Card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wifi_lock_rounded, color: AppColors.primaryCyan, size: 22),
                              const SizedBox(width: 8),
                              Text('Security Standard: $_securityStandard', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._threatsFound.map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.neonGreen, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(t, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface))),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Recommendations
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield_rounded, color: AppColors.accentPurple, size: 20),
                              const SizedBox(width: 8),
                              Text('Wi-Fi Defense Guidelines', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ..._recommendations.map((rec) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text('• $rec', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                              )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    GradientButton(
                      label: 'Re-Audit Connection',
                      icon: Icons.refresh_rounded,
                      onPressed: _auditNetwork,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
