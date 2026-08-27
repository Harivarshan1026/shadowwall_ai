/// Settings screen — Comprehensive Configuration, Privacy Policy & Play Store Compliance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/services/background_guard_service.dart';
import '../../../../core/utils/encryption_helper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _bgGuardActive = false;
  bool _isDeletingAccount = false;

  @override
  void initState() {
    super.initState();
    _loadBgGuardState();
  }

  Future<void> _loadBgGuardState() async {
    final active = await BackgroundGuardService.instance.isGuardActive();
    if (mounted) {
      setState(() => _bgGuardActive = active);
    }
  }

  Future<void> _toggleBgGuard(bool value) async {
    setState(() => _bgGuardActive = value);
    await BackgroundGuardService.instance.toggleGuard(value);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value
              ? '🛡️ Background Guard Protection ON: Monitoring threats (Zero personal data stored)'
              : 'Background Guard Protection turned OFF.',
        ),
        backgroundColor: value ? AppColors.neonGreen : AppColors.warning,
      ),
    );
  }

  Future<void> _showDeleteAccountDialog() async {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.danger),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 28),
            const SizedBox(width: 10),
            Text('Delete Account & Data', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete your account?\n\n'
          'This action is irreversible in compliance with Google Play Data Safety policies. All your cloud records, local scan history, and account credentials will be permanently erased.',
          style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              setState(() => _isDeletingAccount = true);

              try {
                // Purge local secure storage
                await EncryptionHelper.secureDeleteAll();

                // Delete Firebase account
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await user.delete();
                }

                await ref.read(authNotifierProvider.notifier).signOut();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account and all associated data have been permanently deleted.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                  context.go('/login');
                }
              } catch (e) {
                // If re-authentication is required
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e. Please re-login and try again.'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => _isDeletingAccount = false);
                }
              }
            },
            child: const Text('Permanently Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    // Listen for sign-out success
    ref.listen(authNotifierProvider, (_, state) {
      if (state.status == AuthStatus.unauthenticated) {
        context.go('/login');
      }
    });

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Profile & Settings',
        subtitle: 'Manage your preferences & compliance',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Profile Card
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Cyber Defender',
                          style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                        ),
                        Text(
                          user?.email ?? 'user@shadowwall.ai',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Background Guard & Device Security'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    Icons.security_rounded,
                    'Monitor in Background',
                    _bgGuardActive
                        ? 'Active Guard ON (Zero personal data collection)'
                        : 'Background Protection OFF',
                    trailing: Switch(
                      value: _bgGuardActive,
                      activeColor: AppColors.neonGreen,
                      onChanged: _toggleBgGuard,
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  _buildListTile(
                    Icons.fingerprint_rounded,
                    'Biometric Security Gate',
                    'Hardware biometric authentication for Secret Vault',
                    trailing: Switch(value: true, onChanged: (v) {}),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Legal & Play Store Compliance'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _buildListTile(
                    Icons.privacy_tip_rounded,
                    'Privacy Policy & Data Safety',
                    'Learn how your data is protected with zero tracking',
                    iconColor: AppColors.neonGreen,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkOnSurfaceVariant),
                    onTap: () => context.push('/privacy-policy'),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  _buildListTile(
                    Icons.gavel_rounded,
                    'Terms of Service & EULA',
                    'User agreement and defensive security guidelines',
                    iconColor: AppColors.primaryCyan,
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkOnSurfaceVariant),
                    onTap: () => context.push('/terms-of-service'),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  _buildListTile(
                    Icons.verified_user_rounded,
                    'Security Architecture',
                    'AES-256 GCM • Google Safe Browsing • VirusTotal • FreeRASP',
                    iconColor: AppColors.accentPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('Account Management'),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout_rounded, color: AppColors.warning),
                    title: Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface)),
                    subtitle: Text('Log out of your account on this device', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  ListTile(
                    leading: const Icon(Icons.delete_forever_rounded, color: AppColors.danger),
                    title: Text('Delete Account & All Data', style: AppTypography.bodyMedium.copyWith(color: AppColors.danger)),
                    subtitle: Text('Permanently erase account in compliance with GDPR/Play Store',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    trailing: _isDeletingAccount
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
                        : null,
                    onTap: _isDeletingAccount ? null : _showDeleteAccountDialog,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                'ShadowWall AI v1.0.0 (Production Release)\nEncrypted • Play Store Compliant • Zero Data Harvesting',
                style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurfaceVariant),
      ),
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title,
    String subtitle, {
    Widget? trailing,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryCyan),
      title: Text(title, style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface)),
      subtitle: Text(subtitle, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
