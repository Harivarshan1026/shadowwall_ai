/// Asset path constants.
library;

class AssetConstants {
  AssetConstants._();

  // TFLite Models
  static const String urlClassifierModel = 'assets/models/url_classifier.tflite';
  static const String screenshotClassifierModel =
      'assets/models/screenshot_classifier.tflite';

  // Images
  static const String logoLight = 'assets/images/logo_light.png';
  static const String logoDark = 'assets/images/logo_dark.png';
  static const String onboardingBg = 'assets/images/onboarding_bg.png';
  static const String emptyState = 'assets/images/empty_state.png';

  // Lottie Animations
  static const String scanningAnim = 'assets/animations/scanning.json';
  static const String shieldAnim = 'assets/animations/shield.json';
  static const String successAnim = 'assets/animations/success.json';
  static const String warningAnim = 'assets/animations/warning.json';
  static const String dangerAnim = 'assets/animations/danger.json';
  static const String loadingAnim = 'assets/animations/loading.json';
  static const String chatbotAnim = 'assets/animations/chatbot.json';
  static const String congratsAnim = 'assets/animations/congrats.json';
}
