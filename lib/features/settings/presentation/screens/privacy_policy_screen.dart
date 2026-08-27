/// Privacy Policy Screen — Compliant with Google Play Store Data Safety Guidelines.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Privacy Policy',
        subtitle: 'Data Safety & Transparency Standard',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.neonGreen.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.privacy_tip_rounded, color: AppColors.neonGreen, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy-First Architecture', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                        const SizedBox(height: 4),
                        Text('Last Updated: August 2026 | Compliant with Google Play Data Safety',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: '1. Our Privacy Commitment',
              content:
                  'ShadowWall AI is engineered with a strict Privacy-by-Design philosophy. We believe your cybersecurity tool should never compromise your personal privacy. We do not sell, rent, or commercialize your personal data, files, or threat logs to any third-party advertising networks.',
            ),

            _buildSection(
              title: '2. Data We Collect & How It Is Used',
              content:
                  '• Account Credentials: When you sign up, your email and user identifier are securely managed via Google Firebase Authentication.\n'
                  '• Secret Vault Files: When you import images, documents, PDFs, videos, or audio into the Secret Encrypted Vault, they are encrypted on-device using AES-256 and stored exclusively inside your local sandboxed app directory. ShadowWall AI cannot read, view, or transmit your private vault files.\n'
                  '• Threat Scans & AI Analysis: When you scan URLs, APK packages, or screenshots, the technical strings or metadata are checked against Google Gemini AI, Google Safe Browsing, and VirusTotal to detect phishing, malware, and fraudulent campaigns.\n'
                  '• Device Hardware Posture: Device security statuses (Screen Lock, Developer Options, USB Debugging) are analyzed on-device to compute your device security score.',
            ),

            _buildSection(
              title: '3. Device Permissions & Transparency',
              content:
                  'ShadowWall AI requests only permissions essential to providing security features:\n\n'
                  '• Biometrics (`USE_BIOMETRIC`): Used solely to authenticate your identity when unlocking the Secret Encrypted Vault.\n'
                  '• Media & Storage (`READ_MEDIA_*`): Used only when you choose to import a file or screenshot for encryption or scam analysis.\n'
                  '• Installed App Visibility (`QUERY_ALL_PACKAGES`): Used strictly for the Permission Doctor and APK threat scanner to detect malicious apps and dangerous permission combinations.\n'
                  '• Notifications (`POST_NOTIFICATIONS`): Used to alert you of urgent security threats and background defense alerts.',
            ),

            _buildSection(
              title: '4. Third-Party Service Providers',
              content:
                  'To deliver threat intelligence, ShadowWall AI integrates industry-standard APIs:\n'
                  '• Google Firebase (Authentication & Cloud Firestore)\n'
                  '• Google AI Studio (Gemini AI Threat Reasoning)\n'
                  '• Google Safe Browsing API (Phishing & Malware Web Intelligence)\n'
                  '• VirusTotal API (Multi-Antivirus Scan Engine)\n\n'
                  'All API communications use TLS 1.3 cryptographic encryption in transit.',
            ),

            _buildSection(
              title: '5. Account & Data Deletion Rights',
              content:
                  'In compliance with Google Play Store user data policies and GDPR/CCPA, you possess complete ownership of your data:\n\n'
                  '• You can delete your account and all associated cloud/local records instantly from Settings > "Delete Account & All Data".\n'
                  '• Deleting the application immediately purges all encrypted local vault files and cached scan logs.',
            ),

            _buildSection(
              title: '6. Security & Contact Information',
              content:
                  'If you have any questions, vulnerability disclosures, or data privacy requests, please contact our security team:\n\n'
                  '📧 Security Desk: harivarshan1026@gmail.com\n'
                  '🛡️ ShadowWall AI Defense Team',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCyan)),
            const SizedBox(height: 10),
            Text(
              content,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkOnSurface,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
