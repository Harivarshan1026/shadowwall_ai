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
    'gemini-2.0-flash',
    'gemini-1.5-flash',
    'gemini-flash-lite-latest',
    'gemini-flash-latest',
    'gemini-2.5-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.7-flash',
  ];

  static const Duration _timeout = Duration(seconds: 20);

  static const String _defaultSystemInstruction = '''
You are ShadowWall AI, a smart, natural, and friendly cybersecurity assistant 🛡️.

CONVERSATION & TONE RULES:
1. Context-Aware & Proportional:
   - If the user sends a greeting (e.g. "hi", "hello", "hey", "good morning"), respond naturally and warmly with a brief 1-2 sentence greeting and ask what cybersecurity question or topic they'd like help with. NEVER dump unsolicited safety tips, menus, or long lectures on greetings.
   - If the user asks a question, answer that specific question directly, concisely, and accurately in natural language.
2. Natural, Human Tone:
   - Talk like a knowledgeable security mentor having a friendly 1-on-1 chat, not a rigid robot or automated template.
3. Clean Formatting (NO RAW MARKDOWN SYMBOLS):
   - Never use '###', '##', or '#' tags.
   - Never use divider lines like '---' or '***'.
   - Do NOT wrap words in '**' double asterisks or '*' single asterisks. Write in plain, elegant, natural text.
   - Use clean bullets (•) or numbered steps (1., 2.) only when necessary for clear explanations.
4. Keep it engaging with tasteful, relevant emojis (🛡️, 🔒, 💡, ⚠️, 📱).
''';

  /// Helper to send request with automatic model fallback if a model is deprecated, 404, or 429 rate-limited
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

        // If not a 404 (model not found), 429 (quota limit), or 503 (high demand), break
        if (response.statusCode != 404 && response.statusCode != 429 && response.statusCode != 503) {
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
      // Build message contents ensuring strictly alternating user/model roles and starting with 'user'
      final contents = <Map<String, dynamic>>[];

      // Filter out empty messages and only take the preceding history
      final historyToProcess = <Map<String, dynamic>>[];
      for (int i = 0; i < conversationHistory.length; i++) {
        final msg = conversationHistory[i];
        final text = (msg['text'] as String?)?.trim() ?? '';
        if (text.isEmpty) continue;

        // Skip if this is the last element and matches the current prompt (already added in screen state)
        if (i == conversationHistory.length - 1 && msg['isUser'] == true && text == userPrompt.trim()) {
          continue;
        }
        historyToProcess.add(msg);
      }

      // Limit history to the last 8 turns for performance & context
      final recentHistory = historyToProcess.length > 8
          ? historyToProcess.sublist(historyToProcess.length - 8)
          : historyToProcess;

      // Find the first user message in recent history so contents starts with 'user'
      int firstUserIndex = recentHistory.indexWhere((m) => m['isUser'] == true);
      if (firstUserIndex != -1) {
        String? lastRole;
        for (int i = firstUserIndex; i < recentHistory.length; i++) {
          final msg = recentHistory[i];
          final text = (msg['text'] as String?)?.trim() ?? '';
          final role = (msg['isUser'] as bool? ?? false) ? 'user' : 'model';

          if (role == lastRole || text.isEmpty) {
            continue; // Ensure strictly alternating roles
          }

          contents.add({
            'role': role,
            'parts': [
              {'text': text}
            ],
          });
          lastRole = role;
        }
      }

      // If the last turn in contents is 'user', remove it to avoid consecutive 'user' turns
      if (contents.isNotEmpty && contents.last['role'] == 'user') {
        contents.removeLast();
      }

      // Append current user prompt
      contents.add({
        'role': 'user',
        'parts': [
          {'text': userPrompt.trim()}
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
              final cleanText = sanitizeAiOutput(text.trim());
              return GeminiResult.success(cleanText);
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

  /// Sanitizes AI output by removing raw markdown symbols (###, ---, **, *)
  static String sanitizeAiOutput(String text) {
    if (text.isEmpty) return text;
    String cleaned = text;
    // Remove markdown headers: ### Title -> Title
    cleaned = cleaned.replaceAll(RegExp(r'#{1,6}\s*'), '');
    // Remove horizontal rules: ---, ***, ___
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-*_]{3,}\s*$', multiLine: true), '');
    // Remove bold/italic markers: **bold** -> bold, *italic* -> italic
    cleaned = cleaned.replaceAll(RegExp(r'\*\*([^*]+)\*\*'), r'$1');
    cleaned = cleaned.replaceAll(RegExp(r'\*([^*]+)\*'), r'$1');
    // Convert asterisk bullets to clean bullet dots
    cleaned = cleaned.replaceAll(RegExp(r'^\s*\*\s+', multiLine: true), '• ');
    // Remove inline backticks
    cleaned = cleaned.replaceAll(RegExp(r'`([^`]+)`'), r'$1');
    // Normalize excessive blank lines
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    return cleaned.trim();
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

  /// AI Image / Social Media Post / News Fact-Checker & Scam Verifier (Multimodal + OCR Text)
  Future<Map<String, dynamic>?> factCheckScreenshotWithAi({
    String? extractedText,
    List<int>? imageBytes,
    String mimeType = 'image/jpeg',
  }) async {
    final key = apiKey;
    if (key.isEmpty) return null;

    try {
      final textContent = (extractedText != null && extractedText.trim().isNotEmpty)
          ? 'Extracted OCR Text:\n"""$extractedText"""\n'
          : '';

      final prompt = '''
You are an expert Cyber Intelligence and Fact-Checking Analyst for ShadowWall AI.
Analyze this Screenshot / Image / Post for factual veracity, digital manipulation, and scam patterns.
$textContent
TASK:
1. Determine with strict accuracy whether the screenshot content is REAL or FAKE.
   - REAL: Verified authentic news from credible publishers, legitimate government orders/circulars, genuine transaction receipts, authentic personal messages without deceit or fraud.
   - FAKE: Fabricated hoaxes, altered/photoshopped headlines or tweets, manipulated screenshots, fake viral rumors/forwards, forged banking/UPI payment receipts, phishing contests, lottery scams, or impersonation fraud.
2. Binary Verdict: Is it REAL or FAKE? Set "isReal": true (if real) or "isReal": false (if fake).
3. Score:
   - If REAL: Set "score" to an Authenticity Confidence Score between 80 and 99 (e.g., 95).
   - If FAKE: Set "score" to a Fake / Threat Risk Score between 75 and 99 (e.g., 90).
4. Provide a crisp verdict headline and a forensic, evidence-based fact-check summary.
5. Highlight specific detected visual/textual indicators.
6. Provide trusted portals or sources to cross-verify.
7. Provide recommended safety actions.

Respond in strictly valid JSON format with NO markdown wrapping or preamble, using this exact schema:
{
  "isReal": true,
  "verdict": "REAL",
  "veracityLabel": "REAL",
  "score": 95,
  "factCheckHeadline": "Authentic Public Announcement",
  "factCheckSummary": "Detailed multi-paragraph explanation of why this content is real or fake, citing verified sources and known context.",
  "detectedIndicators": [
    "Indicator 1 (e.g., Verified official publication source)",
    "Indicator 2 (e.g., Consistent typography and authentic metadata)"
  ],
  "trustedSourcesToVerify": [
    "Official Press Information Bureau (PIB)",
    "Reputable news outlets (Reuters, AP, BBC, The Hindu)"
  ],
  "recommendedActions": [
    "Safe to read and reference.",
    "Verify with official channels when in doubt."
  ]
}
''';

      final parts = <Map<String, dynamic>>[];

      // Multimodal vision inline data if image bytes are provided
      if (imageBytes != null && imageBytes.isNotEmpty) {
        String effectiveMime = mimeType;
        if (imageBytes.length >= 4) {
          if (imageBytes[0] == 0x89 && imageBytes[1] == 0x50 && imageBytes[2] == 0x4E && imageBytes[3] == 0x47) {
            effectiveMime = 'image/png';
          } else if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8 && imageBytes[2] == 0xFF) {
            effectiveMime = 'image/jpeg';
          } else if (imageBytes.length >= 12 &&
              imageBytes[0] == 0x52 && imageBytes[1] == 0x49 && imageBytes[2] == 0x46 && imageBytes[3] == 0x46 &&
              imageBytes[8] == 0x57 && imageBytes[9] == 0x45 && imageBytes[10] == 0x42 && imageBytes[11] == 0x50) {
            effectiveMime = 'image/webp';
          }
        }

        parts.add({
          'inline_data': {
            'mime_type': effectiveMime,
            'data': base64Encode(imageBytes),
          }
        });
      }

      parts.add({'text': prompt});

      final payload = {
        'contents': [
          {
            'role': 'user',
            'parts': parts,
          }
        ],
        'generationConfig': {'temperature': 0.1, 'maxOutputTokens': 1200}
      };

      final response = await _postWithFallback(key, payload);

      if (response != null && response.statusCode == 200) {
        final data = json.decode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates.first['content']['parts'].first['text'] as String;
          final parsed = _cleanAndParseJson(text);
          if (parsed != null) {
            // Standardize output
            final bool isReal = parsed['isReal'] == true ||
                parsed['verdict']?.toString().trim().toUpperCase() == 'REAL' ||
                parsed['isRealNews'] == true;
            final double rawScore = (parsed['score'] as num?)?.toDouble() ??
                (parsed['credibilityScore'] as num?)?.toDouble() ??
                (parsed['veracityScore'] as num?)?.toDouble() ??
                (isReal ? 95.0 : 88.0);

            parsed['isReal'] = isReal;
            parsed['verdict'] = isReal ? 'REAL' : 'FAKE';
            parsed['veracityLabel'] = isReal ? 'REAL' : 'FAKE';
            parsed['score'] = rawScore.clamp(60.0, 99.0);
            return parsed;
          }
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Error in factCheckScreenshotWithAi: $e');
      return null;
    }
  }

  /// Backward-compatible single string wrapper
  Future<Map<String, dynamic>?> factCheckImageTextWithAi(String extractedText) {
    return factCheckScreenshotWithAi(extractedText: extractedText);
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
