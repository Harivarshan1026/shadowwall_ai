/// VirusTotal API v3 Service for ShadowWall AI.
///
/// Queries VirusTotal for URL reputations, multi-antivirus scan detections,
/// and APK file hash threat intelligence.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../utils/logger.dart';

class VirusTotalResult {
  final bool isThreat;
  final int malicious;
  final int suspicious;
  final int harmless;
  final int undetected;
  final int reputation;
  final String? threatCategory;

  const VirusTotalResult({
    required this.isThreat,
    required this.malicious,
    required this.suspicious,
    required this.harmless,
    required this.undetected,
    required this.reputation,
    this.threatCategory,
  });

  int get totalDetections => malicious + suspicious;
}

class VirusTotalService {
  VirusTotalService._();
  static final instance = VirusTotalService._();

  static const Duration _timeout = Duration(seconds: 12);

  /// Check URL intelligence using VirusTotal v3
  Future<VirusTotalResult?> checkUrl(String url) async {
    final apiKey = ApiConstants.virusTotalApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_VIRUSTOTAL_API_KEY') {
      return null;
    }

    try {
      // VirusTotal URL ID is base64 encoded URL without padding
      final urlId = base64Url.encode(utf8.encode(url)).replaceAll('=', '');
      final uri = Uri.parse('${ApiConstants.virusTotalBaseUrl}/urls/$urlId');

      AppLogger.debug('Querying VirusTotal for URL: $url');
      final response = await http.get(
        uri,
        headers: {
          'x-apikey': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']?['attributes'];
        if (data != null) {
          final stats = data['last_analysis_stats'] as Map<String, dynamic>? ?? {};
          final malicious = (stats['malicious'] as num?)?.toInt() ?? 0;
          final suspicious = (stats['suspicious'] as num?)?.toInt() ?? 0;
          final harmless = (stats['harmless'] as num?)?.toInt() ?? 0;
          final undetected = (stats['undetected'] as num?)?.toInt() ?? 0;
          final reputation = (data['reputation'] as num?)?.toInt() ?? 0;

          final isThreat = (malicious + suspicious) > 0 || reputation < -10;

          return VirusTotalResult(
            isThreat: isThreat,
            malicious: malicious,
            suspicious: suspicious,
            harmless: harmless,
            undetected: undetected,
            reputation: reputation,
            threatCategory: isThreat ? '$malicious Security Vendors Flagged This URL' : null,
          );
        }
      } else if (response.statusCode == 404) {
        AppLogger.debug('URL not previously analyzed on VirusTotal: $url');
      } else {
        AppLogger.error('VirusTotal error HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      AppLogger.error('Failed to query VirusTotal API', e);
    }

    return null;
  }

  /// Check APK / file hash threat intelligence
  Future<VirusTotalResult?> checkFileHash(String sha256) async {
    final apiKey = ApiConstants.virusTotalApiKey;
    if (apiKey.isEmpty || apiKey == 'YOUR_VIRUSTOTAL_API_KEY') {
      return null;
    }

    try {
      final uri = Uri.parse('${ApiConstants.virusTotalBaseUrl}/files/$sha256');

      AppLogger.debug('Querying VirusTotal for hash: $sha256');
      final response = await http.get(
        uri,
        headers: {
          'x-apikey': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data']?['attributes'];
        if (data != null) {
          final stats = data['last_analysis_stats'] as Map<String, dynamic>? ?? {};
          final malicious = (stats['malicious'] as num?)?.toInt() ?? 0;
          final suspicious = (stats['suspicious'] as num?)?.toInt() ?? 0;
          final harmless = (stats['harmless'] as num?)?.toInt() ?? 0;
          final undetected = (stats['undetected'] as num?)?.toInt() ?? 0;
          final reputation = (data['reputation'] as num?)?.toInt() ?? 0;

          final isThreat = (malicious + suspicious) > 0;

          return VirusTotalResult(
            isThreat: isThreat,
            malicious: malicious,
            suspicious: suspicious,
            harmless: harmless,
            undetected: undetected,
            reputation: reputation,
            threatCategory: isThreat ? 'Malicious APK detected by $malicious antivirus engines' : null,
          );
        }
      }
    } catch (e) {
      AppLogger.error('Failed to check file hash on VirusTotal', e);
    }

    return null;
  }
}
