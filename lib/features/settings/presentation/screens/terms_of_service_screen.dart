/// Terms of Service Screen for ShadowWall AI.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Terms of Service',
        subtitle: 'User Agreement & Security Guidelines',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              borderColor: AppColors.primaryCyan.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('End User License Agreement (EULA)', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 4),
                  Text('Effective Date: August 2026', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By creating an account or using ShadowWall AI, you agree to these Terms of Service. If you disagree with any part of these terms, you must discontinue using the application.',
            ),

            _buildSection(
              title: '2. Defensive & Educational Purpose',
              content:
                  'ShadowWall AI is created strictly for personal cybersecurity defense, threat mitigation, and educational awareness. You agree not to use the application, its AI responses, or tools for malicious purposes, unauthorized network penetration testing, or distribution of malware.',
            ),

            _buildSection(
              title: '3. Encrypted Vault Responsibility',
              content:
                  'The Secret Encrypted Vault stores files locally using AES-256 cryptographic encryption. You are solely responsible for securing your device passcode and biometric authentication. ShadowWall AI does not retain recovery master keys for decrypted files.',
            ),

            _buildSection(
              title: '4. AI & Heuristic Intelligence Disclaimer',
              content:
                  'While our hybrid fusion engine (Google Gemini AI, Safe Browsing, VirusTotal, and Rule Engine) continuously strives for 100% threat detection accuracy, cyber threat vectors evolve dynamically. ShadowWall AI provides risk scores and recommendations as assistive guidance.',
            ),

            _buildSection(
              title: '5. Limitation of Liability',
              content:
                  'To the maximum extent permitted by applicable law, ShadowWall AI and its developers shall not be liable for indirect, incidental, or consequential damages resulting from third-party cyber attacks, hardware loss, or unauthorized device access.',
            ),

            _buildSection(
              title: '6. Modifications & Contact',
              content:
                  'We may update these terms periodically. Continued use represents acceptance of updated terms.\n\n'
                  'Support Contact: harivarshan1026@gmail.com',
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
