/// QR Scanner screen — Real Camera Scanner & Smart Safety Redirection/Warning Engine.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show File;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../ai_engine/services/risk_engine.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _urlController = TextEditingController();
  bool _isScanning = false;
  String? _selectedImagePath;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _scanWithCamera() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
      await _processImageAndAnalyze(image.path);
    }
  }

  Future<void> _pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImagePath = image.path);
      await _processImageAndAnalyze(image.path);
    }
  }

  Future<void> _processImageAndAnalyze(String imagePath) async {
    setState(() => _isScanning = true);
    String extractedQrData = '';

    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.all]);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isNotEmpty) {
        extractedQrData = barcodes.first.rawValue ?? barcodes.first.displayValue ?? '';
      }
    } catch (e) {
      extractedQrData = '';
    }

    if (!mounted) return;
    setState(() => _isScanning = false);

    if (extractedQrData.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No QR code detected in the captured image. Please try again.'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    _analyzeQrAndRoute(extractedQrData.trim());
  }

  void _analyzeManualUrl() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty) {
      _analyzeQrAndRoute(text);
    }
  }

  Future<void> _analyzeQrAndRoute(String content) async {
    final result = RiskEngine.instance.analyzeUrl(content);

    final lowerContent = content.toLowerCase();
    final isPaymentQr = lowerContent.startsWith('upi://') ||
        lowerContent.contains('paytm') ||
        lowerContent.contains('phonepe') ||
        lowerContent.contains('gpay') ||
        lowerContent.contains('paypal') ||
        lowerContent.contains('pa=') ||
        lowerContent.contains('pn=') ||
        lowerContent.contains('am=') ||
        lowerContent.contains('cu=');

    final isWebLink = lowerContent.startsWith('http://') ||
        lowerContent.startsWith('https://') ||
        lowerContent.contains('google.com') ||
        lowerContent.contains('www.');

    final double riskScore = (result.riskScore).toDouble();
    final bool isSafe = riskScore < 35 && (result.threatCategory == 'Safe' || result.threatCategory == 'Low');

    final qrResult = {
      'content': content,
      'isPaymentQr': isPaymentQr,
      ...result.toMap(),
    };

    if (isPaymentQr) {
      final reasons = List<String>.from(qrResult['reasons'] as List);
      if (isSafe) {
        reasons.insert(0, '💰 Genuine Payment QR verified.');
      } else {
        reasons.insert(0, '⚠️ Suspicious Payment QR: Verify recipient details before transferring funds!');
      }
      qrResult['reasons'] = reasons;
    }

    // Smart Redirection & Warning Logic:
    // If Genuine Payment QR or Safe Google/Web link -> Auto Redirect to Payment App / Browser
    // If Vulnerable / Suspicious -> Do NOT auto redirect, show Warning Screen with Risk Score & Issues!
    if ((isPaymentQr || isWebLink) && isSafe) {
      final uri = Uri.tryParse(content);
      if (uri != null) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPaymentQr
                    ? '🟢 Genuine Payment QR verified! Redirecting to payment app...'
                    : '🟢 Safe & Non-Vulnerable link verified! Opening in browser...',
              ),
              backgroundColor: AppColors.neonGreen,
            ),
          );
          return;
        }
      }
    }

    // If vulnerable, unsafe, or unable to launch -> Display detailed Risk & Warning Screen
    if (mounted) {
      context.push(RoutePaths.qrResult, extra: qrResult);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'QR Guardian',
        subtitle: 'Scan and verify QR codes',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Viewfinder / Scanner Section
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      height: 240,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.primaryCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: _selectedImagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(_selectedImagePath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner_rounded,
                                  size: 72,
                                  color: AppColors.primaryCyan,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _isScanning
                                      ? 'Scanning QR code with ML Kit...'
                                      : 'Point camera or select image to scan QR',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.darkOnSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GradientButton(
                            label: 'Scan Camera',
                            icon: Icons.camera_alt_rounded,
                            isLoading: _isScanning,
                            onPressed: _isScanning ? null : _scanWithCamera,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GradientButton(
                            label: 'Pick Gallery',
                            icon: Icons.photo_library_rounded,
                            gradient: const LinearGradient(
                              colors: [AppColors.accentPurple, AppColors.primaryCyan],
                            ),
                            isLoading: _isScanning,
                            onPressed: _isScanning ? null : _pickFromGallery,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Manual input fallback
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Or enter QR content manually',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.darkOnSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _urlController,
                      style: AppTypography.mono.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Paste URL or payment payload...',
                        prefixIcon: Icon(Icons.link_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GradientButton(
                      label: 'Analyze QR Payload',
                      icon: Icons.search_rounded,
                      onPressed: _analyzeManualUrl,
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
