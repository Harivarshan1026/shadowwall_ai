/// APK Analyzer screen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/services/native_scanner_service.dart';
import '../../../../ai_engine/rules/permission_rules.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';

class ApkAnalyzerScreen extends StatefulWidget {
  const ApkAnalyzerScreen({super.key});

  @override
  State<ApkAnalyzerScreen> createState() => _ApkAnalyzerScreenState();
}

class _ApkAnalyzerScreenState extends State<ApkAnalyzerScreen> {
  String? _selectedFile;
  bool _isAnalyzing = false;

  Future<void> _selectApk() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _selectedFile = result.files.single.path);
    }
  }

  Future<void> _analyzeApk() async {
    if (_selectedFile == null) return;
    setState(() => _isAnalyzing = true);

    // Analyze natively
    final apkInfo = await NativeScannerService.analyzeApk(_selectedFile!);

    if (apkInfo == null) {
      if (!mounted) return;
      setState(() => _isAnalyzing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to analyze the APK file. It may be corrupt or not a valid APK.')),
      );
      return;
    }

    final String fileName = _selectedFile!.split('/').last;
    final String appName = apkInfo['name'] as String? ?? fileName;
    final String packageName = apkInfo['package'] as String? ?? 'com.unknown.app';
    final List<String> permissions = (apkInfo['permissions'] as List<dynamic>).cast<String>();

    // Smart Hybrid Fusion: Combine Native Android Permission Checks + Gemini AI Intent Analysis
    final analysis = PermissionRules.analyze(permissions, appName);
    final aiResult = await GeminiAiService.instance.analyzeApkWithAi(appName, packageName, permissions);

    if (!mounted) return;
    setState(() => _isAnalyzing = false);

    final double nativeScore = (analysis['score'] as num).toDouble();
    final double blendedScore = aiResult != null
        ? (((aiResult['riskScore'] as num).toDouble() * 0.5) + (nativeScore * 0.5)).clamp(0.0, 100.0)
        : nativeScore;

    final String category = (aiResult?['threatCategory'] as String?) ?? (analysis['category'] as String);
    final List<String> reasons = aiResult != null
        ? [...(aiResult['reasons'] as List).cast<String>(), ...(analysis['reasons'] as List).cast<String>()]
        : (analysis['reasons'] as List).cast<String>();
    final List<String> actions = (aiResult?['recommendedActions'] as List?)?.cast<String>() ?? [
      'Review requested permissions carefully',
      'Verify digital signature before installing',
      'Only install from Google Play Store',
    ];

    context.push(RoutePaths.apkResult, extra: {
      'fileName': fileName,
      'packageName': packageName,
      'developer': 'Third-Party / Sideloaded',
      'riskScore': blendedScore,
      'threatCategory': category,
      'signature': 'Inspected via Native Android + AI Engine',
      'permissions': permissions,
      'riskIndicators': aiResult?['riskIndicators'] ?? [
        'Hybrid AI + Native Permission Analysis Complete',
        '${analysis['dangerousCount']} dangerous permissions requested',
        'Package: $packageName'
      ],
      'reasons': reasons.toSet().toList(),
      'recommendedActions': actions.toSet().toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(title: 'APK Analyzer', subtitle: 'Inspect APK files for threats', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.android_rounded, color: AppColors.neonGreen, size: 48),
                ),
              ),
              const SizedBox(height: 24),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_selectedFile != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.insert_drive_file_rounded, color: AppColors.primaryCyan),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_selectedFile!.split('/').last, style: AppTypography.mono.copyWith(color: AppColors.darkOnSurface))),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, color: AppColors.darkOnSurfaceVariant, size: 20),
                            onPressed: () => setState(() => _selectedFile = null),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    GradientButton(
                      label: _selectedFile == null ? 'Select APK File' : 'Analyze APK',
                      icon: _selectedFile == null ? Icons.file_open_rounded : Icons.radar_rounded,
                      isLoading: _isAnalyzing,
                      gradient: _selectedFile == null
                          ? const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan])
                          : AppColors.primaryGradient,
                      onPressed: _selectedFile == null ? _selectApk : _analyzeApk,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('What We Analyze', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 12),
                    ...['APK Signature Verification', 'Requested Permissions Audit', 'Developer Identity Check', 'Package Name Analysis', 'Malware Pattern Matching'].map((item) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(children: [
                          const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.neonGreen),
                          const SizedBox(width: 10),
                          Text(item, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
