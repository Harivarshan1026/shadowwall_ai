import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../providers/learning_provider.dart';

class LearningCenterScreen extends ConsumerWidget {
  const LearningCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningProvider);
    final notifier = ref.read(learningProvider.notifier);

    final int level = (state.totalXp ~/ 100) + 1;
    final int xpInCurrentLevel = state.totalXp % 100;
    final double levelProgress = xpInCurrentLevel / 100;

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Cyber Defense Academy',
        subtitle: 'In-depth masterclasses & certifications',
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Card
              GradientGlassCard(
                accentColor: AppColors.primaryCyan,
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryCyan),
                      ),
                      child: Center(
                        child: Text('Lvl $level', style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cyber Defense Specialist', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: levelProgress,
                              backgroundColor: AppColors.darkSurfaceVariant,
                              color: AppColors.primaryCyan,
                              minHeight: 6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$xpInCurrentLevel / 100 XP to Level ${level + 1} • Total XP: ${state.totalXp}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Masterclass Curriculum', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 6),
              Text(
                'Comprehensive technical courses with real attack case studies, architecture breakdowns, and certifications.',
                style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
              ),
              const SizedBox(height: 16),

              ...availableCourses.map((course) {
                return _buildCourseCard(
                  context,
                  course,
                  notifier.getCourseStatus(course.id),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForName(String name) {
    switch (name) {
      case 'phishing':
        return Icons.phishing_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'wifi':
        return Icons.wifi_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      default:
        return Icons.security_rounded;
    }
  }

  Color _getColorForCourse(String id) {
    switch (id) {
      case 'c1':
        return AppColors.danger;
      case 'c2':
        return AppColors.warning;
      case 'c3':
        return AppColors.primaryCyan;
      case 'c4':
        return AppColors.accentPurple;
      case 'c5':
        return AppColors.danger;
      case 'c6':
        return AppColors.neonGreen;
      case 'c7':
        return Colors.tealAccent;
      case 'c8':
        return AppColors.primaryCyanLight;
      default:
        return AppColors.primaryCyan;
    }
  }

  Widget _buildCourseCard(BuildContext context, CourseEntity course, String status) {
    final bool isCompleted = status == 'Completed';
    final color = _getColorForCourse(course.id);
    final icon = _getIconForName(course.iconName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () => context.push(RoutePaths.lesson.replaceAll(':id', course.id)),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          course.level,
                          style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${course.duration}',
                        style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                      ),
                      const Spacer(),
                      if (isCompleted)
                        const Icon(Icons.verified_rounded, color: AppColors.neonGreen, size: 16),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(course.title, style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    course.description,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.menu_book_rounded, size: 14, color: AppColors.primaryCyan),
                      const SizedBox(width: 4),
                      Text('${course.lessons.length} Modules', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      const Spacer(),
                      Text(
                        status,
                        style: AppTypography.labelSmall.copyWith(
                          color: isCompleted ? AppColors.neonGreen : color,
                          fontWeight: FontWeight.bold,
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
    );
  }
}
