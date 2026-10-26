import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../../../../core/router/app_router.dart';
import '../providers/learning_provider.dart';

class LessonScreen extends ConsumerWidget {
  final String lessonId; // Acts as courseId
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningProvider);
    final notifier = ref.read(learningProvider.notifier);

    final course = availableCourses.firstWhere(
      (c) => c.id == lessonId,
      orElse: () => availableCourses.first,
    );

    final completedLessons = state.completedLessonsPerCourse[course.id] ?? 0;
    final isCourseCompleted = state.completedCourses.contains(course.id);

    if (isCourseCompleted) {
      return _buildCourseCompletedView(context, course);
    }

    if (completedLessons >= course.lessons.length) {
      return _buildReadyForQuizView(context, course);
    }

    final currentLesson = course.lessons[completedLessons];
    final progress = (completedLessons / course.lessons.length);

    return Scaffold(
      appBar: CyberAppBar(
        title: course.title,
        subtitle: 'Lesson ${completedLessons + 1} of ${course.lessons.length} • ${course.duration}',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.darkSurfaceVariant,
              color: AppColors.primaryCyan,
              minHeight: 4,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.4)),
                                ),
                                child: Text(
                                  'MODULE ${completedLessons + 1}',
                                  style: const TextStyle(color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurfaceVariant,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  course.level,
                                  style: const TextStyle(color: AppColors.darkOnSurfaceVariant, fontSize: 11),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(currentLesson.title, style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
                          const SizedBox(height: 4),
                          Text(currentLesson.subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.primaryCyanLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Conceptual Explanation
                    Text('Core Concepts & Technical Architecture', style: AppTypography.titleSmall.copyWith(color: AppColors.darkOnSurface, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        currentLesson.content,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface, height: 1.65, fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Attack Scenario / Case Study
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 8),
                        Text('Real-World Attack Case Study', style: AppTypography.titleSmall.copyWith(color: AppColors.danger, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      borderColor: AppColors.danger.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        currentLesson.attackScenario,
                        style: AppTypography.bodySmall.copyWith(color: AppColors.darkOnSurface, height: 1.5, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Defense Checklist
                    Row(
                      children: [
                        const Icon(Icons.security_rounded, color: AppColors.neonGreen, size: 20),
                        const SizedBox(width: 8),
                        Text('Actionable Defense Playbook', style: AppTypography.titleSmall.copyWith(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: currentLesson.defenseChecklist.map((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check_circle_outline_rounded, color: AppColors.neonGreen, size: 18),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(tip, style: const TextStyle(color: AppColors.darkOnSurface, height: 1.4, fontSize: 13)),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Key Takeaway
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentPurple.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentPurple.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accentPurpleLight, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('KEY TAKEAWAY', style: TextStyle(color: AppColors.accentPurpleLight, fontWeight: FontWeight.bold, fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(currentLesson.keyTakeaway, style: const TextStyle(color: AppColors.darkOnSurface, fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Complete Lesson Button
                    GradientButton(
                      label: completedLessons + 1 == course.lessons.length ? 'Finish Course Modules (+25 XP)' : 'Next Lesson (+25 XP)',
                      icon: Icons.check_circle_rounded,
                      gradient: const LinearGradient(colors: [AppColors.neonGreen, AppColors.primaryCyan]),
                      onPressed: () {
                        notifier.completeLesson(course.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎉 +25 XP Earned! Great progress!'), backgroundColor: AppColors.neonGreen),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyForQuizView(BuildContext context, CourseEntity course) {
    return Scaffold(
      appBar: CyberAppBar(title: course.title, subtitle: 'Certification Ready', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentPurple.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.accentPurple, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded, size: 44, color: AppColors.accentPurpleLight),
                ),
              ),
              const SizedBox(height: 24),
              Text('All Modules Completed!', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 12),
              Text(
                'You have completed all technical lessons in "${course.title}". Pass the final interactive knowledge exam to earn your Defender Certification (+100 XP).',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Take Certification Exam',
                icon: Icons.quiz_rounded,
                gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan]),
                onPressed: () {
                  context.push(RoutePaths.quiz.replaceAll(':id', course.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCompletedView(BuildContext context, CourseEntity course) {
    return Scaffold(
      appBar: CyberAppBar(title: course.title, subtitle: 'Certified Defender', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen.withValues(alpha: 0.15),
                  border: Border.all(color: AppColors.neonGreen, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.verified_rounded, size: 44, color: AppColors.neonGreen),
                ),
              ),
              const SizedBox(height: 24),
              Text('Course Mastery Achieved!', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
              const SizedBox(height: 12),
              Text(
                'You have mastered "${course.title}" and passed the certification examination. You are fully equipped with modern defensive tactics.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GradientButton(
                label: 'Explore Other Masterclasses',
                icon: Icons.menu_book_rounded,
                gradient: AppColors.primaryGradient,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
