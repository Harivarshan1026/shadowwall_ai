/// Report Detail Screen — Complete in-depth breakdown of crowdsourced user scam incident.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/cyber_markdown_view.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/scam_community_provider.dart';

class ReportDetailScreen extends ConsumerWidget {
  final String reportId;
  const ReportDetailScreen({super.key, required this.reportId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scamCommunityProvider);
    final report = state.reports.firstWhere(
      (r) => r.id == reportId,
      orElse: () => ScamReportEntity(
        id: reportId,
        title: 'Community Incident Report',
        description: 'Details for this community submission are loading or pending verification.',
        type: 'Threat Advisory',
        user: 'Community Member',
        time: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Community Threat Report',
        subtitle: 'Authentic incident submitted by verified defender',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Tags
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            report.type.toUpperCase(),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                'User Verified',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.neonGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      report.title,
                      style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
                    ),
                    const SizedBox(height: 12),

                    // Submitter metadata
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primaryCyan.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.person_pin_rounded, color: AppColors.primaryCyan, size: 20),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          report.user,
                          style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '• ${report.time.timeAgo}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Full description
                    Text(
                      'Victim Encounter & Incident Narrative',
                      style: AppTypography.titleSmall.copyWith(color: AppColors.primaryCyanLight, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        report.description,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface, height: 1.5),
                      ),
                    ),

                    // Indicators of Compromise (IoCs)
                    if ((report.maliciousUrl != null && report.maliciousUrl!.isNotEmpty) ||
                        (report.scammerContact != null && report.scammerContact!.isNotEmpty)) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Reported Indicators of Compromise (IoC)',
                        style: AppTypography.titleSmall.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            if (report.maliciousUrl != null && report.maliciousUrl!.isNotEmpty)
                              _buildIocRow('Malicious Link / Domain', report.maliciousUrl!, Icons.link_off_rounded, AppColors.danger),
                            if (report.scammerContact != null && report.scammerContact!.isNotEmpty) ...[
                              if (report.maliciousUrl != null && report.maliciousUrl!.isNotEmpty) const Divider(color: Colors.white10),
                              _buildIocRow('Perpetrator Contact / ID', report.scammerContact!, Icons.phone_disabled_rounded, AppColors.warning),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // Gemini AI Threat Verification
                    if (report.aiAnalysis != null && report.aiAnalysis!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.psychology_rounded, color: AppColors.accentPurpleLight, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'AI Threat Intelligence Verification',
                            style: AppTypography.titleSmall.copyWith(color: AppColors.accentPurpleLight, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.accentPurple.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.25)),
                        ),
                        child: CyberMarkdownView(
                          text: report.aiAnalysis!,
                          accentColor: AppColors.accentPurpleLight,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Divider(color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 8),

                    // Actions (Upvote, Share)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: () {
                            ref.read(scamCommunityProvider.notifier).upvoteReport(report.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('▲ Upvoted! Thank you for validating community reports.'),
                                backgroundColor: AppColors.primaryCyan,
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward_rounded, color: AppColors.primaryCyan, size: 20),
                                const SizedBox(width: 6),
                                Text('${report.upvotes} Upvotes', style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Share.share('⚠️ Cyber Scam Alert from ShadowWall AI:\n${report.title}\n\n${report.description}');
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.share_rounded, color: AppColors.darkOnSurfaceVariant, size: 20),
                                SizedBox(width: 6),
                                Text('Share Alert', style: TextStyle(color: AppColors.darkOnSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildIocRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                SelectableText(value, style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
