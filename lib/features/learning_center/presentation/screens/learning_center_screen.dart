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
    
    // Calculate Level based on XP (every 100 XP is 1 level)
    final int level = (state.totalXp ~/ 100) + 1;
    final int xpInCurrentLevel = state.totalXp % 100;
    final double levelProgress = xpInCurrentLevel / 100;

    return Scaffold(
      appBar: const CyberAppBar(
        title: 'Cyber Academy',
        subtitle: 'Level up your security knowledge',
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
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryCyan.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryCyan),
                      ),
                      child: Center(
                        child: Text('Lvl $level', style: const TextStyle(color: AppColors.primaryCyan, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cyber Defender', style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
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
                          Text('$xpInCurrentLevel / 100 XP to Level ${level + 1}', style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text('Featured Courses', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 16),

              ...availableCourses.map((course) {
                return _buildCourseCard(
                  context, 
                  course.id,
                  course.title,
                  course.description,
                  _getIconForName(course.iconName),
                  _getColorForCourse(course.id),
                  '${course.lessons.length} Lessons', 
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
    switch(name) {
      case 'phishing': return Icons.phishing_rounded;
      case 'password': return Icons.password_rounded;
      case 'psychology': return Icons.psychology_rounded;
      case 'wifi': return Icons.wifi_rounded;
      case 'phone_android': return Icons.phone_android_rounded;
      default: return Icons.book_rounded;
    }
  }

  Color _getColorForCourse(String id) {
    switch(id) {
      case 'c1': return AppColors.danger;
      case 'c2': return AppColors.primaryCyan;
      case 'c3': return AppColors.accentPurple;
      case 'c4': return AppColors.warning;
      case 'c5': return AppColors.neonGreen;
      default: return AppColors.primaryCyan;
    }
  }

  Widget _buildCourseCard(BuildContext context, String id, String title, String desc, IconData icon, Color color, String lessons, String status) {
    final bool isCompleted = status == 'Completed';
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        onTap: () => context.push(RoutePaths.lesson.replaceAll(':id', id)),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleMedium.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 4),
                  Text(desc, style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.library_books_rounded, size: 14, color: AppColors.darkOnSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(lessons, style: AppTypography.labelSmall.copyWith(color: AppColors.darkOnSurfaceVariant)),
                      const Spacer(),
                      Text(status, style: AppTypography.labelSmall.copyWith(color: isCompleted ? AppColors.neonGreen : color, fontWeight: FontWeight.w600)),
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
