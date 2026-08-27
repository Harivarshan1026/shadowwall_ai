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
  final String lessonId; // Actually acts as courseId from the router
  const LessonScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(learningProvider);
    final notifier = ref.read(learningProvider.notifier);
    
    // Find the course
    final course = availableCourses.firstWhere((c) => c.id == lessonId, 
        orElse: () => availableCourses.first);

    final completedLessons = state.completedLessonsPerCourse[course.id] ?? 0;
    final isCourseCompleted = state.completedCourses.contains(course.id);
    
    // Determine what to show
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
        subtitle: 'Lesson ${completedLessons + 1} of ${course.lessons.length}',
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
                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Icon(_getIconForName(course.iconName), size: 48, color: AppColors.primaryCyan),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(currentLesson.title, style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
                    const SizedBox(height: 16),
                    Text(
                      currentLesson.content,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface, height: 1.6),
                    ),
                    const SizedBox(height: 32),
                    GradientButton(
                      label: 'Complete Lesson (+20 XP)',
                      icon: Icons.check_circle_rounded,
                      gradient: const LinearGradient(colors: [AppColors.neonGreen, AppColors.primaryCyan]),
                      onPressed: () {
                        notifier.completeLesson(course.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('+20 XP Earned!'), backgroundColor: AppColors.neonGreen)
                        );
                      },
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

  Widget _buildReadyForQuizView(BuildContext context, CourseEntity course) {
    return Scaffold(
      appBar: CyberAppBar(title: course.title, subtitle: 'Final Challenge', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_rounded, size: 64, color: AppColors.accentPurple),
                  const SizedBox(height: 24),
                  Text('Ready for the Quiz?', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 16),
                  Text(
                    'You have completed all lessons in this course. Take the final quiz and score at least 70% to earn your completion badge and 100 bonus XP!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Start Quiz',
                    icon: Icons.play_arrow_rounded,
                    gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryCyan]),
                    onPressed: () => context.push('/quiz/${course.id}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseCompletedView(BuildContext context, CourseEntity course) {
    return Scaffold(
      appBar: CyberAppBar(title: course.title, subtitle: 'Course Completed', showBack: true),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              borderColor: AppColors.neonGreen,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, size: 64, color: AppColors.neonGreen),
                  ),
                  const SizedBox(height: 24),
                  Text('Course Mastered!', style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 16),
                  Text(
                    'You have successfully passed the final quiz for ${course.title}.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: 'Return to Academy',
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
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
}
