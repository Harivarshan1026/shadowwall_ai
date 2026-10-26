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
  bool _hasUsageStats = true;

  @override
  void initState() {
    super.initState();
    _loadBgGuardState();
  }

  Future<void> _loadBgGuardState() async {
    final active = await BackgroundGuardService.instance.isGuardActive();
    final hasUsage = await BackgroundGuardService.instance.hasUsageStatsPermission();
    if (mounted) {
      setState(() {
        _bgGuardActive = active;
        _hasUsageStats = hasUsage;
      });
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
      appBar: CyberAppBar(
        title: 'Profile & Settings',
        subtitle: 'Manage your preferences & compliance',
        showBack: true,
        onBack: () => context.go('/'),
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

            _buildSectionHeader('24/7 Background Guard & Device Activity Sentinel'),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _bgGuardActive
                              ? AppColors.neonGreen.withValues(alpha: 0.15)
                              : AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _bgGuardActive ? Icons.shield_rounded : Icons.shield_outlined,
                          color: _bgGuardActive ? AppColors.neonGreen : AppColors.darkOnSurfaceVariant,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Real-Time Background Sentinel',
                              style: AppTypography.titleSmall.copyWith(
                                color: AppColors.darkOnSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _bgGuardActive
                                  ? 'Active 24/7 • Monitoring Apps, Downloads & URLs'
                                  : 'Protection Paused',
                              style: AppTypography.bodySmall.copyWith(
                                color: _bgGuardActive ? AppColors.neonGreen : AppColors.darkOnSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _bgGuardActive,
                        activeColor: AppColors.neonGreen,
                        onChanged: _toggleBgGuard,
                      ),
                    ],
                  ),
                  if (!_hasUsageStats) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.security_update_warning_rounded,
                            color: AppColors.warning,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Usage Access Permission Needed',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Grant Usage Access so Sentinel can detect and warn you when entering malicious apps.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.darkOnSurfaceVariant,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: AppColors.warning.withValues(alpha: 0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () async {
                              await BackgroundGuardService.instance.requestUsageStatsPermission();
                              await Future.delayed(const Duration(seconds: 1));
                              _loadBgGuardState();
                            },
                            child: const Text(
                              'Grant',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'Active Monitoring Capabilities:',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.darkOnSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...[
                    ('New App & Download Sentinel', 'Automatically scans new Play Store & sideloaded apps upon install.'),
                    ('Vulnerable App Activity Alert', 'Warns on background overlay injection & accessibility hijacking.'),
                    ('Clipboard Phishing Interceptor', 'Blocks deceptive financial & phishing URLs copied to clipboard.'),
                    ('Wi-Fi Security Sentinel', 'Audits network packets and DNS routes on wireless connections.'),
                  ].map((cap) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.neonGreen, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${cap.$1}: ',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.primaryCyan,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                    TextSpan(
                                      text: cap.$2,
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.darkOnSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 14),
                  Text(
                    'Test Background Surveillance Triggers:',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.darkOnSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        backgroundColor: AppColors.neonGreen.withValues(alpha: 0.12),
                        side: BorderSide(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                        label: Text(
                          '📥 Simulate Play Store Clean App',
                          style: TextStyle(color: AppColors.neonGreen, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await BackgroundGuardService.instance.simulateAppDownloadScan(
                            appName: 'Spotify Music',
                            packageName: 'com.spotify.music',
                            isMalicious: false,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Simulated Play Store download: Scanned clean (Score: 0/100)!'),
                                backgroundColor: AppColors.neonGreen,
                              ),
                            );
                            setState(() {});
                          }
                        },
                      ),
                      ActionChip(
                        backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                        side: BorderSide(color: AppColors.danger.withValues(alpha: 0.3)),
                        label: Text(
                          '🚨 Simulate Malicious Sideload Alert',
                          style: TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await BackgroundGuardService.instance.simulateAppDownloadScan(
                            appName: 'FreeRecharge_Offer.apk',
                            packageName: 'com.spynote.stealer.trojan',
                            isMalicious: true,
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('🚨 Simulated Trojan Sideload: High Risk Alert Triggered!'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            setState(() {});
                          }
                        },
                      ),
                      ActionChip(
                        backgroundColor: AppColors.warning.withValues(alpha: 0.12),
                        side: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
                        label: Text(
                          '⚠️ Simulate Vulnerable Activity',
                          style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await BackgroundGuardService.instance.simulateVulnerableAppActivity(
                            appName: 'BackgroundFlashlight',
                            vulnerabilityReason: 'Vulnerability Alert: App attempted background overlay injection and accessibility screen scraping without user consent.',
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Vulnerable Activity Warning Sent!'),
                                backgroundColor: AppColors.warning,
                              ),
                            );
                            setState(() {});
                          }
                        },
                      ),
                    ],
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
