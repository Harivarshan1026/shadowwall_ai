/// Password Guardian screen — local password strength checker and generator.
library;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/utils/validators.dart';

class PasswordGuardianScreen extends StatefulWidget {
  const PasswordGuardianScreen({super.key});

  @override
  State<PasswordGuardianScreen> createState() => _PasswordGuardianScreenState();
}

class _PasswordGuardianScreenState extends State<PasswordGuardianScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  late TabController _tabController;
  int _strengthScore = 0;
  String _generatedPassword = '';

  // Generator settings
  int _genLength = 16;
  bool _genUppercase = true;
  bool _genLowercase = true;
  bool _genDigits = true;
  bool _genSpecial = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _passwordController.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updateStrength() {
    setState(() {
      _strengthScore = Validators.passwordStrengthScore(_passwordController.text);
    });
  }

  void _generatePassword() {
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    const special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (_genUppercase) chars += uppercase;
    if (_genLowercase) chars += lowercase;
    if (_genDigits) chars += digits;
    if (_genSpecial) chars += special;

    if (chars.isEmpty) chars = lowercase + digits;

    final random = Random.secure();
    setState(() {
      _generatedPassword = List.generate(
        _genLength,
        (_) => chars[random.nextInt(chars.length)],
      ).join();
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard!'),
        backgroundColor: AppColors.neonGreen,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Password Guardian',
        subtitle: 'Check & generate strong passwords',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AppColors.primaryCyan,
                unselectedLabelColor: AppColors.darkOnSurfaceVariant,
                labelStyle: AppTypography.labelMedium,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Check'),
                  Tab(text: 'Generate'),
                  Tab(text: '2FA & Passkeys'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCheckerTab(),
                  _buildGeneratorTab(),
                  _buildSecurityTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckerTab() {
    final strengthLabel = _strengthScore >= 80
        ? 'Strong'
        : _strengthScore >= 60
            ? 'Good'
            : _strengthScore >= 40
                ? 'Fair'
                : _strengthScore >= 20
                    ? 'Weak'
                    : 'Very Weak';
    final strengthColor = AppColors.getScoreColor(_strengthScore.toDouble());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Check Password Strength', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                const SizedBox(height: 4),
                Text('Everything stays on your device', style: AppTypography.labelSmall.copyWith(color: AppColors.neonGreen)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: false,
                  style: AppTypography.mono.copyWith(color: AppColors.darkOnSurface),
                  decoration: const InputDecoration(
                    hintText: 'Enter a password to check...',
                    prefixIcon: Icon(Icons.password_rounded, size: 20),
                  ),
                ),
                const SizedBox(height: 16),

                // Strength bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _strengthScore / 100,
                    backgroundColor: strengthColor.withValues(alpha: 0.15),
                    color: strengthColor,
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(strengthLabel, style: AppTypography.labelMedium.copyWith(color: strengthColor, fontWeight: FontWeight.w600)),
                    Text('$_strengthScore/100', style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Criteria checklist
          if (_passwordController.text.isNotEmpty)
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Password Criteria', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 12),
                  _criteriaRow('At least 8 characters', _passwordController.text.length >= 8),
                  _criteriaRow('Contains uppercase', RegExp(r'[A-Z]').hasMatch(_passwordController.text)),
                  _criteriaRow('Contains lowercase', RegExp(r'[a-z]').hasMatch(_passwordController.text)),
                  _criteriaRow('Contains numbers', RegExp(r'[0-9]').hasMatch(_passwordController.text)),
                  _criteriaRow('Contains special chars', RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(_passwordController.text)),
                  _criteriaRow('12+ characters', _passwordController.text.length >= 12),
                  _criteriaRow('No common patterns', !RegExp(r'(123|abc|password|qwerty)', caseSensitive: false).hasMatch(_passwordController.text)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _criteriaRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 18,
            color: met ? AppColors.neonGreen : AppColors.danger,
          ),
          const SizedBox(width: 10),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
        ],
      ),
    );
  }

  Widget _buildGeneratorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Generate Strong Password', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                const SizedBox(height: 16),

                // Length slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Length', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    Text('$_genLength', style: AppTypography.titleMedium.copyWith(color: AppColors.primaryCyan)),
                  ],
                ),
                Slider(
                  value: _genLength.toDouble(),
                  min: 8, max: 32,
                  divisions: 24,
                  activeColor: AppColors.primaryCyan,
                  onChanged: (v) => setState(() => _genLength = v.round()),
                ),

                // Character toggles
                _toggleRow('Uppercase (A-Z)', _genUppercase, (v) => setState(() => _genUppercase = v)),
                _toggleRow('Lowercase (a-z)', _genLowercase, (v) => setState(() => _genLowercase = v)),
                _toggleRow('Digits (0-9)', _genDigits, (v) => setState(() => _genDigits = v)),
                _toggleRow('Special (!@#\$)', _genSpecial, (v) => setState(() => _genSpecial = v)),
                const SizedBox(height: 16),

                GradientButton(
                  label: 'Generate Password',
                  icon: Icons.casino_rounded,
                  onPressed: _generatePassword,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_generatedPassword.isNotEmpty)
            GlassCard(
              glowColor: AppColors.neonGreen,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(_generatedPassword, style: AppTypography.mono.copyWith(color: AppColors.neonGreen, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Strength: ${Validators.passwordStrengthScore(_generatedPassword)}/100',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                      ),
                      TextButton.icon(
                        onPressed: () => _copyToClipboard(_generatedPassword),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryCyan),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Passkeys
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.accentPurple.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.key_rounded, color: AppColors.accentPurple, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Passkeys (Recommended)', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(
                  'Passkeys are the future of authentication. They use biometrics or device PINs instead of passwords, making them phishing-resistant and much more secure.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Text('✅ No passwords to remember\n✅ Phishing-resistant\n✅ Supported by Google, Apple, Microsoft',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.neonGreen)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2FA
          GlassCard(
            padding: const EdgeInsets.all(20),
            borderColor: AppColors.neonGreen.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Two-Factor Authentication', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                  ),
                ]),
                const SizedBox(height: 12),
                Text(
                  'Enable 2FA on all important accounts. Even if your password is stolen, attackers cannot access your account without the second factor.',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                ),
                const SizedBox(height: 12),
                Text('Recommended 2FA Apps:', style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface)),
                const SizedBox(height: 8),
                ...['Google Authenticator', 'Microsoft Authenticator', 'Authy', 'Aegis (Open Source)'].map((app) =>
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(children: [
                      const Icon(Icons.apps_rounded, size: 16, color: AppColors.primaryCyan),
                      const SizedBox(width: 8),
                      Text(app, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
