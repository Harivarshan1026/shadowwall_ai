/// Google AI Studio Gemini API Service for ShadowWall AI.
///
/// Provides multi-turn conversational AI assistance, deep URL threat analysis,
/// APK package risk evaluation, image/screenshot fact-checking, and hardware posture reviews.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/config/env_config.dart';
import '../../core/utils/logger.dart';

/// Result wrapper for Gemini API operations with diagnostics
class GeminiResult {
  final String? text;
  final bool isSuccess;
  final String? errorMessage;
  final int? statusCode;

  const GeminiResult.success(this.text)
      : isSuccess = true,
        errorMessage = null,
        statusCode = 200;

  const GeminiResult.failure(this.errorMessage, {this.statusCode})
      : isSuccess = false,
        text = null;
}

class GeminiAiService {
  GeminiAiService._();
  static final instance = GeminiAiService._();

  /// Dynamic API Key from EnvConfig (.env, SharedPreferences, --dart-define)
  static String get apiKey => EnvConfig.geminiApiKey;
  static set apiKey(String key) => EnvConfig.setGeminiApiKey(key);

  /// Configured Model (default: gemini-3.6-flash)
  static String get model => EnvConfig.geminiModel;

  static const List<String> _fallbackModels = [
    'gemini-3.6-flash',
    'gemini-3.7-flash',
    'gemini-flash-latest',
    'gemini-2.5-pro',
  ];

  static const Duration _timeout = Duration(seconds: 25);

  static const String _defaultSystemInstruction = '''
You are ShadowWall AI, an elite cybersecurity and mobile defense AI assistant created to protect users from cyber threats, hacking, scams, malware, phishing, and privacy violations.
- Provide accurate, comprehensive, and technically grounded answers to user questions.
- When explaining attack mechanics (e.g. Wi-Fi WPA2/WPA3 handshake capture, phishing vectors, social engineering, ransomware, APK sideloading risks), always emphasize the underlying defensive principles and actionable mitigation steps.
- Format responses clearly with markdown formatting, bold keywords, and clean bullet points.
- Maintain a professional, reassuring, and security-centric tone.
''';

  /// Helper to send request with automatic model fallback if a model is deprecated / 404
  Future<http.Response?> _postWithFallback(String key, Map<String, dynamic> payload) async {
    final candidateModels = <String>[
      model,
      ..._fallbackModels.where((m) => m != model),
    ];

    http.Response? lastResponse;

    for (final candidate in candidateModels) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$candidate:generateContent?key=$key',
        );

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: json.encode(payload),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          return response;
        }

        lastResponse = response;

        // If not a 404 (model not found / deprecated), do not try next model
        if (response.statusCode != 404) {
          return response;
        }
      } catch (e) {
        AppLogger.error('Attempt with model $candidate failed: $e');
      }
    }

    return lastResponse;
  }

  /// Test whether an API key is valid by running a lightweight ping
  Future<bool> testApiKey(String candidateKey) async {
    final key = candidateKey.trim();
    if (key.isEmpty) return false;

    final candidateModels = [
      model,
      ..._fallbackModels.where((m) => m != model),
    ];

    for (final m in candidateModels) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$m:generateContent?key=$key',
        );
        final body = json.encode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': 'ping'}
              ]
            }
          ],
          'generationConfig': {'maxOutputTokens': 5}
        });

        final response = await http
            .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  /// Multi-turn Conversational AI Assistant Query
  /// Accepts conversation history so the model understands context and follow-ups.
  Future<GeminiResult> queryGeminiChat({
    required List<Map<String, dynamic>> conversationHistory,
    required String userPrompt,
  }) async {
    final key = apiKey;
    if (key.isEmpty) {
      return const GeminiResult.failure(
        'Gemini API key is not configured. Please add your key in .env or via the 🔑 settings.',
      );
    }

    try {
      // Build message contents from recent history (last 10 messages for token efficiency)
      final contents = <Map<String, dynamic>>[];

      final recentHistory = conversationHistory.length > 10
          ? conversationHistory.sublist(conversationHistory.length - 10)
          : conversationHistory;

      for (final msg in recentHistory) {
        final text = (msg['text'] as String?)?.trim() ?? '';
        final isUser = msg['isUser'] as bool? ?? false;
        if (text.isEmpty) continue;

        contents.add({
          'role': isUser ? 'user' : 'model',
          'parts': [
            {'text': text}
          ],
        });
      }

      // Add the current user prompt
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userPrompt}
        ],
      });

      final requestPayload = {
        'system_instruction': {
          'parts': [
            {'text': _defaultSystemInstruction}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 2048,
          'topP': 0.95,
        }
      };

      AppLogger.debug('Sending query to Gemini API...');
      final response = await _postWithFallback(key, requestPayload);

      if (response == null) {
        return const GeminiResult.failure('Failed to get a response from Gemini servers.');
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final parts = candidates.first['content']?['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts.first['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return GeminiResult.success(text.trim());
            }
          }
        }
        return const GeminiResult.failure('No text response received from Gemini model.');
      } else {
        final errorMessage = _extractErrorMessage(response.statusCode, response.body);
        AppLogger.error('Gemini API failed with status ${response.statusCode}: $errorMessage');
        return GeminiResult.failure(errorMessage, statusCode: response.statusCode);
      }
    } on TimeoutException {
      AppLogger.error('Gemini API request timed out after ${_timeout.inSeconds} seconds.');
      return const GeminiResult.failure(
        'Request timed out. Please check your internet connection and try again.',
      );
    } on SocketException catch (e) {
      AppLogger.error('Network connection error when contacting Gemini API: $e');
      return const GeminiResult.failure(
        'Unable to connect to Google AI Studio. Please verify your network connection.',
      );
    } catch (e, stack) {
      AppLogger.error('Unexpected error in Gemini AI service', e, stack);
      return GeminiResult.failure('Error communicating with Gemini AI: $e');
    }
  }

  /// Single Query Wrapper (Backward compatible)
  Future<String?> queryGemini(String userPrompt) async {
    final result = await queryGeminiChat(
      conversationHistory: [],
      userPrompt: userPrompt,
    );
    return result.text;
  }

  /// AI URL Scanning & Deep Risk Analysis
  Future<Map<String, dynamic>?> analyzeUrlWithAi(String url) async {
    final key = apiKey;
    if (key.isEmpty) return null;

    try {
      final prompt = '''
Analyze this URL for cyber security threats: "$url"
Evaluate typosquatting, phishing, domain reputation, TLD risk, and SSL protocol.
Return JSON format ONLY with these exact keys:
{
  "riskScore": 85,
  "threatCategory": "Phishing / Typosquatting",
  "confidence": "High",
  "aiAnalysis": "Deep AI explanation of why this URL is dangerous or safe.",
  "reasons": ["Reason 1", "Reason 2"],
  "recommendedActions": ["Action 1", "Action 2"]
}
''';

      final payload = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1000}
      };

      final response = await _postWithFallback(key, payload);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']['parts'].first['text'] as String;
          return _cleanAndParseJson(text);
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error in analyzeUrlWithAi: $e');
      return null;
    }
  }

  /// AI APK Package & Permissions Threat Analyzer
  Future<Map<String, dynamic>?> analyzeApkWithAi(
    String appName,
    String packageName,
    List<String> permissions,
  ) async {
    final key = apiKey;
    if (key.isEmpty) return null;

    try {
      final prompt = '''
Analyze this Android APK Package for malware, trojans, and privacy risks:
App Name: "$appName"
Package ID: "$packageName"
Permissions Requested: ${permissions.join(', ')}

Return JSON format ONLY with these exact keys:
{
  "riskScore": 75,
  "threatCategory": "Excessive Permission / Trojan Risk",
  "aiSummary": "Deep AI review of potential malicious intents in this app.",
  "riskIndicators": ["Indicator 1", "Indicator 2"],
  "reasons": ["Detailed reason 1", "Detailed reason 2"],
  "recommendedActions": ["Action 1", "Action 2"]
}
''';

      final payload = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1000}
      };

      final response = await _postWithFallback(key, payload);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']['parts'].first['text'] as String;
          return _cleanAndParseJson(text);
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error in analyzeApkWithAi: $e');
      return null;
    }
  }

  /// AI Image / Social Media Post / News Fact-Checker & Scam Verifier
  Future<Map<String, dynamic>?> factCheckImageTextWithAi(String extractedText) async {
    final key = apiKey;
    if (key.isEmpty) return null;

    try {
      final prompt = '''
You are an expert Cyber Intelligence and Fact-Checking Analyst for ShadowWall AI.
Analyze the following text extracted from a Screenshot, Social Media Post, News Article, or Message:
Text: "$extractedText"

TASK:
1. Determine if the information/news in the screenshot is REAL NEWS, FAKE NEWS / FABRICATED HOAX, MISLEADING / OUT OF CONTEXT, or a FINANCIAL / PHISHING SCAM.
2. Provide a detailed, evidence-based fact-check analysis explaining WHY it is real or fake.
3. Highlight specific indicators, digital manipulation clues, or fact-check references (e.g., official government statements, known hoaxes, viral rumors).

Respond in strictly valid JSON format with NO markdown wrapping or preamble, using this exact schema:
{
  "isRealNews": false,
  "veracityLabel": "Fake News / Fabricated Hoax",
  "veracityScore": 85,
  "credibilityScore": 15,
  "factCheckHeadline": "Crisp verdict headline",
  "factCheckSummary": "Detailed multi-paragraph explanation of why this news is real or fake, what the actual truth is, and any official statements or known precedents.",
  "detectedIndicators": [
    "Specific evidence/reason 1 (e.g. fabricated quote not found on official channels)",
    "Specific evidence/reason 2 (e.g. altered dates or sensational clickbait tone)",
    "Specific evidence/reason 3 (e.g. typical phishing lure requesting sensitive actions)"
  ],
  "trustedSourcesToVerify": [
    "Official Press Information Bureau (PIB)",
    "Reputable news outlets (Reuters, AP, BBC, The Hindu)"
  ],
  "recommendedActions": [
    "Do not forward or share this image on social media or messaging apps.",
    "Verify through official government / regulatory portals."
  ]
}
''';

      final payload = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1200}
      };

      final response = await _postWithFallback(key, payload);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']['parts'].first['text'] as String;
          return _cleanAndParseJson(text);
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error in factCheckImageTextWithAi: $e');
      return null;
    }
  }

  /// AI Device Security & Hardware Posture Review
  Future<Map<String, dynamic>?> analyzeDeviceWithAi(Map<String, dynamic> hardwareStatus) async {
    final key = apiKey;
    if (key.isEmpty) return null;

    try {
      final prompt = '''
Analyze this Android device hardware security status:
Status: ${json.encode(hardwareStatus)}

Provide a detailed human-like AI security review. Return JSON format ONLY with keys:
{
  "aiReview": "Detailed human-like AI review explaining device risks and security posture.",
  "riskLevel": "Low / Medium / High",
  "recommendations": ["Recommendation 1", "Recommendation 2"]
}
''';

      final payload = {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1000}
      };

      final response = await _postWithFallback(key, payload);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']['parts'].first['text'] as String;
          return _cleanAndParseJson(text);
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error in analyzeDeviceWithAi: $e');
      return null;
    }
  }

  /// Helper to clean Markdown json code blocks
  Map<String, dynamic>? _cleanAndParseJson(String rawText) {
    try {
      var cleanJson = rawText.trim();
      if (cleanJson.startsWith('```json')) {
        cleanJson = cleanJson.substring(7);
      } else if (cleanJson.startsWith('```')) {
        cleanJson = cleanJson.substring(3);
      }
      if (cleanJson.endsWith('```')) {
        cleanJson = cleanJson.substring(0, cleanJson.length - 3);
      }
      cleanJson = cleanJson.trim();
      return json.decode(cleanJson) as Map<String, dynamic>;
    } catch (e) {
      AppLogger.error('Failed to parse JSON from AI response: $rawText', e);
      return null;
    }
  }

  /// Extract friendly error messages based on HTTP status codes
  String _extractErrorMessage(int statusCode, String responseBody) {
    try {
      final decoded = json.decode(responseBody);
      final message = decoded['error']?['message'] as String?;
      if (message != null && message.isNotEmpty) {
        if (message.contains('API_KEY_INVALID') || message.contains('API key not valid')) {
          return 'Invalid Gemini API key. Please check your key at https://aistudio.google.com/app/apikey';
        }
        return message;
      }
    } catch (_) {}

    switch (statusCode) {
      case 400:
        return 'Bad Request / Invalid API Key provided to Google AI Studio.';
      case 403:
        return 'Access forbidden. Please verify your Gemini API key permissions.';
      case 429:
        return 'Gemini API rate limit exceeded. Please wait a few moments before trying again.';
      case 500:
      case 503:
        return 'Google AI Studio servers are temporarily unavailable. Please retry shortly.';
      default:
        return 'Error connecting to Gemini API (HTTP $statusCode).';
    }
  }
}
