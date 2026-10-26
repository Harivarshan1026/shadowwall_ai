/// Environment Configuration and API Key Manager for ShadowWall AI.
///
/// Loads secrets from:
/// 1. SharedPreferences (User entered / overridden via UI)
/// 2. `.env` asset file in root directory
/// 3. `--dart-define` compile-time environment flags
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/logger.dart';

class EnvConfig {
  EnvConfig._();

  static const String prefKeyGeminiApiKey = 'shadowwall_gemini_api_key';
  static const String prefKeyGeminiModel = 'shadowwall_gemini_model';
  static const String prefKeyIsLoggedIn = 'shadowwall_user_logged_in';
  static const String prefKeyUserEmail = 'shadowwall_user_email';
  static const String prefKeyUserDisplayName = 'shadowwall_user_display_name';
  static const String prefKeyUserUid = 'shadowwall_user_uid';

  static const String defaultGeminiModel = 'gemini-flash-lite-latest';
  static const String defaultGeminiApiKey = '';
  static const String defaultSafeBrowsingApiKey = '';
  static const String defaultVirusTotalApiKey = '';

  static String _geminiApiKey = defaultGeminiApiKey;
  static String _geminiModel = defaultGeminiModel;
  static String _safeBrowsingApiKey = defaultSafeBrowsingApiKey;
  static String _virusTotalApiKey = defaultVirusTotalApiKey;
  static bool _initialized = false;

  static bool _isLoggedIn = false;
  static String? _userEmail;
  static String? _userDisplayName;
  static String? _userUid;

  /// Reactive notifier for router redirect & session refresh
  static final ValueNotifier<bool> authListenable = ValueNotifier<bool>(false);

  /// Getters
  static String get geminiApiKey => _geminiApiKey.isNotEmpty ? _geminiApiKey : defaultGeminiApiKey;
  static bool get hasGeminiApiKey => geminiApiKey.trim().isNotEmpty;
  static String get geminiModel => _geminiModel.isNotEmpty ? _geminiModel : defaultGeminiModel;
  static String get safeBrowsingApiKey => _safeBrowsingApiKey.isNotEmpty ? _safeBrowsingApiKey : defaultSafeBrowsingApiKey;
  static String get virusTotalApiKey => _virusTotalApiKey.isNotEmpty ? _virusTotalApiKey : defaultVirusTotalApiKey;
  static bool get isInitialized => _initialized;

  static bool get isUserLoggedIn => _isLoggedIn;
  static String? get userEmail => _userEmail;
  static String? get userDisplayName => _userDisplayName;
  static String? get userUid => _userUid;

  /// Initialize Environment Variables & Stored User Keys
  static Future<void> init() async {
    if (_initialized) return;

    // 1. Compile-time --dart-define environment variables
    const defineGeminiKey = String.fromEnvironment('GEMINI_API_KEY', defaultValue: defaultGeminiApiKey);
    const defineGeminiModel = String.fromEnvironment('GEMINI_MODEL', defaultValue: defaultGeminiModel);
    const defineSafeBrowsingKey = String.fromEnvironment('SAFE_BROWSING_API_KEY', defaultValue: defaultSafeBrowsingApiKey);
    const defineVirusTotalKey = String.fromEnvironment('VIRUSTOTAL_API_KEY', defaultValue: defaultVirusTotalApiKey);

    if (defineGeminiKey.isNotEmpty) _geminiApiKey = defineGeminiKey;
    if (defineGeminiModel.isNotEmpty) _geminiModel = defineGeminiModel;
    if (defineSafeBrowsingKey.isNotEmpty) _safeBrowsingApiKey = defineSafeBrowsingKey;
    if (defineVirusTotalKey.isNotEmpty) _virusTotalApiKey = defineVirusTotalKey;

    // 2. Load from .env asset or local file
    final envMap = await _loadEnvFile();
    if (envMap.containsKey('GEMINI_API_KEY') && envMap['GEMINI_API_KEY']!.isNotEmpty) {
      _geminiApiKey = envMap['GEMINI_API_KEY']!;
    }
    if (envMap.containsKey('GEMINI_MODEL') && envMap['GEMINI_MODEL']!.isNotEmpty) {
      _geminiModel = envMap['GEMINI_MODEL']!;
    }
    if (envMap.containsKey('SAFE_BROWSING_API_KEY') && envMap['SAFE_BROWSING_API_KEY']!.isNotEmpty) {
      _safeBrowsingApiKey = envMap['SAFE_BROWSING_API_KEY']!;
    }
    if (envMap.containsKey('VIRUSTOTAL_API_KEY') && envMap['VIRUSTOTAL_API_KEY']!.isNotEmpty) {
      _virusTotalApiKey = envMap['VIRUSTOTAL_API_KEY']!;
    }

    // Ensure non-empty fallback
    if (_geminiApiKey.isEmpty) _geminiApiKey = defaultGeminiApiKey;
    if (_safeBrowsingApiKey.isEmpty) _safeBrowsingApiKey = defaultSafeBrowsingApiKey;
    if (_virusTotalApiKey.isEmpty) _virusTotalApiKey = defaultVirusTotalApiKey;

    // 3. User-configured override from SharedPreferences (takes highest priority)
    try {
      final prefs = await SharedPreferences.getInstance();
      final userKey = prefs.getString(prefKeyGeminiApiKey);
      if (userKey != null && userKey.trim().isNotEmpty) {
        _geminiApiKey = userKey.trim();
      }

      final userModel = prefs.getString(prefKeyGeminiModel);
      if (userModel != null && userModel.trim().isNotEmpty) {
        _geminiModel = userModel.trim();
      }

      // Load remembered session for device
      _isLoggedIn = prefs.getBool(prefKeyIsLoggedIn) ?? false;
      _userEmail = prefs.getString(prefKeyUserEmail);
      _userDisplayName = prefs.getString(prefKeyUserDisplayName);
      _userUid = prefs.getString(prefKeyUserUid);

      authListenable.value = _isLoggedIn;
    } catch (e) {
      AppLogger.error('Failed to read stored user session from SharedPreferences', e);
    }

    _initialized = true;
    AppLogger.info(
      'EnvConfig Initialized | Gemini Key: ${_geminiApiKey.isNotEmpty ? "Configured (${_geminiApiKey.substring(0, _geminiApiKey.length > 6 ? 6 : _geminiApiKey.length)}...)" : "Missing"} | Model: $_geminiModel | LoggedIn: $_isLoggedIn',
    );
  }

  /// Sync Firebase current user if available
  static void syncFirebaseUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _isLoggedIn = true;
        _userUid = user.uid;
        _userEmail = user.email ?? _userEmail;
        _userDisplayName = user.displayName ?? _userDisplayName;
        authListenable.value = true;
        saveUserSession(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName,
        );
      }
    } catch (_) {}
  }

  /// Persist authenticated user session to remember device
  static Future<void> saveUserSession({
    required String uid,
    required String email,
    String? displayName,
  }) async {
    _isLoggedIn = true;
    _userUid = uid;
    _userEmail = email;
    _userDisplayName = displayName;
    authListenable.value = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyIsLoggedIn, true);
      await prefs.setString(prefKeyUserUid, uid);
      await prefs.setString(prefKeyUserEmail, email);
      if (displayName != null && displayName.isNotEmpty) {
        await prefs.setString(prefKeyUserDisplayName, displayName);
      }
    } catch (e) {
      AppLogger.error('Failed to save user session in SharedPreferences', e);
    }
  }

  /// Clear user session on voluntary logout
  static Future<void> clearUserSession() async {
    _isLoggedIn = false;
    _userUid = null;
    _userEmail = null;
    _userDisplayName = null;
    authListenable.value = false;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(prefKeyIsLoggedIn, false);
      await prefs.remove(prefKeyUserUid);
      await prefs.remove(prefKeyUserEmail);
      await prefs.remove(prefKeyUserDisplayName);
    } catch (e) {
      AppLogger.error('Failed to clear user session in SharedPreferences', e);
    }
  }

  /// Persist user-entered Gemini API key across app restarts
  static Future<void> setGeminiApiKey(String key) async {
    final trimmedKey = key.trim();
    _geminiApiKey = trimmedKey;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (trimmedKey.isEmpty) {
        await prefs.remove(prefKeyGeminiApiKey);
        // Reload from .env if available
        final envMap = await _loadEnvFile();
        if (envMap.containsKey('GEMINI_API_KEY')) {
          _geminiApiKey = envMap['GEMINI_API_KEY']!;
        }
      } else {
        await prefs.setString(prefKeyGeminiApiKey, trimmedKey);
      }
    } catch (e) {
      AppLogger.error('Failed to save Gemini API key in SharedPreferences', e);
    }
  }

  /// Persist user-selected Gemini model
  static Future<void> setGeminiModel(String model) async {
    final trimmedModel = model.trim();
    if (trimmedModel.isEmpty) return;
    _geminiModel = trimmedModel;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(prefKeyGeminiModel, trimmedModel);
    } catch (e) {
      AppLogger.error('Failed to save Gemini model in SharedPreferences', e);
    }
  }

  /// Internal parser for .env format
  static Future<Map<String, String>> _loadEnvFile() async {
    String? content;

    // 1. Try loading via rootBundle asset (standard for bundled APK / iOS / Web)
    try {
      content = await rootBundle.loadString('.env');
    } catch (_) {}

    if (content == null || content.trim().isEmpty) {
      try {
        content = await rootBundle.loadString('.env.example');
      } catch (_) {}
    }

    // 2. Try loading via direct File system (for local runs & tests outside asset bundle)
    if (content == null || content.trim().isEmpty) {
      if (!kIsWeb) {
        try {
          final file = File('.env');
          if (await file.exists()) {
            content = await file.readAsString();
          }
        } catch (_) {}

        if (content == null || content.trim().isEmpty) {
          try {
            final exampleFile = File('.env.example');
            if (await exampleFile.exists()) {
              content = await exampleFile.readAsString();
            }
          } catch (_) {}
        }
      }
    }

    if (content == null || content.trim().isEmpty) {
      return {};
    }

    return _parseEnvString(content);
  }

  /// Parse KEY=VALUE text lines
  static Map<String, String> _parseEnvString(String content) {
    final result = <String, String>{};
    final lines = const LineSplitter().convert(content);

    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final eqIdx = line.indexOf('=');
      if (eqIdx == -1) continue;

      final key = line.substring(0, eqIdx).trim();
      var value = line.substring(eqIdx + 1).trim();

      // Remove surrounding quotes if present
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        if (value.length >= 2) {
          value = value.substring(1, value.length - 1);
        }
      }

      if (key.isNotEmpty) {
        result[key] = value;
      }
    }

    return result;
  }

  /// Mask sensitive API key for safe UI display & logs
  static String maskKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return 'Not Configured';
    if (trimmed.length <= 8) return '****';
    return '${trimmed.substring(0, 4)}****${trimmed.substring(trimmed.length - 4)}';
  }
}
