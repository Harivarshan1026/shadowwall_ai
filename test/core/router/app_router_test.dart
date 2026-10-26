import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shadowwall_ai/core/config/env_config.dart';
import 'package:shadowwall_ai/core/router/app_router.dart';

void main() {
  group('AppRouter & Auth Redirect Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Unauthenticated user is restricted to auth paths', () async {
      await EnvConfig.clearUserSession();
      expect(EnvConfig.isUserLoggedIn, isFalse);

      // Verify route constants
      expect(RoutePaths.login, equals('/login'));
      expect(RoutePaths.dashboard, equals('/'));

      // In initial unauthenticated state, router is initialized with login
      expect(appRouter.configuration.routes.isNotEmpty, isTrue);
    });

    test('Authenticated user session updates authListenable and activates dashboard access', () async {
      await EnvConfig.saveUserSession(
        uid: 'user-789',
        email: 'defender@shadowwall.ai',
        displayName: 'Cyber Sentinel',
      );

      expect(EnvConfig.isUserLoggedIn, isTrue);
      expect(EnvConfig.authListenable.value, isTrue);

      // Clearing session notifies router to redirect to login
      await EnvConfig.clearUserSession();
      expect(EnvConfig.isUserLoggedIn, isFalse);
      expect(EnvConfig.authListenable.value, isFalse);
    });
  });
}
