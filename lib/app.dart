/// ShadowWall AI — Root Application Widget.
///
/// Configures MaterialApp with theming, routing, and global providers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

/// Theme mode provider — toggles between light, dark, and system.
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class ShadowWallApp extends ConsumerWidget {
  const ShadowWallApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'ShadowWall AI',
      debugShowCheckedModeBanner: false,

      // Dark Theme Only
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // Router
      routerConfig: appRouter,
    );
  }
}
