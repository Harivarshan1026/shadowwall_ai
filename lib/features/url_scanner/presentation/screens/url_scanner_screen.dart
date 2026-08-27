/// URL Scanner screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/router/app_router.dart';
import '../../../../ai_engine/services/risk_engine.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';
import '../../../../core/services/safe_browsing_service.dart';
import '../../../../core/services/virus_total_service.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class UrlScannerScreen extends ConsumerStatefulWidget {
  const UrlScannerScreen({super.key});

  @override
  ConsumerState<UrlScannerScreen> createState() => _UrlScannerScreenState();
}

class _UrlScannerScreenState extends ConsumerState<UrlScannerScreen> {
  final _urlController = TextEditingController();
  bool _isScanning = false;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scanUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() => _isScanning = true);

    // 1. Query Google Safe Browsing ThreatMatches API
    final safeBrowsing = await SafeBrowsingService.instance.checkUrl(url);

    // 2. Query VirusTotal Multi-AV Intelligence
    final virusTotal = await VirusTotalService.instance.checkUrl(url);

    // 3. Query Google Gemini AI
    final aiResult = await GeminiAiService.instance.analyzeUrlWithAi(url);

    // 4. Run Technical Heuristic Rules
    final heuristicResult = RiskEngine.instance.analyzeUrl(url);

    if (!mounted) return;
    setState(() => _isScanning = false);

    // Fusion Score Calculation
    double blendedScore;
    if (safeBrowsing?.isThreat == true) {
      blendedScore = 95.0;
    } else if (virusTotal?.isThreat == true) {
      blendedScore = (virusTotal!.totalDetections * 15.0).clamp(60.0, 98.0);
    } else if (aiResult != null) {
      blendedScore = (((aiResult['riskScore'] as num).toDouble() * 0.6) + (heuristicResult.riskScore * 0.4)).clamp(0.0, 100.0);
    } else {
      blendedScore = heuristicResult.riskScore;
    }

    final String category = safeBrowsing?.isThreat == true
        ? safeBrowsing!.threatDescription
        : (virusTotal?.isThreat == true
            ? virusTotal!.threatCategory!
            : (aiResult != null ? (aiResult['threatCategory'] as String) : heuristicResult.threatCategory));

    final List<String> reasons = [
      if (safeBrowsing?.isThreat == true)
        'Google Safe Browsing Flag: Verified ${safeBrowsing!.threatDescription}',
      if (safeBrowsing != null && !safeBrowsing.isThreat)
        'Google Safe Browsing: No known active malware/phishing records found',
      if (virusTotal?.isThreat == true)
        'VirusTotal Security Flag: ${virusTotal!.malicious} vendors detected malware/phishing',
      if (virusTotal != null && !virusTotal.isThreat)
        'VirusTotal Clean: 0 vendors flagged malicious activity',
      if (aiResult != null) ...(aiResult['reasons'] as List).cast<String>(),
      ...heuristicResult.reasons,
    ];

    final List<String> actions = aiResult != null
        ? (aiResult['recommendedActions'] as List).cast<String>()
        : heuristicResult.recommendedActions;

    final resultMap = {
      'url': url,
      'riskScore': blendedScore,
      'threatCategory': category,
      'confidence': (safeBrowsing != null || virusTotal != null)
          ? 'Enterprise (Safe Browsing + VirusTotal + Gemini AI)'
          : (aiResult != null ? 'High (Gemini AI + Technical)' : 'Medium (Technical Engine)'),
      'reasons': reasons.toSet().toList(),
      'recommendedActions': actions.toSet().toList(),
    };

    // Save to dashboard
    ref.read(dashboardProvider.notifier).addScanResult({
      'type': 'url',
      'input': url,
      'riskScore': blendedScore,
      'category': category,
      'time': DateTime.now(),
    });

    context.push(RoutePaths.urlResult, extra: resultMap);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      _urlController.text = data.text!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'URL Threat Scanner',
        subtitle: 'Analyze any URL for threats',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header illustration ──
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryCyan.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.link_rounded,
                    color: AppColors.primaryCyan,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── URL Input ──
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter URL to Scan',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _urlController,
                      keyboardType: TextInputType.url,
                      style: AppTypography.mono.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'https://example.com',
                        prefixIcon: const Icon(Icons.language_rounded,
                            size: 20, color: AppColors.darkOnSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.content_paste_rounded,
                              size: 20, color: AppColors.primaryCyan),
                          onPressed: _pasteFromClipboard,
                          tooltip: 'Paste from clipboard',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GradientButton(
                      label: 'Scan URL',
                      icon: Icons.radar_rounded,
                      isLoading: _isScanning,
                      onPressed: _isScanning ? null : _scanUrl,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── What we check ──
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What We Analyze',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._buildCheckItems(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCheckItems() {
    final items = [
      ('SSL Certificate', Icons.lock_rounded, AppColors.neonGreen),
      ('Domain Reputation', Icons.domain_rounded, AppColors.primaryCyan),
      ('Typosquatting Detection', Icons.spellcheck_rounded, AppColors.warning),
      ('Suspicious Keywords', Icons.text_fields_rounded, AppColors.danger),
      ('Redirect Risk', Icons.alt_route_rounded, AppColors.accentPurple),
      ('URL Structure', Icons.architecture_rounded, AppColors.info),
    ];

    return items.map((item) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: item.$3.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.$2, size: 16, color: item.$3),
            ),
            const SizedBox(width: 12),
            Text(
              item.$1,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.darkOnSurface,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
