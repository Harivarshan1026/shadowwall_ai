/// Interactive Threat Analytics & Scam Category Heatmap Screen.
library;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';

class ThreatAnalyticsScreen extends StatefulWidget {
  const ThreatAnalyticsScreen({super.key});

  @override
  State<ThreatAnalyticsScreen> createState() => _ThreatAnalyticsScreenState();
}

class _ThreatAnalyticsScreenState extends State<ThreatAnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Threat Analytics',
        subtitle: 'Scam category heatmap & trend insights',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards Grid
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile('Total Interceptions', '142', Icons.security_rounded, AppColors.primaryCyan),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMetricTile('High Risk Blocked', '38', Icons.gavel_rounded, AppColors.danger),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Scam Category Pie Chart Card
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Scam Category Distribution', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 4),
                    Text('Breakdown of intercepted attack vectors', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback: (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  _touchedIndex = -1;
                                  return;
                                }
                                _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: _showingSections(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem('Phishing', AppColors.danger),
                        _buildLegendItem('Fake UPI', AppColors.warning),
                        _buildLegendItem('Malware APK', AppColors.neonGreen),
                        _buildLegendItem('Fake News', AppColors.primaryCyan),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Weekly Cyber Posture Trend Bar Chart
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('7-Day Health Score History', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 4),
                    Text('Daily device security posture tracking', style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            _makeGroupData(0, 95),
                            _makeGroupData(1, 90),
                            _makeGroupData(2, 85),
                            _makeGroupData(3, 100),
                            _makeGroupData(4, 95),
                            _makeGroupData(5, 88),
                            _makeGroupData(6, 96),
                          ],
                          titlesData: FlTitlesData(
                            show: true,
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  return Text(days[val.toInt()], style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10));
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          gridData: const FlGridData(show: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Regional Scam Campaign Heatmap
              GlassCard(
                padding: const EdgeInsets.all(20),
                borderColor: AppColors.warning.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: AppColors.warning, size: 22),
                        const SizedBox(width: 8),
                        Text('Active Regional Threat Heatmap', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildHeatmapTile('Fake Bank SMS OTP Intercepts', 'HIGH ACTIVITY', AppColors.danger),
                    _buildHeatmapTile('Typosquatting .XYZ Payment Links', 'MODERATE', AppColors.warning),
                    _buildHeatmapTile('Fake Telegram Investment Bots', 'ELEVATED', AppColors.warning),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.headlineMedium.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold)),
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
        ],
      ),
    );
  }

  List<PieChartSectionData> _showingSections() {
    return List.generate(4, (i) {
      final isTouched = i == _touchedIndex;
      final radius = isTouched ? 45.0 : 38.0;

      switch (i) {
        case 0:
          return PieChartSectionData(color: AppColors.danger, value: 35, title: '35%', radius: radius, titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold));
        case 1:
          return PieChartSectionData(color: AppColors.warning, value: 30, title: '30%', radius: radius, titleStyle: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold));
        case 2:
          return PieChartSectionData(color: AppColors.neonGreen, value: 20, title: '20%', radius: radius, titleStyle: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold));
        case 3:
          return PieChartSectionData(color: AppColors.primaryCyan, value: 15, title: '15%', radius: radius, titleStyle: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold));
        default:
          throw Error();
      }
    });
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y >= 90 ? AppColors.neonGreen : AppColors.warning,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(title, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant, fontSize: 10)),
      ],
    );
  }

  Widget _buildHeatmapTile(String title, String badgeText, Color badgeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
            child: Text(badgeText, style: AppTypography.mono.copyWith(color: badgeColor, fontSize: 9, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
