import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class NativeScannerService {
  static const MethodChannel _channel = MethodChannel('com.shadowwall.ai/native_scanner');
  static final _logger = Logger();

  /// Get installed apps with their permissions
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      _logger.e('Error getting installed apps', error: e);
      return [];
    }
  }

  /// Analyze a local APK file from path
  static Future<Map<String, dynamic>?> analyzeApk(String path) async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('analyzeApk', {'path': path});
      return Map<String, dynamic>.from(result);
    } catch (e) {
      _logger.e('Error analyzing APK at $path', error: e);
      return null;
    }
  }

  /// Get real device security status (Developer Options, USB Debugging, Screen Lock)
  static Future<Map<String, bool>> getDeviceSecurityStatus() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getDeviceSecurityStatus');
      return Map<String, bool>.from(result);
    } catch (e) {
      _logger.e('Error getting device security status', error: e);
      return {
        'developerOptions': false,
        'usbDebugging': false,
        'screenLock': true,
      };
    }
  }

  /// Secure screen against screenshots
  static Future<void> secureScreen() async {
    try {
      await _channel.invokeMethod('secureScreen');
    } catch (e) {
      _logger.e('Error securing screen', error: e);
    }
  }
}
