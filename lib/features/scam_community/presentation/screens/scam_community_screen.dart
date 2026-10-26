/// Threat Intelligence & Crowdsourced Community Watch Screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_markdown_view.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/scam_community_provider.dart';
import '../../data/services/cyber_news_service.dart';

class ScamCommunityScreen extends ConsumerStatefulWidget {
  const ScamCommunityScreen({super.key});

  @override
  ConsumerState<ScamCommunityScreen> createState() => _ScamCommunityScreenState();
}

class _ScamCommunityScreenState extends ConsumerState<ScamCommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CyberAttackNews> _liveNews = [];
  bool _isLoadingNews = true;
  String _selectedNewsCategory = 'All';
  String _newsSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadLiveNews();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLiveNews() async {
    setState(() => _isLoadingNews = true);
    final news = await CyberNewsService.instance.fetchLiveThreatNews();
    if (!mounted) return;
    setState(() {
      _liveNews = news;
      _isLoadingNews = false;
    });
  }

  List<CyberAttackNews> get _filteredNews {
    var list = _liveNews;
    if (_selectedNewsCategory != 'All') {
      list = list.where((n) => n.threatType == _selectedNewsCategory).toList();
    }
    if (_newsSearchQuery.isNotEmpty) {
      final q = _newsSearchQuery.toLowerCase();
      list = list.where((n) =>
          n.title.toLowerCase().contains(q) ||
          n.summary.toLowerCase().contains(q) ||
          n.affectedSystems.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final communityState = ref.watch(scamCommunityProvider);
    final communityReports = communityState.filteredReports;

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Threat Intelligence',
        subtitle: 'Live attack news & crowdsourced defense',
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Tab Selector
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.black,
                unselectedLabelColor: AppColors.darkOnSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(icon: Icon(Icons.newspaper_rounded, size: 18), text: 'Live Attack News'),
                  Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Community Watch'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Live Cyber Attack News
                  _buildLiveNewsTab(),

                  // Tab 2: User Community Reports
                  _buildCommunityReportsTab(communityState, communityReports),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryCyan,
        icon: const Icon(Icons.add_rounded, color: Colors.black),
        label: const Text('Report Scam', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        onPressed: () => context.push(RoutePaths.createReport),
      ),
    );
  }

  Widget _buildLiveNewsTab() {
    return Column(
      children: [
        // Search & Refresh bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, color: AppColors.darkOnSurfaceVariant, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => setState(() => _newsSearchQuery = val),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface),
                          decoration: const InputDecoration(
                            hintText: 'Search breaking cyber attacks & CVEs...',
                            hintStyle: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 13),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.darkSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryCyan, size: 20),
                onPressed: _loadLiveNews,
              ),
            ],
          ),
        ),

        // Attack Category Filter Chips
        SizedBox(
          height: 36,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              _buildNewsFilterChip('All', AppColors.primaryCyan),
              _buildNewsFilterChip('Ransomware', AppColors.danger),
              _buildNewsFilterChip('Zero-Day', AppColors.accentPurple),
              _buildNewsFilterChip('Phishing', AppColors.warning),
              _buildNewsFilterChip('Trojan', AppColors.neonGreen),
              _buildNewsFilterChip('Data Breach', Colors.tealAccent),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Live News Feed List
        Expanded(
          child: _isLoadingNews
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryCyan),
                      SizedBox(height: 12),
                      Text('Fetching live online cyber attack feeds...', style: TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                )
              : _filteredNews.isEmpty
                  ? Center(
                      child: Text(
                        'No attack bulletins matching your search.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                      ),
                    )
                  : RefreshIndicator(
                      color: AppColors.primaryCyan,
                      onRefresh: _loadLiveNews,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        itemCount: _filteredNews.length,
                        itemBuilder: (context, index) {
                          final item = _filteredNews[index];
                          return _buildAttackNewsCard(item);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildNewsFilterChip(String category, Color accentColor) {
    final isSelected = _selectedNewsCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedNewsCategory = category),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.2) : AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected ? accentColor : AppColors.darkOnSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildAttackNewsCard(CyberAttackNews item) {
    Color sevColor = AppColors.neonGreen;
    if (item.severity == 'CRITICAL') {
      sevColor = AppColors.danger;
    } else if (item.severity == 'HIGH') {
      sevColor = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: sevColor.withValues(alpha: 0.25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: sevColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: sevColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    item.severity,
                    style: TextStyle(color: sevColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.threatType,
                    style: const TextStyle(color: AppColors.primaryCyan, fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  item.timeAgo,
                  style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              item.title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.darkOnSurface,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              item.summary,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.darkOnSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.devices_other_rounded, size: 14, color: AppColors.darkOnSurfaceVariant),
                      const SizedBox(width: 6),
                      Text('Target: ', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      Expanded(
                        child: Text(
                          item.affectedSystems,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_rounded, size: 14, color: AppColors.neonGreen),
                      const SizedBox(width: 6),
                      Text('Defense: ', style: AppTypography.labelSmall.copyWith(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          item.mitigation,
                          style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurface),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.rss_feed_rounded, size: 14, color: AppColors.darkOnSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'Source: ${item.source}',
                      style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: () => _showFullNewsModal(item),
                  child: const Text('Read Full Attack Details →', style: TextStyle(color: AppColors.primaryCyan, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFullNewsModal(CyberAttackNews item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.danger),
                      ),
                      child: Text(
                        '${item.severity} • ${item.threatType}',
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item.source, style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 12)),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.darkOnSurfaceVariant),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Content
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CyberMarkdownView(
                        text: item.fullContent,
                        accentColor: AppColors.primaryCyan,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // IoCs
                    if (item.indicatorsOfCompromise.isNotEmpty) ...[
                      Text('Indicators of Compromise (IoC)', style: AppTypography.titleSmall.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: item.indicatorsOfCompromise.map((ioc) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.danger),
                                const SizedBox(width: 8),
                                Expanded(child: SelectableText(ioc, style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 12))),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Remediation Action
                    Text('Defense & Hardening Protocol', style: AppTypography.titleSmall.copyWith(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        item.mitigation,
                        style: const TextStyle(color: AppColors.darkOnSurface, height: 1.4, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityReportsTab(ScamCommunityState communityState, List<ScamReportEntity> communityReports) {
    if (communityState.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryCyan));
    }

    if (communityReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.primaryCyan, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'No Community Scam Reports Yet',
                style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Community Watch displays authentic threats submitted by defenders like you. Be the first to report a suspicious phone call, SMS phishing link, or fake website.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Report a Scam Now',
                icon: Icons.add_moderator_rounded,
                gradient: AppColors.primaryGradient,
                onPressed: () => context.push(RoutePaths.createReport),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: communityReports.length,
      itemBuilder: (context, index) {
        final report = communityReports[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GlassCard(
            onTap: () => context.push(RoutePaths.reportDetail.replaceAll(':id', report.id)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        report.type,
                        style: const TextStyle(color: AppColors.danger, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      report.time.timeAgo,
                      style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  report.title,
                  style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  report.description,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 14, color: AppColors.primaryCyan),
                    const SizedBox(width: 4),
                    Text(report.user, style: const TextStyle(color: AppColors.darkOnSurface, fontSize: 11, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.primaryCyan),
                        const SizedBox(width: 4),
                        Text('${report.upvotes} Upvotes', style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                        const Text('Read Details →', style: TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
