/// ShadowWall AI – Intelligent Mobile Cyber Safety Companion
///
/// Application constants used throughout the app.
library;

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'ShadowWall AI';
  static const String appTagline = 'Your Intelligent Cyber Safety Companion';
  static const String appVersion = '1.0.0';

  // Cyber Health Score Thresholds
  static const int scoreExcellent = 80;
  static const int scoreGood = 60;
  static const int scoreFair = 40;
  static const int scorePoor = 20;

  // Risk Score Thresholds
  static const double riskLow = 30.0;
  static const double riskMedium = 60.0;
  static const double riskHigh = 80.0;
  static const double riskCritical = 95.0;

  // Scan Types
  static const String scanTypeUrl = 'url';
  static const String scanTypeQr = 'qr';
  static const String scanTypeApk = 'apk';
  static const String scanTypeScreenshot = 'screenshot';
  static const String scanTypePermission = 'permission';
  static const String scanTypeDevice = 'device';

  // Threat Categories
  static const String threatPhishing = 'Phishing';
  static const String threatMalware = 'Malware';
  static const String threatScam = 'Scam';
  static const String threatPrivacy = 'Privacy Risk';
  static const String threatDevice = 'Device Risk';
  static const String threatSafe = 'Safe';

  // Confidence Levels
  static const String confidenceHigh = 'High';
  static const String confidenceMedium = 'Medium';
  static const String confidenceLow = 'Low';

  // Password Strength
  static const int passwordMinLength = 8;
  static const int passwordStrongLength = 16;

  // Community Report Types
  static const String reportFakeNumber = 'fake_number';
  static const String reportFakeWebsite = 'fake_website';
  static const String reportFakeQr = 'fake_qr';
  static const String reportScamMessage = 'scam_message';

  // Report Statuses
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Learning
  static const int dailyChallengeCount = 1;
  static const int quizPassScore = 70;
  static const int maxBadges = 20;

  // Report Periods
  static const String periodWeekly = 'weekly';
  static const String periodMonthly = 'monthly';

  // Animation Durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 400);
  static const Duration animSlow = Duration(milliseconds: 800);
  static const Duration animVerySlow = Duration(milliseconds: 1200);

  // Limits
  static const int maxRecentScans = 10;
  static const int maxCommunityReportsPerPage = 20;
  static const int maxChatHistoryLocal = 100;
}
