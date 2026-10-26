/// Device Security & Antivirus Vulnerability Scanner Screen.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/cyber_markdown_view.dart';
import '../../../../core/services/antivirus_scanner_service.dart';
import '../../../../core/services/pdf_audit_exporter.dart';

class DeviceSecurityScreen extends StatefulWidget {
  const DeviceSecurityScreen({super.key});

  @override
  State<DeviceSecurityScreen> createState() => _DeviceSecurityScreenState();
}

class _DeviceSecurityScreenState extends State<DeviceSecurityScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanning = false;
  bool _hasScanned = false;
  String _currentScanPhase = 'Ready to scan';
  double _scanProgress = 0.0;
  AntivirusScanResult? _scanResult;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startAntivirusScan() async {
    setState(() {
      _isScanning = true;
      _hasScanned = false;
      _scanProgress = 0.0;
      _currentScanPhase = 'Initializing Antivirus Engine...';
    });
    _pulseController.repeat(reverse: true);

    try {
      final result = await AntivirusScannerService.instance.performFullDeviceScan(
        onProgress: (phase, progress) {
          if (mounted) {
            setState(() {
              _currentScanPhase = phase;
              _scanProgress = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isScanning = false;
          _hasScanned = true;
          _scanResult = result;
        });
        _pulseController.stop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _currentScanPhase = 'Scan failed: $e';
        });
        _pulseController.stop();
      }
    }
  }

  Color _getSeverityColor(ThreatSeverity sev) {
    switch (sev) {
      case ThreatSeverity.critical:
        return AppColors.danger;
      case ThreatSeverity.high:
        return Colors.orangeAccent;
      case ThreatSeverity.medium:
        return AppColors.warning;
      case ThreatSeverity.low:
        return AppColors.info;
      case ThreatSeverity.info:
        return AppColors.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Device Antivirus & Vulnerability Check',
        subtitle: 'Deep hardware, OS & package integrity scan',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Summary & Trigger Card ──
              _buildScanOverviewCard(),
              const SizedBox(height: 20),

              // ── Scanning Progress Card (When Active) ──
              if (_isScanning) _buildScanningProgressCard(),

              // ── Results Section ──
              if (_hasScanned && _scanResult != null) ...[
                // Vulnerabilities & Identified Risks
                _buildVulnerabilitiesSection(),
                const SizedBox(height: 20),

                // System Posture Diagnostic Items
                _buildSystemPostureSection(),
                const SizedBox(height: 20),

                // AI Threat Vector Analysis
                _buildAiReportSection(),
                const SizedBox(height: 20),

                // Action buttons (Export PDF / Rescan)
                _buildBottomActionButtons(),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanOverviewCard() {
    final score = _scanResult?.securityScore ?? 100.0;
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              if (_hasScanned)
                AnimatedScoreRing(score: score, size: 90)
              else
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.4), width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.security_rounded, color: AppColors.primaryCyan, size: 44),
                  ),
                ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasScanned ? 'Posture: ${score >= 80 ? "Hardened" : (score >= 60 ? "Moderate Risk" : "High Exposure")}' : 'Antivirus Engine',
                      style: AppTypography.titleLarge.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _hasScanned
                          ? 'Audited ${_scanResult?.scannedAppsCount ?? 0} packages & ${_scanResult?.scannedItemsCount ?? 0} system checks. ${_scanResult?.vulnerabilities.length ?? 0} threats identified.'
                          : 'Performs full multi-layer scan of packages, permissions, OS CVEs, ADB bridge, and root posture.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    ),
                    if (_hasScanned) ...[
                      const SizedBox(height: 8),
                      ThreatBadge.fromScore(score),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GradientButton(
            label: _isScanning ? 'Deep Scanning in Progress...' : (_hasScanned ? 'Run Full Device Scan Again' : 'Scan Entire Device for Malware'),
            icon: _isScanning ? Icons.hourglass_top_rounded : Icons.radar_rounded,
            gradient: AppColors.primaryGradient,
            isLoading: _isScanning,
            onPressed: _isScanning ? null : _startAntivirusScan,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningProgressCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentScanPhase,
                  style: AppTypography.titleSmall.copyWith(color: AppColors.primaryCyan),
                ),
              ),
              Text(
                '${(_scanProgress * 100).toInt()}%',
                style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _scanProgress,
              backgroundColor: AppColors.darkSurfaceVariant,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilitiesSection() {
    final issues = _scanResult!.vulnerabilities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Identified Vulnerabilities (${issues.length})',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: issues.isEmpty ? AppColors.neonGreen.withValues(alpha: 0.15) : AppColors.danger.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: issues.isEmpty ? AppColors.neonGreen : AppColors.danger),
              ),
              child: Text(
                issues.isEmpty ? 'Clean Device' : '${issues.length} Threat Vectors',
                style: TextStyle(
                  color: issues.isEmpty ? AppColors.neonGreen : AppColors.danger,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (issues.isEmpty)
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zero Malware or System Flaws Detected',
                        style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'All verified packages, biometric hardware, and OS parameters conform to high cybersecurity standards.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...issues.map((issue) {
            final color = _getSeverityColor(issue.severity);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            issue.severity.name.toUpperCase(),
                            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            issue.category,
                            style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                          ),
                        ),
                        if (issue.cveId != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            issue.cveId!,
                            style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      issue.title,
                      style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      issue.description,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.build_circle_outlined, color: AppColors.neonGreen, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Remediation Action:',
                                  style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  issue.remediation,
                                  style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSystemPostureSection() {
    final posture = _scanResult!.systemPosture;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Posture & Integrity Matrix',
          style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildPostureRow(
                'Operating System',
                posture['os'] ?? 'Standard OS',
                Icons.devices_rounded,
                true,
              ),
              const Divider(color: Colors.white10),
              _buildPostureRow(
                'Hardware Architecture',
                posture['hardware'] ?? 'Hardware Verified',
                Icons.memory_rounded,
                true,
              ),
              const Divider(color: Colors.white10),
              _buildPostureRow(
                'Biometric Keystore',
                posture['biometrics'] == true ? 'Hardware Enrolled & Active' : 'No Enrolled Biometrics',
                Icons.fingerprint_rounded,
                posture['biometrics'] == true,
              ),
              const Divider(color: Colors.white10),
              _buildPostureRow(
                'USB Debugging (ADB)',
                posture['usbDebugging'] == true ? 'Exposed / Active' : 'Secure / Inactive',
                Icons.usb_rounded,
                posture['usbDebugging'] != true,
              ),
              const Divider(color: Colors.white10),
              _buildPostureRow(
                'Developer Options',
                posture['developerOptions'] == true ? 'Active (Attack Surface Elevated)' : 'Disabled / Hardened',
                Icons.code_rounded,
                posture['developerOptions'] != true,
              ),
              const Divider(color: Colors.white10),
              _buildPostureRow(
                'Screen Lock Protection',
                posture['screenLock'] == false ? 'No Lock Screen' : 'PIN / Passcode Active',
                Icons.lock_rounded,
                posture['screenLock'] != false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostureRow(String label, String value, IconData icon, bool isSecure) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: isSecure ? AppColors.neonGreen : AppColors.danger, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.darkOnSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                Text(value, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Icon(
            isSecure ? Icons.check_circle_rounded : Icons.warning_rounded,
            color: isSecure ? AppColors.neonGreen : AppColors.danger,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildAiReportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.psychology_rounded, color: AppColors.accentPurpleLight, size: 22),
            const SizedBox(width: 8),
            Text(
              'ShadowWall Cyber Intelligence Audit',
              style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
                ),
                child: CyberMarkdownView(
                  text: _scanResult!.aiAnalysisReport,
                  accentColor: AppColors.accentPurpleLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GradientButton(
            label: 'Export PDF Audit Report',
            icon: Icons.picture_as_pdf_rounded,
            gradient: const LinearGradient(colors: [AppColors.primaryCyan, AppColors.accentPurple]),
            onPressed: () {
              PdfAuditExporter.generateAndExportReport(
                healthScore: _scanResult!.securityScore,
                deviceStatus: _scanResult!.systemPosture,
                recentScans: [],
                aiReview: _scanResult!.aiAnalysisReport,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📄 Cryptographic PDF Security Audit generated!'),
                  backgroundColor: AppColors.neonGreen,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
