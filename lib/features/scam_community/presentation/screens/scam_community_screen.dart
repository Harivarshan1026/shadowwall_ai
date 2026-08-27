import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/scam_community_provider.dart';

class ScamCommunityScreen extends ConsumerWidget {
  const ScamCommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scamCommunityProvider);
    final reports = state.filteredReports;

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Community Watch',
        subtitle: 'Crowdsourced scam intelligence',
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Search & Filter
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search_rounded, color: AppColors.darkOnSurfaceVariant, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              onChanged: (val) => ref.read(scamCommunityProvider.notifier).setSearchQuery(val),
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                              decoration: InputDecoration(
                                hintText: 'Search scams...',
                                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Categories
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildChip(ref, state.selectedCategory, 'Trending', AppColors.neonGreen),
                  _buildChip(ref, state.selectedCategory, 'Phishing', AppColors.danger),
                  _buildChip(ref, state.selectedCategory, 'Calls/SMS', AppColors.warning),
                  _buildChip(ref, state.selectedCategory, 'Social Media', AppColors.accentPurple),
                  _buildChip(ref, state.selectedCategory, 'Crypto', AppColors.primaryCyan),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Feed
            Expanded(
              child: reports.isEmpty 
                ? Center(
                    child: Text(
                      'No reports found.', 
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant)
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final r = reports[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () => context.push(RoutePaths.reportDetail.replaceAll(':id', r.id)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(r.type).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(r.type, style: AppTypography.labelSmall.copyWith(color: _getCategoryColor(r.type), fontSize: 10)),
                                  ),
                                  const Spacer(),
                                  if (r.isVerified)
                                    Row(
                                      children: [
                                        const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 14),
                                        const SizedBox(width: 4),
                                        Text('Verified', style: AppTypography.labelSmall.copyWith(color: AppColors.neonGreen, fontSize: 10)),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(r.title, style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.account_circle_rounded, color: AppColors.darkOnSurfaceVariant, size: 16),
                                  const SizedBox(width: 6),
                                  Text(r.user, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.schedule_rounded, color: AppColors.darkOnSurfaceVariant, size: 14),
                                  const SizedBox(width: 4),
                                  Text(r.time.timeAgo, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.white.withValues(alpha: 0.1)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => ref.read(scamCommunityProvider.notifier).upvoteReport(r.id),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.arrow_upward_rounded, color: AppColors.primaryCyan, size: 18),
                                        const SizedBox(width: 4),
                                        Text('${r.upvotes}', style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface)),
                                      ]
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.chat_bubble_outline_rounded, color: AppColors.darkOnSurfaceVariant, size: 16),
                                  const SizedBox(width: 6),
                                  Text('${r.comments}', style: AppTypography.labelMedium.copyWith(color: AppColors.darkOnSurface)),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () => context.push(RoutePaths.reportDetail.replaceAll(':id', r.id)),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text('Read More', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryCyan)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.createReport),
        backgroundColor: AppColors.primaryCyan,
        icon: const Icon(Icons.report_rounded, color: AppColors.darkSurface),
        label: Text('Report Scam', style: AppTypography.labelLarge.copyWith(color: AppColors.darkSurface, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildChip(WidgetRef ref, String currentCategory, String label, Color color) {
    final isSelected = currentCategory == label;
    return GestureDetector(
      onTap: () => ref.read(scamCommunityProvider.notifier).setCategory(label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? color : AppColors.darkOnSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String type) {
    switch(type) {
      case 'Phishing': return AppColors.danger;
      case 'Calls/SMS': return AppColors.warning;
      case 'Social Media': return AppColors.accentPurple;
      case 'Crypto': return AppColors.primaryCyan;
      default: return AppColors.neonGreen;
    }
  }
}
