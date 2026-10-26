/// ShadowWall AI — Application Entry Point.
///
/// Initializes Firebase, sets up the ProviderScope,
/// and launches the application.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'core/config/env_config.dart';
import 'core/services/background_guard_service.dart';

void _initRaspSecurity() {
  try {
    const playStoreCertHash = String.fromEnvironment('PLAY_STORE_CERT_HASH', defaultValue: '');
    final certHashes = playStoreCertHash.isNotEmpty
        ? [playStoreCertHash]
        : ['DUMMY_CERT_HASH_REPLACE_IN_PROD'];

    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.shadowwall.ai',
        signingCertHashes: certHashes,
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.shadowwall.ai'],
        teamId: 'YOUR_TEAM_ID',
      ),
      watcherMail: 'harivarshan1026@gmail.com',
      isProd: playStoreCertHash.isNotEmpty,
    );

    final callback = ThreatCallback(
      onAppIntegrity: () => AppLogger.error('RASP THREAT: App integrity'),
      onObfuscationIssues: () => AppLogger.error('RASP THREAT: Obfuscation'),
      onDebug: () => AppLogger.error('RASP THREAT: Debug'),
      onDeviceBinding: () => AppLogger.error('RASP THREAT: Device binding'),
      onDeviceID: () => AppLogger.error('RASP THREAT: Device ID'),
      onHooks: () => AppLogger.error('RASP THREAT: Hook framework detected'),
      onPrivilegedAccess: () => AppLogger.error('RASP THREAT: Root/Jailbreak detected!'),
      onSecureHardwareNotAvailable: () => AppLogger.error('RASP THREAT: Secure hardware unavailable'),
      onSimulator: () => AppLogger.error('RASP THREAT: Simulator detected'),
      onUnofficialStore: () => AppLogger.error('RASP THREAT: Unofficial store'),
    );

    Talsec.instance.start(config);
    Talsec.instance.attachListener(callback);
  } catch (e) {
    AppLogger.error('Failed to init FreeRASP security', e);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Environment Configuration (.env, SharedPreferences, --dart-define)
  try {
    await EnvConfig.init();
  } catch (e) {
    AppLogger.error('Failed to initialize EnvConfig', e);
  }

  if (!kIsWeb) {
    // Lock orientation to portrait on mobile
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      AppLogger.error('Failed to set preferred orientations', e);
    }

    // Set system UI overlay style
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF111633),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to set system UI overlay style', e);
    }

    // Allow screenshots and screen recording (FLAG_SECURE disabled)

    // Initialize FreeRASP
    _initRaspSecurity();
  }

  // Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    EnvConfig.syncFirebaseUser();
  } catch (e) {
    AppLogger.error('Failed to initialize Firebase', e);
  }

  // Initialize Background Guard Service
  try {
    await BackgroundGuardService.instance.init();
  } catch (e) {
    AppLogger.error('Failed to initialize BackgroundGuardService', e);
  }

  runApp(
    const ProviderScope(
      child: ShadowWallApp(),
    ),
  );
}
