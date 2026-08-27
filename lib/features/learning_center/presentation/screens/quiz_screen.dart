import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/cyber_app_bar.dart';
import '../providers/learning_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String courseId;
  const QuizScreen({super.key, required this.courseId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  List<int?> _selectedAnswers = [];
  bool _isSubmitted = false;
  double _scorePercentage = 0;

  @override
  void initState() {
    super.initState();
    final course = availableCourses.firstWhere((c) => c.id == widget.courseId, orElse: () => availableCourses.first);
    _selectedAnswers = List.filled(course.finalQuiz.length, null);
  }

  void _submitQuiz(CourseEntity course) {
    int correctAnswers = 0;
    for (int i = 0; i < course.finalQuiz.length; i++) {
      if (_selectedAnswers[i] == course.finalQuiz[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }
    
    _scorePercentage = (correctAnswers / course.finalQuiz.length) * 100;
    
    setState(() {
      _isSubmitted = true;
    });

    ref.read(learningProvider.notifier).completeCourseQuiz(course.id, _scorePercentage);
  }

  @override
  Widget build(BuildContext context) {
    final course = availableCourses.firstWhere((c) => c.id == widget.courseId, orElse: () => availableCourses.first);
    
    if (_isSubmitted) {
      return _buildResultView(context, course);
    }

    final question = course.finalQuiz[_currentQuestionIndex];

    return Scaffold(
      appBar: CyberAppBar(
        title: 'Quiz: ${course.title}',
        subtitle: 'Question ${_currentQuestionIndex + 1} of ${course.finalQuiz.length}',
        showBack: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / course.finalQuiz.length,
                backgroundColor: AppColors.darkSurfaceVariant,
                color: AppColors.accentPurple,
              ),
              const SizedBox(height: 32),
              Text(
                question.question,
                style: AppTypography.headlineSmall.copyWith(color: AppColors.darkOnSurface),
              ),
              const SizedBox(height: 32),
              ...List.generate(question.options.length, (index) {
                final isSelected = _selectedAnswers[_currentQuestionIndex] == index;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: isSelected ? AppColors.primaryCyan : Colors.transparent,
                    glowColor: isSelected ? AppColors.primaryCyan : null,
                    onTap: () {
                      setState(() {
                        _selectedAnswers[_currentQuestionIndex] = index;
                      });
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppColors.primaryCyan : AppColors.darkOnSurfaceVariant),
                            color: isSelected ? AppColors.primaryCyan : Colors.transparent,
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 16, color: AppColors.darkSurface) : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            question.options[index],
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurface),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const Spacer(),
              GradientButton(
                label: _currentQuestionIndex == course.finalQuiz.length - 1 ? 'Submit Quiz' : 'Next Question',
                icon: _currentQuestionIndex == course.finalQuiz.length - 1 ? Icons.send_rounded : Icons.arrow_forward_rounded,
                onPressed: _selectedAnswers[_currentQuestionIndex] == null 
                  ? null 
                  : () {
                      if (_currentQuestionIndex < course.finalQuiz.length - 1) {
                        setState(() {
                          _currentQuestionIndex++;
                        });
                      } else {
                        _submitQuiz(course);
                      }
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView(BuildContext context, CourseEntity course) {
    final passed = _scorePercentage >= 70;
    
    return Scaffold(
      appBar: CyberAppBar(title: 'Quiz Results', showBack: false),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GlassCard(
              padding: const EdgeInsets.all(32),
              borderColor: passed ? AppColors.neonGreen : AppColors.danger,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: (passed ? AppColors.neonGreen : AppColors.danger).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed ? Icons.emoji_events_rounded : Icons.sentiment_dissatisfied_rounded,
                      size: 64,
                      color: passed ? AppColors.neonGreen : AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('${_scorePercentage.toInt()}%', style: AppTypography.headlineMedium.copyWith(color: AppColors.darkOnSurface)),
                  const SizedBox(height: 8),
                  Text(
                    passed ? 'Congratulations!' : 'Keep Trying!',
                    style: AppTypography.titleMedium.copyWith(color: passed ? AppColors.neonGreen : AppColors.danger),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    passed 
                      ? 'You have passed the quiz and earned 100 bonus XP. You are now certified in ${course.title}.' 
                      : 'You need at least 70% to pass. Review the lessons and try again.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.darkOnSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  GradientButton(
                    label: passed ? 'Return to Academy' : 'Retry Course',
                    icon: passed ? Icons.arrow_back_rounded : Icons.refresh_rounded,
                    onPressed: () {
                      if (passed) {
                        context.pop(); // Go back to lesson screen which will now show completed state
                      } else {
                        context.pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
