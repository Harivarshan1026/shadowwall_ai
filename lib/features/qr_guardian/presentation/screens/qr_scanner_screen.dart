/// QR Scanner screen — 60fps Live Camera Scanner & Smart Safety Redirection Engine.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart' as mlkit;
import 'package:url_launcher/url_launcher.dart';
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

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final _urlController = TextEditingController();
  late final MobileScannerController _scannerController;
  late final AnimationController _scanLineAnimController;
  late final Animation<double> _scanLineAnimation;

  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isManualInputExpanded = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );

    _scanLineAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: _scanLineAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    _scannerController.dispose();
    _scanLineAnimController.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final code = barcode.rawValue ?? barcode.displayValue;
      if (code != null && code.trim().isNotEmpty) {
        _isProcessing = true;
        HapticFeedback.mediumImpact();
        _analyzeQrAndRoute(code.trim());
        break;
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => _isProcessing = true);
      String extracted = '';

      final inputImage = mlkit.InputImage.fromFilePath(image.path);
      final barcodeScanner = mlkit.BarcodeScanner(formats: [mlkit.BarcodeFormat.all]);
      final List<mlkit.Barcode> barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();

      if (barcodes.isNotEmpty) {
        extracted = barcodes.first.rawValue ?? barcodes.first.displayValue ?? '';
      }

      if (extracted.trim().isEmpty) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No QR code detected in the selected image.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      _analyzeQrAndRoute(extracted.trim());
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to read image: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _analyzeManualUrl() {
    final text = _urlController.text.trim();
    if (text.isNotEmpty && !_isProcessing) {
      _isProcessing = true;
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
        lowerContent.contains('pa=') ||
        lowerContent.contains('pn=');

    final isWebLink = lowerContent.startsWith('http://') ||
        lowerContent.startsWith('https://');

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
        reasons.insert(0, '💰 Verified Payment QR format');
      } else {
        reasons.insert(0, '⚠️ Suspicious Payment QR: Verify payee details before transferring funds!');
      }
      qrResult['reasons'] = reasons;
    }

    // Auto-launch genuine payment QR or safe web links
    if ((isPaymentQr || isWebLink) && isSafe) {
      final uri = Uri.tryParse(content);
      if (uri != null) {
        try {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (!launched && isPaymentQr) {
            await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);
          }
        } catch (_) {}
      }
    }

    if (mounted) {
      await context.push(RoutePaths.qrResult, extra: qrResult);
      // Reset scanning state when navigating back
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Live QR Guardian',
        subtitle: 'Instant AI Safety Verification',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Live Camera Viewfinder Box ──
              Container(
                height: 330,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primaryCyan.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryCyan.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // 1. 60fps Live Video Stream
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onQrDetected,
                        errorBuilder: (context, error) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 48,
                                    color: AppColors.warning,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Camera Access Needed',
                                    style: AppTypography.titleMedium.copyWith(
                                      color: AppColors.darkOnSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Please allow camera permission in device settings or pick a QR code from gallery below.',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.darkOnSurfaceVariant,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // 2. Cyber Scanner Reticle & Viewfinder Corners
                      _buildCyberReticle(),

                      // 3. Animated Laser Scan Line
                      AnimatedBuilder(
                        animation: _scanLineAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: 330 * _scanLineAnimation.value,
                            left: 30,
                            right: 30,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.neonGreen,
                                    AppColors.primaryCyan,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.neonGreen.withValues(alpha: 0.8),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // 4. Processing overlay
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withValues(alpha: 0.65),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: AppColors.primaryCyan,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Verifying Safety & Signatures...',
                                  style: AppTypography.titleSmall.copyWith(
                                    color: AppColors.primaryCyan,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // 5. Camera Control Action Buttons (Torch & Camera Switch)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            _buildCircleButton(
                              icon: _isTorchOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: _isTorchOn
                                  ? AppColors.warning
                                  : AppColors.darkOnSurface,
                              onTap: () async {
                                await _scannerController.toggleTorch();
                                setState(() => _isTorchOn = !_isTorchOn);
                              },
                            ),
                            const SizedBox(width: 8),
                            _buildCircleButton(
                              icon: Icons.flip_camera_android_rounded,
                              color: AppColors.primaryCyan,
                              onTap: () async {
                                await _scannerController.switchCamera();
                              },
                            ),
                          ],
                        ),
                      ),

                      // 6. Live Status Chip
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primaryCyan.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.neonGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Live Scanning Active',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.darkOnSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ── Quick Action: Pick from Gallery ──
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.accentPurple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scan Image from Gallery',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.darkOnSurface,
                            ),
                          ),
                          Text(
                            'Upload screenshot or saved QR photo',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.darkOnSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      color: AppColors.primaryCyan,
                      onPressed: _isProcessing ? null : _pickFromGallery,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Manual Input Accordion ──
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => setState(
                        () => _isManualInputExpanded = !_isManualInputExpanded,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.keyboard_alt_outlined,
                            color: AppColors.primaryCyan,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enter QR or UPI text manually',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                          ),
                          Icon(
                            _isManualInputExpanded
                                ? Icons.expand_less_rounded
                                : Icons.expand_more_rounded,
                            color: AppColors.darkOnSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                    if (_isManualInputExpanded) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _urlController,
                        style: AppTypography.mono.copyWith(
                          color: AppColors.darkOnSurface,
                          fontSize: 13,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. upi://pay?pa=... or https://...',
                          prefixIcon: Icon(Icons.link_rounded, size: 20),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GradientButton(
                        label: 'Analyze Payload',
                        icon: Icons.shield_rounded,
                        isLoading: _isProcessing,
                        onPressed: _analyzeManualUrl,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCyberReticle() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.primaryCyan.withValues(alpha: 0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Top-left
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.primaryCyan, width: 3),
                      left: BorderSide(color: AppColors.primaryCyan, width: 3),
                    ),
                  ),
                ),
              ),
              // Top-right
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: AppColors.primaryCyan, width: 3),
                      right: BorderSide(color: AppColors.primaryCyan, width: 3),
                    ),
                  ),
                ),
              ),
              // Bottom-left
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.primaryCyan, width: 3),
                      left: BorderSide(color: AppColors.primaryCyan, width: 3),
                    ),
                  ),
                ),
              ),
              // Bottom-right
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.primaryCyan, width: 3),
                      right: BorderSide(color: AppColors.primaryCyan, width: 3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}
