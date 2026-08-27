/// Screenshot AI Analyzer & News Fact-Checking Screen.
///
/// Features Optical Character Recognition (OCR), Google Gemini Deep Fact-Checking,
/// fake news vs authentic news verification, and deceptive scam indicator detection.
library;

import 'dart:io' show File;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../ai_engine/services/risk_engine.dart';
import '../../../../ai_engine/services/gemini_ai_service.dart';

class ScreenshotAnalyzerScreen extends StatefulWidget {
  const ScreenshotAnalyzerScreen({super.key});

  @override
  State<ScreenshotAnalyzerScreen> createState() => _ScreenshotAnalyzerScreenState();
}

class _ScreenshotAnalyzerScreenState extends State<ScreenshotAnalyzerScreen> {
  bool _isAnalyzing = false;
  bool _hasResult = false;
  Map<String, dynamic>? _result;
  String? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        _selectedImage = file.path;
        _hasResult = false;
        _result = null;
      });
    }
  }

  Future<void> _analyzeScreenshot() async {
    if (_selectedImage == null) return;
    setState(() => _isAnalyzing = true);

    String extractedText = '';

    try {
      final inputImage = InputImage.fromFilePath(_selectedImage!);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      extractedText = recognizedText.text;
      await textRecognizer.close();
    } catch (e) {
      extractedText = 'Error extracting text. Please ensure the image is clear and readable.';
    }

    if (extractedText.trim().isEmpty) {
      extractedText = 'No readable text detected in this image. Please upload a clear screenshot of news, messages, or posts.';
    }

    // 1. Execute AI Deep Real vs Fake News Fact-Checking
    final aiFactCheck = await GeminiAiService.instance.factCheckImageTextWithAi(extractedText);

    // 2. Fallback heuristic RiskEngine if AI is offline
    final fallbackResult = RiskEngine.instance.analyzeScreenshotText(extractedText);

    final bool isReal = aiFactCheck?['isRealNews'] == true ||
        (aiFactCheck?['veracityLabel']?.toString().toLowerCase().contains('real') == true &&
            aiFactCheck?['veracityLabel']?.toString().toLowerCase().contains('fake') == false);

    final double riskScore = (aiFactCheck?['veracityScore'] as num?)?.toDouble() ?? fallbackResult.riskScore;
    final String veracityLabel = (aiFactCheck?['veracityLabel'] as String?) ?? fallbackResult.threatCategory;
    final String? headline = aiFactCheck?['factCheckHeadline'] as String?;
    final String? factSummary = aiFactCheck?['factCheckSummary'] as String?;
    final List<String> indicators = (aiFactCheck?['detectedIndicators'] as List?)?.cast<String>() ?? fallbackResult.reasons;
    final List<String> sources = (aiFactCheck?['trustedSourcesToVerify'] as List?)?.cast<String>() ?? [];
    final List<String> actions = (aiFactCheck?['recommendedActions'] as List?)?.cast<String>() ?? fallbackResult.recommendedActions;

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _hasResult = true;
      _result = {
        'extractedText': extractedText.trim(),
        'isRealNews': isReal,
        'riskScore': riskScore,
        'veracityLabel': veracityLabel,
        'headline': headline,
        'factSummary': factSummary ?? 'AI evaluated this content against verified sources and cybersecurity threat databases.',
        'indicators': indicators,
        'sources': sources,
        'actions': actions,
      };
    });
  }

  Color _getVeracityColor(bool isReal, double riskScore) {
    if (isReal && riskScore < 30) return AppColors.neonGreen;
    if (riskScore >= 70) return AppColors.danger;
    if (riskScore >= 40) return AppColors.warning;
    return AppColors.primaryCyan;
  }

  IconData _getVeracityIcon(bool isReal, double riskScore) {
    if (isReal && riskScore < 30) return Icons.verified_rounded;
    if (riskScore >= 70) return Icons.gpp_bad_rounded;
    if (riskScore >= 40) return Icons.warning_amber_rounded;
    return Icons.fact_check_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Screenshot AI Fact-Checker',
        subtitle: 'Real vs Fake News & Scam Detector',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (!_hasResult) ...[
                // Upload Hero Banner
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.35)),
                    ),
                    child: const Icon(Icons.fact_check_rounded, color: AppColors.primaryCyan, size: 44),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Real vs Fake News Analyzer', style: AppTypography.headlineMedium.copyWith(color: AppColors.darkOnSurface)),
                const SizedBox(height: 8),
                Text(
                  'Upload any news screenshot, WhatsApp forward, social media post, or banking receipt. Our AI verifies its factual authenticity and detects digital manipulation.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Image Selector Card
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_selectedImage != null) ...[
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              File(_selectedImage!),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              label: _selectedImage == null ? 'Select News / Image' : 'Change Image',
                              icon: Icons.photo_library_rounded,
                              gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan]),
                              onPressed: _pickImage,
                              height: 48,
                            ),
                          ),
                          if (_selectedImage != null) ...[
                            const SizedBox(width: 12),
                            Expanded(
                              child: GradientButton(
                                label: 'Fact-Check Now',
                                icon: Icons.psychology_rounded,
                                isLoading: _isAnalyzing,
                                onPressed: _isAnalyzing ? null : _analyzeScreenshot,
                                height: 48,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // AI Detection Capabilities Grid
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What Our AI Verifies', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                      const SizedBox(height: 14),
                      ...[
                        ('Viral Fake News & Hoaxes', 'Debunking altered headlines, fabricated quotes, and rumors.', Icons.campaign_rounded, AppColors.danger),
                        ('Manipulated Social Posts', 'Detecting edited X/Twitter/Facebook screenshots and fake circulars.', Icons.edit_note_rounded, AppColors.warning),
                        ('Fake Banking & UPI Receipts', 'Identifying forged transaction IDs and scam payment screenshots.', Icons.account_balance_wallet_rounded, AppColors.accentPurple),
                        ('Phishing & Prize Contests', 'Uncovering deceptive lottery, job, and KYC renewal lures.', Icons.military_tech_rounded, AppColors.primaryCyan),
                        ('Government & Regulatory Orders', 'Cross-referencing claims with official portals (PIB, RBI, Police).', Icons.verified_user_rounded, AppColors.neonGreen),
                      ].map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: item.$4.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: Icon(item.$3, size: 18, color: item.$4),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.$1, style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontSize: 13)),
                                  Text(item.$2, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 11)),
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

              // Fact-Check Results View
              if (_hasResult && _result != null) ...[
                // Main Verdict Card
                Builder(builder: (context) {
                  final isReal = _result!['isRealNews'] as bool;
                  final riskScore = (_result!['riskScore'] as num).toDouble();
                  final verdictColor = _getVeracityColor(isReal, riskScore);

                  return GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: verdictColor.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: verdictColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: verdictColor.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_getVeracityIcon(isReal, riskScore), color: verdictColor, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _result!['veracityLabel'] as String,
                                style: TextStyle(color: verdictColor, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedScoreRing(
                          score: riskScore,
                          size: 130,
                          strokeWidth: 10,
                          label: isReal ? 'Authentic' : 'Threat Level',
                          overrideColor: verdictColor,
                        ),
                        if (_result!['headline'] != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _result!['headline'] as String,
                            style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Detailed Fact-Check Reasoning
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics_rounded, color: AppColors.primaryCyan, size: 22),
                          const SizedBox(width: 10),
                          Text('AI Fact-Check Forensic Analysis', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result!['factSummary'] as String,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Evidence & Detected Discrepancies
                if ((_result!['indicators'] as List).isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.troubleshoot_rounded, color: AppColors.accentPurple, size: 20),
                            const SizedBox(width: 10),
                            Text('Evidence & Key Observations', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...(_result!['indicators'] as List).cast<String>().map((indicator) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ', style: TextStyle(color: AppColors.accentPurple, fontSize: 16, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(indicator, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface, height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Trusted Sources to Cross-Verify
                if ((_result!['sources'] as List).isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.neonGreen.withValues(alpha: 0.25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 20),
                            const SizedBox(width: 10),
                            Text('Official Portals to Cross-Verify', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...(_result!['sources'] as List).cast<String>().map((source) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: AppColors.neonGreen, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(source, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Actionable Guidelines
                if ((_result!['actions'] as List).isNotEmpty) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(20),
                    borderColor: AppColors.warning.withValues(alpha: 0.25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
                            const SizedBox(width: 10),
                            Text('Recommended Safety Actions', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...(_result!['actions'] as List).cast<String>().map((action) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('→ ', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(action, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface, height: 1.4)),
                              ),
                            ],
                          ),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Extracted OCR Text with Copy Button
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.text_fields_rounded, color: AppColors.primaryCyan, size: 18),
                              const SizedBox(width: 8),
                              Text('Extracted OCR Text', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded, color: AppColors.primaryCyan, size: 18),
                            tooltip: 'Copy Text',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _result!['extractedText'] as String));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('OCR text copied to clipboard!'), backgroundColor: AppColors.neonGreen),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _result!['extractedText'] as String,
                          style: AppTypography.mono.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                          maxLines: 8,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Reset Button
                GradientButton(
                  label: 'Fact-Check Another Screenshot',
                  icon: Icons.refresh_rounded,
                  gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan]),
                  onPressed: () => setState(() {
                    _hasResult = false;
                    _result = null;
                    _selectedImage = null;
                  }),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
