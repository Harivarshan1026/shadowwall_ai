/// Permission Doctor screen — analyzes installed app permissions.
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../ai_engine/rules/permission_rules.dart';
import '../../../../core/services/native_scanner_service.dart';

class PermissionDoctorScreen extends StatefulWidget {
  const PermissionDoctorScreen({super.key});

  @override
  State<PermissionDoctorScreen> createState() => _PermissionDoctorScreenState();
}

class _PermissionDoctorScreenState extends State<PermissionDoctorScreen> {
  bool _isScanning = false;
  List<Map<String, dynamic>> _appResults = [];
  bool _hasScanned = false;

  Future<void> _scanApps() async {
    setState(() => _isScanning = true);

    final installedApps = await NativeScannerService.getInstalledApps();

    final results = <Map<String, dynamic>>[];
    for (final app in installedApps) {
      final perms = (app['permissions'] as List<dynamic>).cast<String>();
      final analysis = PermissionRules.analyze(perms, app['name'] as String);
      results.add({
        ...app,
        'icon': Icons.android_rounded,
        'analysis': analysis,
      });
    }

    // Sort by risk score descending
    results.sort((a, b) {
      final scoreA = ((a['analysis'] as Map)['score'] as num).toDouble();
      final scoreB = ((b['analysis'] as Map)['score'] as num).toDouble();
      return scoreB.compareTo(scoreA);
    });

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _appResults = results;
      _hasScanned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Permission Doctor',
        subtitle: 'Analyze app permissions',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: _hasScanned ? _buildResults() : _buildInitial(),
      ),
    );
  }

  Widget _buildInitial() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: AppColors.warning, size: 56),
            ),
            const SizedBox(height: 24),
            Text('Permission Audit', style: AppTypography.headlineMedium.copyWith(color: AppColors.darkOnSurface)),
            const SizedBox(height: 8),
            Text(
              'Scan installed apps to identify dangerous permissions and find safer alternatives.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GradientButton(
              label: 'Scan Installed Apps',
              icon: Icons.search_rounded,
              isLoading: _isScanning,
              gradient: const LinearGradient(colors: [AppColors.warning, AppColors.danger]),
              onPressed: _isScanning ? null : _scanApps,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults() {
    // Overall stats
    final totalApps = _appResults.length;
    final riskyApps = _appResults.where((a) {
      final score = ((a['analysis'] as Map)['score'] as num).toDouble();
      return score > 40;
    }).length;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GradientGlassCard(
              accentColor: riskyApps > 0 ? AppColors.warning : AppColors.neonGreen,
              child: Row(
                children: [
                  AnimatedScoreRing(
                    score: ((totalApps - riskyApps) / totalApps * 100),
                    size: 90,
                    strokeWidth: 7,
                    label: '${totalApps - riskyApps}/$totalApps safe',
                    showPercentage: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$totalApps apps scanned', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                        const SizedBox(height: 4),
                        if (riskyApps > 0)
                          Text('$riskyApps apps have risky permissions', style: AppTypography.bodySmall.copyWith(color: AppColors.warning))
                        else
                          Text('All apps have safe permissions!', style: AppTypography.bodySmall.copyWith(color: AppColors.neonGreen)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final app = _appResults[index];
              final analysis = app['analysis'] as Map<String, dynamic>;
              final score = (analysis['score'] as num).toDouble();
              final reasons = (analysis['reasons'] as List).cast<String>();
              final dangerousCount = analysis['dangerousCount'] as int;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: score > 40
                      ? AppColors.getRiskColor(score).withValues(alpha: 0.2)
                      : null,
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: const EdgeInsets.only(top: 12),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.getRiskColor(score).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(app['icon'] as IconData, color: AppColors.getRiskColor(score), size: 24),
                    ),
                    title: Text(app['name'] as String, style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                    subtitle: Row(
                      children: [
                        ThreatBadge.fromScore(score, showIcon: false),
                        const SizedBox(width: 8),
                        Text('$dangerousCount dangerous', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      ],
                    ),
                    iconColor: AppColors.darkOnSurfaceVariant,
                    collapsedIconColor: AppColors.darkOnSurfaceVariant,
                    children: reasons.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(r, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
                    )).toList(),
                  ),
                ),
              );
            },
            childCount: _appResults.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
