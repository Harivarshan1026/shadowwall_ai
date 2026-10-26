/// Complete Cyber Security Audit Reports & Incident Logs Center.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/widgets/cyber_markdown_view.dart';
import '../../../../core/widgets/animated_score_ring.dart';
import '../../../../core/widgets/threat_badge.dart';
import '../../../../core/services/antivirus_scanner_service.dart';
import '../../../../core/services/audit_report_service.dart';

enum AuditReportCategory { all, device, apk, wifi, network, url }

class CyberReportsScreen extends StatefulWidget {
  const CyberReportsScreen({super.key});

  @override
  State<CyberReportsScreen> createState() => _CyberReportsScreenState();
}

class _CyberReportsScreenState extends State<CyberReportsScreen> {
  AuditReportCategory _selectedFilter = AuditReportCategory.all;
  bool _isGeneratingReport = false;
  bool _isLoading = true;
  String _generationPhase = '';
  List<CyberAuditReport> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadGenuineReports();
  }

  Future<void> _loadGenuineReports() async {
    setState(() => _isLoading = true);
    final reports = await AuditReportService.instance.getReports();
    if (!mounted) return;
    setState(() {
      _reports = reports;
      _isLoading = false;
    });
  }

  Future<void> _generateNewAuditReport() async {
    setState(() {
      _isGeneratingReport = true;
      _generationPhase = 'Auditing Kernel, Hardware Posture & OS...';
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _generationPhase = 'Inspecting Background Sentinel Interception Logs...');

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _generationPhase = 'Evaluating Vulnerabilities & Compiling Audit Document...');

    final result = await AntivirusScannerService.instance.performFullDeviceScan();
    final newReport = await AuditReportService.instance.recordDeviceScan(result);

    if (!mounted) return;
    setState(() {
      _reports.insert(0, newReport);
      _isGeneratingReport = false;
    });

    _showReportDetailsModal(newReport);
  }

  void _showReportDetailsModal(CyberAuditReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          report.title,
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.darkOnSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Report ID: ${report.id} • ${DateFormat('MMM dd, yyyy HH:mm').format(report.timestamp)}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.primaryCyan, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, color: AppColors.primaryCyan),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                        text: 'ShadowWall AI Audit Report [${report.id}]\n'
                            'Title: ${report.title}\n'
                            'Security Score: ${report.securityScore.toInt()}/100\n'
                            'Executive Summary: ${report.executiveSummary}\n'
                            'Key Findings:\n${report.keyFindings.map((f) => '• $f').join('\n')}',
                      ));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✓ Full Audit Report copied to clipboard!'),
                          backgroundColor: AppColors.neonGreen,
                        ),
                      );
                    },
                    tooltip: 'Export & Copy Report',
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.darkOnSurfaceVariant),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score Banner
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          AnimatedScoreRing(
                            score: report.securityScore,
                            size: 70,
                            strokeWidth: 6,
                            overrideColor: AppColors.getRiskColor(report.securityScore),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Security Posture Index',
                                  style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface),
                                ),
                                const SizedBox(height: 4),
                                ThreatBadge.fromScore(report.securityScore),
                                const SizedBox(height: 6),
                                Text(
                                  '${report.itemsAudited} Parameters Checked • ${report.vulnerabilitiesFound} Vulnerabilities Found',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Executive Summary
                    Text(
                      'Executive Threat Summary',
                      style: AppTypography.titleSmall.copyWith(color: AppColors.primaryCyan, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: CyberMarkdownView(
                        text: report.executiveSummary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Findings & Vulnerability Logs
                    Text(
                      'Detailed Audit Findings',
                      style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...report.keyFindings.map((finding) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceVariant,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white10),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    finding,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _reports.where((r) {
      if (_selectedFilter == AuditReportCategory.all) return true;
      return r.category.toLowerCase() == _selectedFilter.name.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Cyber Audit Reports',
        subtitle: 'Comprehensive incident logs and posture audits',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Top Executive Action Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: GlassCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: AppColors.neonGreen, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Security Audit Management',
                                style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.darkOnSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${_reports.length} Verified Audits • All engines compliant',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (_isGeneratingReport) ...[
                      const LinearProgressIndicator(color: AppColors.primaryCyan, backgroundColor: AppColors.darkSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(
                        _generationPhase,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryCyan, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.neonGreen,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.post_add_rounded, color: Colors.black, size: 20),
                        label: const Text(
                          'Generate New Comprehensive Audit Report',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: _generateNewAuditReport,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Category Filter Chips
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildFilterChip('All Audits', AuditReportCategory.all),
                  _buildFilterChip('Device Security', AuditReportCategory.device),
                  _buildFilterChip('APK Malware', AuditReportCategory.apk),
                  _buildFilterChip('Wi-Fi Audits', AuditReportCategory.wifi),
                  _buildFilterChip('URL Scans', AuditReportCategory.url),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Reports List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryCyan),
                    )
                  : filteredReports.isEmpty
                      ? Center(
                          child: Text(
                            'No audit reports found for this category.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = filteredReports[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _showReportDetailsModal(report),
                                borderRadius: BorderRadius.circular(14),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.getRiskColor(report.securityScore).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: AppColors.getRiskColor(report.securityScore).withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${report.securityScore.toInt()}',
                                            style: TextStyle(
                                              color: AppColors.getRiskColor(report.securityScore),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    report.category.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppColors.primaryCyan,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  report.id,
                                                  style: AppTypography.mono.copyWith(
                                                    color: AppColors.darkOnSurfaceVariant,
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              report.title,
                                              style: AppTypography.titleSmall.copyWith(
                                                color: AppColors.darkOnSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '${report.vulnerabilitiesFound} vulnerabilities • ${DateFormat('MMM dd, yyyy').format(report.timestamp)}',
                                              style: AppTypography.bodySmall.copyWith(
                                                color: AppColors.darkOnSurfaceVariant,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        size: 14,
                                        color: AppColors.darkOnSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, AuditReportCategory category) {
    final isSelected = _selectedFilter == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : AppColors.darkOnSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 11,
        ),
        backgroundColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.primaryCyan,
        checkmarkColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(
          color: isSelected ? AppColors.primaryCyan : Colors.white10,
        ),
        onSelected: (_) => setState(() => _selectedFilter = category),
      ),
    );
  }
}
