/// Google Safe Browsing API Service for ShadowWall AI.
///
/// Checks URLs against Google's constantly updated lists of unsafe web resources
/// (e.g. malware, social engineering/phishing, unwanted software).
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class SafeBrowsingResult {
  final bool isThreat;
  final String? threatType;
  final String? platformType;
  final String? cacheDuration;

  const SafeBrowsingResult({
    required this.isThreat,
    this.threatType,
    this.platformType,
    this.cacheDuration,
  });

  String get threatDescription {
    switch (threatType) {
      case 'MALWARE':
        return 'Malware / Harmful Software Distribution';
      case 'SOCIAL_ENGINEERING':
        return 'Phishing / Deceptive Social Engineering';
      case 'UNWANTED_SOFTWARE':
        return 'Unwanted / Adware Software';
      case 'POTENTIALLY_HARMFUL_APPLICATION':
        return 'Potentially Harmful Application (PHA)';
      default:
        return threatType ?? 'Unspecified Web Threat';
    }
  }
}

class SafeBrowsingService {
  SafeBrowsingService._();
  static final instance = SafeBrowsingService._();

  /// Check a target URL against the Google Safe Browsing v4 ThreatMatches database
  Future<SafeBrowsingResult?> checkUrl(String url) async {
    final apiKey = ApiConstants.safeBrowsingApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_SAFE_BROWSING_API_KEY') {
      return null;
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.safeBrowsingBaseUrl}${ApiConstants.safeBrowsingLookup}?key=$apiKey',
      );

      final payload = {
        'client': {
          'clientId': 'shadowwall-ai',
          'clientVersion': '1.0.0',
        },
        'threatInfo': {
          'threatTypes': [
            'MALWARE',
            'SOCIAL_ENGINEERING',
            'UNWANTED_SOFTWARE',
            'POTENTIALLY_HARMFUL_APPLICATION',
          ],
          'platformTypes': ['ANY_PLATFORM'],
          'threatEntryTypes': ['URL'],
          'threatEntries': [
            {'url': url},
          ],
        },
      };

      AppLogger.debug('Querying Google Safe Browsing for: $url');
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final matches = data['matches'] as List?;

        if (matches != null && matches.isNotEmpty) {
          final first = matches.first as Map<String, dynamic>;
          AppLogger.warning('Google Safe Browsing MATCH detected: ${first['threatType']}');
          return SafeBrowsingResult(
            isThreat: true,
            threatType: first['threatType'] as String?,
            platformType: first['platformType'] as String?,
            cacheDuration: first['cacheDuration'] as String?,
          );
        }

        return const SafeBrowsingResult(isThreat: false);
      } else {
        AppLogger.error('Google Safe Browsing returned HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Failed to query Google Safe Browsing API', e);
    }

    return null;
  }
}
