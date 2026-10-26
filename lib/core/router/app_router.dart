/// Application router using go_router.
///
/// Defines all navigation routes with a shell route for the
/// bottom navigation bar, and feature-specific sub-routes.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/env_config.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/url_scanner/presentation/screens/url_scanner_screen.dart';
import '../../features/url_scanner/presentation/screens/url_result_screen.dart';
import '../../features/qr_guardian/presentation/screens/qr_scanner_screen.dart';
import '../../features/qr_guardian/presentation/screens/qr_result_screen.dart';
import '../../features/apk_analyzer/presentation/screens/apk_analyzer_screen.dart';
import '../../features/apk_analyzer/presentation/screens/apk_result_screen.dart';
import '../../features/permission_doctor/presentation/screens/permission_doctor_screen.dart';
import '../../features/device_security/presentation/screens/device_security_screen.dart';
import '../../features/screenshot_analyzer/presentation/screens/screenshot_analyzer_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_assistant_screen.dart';
import '../../features/scam_community/presentation/screens/scam_community_screen.dart';
import '../../features/scam_community/presentation/screens/report_detail_screen.dart';
import '../../features/scam_community/presentation/screens/create_report_screen.dart';
import '../../features/learning_center/presentation/screens/learning_center_screen.dart';
import '../../features/learning_center/presentation/screens/lesson_screen.dart';
import '../../features/learning_center/presentation/screens/quiz_screen.dart';
import '../../features/wifi_guardian/presentation/screens/wifi_guardian_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/terms_of_service_screen.dart';
import '../../features/secret_locker/presentation/screens/secret_locker_screen.dart';
import '../widgets/navigation_shell.dart';

/// Route path constants.
class RoutePaths {
  RoutePaths._();

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Main
  static const String dashboard = '/';
  static const String scanner = '/scanner';
  static const String community = '/community';
  static const String learn = '/learn';
  static const String profile = '/profile';

  // Features
  static const String urlScanner = '/url-scanner';
  static const String urlResult = '/url-result';
  static const String qrScanner = '/qr-scanner';
  static const String qrResult = '/qr-result';
  static const String apkAnalyzer = '/apk-analyzer';
  static const String apkResult = '/apk-result';
  static const String permissionDoctor = '/permission-doctor';
  static const String deviceSecurity = '/device-security';
  static const String screenshotAnalyzer = '/screenshot-analyzer';
  static const String aiAssistant = '/ai-assistant';
  static const String createReport = '/create-report';
  static const String reportDetail = '/report-detail/:id';
  static const String learningCenter = '/learning';
  static const String lesson = '/lesson/:id';
  static const String quiz = '/quiz/:id';
  static const String wifiGuardian = '/wifi-guardian';
  static const String secretLocker = '/secret-locker';
  static const String settings = '/settings';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsOfService = '/terms-of-service';
}

/// Global navigator key.
final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// App router configuration.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: EnvConfig.isUserLoggedIn ? RoutePaths.dashboard : RoutePaths.login,
  refreshListenable: EnvConfig.authListenable,
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = EnvConfig.isUserLoggedIn;
    final String location = state.uri.path;
    final bool isAuthRoute = location == RoutePaths.login ||
        location == RoutePaths.register ||
        location == RoutePaths.forgotPassword;

    // 1. If not logged in and accessing protected route -> redirect to login
    if (!isLoggedIn && !isAuthRoute) {
      return RoutePaths.login;
    }

    // 2. If already logged in and accessing auth routes -> redirect to dashboard
    if (isLoggedIn && isAuthRoute) {
      return RoutePaths.dashboard;
    }

    return null; // allow requested navigation
  },
  routes: [
    // ──────────── Auth Routes ────────────
    GoRoute(
      path: RoutePaths.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RoutePaths.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: RoutePaths.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // ──────────── Shell Route (Bottom Navigation) ────────────
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => NavigationShell(child: child),
      routes: [
        GoRoute(
          path: RoutePaths.dashboard,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.community,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ScamCommunityScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.learn,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: LearningCenterScreen(),
          ),
        ),
        GoRoute(
          path: RoutePaths.profile,
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),

    // ──────────── Feature Routes ────────────
    GoRoute(
      path: RoutePaths.urlScanner,
      builder: (context, state) => const UrlScannerScreen(),
    ),
    GoRoute(
      path: RoutePaths.urlResult,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return UrlResultScreen(scanResult: extra);
      },
    ),
    GoRoute(
      path: RoutePaths.qrScanner,
      builder: (context, state) => const QrScannerScreen(),
    ),
    GoRoute(
      path: RoutePaths.qrResult,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return QrResultScreen(scanResult: extra);
      },
    ),
    GoRoute(
      path: RoutePaths.apkAnalyzer,
      builder: (context, state) => const ApkAnalyzerScreen(),
    ),
    GoRoute(
      path: RoutePaths.apkResult,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ApkResultScreen(analysisResult: extra);
      },
    ),
    GoRoute(
      path: RoutePaths.permissionDoctor,
      builder: (context, state) => const PermissionDoctorScreen(),
    ),
    GoRoute(
      path: RoutePaths.deviceSecurity,
      builder: (context, state) => const DeviceSecurityScreen(),
    ),
    GoRoute(
      path: RoutePaths.screenshotAnalyzer,
      builder: (context, state) => const ScreenshotAnalyzerScreen(),
    ),
    GoRoute(
      path: RoutePaths.aiAssistant,
      builder: (context, state) => const AiAssistantScreen(),
    ),
    GoRoute(
      path: RoutePaths.createReport,
      builder: (context, state) => const CreateReportScreen(),
    ),
    GoRoute(
      path: RoutePaths.reportDetail,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ReportDetailScreen(reportId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.lesson,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return LessonScreen(lessonId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.quiz,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuizScreen(courseId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.wifiGuardian,
      builder: (context, state) => const WifiGuardianScreen(),
    ),
    GoRoute(
      path: RoutePaths.secretLocker,
      builder: (context, state) => const SecretLockerScreen(),
    ),
    GoRoute(
      path: RoutePaths.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: RoutePaths.privacyPolicy,
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: RoutePaths.termsOfService,
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
  ],
);
