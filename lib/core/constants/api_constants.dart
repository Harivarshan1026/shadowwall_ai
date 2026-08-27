/// API and service endpoint constants.
library;

import '../config/env_config.dart';

class ApiConstants {
  ApiConstants._();

  // Google Safe Browsing (optional — requires API key)
  static const String safeBrowsingBaseUrl =
      'https://safebrowsing.googleapis.com/v4';
  static const String safeBrowsingLookup = '/threatMatches:find';

  // VirusTotal (optional — requires API key)
  static const String virusTotalBaseUrl = 'https://www.virustotal.com/api/v3';
  static const String virusTotalUrlScan = '/urls';

  // API keys loaded from .env / SharedPreferences / --dart-define
  static String get safeBrowsingApiKey =>
      EnvConfig.safeBrowsingApiKey.isNotEmpty
          ? EnvConfig.safeBrowsingApiKey
          : 'YOUR_SAFE_BROWSING_API_KEY';

  static String get virusTotalApiKey =>
      EnvConfig.virusTotalApiKey.isNotEmpty
          ? EnvConfig.virusTotalApiKey
          : 'YOUR_VIRUSTOTAL_API_KEY';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String scanHistoryCollection = 'scanHistory';
  static const String threatReportsCollection = 'threatReports';
  static const String communityReportsCollection = 'communityReports';
  static const String cyberReportsCollection = 'cyberReports';
  static const String learningProgressCollection = 'learningProgress';
  static const String settingsCollection = 'settings';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration scanTimeout = Duration(seconds: 30);
}
