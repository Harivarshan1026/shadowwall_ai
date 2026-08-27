/// ShadowWall AI — Application Entry Point.
///
/// Initializes Firebase, sets up the ProviderScope,
/// and launches the application.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'core/services/native_scanner_service.dart';
import 'package:flutter/foundation.dart';
import 'package:freerasp/freerasp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'core/utils/logger.dart';
import 'core/config/env_config.dart';

void _initRaspSecurity() {
  try {
    final config = TalsecConfig(
      androidConfig: AndroidConfig(
        packageName: 'com.shadowwall.ai',
        signingCertHashes: ['DUMMY_CERT_HASH_REPLACE_IN_PROD'],
      ),
      iosConfig: IOSConfig(
        bundleIds: ['com.shadowwall.ai'],
        teamId: 'YOUR_TEAM_ID',
      ),
      watcherMail: 'harivarshan1026@gmail.com',
      isProd: false,
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

  // Lock orientation to portrait
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

  // Secure the app against screenshots natively
  if (defaultTargetPlatform == TargetPlatform.android) {
    try {
      await NativeScannerService.secureScreen();
    } catch (e) {
      AppLogger.error('Failed to set FLAG_SECURE', e);
    }
  }

  // Initialize FreeRASP (Root/Hook/Emulator detection)
  if (!kIsWeb) {
    _initRaspSecurity();
  }

  // Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    AppLogger.error('Failed to initialize Firebase', e);
  }

  runApp(
    const ProviderScope(
      child: ShadowWallApp(),
    ),
  );
}
