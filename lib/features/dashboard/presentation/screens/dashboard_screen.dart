/// Dashboard screen — main hub of ShadowWall AI.
///
/// Displays Cyber Health Score, risk trends, device status,
/// recent scans, quick actions, and security tips.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/cyber_health_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_scans_list.dart';
import '../widgets/security_tips_carousel.dart';
import '../widgets/device_status_card.dart';
import '../widgets/risk_trend_chart.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/services/pdf_audit_exporter.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── App Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      const ShieldLogo(size: 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ShadowWall AI',
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                            Text(
                              'Your Cyber Safety Companion',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.darkOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.darkOnSurface,
                        onPressed: () => _showSecurityAlertsModal(context, dashboardState),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined),
                        color: AppColors.darkOnSurface,
                        onPressed: () => context.push(RoutePaths.settings),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Cyber Health Score ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CyberHealthCard(
                    score: dashboardState.cyberHealthScore,
                    trend: dashboardState.scoreTrend,
                  ),
                ),
              ),

              // ── Quick Actions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    'Quick Actions',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: QuickActionsGrid(),
                ),
              ),

              // ── Device Status ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Text(
                    'Device Security',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: DeviceStatusCard(
                    status: dashboardState.deviceStatus,
                  ),
                ),
              ),

              // ── Export PDF Audit Report Button ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: GradientButton(
                    label: 'Export PDF Security Audit Report',
                    icon: Icons.picture_as_pdf_rounded,
                    gradient: const LinearGradient(colors: [AppColors.primaryCyan, AppColors.accentPurple]),
                    onPressed: () {
                      PdfAuditExporter.generateAndExportReport(
                        healthScore: dashboardState.cyberHealthScore,
                        deviceStatus: dashboardState.deviceStatus,
                        recentScans: dashboardState.recentScans,
                        aiReview: 'ShadowWall Deep Native Scan & Neural Threat Audit Complete. Device hardware parameters and recent threat vectors have been cryptographically verified.',
                      );
                    },
                  ),
                ),
              ),

              // ── Recent Scans ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Recent Scans',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: RecentScansList(
                    scans: dashboardState.recentScans,
                  ),
                ),
              ),

              // ── Security Tips ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Text(
                    'Security Tips',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 32),
                  child: SecurityTipsCarousel(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSecurityAlertsModal(BuildContext context, DashboardState state) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final recentScans = state.recentScans;
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_active_rounded, color: AppColors.primaryCyan),
                      const SizedBox(width: 10),
                      Text(
                        'Security Alerts Center',
                        style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.darkOnSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Live threat notifications & security posture logs:',
                style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (recentScans.isEmpty) ...[
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_moon_rounded, color: AppColors.neonGreen, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Device Protection Active', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                            Text('No critical threat alerts detected. Real-time background guard is active.', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...recentScans.map((scan) {
                  final score = (scan['riskScore'] as num?)?.toDouble() ?? 0;
                  final category = scan['category'] ?? 'Scan';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            score > 40 ? Icons.warning_amber_rounded : Icons.check_circle_rounded,
                            color: AppColors.getRiskColor(score),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$category Analysis Log', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface)),
                                Text('Risk Score: ${score.toInt()}/100', style: AppTypography.bodySmall.copyWith(color: AppColors.getRiskColor(score))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
