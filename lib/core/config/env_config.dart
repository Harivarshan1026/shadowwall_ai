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
import '../utils/logger.dart';

class EnvConfig {
  EnvConfig._();

  static const String prefKeyGeminiApiKey = 'shadowwall_gemini_api_key';
  static const String prefKeyGeminiModel = 'shadowwall_gemini_model';
  static const String defaultGeminiModel = 'gemini-3.6-flash';

  static String _geminiApiKey = '';
  static String _geminiModel = defaultGeminiModel;
  static String _safeBrowsingApiKey = '';
  static String _virusTotalApiKey = '';
  static bool _initialized = false;

  /// Getters
  static String get geminiApiKey => _geminiApiKey;
  static bool get hasGeminiApiKey => _geminiApiKey.trim().isNotEmpty;
  static String get geminiModel => _geminiModel.isNotEmpty ? _geminiModel : defaultGeminiModel;
  static String get safeBrowsingApiKey => _safeBrowsingApiKey;
  static String get virusTotalApiKey => _virusTotalApiKey;
  static bool get isInitialized => _initialized;

  /// Initialize Environment Variables & Stored User Keys
  static Future<void> init() async {
    if (_initialized) return;

    // 1. Compile-time --dart-define environment variables
    const defineGeminiKey = String.fromEnvironment('GEMINI_API_KEY');
    const defineGeminiModel = String.fromEnvironment('GEMINI_MODEL', defaultValue: defaultGeminiModel);
    const defineSafeBrowsingKey = String.fromEnvironment('SAFE_BROWSING_API_KEY');
    const defineVirusTotalKey = String.fromEnvironment('VIRUSTOTAL_API_KEY');

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
    } catch (e) {
      AppLogger.error('Failed to read stored user API key from SharedPreferences', e);
    }

    _initialized = true;
    AppLogger.info(
      'EnvConfig Initialized | Gemini Key: ${_geminiApiKey.isNotEmpty ? "Configured (${_geminiApiKey.substring(0, _geminiApiKey.length > 6 ? 6 : _geminiApiKey.length)}...)" : "Missing"} | Model: $_geminiModel',
    );
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

    // Try loading via direct File system (for local runs & tests)
    try {
      final file = File('.env');
      if (await file.exists()) {
        content = await file.readAsString();
      }
    } catch (_) {}

    // Fallback to .env.example if .env is not present
    if (content == null || content.isEmpty) {
      try {
        final exampleFile = File('.env.example');
        if (await exampleFile.exists()) {
          content = await exampleFile.readAsString();
        }
      } catch (_) {}
    }

    if (content == null || content.isEmpty) {
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
}
