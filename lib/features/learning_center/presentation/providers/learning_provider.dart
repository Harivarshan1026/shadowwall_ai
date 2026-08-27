import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
  });
}

class LessonEntity {
  final String id;
  final String title;
  final String content;

  const LessonEntity({
    required this.id,
    required this.title,
    required this.content,
  });
}

class CourseEntity {
  final String id;
  final String title;
  final String description;
  final String iconName; // e.g. 'phishing', 'password'
  final List<LessonEntity> lessons;
  final List<QuizQuestion> finalQuiz;
  
  const CourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.lessons,
    required this.finalQuiz,
  });
}

class LearningState {
  final int totalXp;
  final Map<String, int> completedLessonsPerCourse; // courseId -> number of completed lessons
  final Set<String> completedCourses; // courseIds that have passed the quiz

  const LearningState({
    this.totalXp = 0,
    this.completedLessonsPerCourse = const {},
    this.completedCourses = const {},
  });

  LearningState copyWith({
    int? totalXp,
    Map<String, int>? completedLessonsPerCourse,
    Set<String>? completedCourses,
  }) {
    return LearningState(
      totalXp: totalXp ?? this.totalXp,
      completedLessonsPerCourse: completedLessonsPerCourse ?? this.completedLessonsPerCourse,
      completedCourses: completedCourses ?? this.completedCourses,
    );
  }
}

// ── Hardcoded Courses ──
final List<CourseEntity> availableCourses = [
  CourseEntity(
    id: 'c1',
    title: 'Phishing Defense 101',
    description: 'Learn how to spot deceptive emails, malicious URLs, and fake login pages before it\'s too late.',
    iconName: 'phishing',
    lessons: [
      const LessonEntity(id: 'l1', title: 'What is Phishing?', content: 'Phishing is a cyber attack that uses disguised email as a weapon...'),
      const LessonEntity(id: 'l2', title: 'Spotting Fake URLs', content: 'Look for typosquatting like google.com vs g00gle.com...'),
      const LessonEntity(id: 'l3', title: 'Urgency Tactics', content: 'Scammers create a false sense of urgency to bypass your logical thinking...'),
    ],
    finalQuiz: [
      const QuizQuestion(question: 'What is the main goal of phishing?', options: ['To install antivirus', 'To steal personal information', 'To upgrade your software'], correctAnswerIndex: 1),
      const QuizQuestion(question: 'Which URL is suspicious?', options: ['https://paypal.com', 'https://amazon.com', 'http://secure-paypal-update.tk'], correctAnswerIndex: 2),
    ],
  ),
  CourseEntity(
    id: 'c2',
    title: 'Mastering Passwords',
    description: 'Discover how to create uncrackable passwords, use managers, and enable 2FA properly.',
    iconName: 'password',
    lessons: [
      const LessonEntity(id: 'l1', title: 'Password Length vs Complexity', content: 'Length is often more important than complexity...'),
      const LessonEntity(id: 'l2', title: 'Password Managers', content: 'A password manager encrypts your vault...'),
      const LessonEntity(id: 'l3', title: 'Two-Factor Authentication', content: 'Always enable 2FA on important accounts...'),
    ],
    finalQuiz: [
      const QuizQuestion(question: 'Which is stronger?', options: ['P@ssw0rd1', 'CorrectHorseBatteryStaple', '12345678'], correctAnswerIndex: 1),
      const QuizQuestion(question: 'What does 2FA stand for?', options: ['Two-Factor Authentication', 'Two-File Analysis', 'To Fraud Alert'], correctAnswerIndex: 0),
    ],
  ),
  CourseEntity(
    id: 'c3',
    title: 'Social Engineering',
    description: 'Understand how attackers manipulate human psychology to gain access to systems and data.',
    iconName: 'psychology',
    lessons: [
      const LessonEntity(id: 'l1', title: 'The Human Element', content: 'Humans are often the weakest link in security...'),
      const LessonEntity(id: 'l2', title: 'Pretexting', content: 'Pretexting involves a scammer fabricating a scenario...'),
      const LessonEntity(id: 'l3', title: 'Baiting', content: 'Baiting leaves a malware-infected physical device for a victim to find...'),
    ],
    finalQuiz: [
      const QuizQuestion(question: 'What is pretexting?', options: ['Creating a fabricated scenario', 'Guessing passwords', 'Sending spam emails'], correctAnswerIndex: 0),
      const QuizQuestion(question: 'Why do attackers use social engineering?', options: ['It is faster than hacking technical systems', 'They like talking to people', 'It is required by law'], correctAnswerIndex: 0),
    ],
  ),
  CourseEntity(
    id: 'c4',
    title: 'Public Wi-Fi Safety',
    description: 'Stay safe when browsing on coffee shop or airport networks.',
    iconName: 'wifi',
    lessons: [
      const LessonEntity(id: 'l1', title: 'The Risks of Public Wi-Fi', content: 'Anyone on the network can intercept traffic...'),
      const LessonEntity(id: 'l2', title: 'Using a VPN', content: 'A Virtual Private Network encrypts your connection...'),
    ],
    finalQuiz: [
      const QuizQuestion(question: 'What is the best way to secure a public Wi-Fi connection?', options: ['Use Incognito mode', 'Use a VPN', 'Turn off Bluetooth'], correctAnswerIndex: 1),
    ],
  ),
  CourseEntity(
    id: 'c5',
    title: 'Mobile Device Security',
    description: 'Protect your smartphone from malware and physical theft.',
    iconName: 'phone_android',
    lessons: [
      const LessonEntity(id: 'l1', title: 'App Permissions', content: 'Don\'t give flashlight apps access to your contacts...'),
      const LessonEntity(id: 'l2', title: 'Physical Security', content: 'Use biometrics and strong lock screens...'),
    ],
    finalQuiz: [
      const QuizQuestion(question: 'Should a simple calculator app need location permissions?', options: ['Yes', 'No', 'Only on weekends'], correctAnswerIndex: 1),
    ],
  ),
];

class LearningNotifier extends StateNotifier<LearningState> {
  LearningNotifier() : super(const LearningState());

  void completeLesson(String courseId) {
    final current = state.completedLessonsPerCourse[courseId] ?? 0;
    final course = availableCourses.firstWhere((c) => c.id == courseId);
    
    if (current < course.lessons.length) {
      final updated = Map<String, int>.from(state.completedLessonsPerCourse);
      updated[courseId] = current + 1;
      
      // Award 20 XP per lesson
      state = state.copyWith(
        completedLessonsPerCourse: updated,
        totalXp: state.totalXp + 20,
      );
    }
  }

  void completeCourseQuiz(String courseId, double scorePercentage) {
    if (scorePercentage >= 70.0) {
      final completed = Set<String>.from(state.completedCourses);
      if (!completed.contains(courseId)) {
        completed.add(courseId);
        // Award 100 bonus XP for passing the quiz
        state = state.copyWith(
          completedCourses: completed,
          totalXp: state.totalXp + 100,
        );
      }
    }
  }

  double getCourseProgress(String courseId) {
    final course = availableCourses.firstWhere((c) => c.id == courseId);
    final completedLessons = state.completedLessonsPerCourse[courseId] ?? 0;
    
    if (state.completedCourses.contains(courseId)) return 1.0;
    
    return completedLessons / course.lessons.length;
  }

  String getCourseStatus(String courseId) {
    if (state.completedCourses.contains(courseId)) return 'Completed';
    final progress = getCourseProgress(courseId);
    if (progress == 0) return 'Start Course';
    return 'In Progress (${(progress * 100).toInt()}%)';
  }
}

final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier();
});
