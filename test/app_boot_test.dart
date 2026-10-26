import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadowwall_ai/app.dart';
import 'package:shadowwall_ai/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShadowWallApp Unit Tests', () {
    test('themeModeProvider initializes with dark theme by default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final theme = container.read(themeModeProvider);
      expect(theme, equals(ThemeMode.dark));
    });

    test('AppTheme configuration builds valid dark theme', () {
      final darkTheme = AppTheme.darkTheme;
      expect(darkTheme.brightness, equals(Brightness.dark));
    });
  });
}
