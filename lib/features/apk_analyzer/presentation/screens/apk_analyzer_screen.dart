/// APK Analyzer Screen — Cross-platform Android Package & Malware Inspection.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/apk_inspection_service.dart';

class ApkAnalyzerScreen extends StatefulWidget {
  const ApkAnalyzerScreen({super.key});

  @override
  State<ApkAnalyzerScreen> createState() => _ApkAnalyzerScreenState();
}

class _ApkAnalyzerScreenState extends State<ApkAnalyzerScreen> {
  PlatformFile? _pickedFile;
  bool _isAnalyzing = false;
  String _scanPhase = 'Preparing Scan Engine...';

  Future<void> _selectApk() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['apk', 'APK'],
        withData: kIsWeb, // true on Web (no filesystem paths), false on Native (prevents Android 1MB Binder crash)
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Maximum file size safety guard (500 MB)
        if (file.size > 500 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('File exceeds 500MB maximum limit. Please select an APK under 500MB.'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }

        setState(() {
          _pickedFile = file;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File selection error: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  int _getPickedFileSize() {
    if (_pickedFile == null) return 0;
    if (_pickedFile!.size > 0) return _pickedFile!.size;
    if (!kIsWeb && _pickedFile!.path != null) {
      try {
        final f = File(_pickedFile!.path!);
        if (f.existsSync()) return f.lengthSync();
      } catch (_) {}
    }
    return 0;
  }

  void _loadSampleApk(String sampleName, String riskLevel) {
    // Generate synthetic binary payload for testing/demoing
    final mockBytes = Uint8List.fromList(
      'PK\x03\x04AndroidManifest.xml package="com.shadow.threat.${sampleName.toLowerCase()}" '
      'android.permission.INTERNET android.permission.ACCESS_NETWORK_STATE '
      '${riskLevel == "high" ? "android.permission.READ_SMS android.permission.SEND_SMS android.permission.SYSTEM_ALERT_WINDOW android.permission.BIND_ACCESSIBILITY_SERVICE /system/bin/su DexClassLoader" : "android.permission.ACCESS_FINE_LOCATION android.permission.CAMERA"}'
      .codeUnits,
    );

    setState(() {
      _pickedFile = PlatformFile(
        name: sampleName,
        size: 14850000,
        bytes: mockBytes,
      );
    });
  }

  Future<void> _analyzeApk() async {
    if (_pickedFile == null) return;
    setState(() {
      _isAnalyzing = true;
      _scanPhase = 'Reading APK Binary & Manifest Bytes...';
    });

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _scanPhase = 'Auditing Requested Permissions & API Calls...');

      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _scanPhase = 'Evaluating Heuristic Signatures & Trojan Vectors...');

      // Run Full Cross-Platform APK Inspection
      final analysisResult = await ApkInspectionService.inspectApk(_pickedFile!);

      if (!mounted) return;
      setState(() => _isAnalyzing = false);

      context.push(RoutePaths.apkResult, extra: analysisResult);
    } catch (e, stack) {
      debugPrint('APK analysis error: $e\n$stack');
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to inspect APK: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'APK Analyzer',
        subtitle: 'Inspect Android packages for malware and privacy leaks',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.35), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.15),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.android_rounded, color: AppColors.neonGreen, size: 46),
                ),
              ),
              const SizedBox(height: 20),

              // Upload Container Card
              GlassCard(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    if (_pickedFile != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.25)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.insert_drive_file_rounded, color: AppColors.primaryCyan, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pickedFile!.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: AppColors.darkOnSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Size: ${_formatSize(_getPickedFileSize())} • Ready to inspect',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primaryCyan,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_isAnalyzing)
                              IconButton(
                                icon: const Icon(Icons.close_rounded, color: AppColors.darkOnSurfaceVariant),
                                onPressed: () => setState(() => _pickedFile = null),
                                tooltip: 'Remove file',
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],

                    if (_isAnalyzing) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const LinearProgressIndicator(
                              color: AppColors.neonGreen,
                              backgroundColor: AppColors.darkSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _scanPhase,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.neonGreen,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      GradientButton(
                        label: _pickedFile == null ? 'Select / Upload APK File' : 'Start Full APK Security Scan',
                        icon: _pickedFile == null ? Icons.upload_file_rounded : Icons.security_rounded,
                        isLoading: _isAnalyzing,
                        gradient: _pickedFile == null
                            ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan])
                            : AppColors.primaryGradient,
                        onPressed: _pickedFile == null ? _selectApk : _analyzeApk,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Sample Test APKs for quick demo
              Text(
                'Or Test with Demo APK Samples',
                style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildSampleCard(
                      'CraxsRAT_Trojan.apk',
                      'High Risk Sideload',
                      Icons.bug_report_rounded,
                      AppColors.danger,
                      () => _loadSampleApk('CraxsRAT_Trojan.apk', 'high'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildSampleCard(
                      'FastClean_Utility.apk',
                      'Moderate Risk',
                      Icons.warning_amber_rounded,
                      AppColors.warning,
                      () => _loadSampleApk('FastClean_Utility.apk', 'medium'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Inspection Architecture Matrix
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Deep APK Security Checks',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...[
                      ('Cryptographic SHA-256 Checksum', 'Validates package integrity and checks known malware databases.', Icons.fingerprint_rounded),
                      ('Permission Abuse & Exploit Vectors', 'Identifies SMS grabbers, accessibility exploits, and overlay injection.', Icons.admin_panel_settings_rounded),
                      ('Hidden Shell & Dropper Detection', 'Detects dynamic class loaders and root command invocation.', Icons.terminal_rounded),
                      ('ShadowWall Neural Security Audit', 'Generates plain-English threat rationale and actionable safety checklist.', Icons.psychology_rounded),
                    ].map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCyan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(item.$3, size: 16, color: AppColors.primaryCyan),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.$1,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: AppColors.darkOnSurface,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.$2,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.darkOnSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 18),
                const Spacer(),
                Text(
                  'Tap to load',
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkOnSurface,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
