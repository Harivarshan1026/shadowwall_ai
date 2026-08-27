/// Device security analysis rules.
library;

class DeviceRules {
  DeviceRules._();

  static Map<String, dynamic> analyze(Map<String, bool> deviceStatus) {
    double score = 0;
    final reasons = <String>[];
    final actions = <String>[];

    // Screen lock
    if (deviceStatus['screenLock'] != true) {
      score += 20;
      reasons.add('🔓 No screen lock: Anyone can access your device');
      actions.add('Set up a PIN, password, or biometric lock');
    }

    // Encryption
    if (deviceStatus['encryption'] != true) {
      score += 18;
      reasons.add('🔓 Device not encrypted: Data can be extracted if device is stolen');
      actions.add('Enable device encryption in Settings > Security');
    }

    // Developer options
    if (deviceStatus['developerOptions'] == true) {
      score += 12;
      reasons.add('⚠️ Developer options enabled: Increases attack surface');
      actions.add('Disable developer options unless actively developing');
    }

    // USB debugging
    if (deviceStatus['usbDebugging'] == true) {
      score += 15;
      reasons.add('⚠️ USB debugging enabled: Allows computer access to device data');
      actions.add('Disable USB debugging when not in use');
    }

    // Play Protect
    if (deviceStatus['playProtect'] != true) {
      score += 15;
      reasons.add('🔴 Play Protect disabled: No malware scanning active');
      actions.add('Enable Google Play Protect in Play Store settings');
    }

    // Unknown sources
    if (deviceStatus['unknownSources'] == true) {
      score += 18;
      reasons.add('🔴 Unknown sources allowed: Sideloaded apps bypass security checks');
      actions.add('Disable installing from unknown sources');
    }

    // Category
    String category;
    if (score <= 10) {
      category = 'Safe';
      if (reasons.isEmpty) {
        reasons.add('✅ All security checks passed! Your device is well-secured.');
      }
      actions.add('Great job! Keep your device updated.');
    } else if (score <= 30) {
      category = 'Low Risk';
    } else if (score <= 60) {
      category = 'Medium Risk';
    } else {
      category = 'High Risk';
    }

    score = score.clamp(0, 100);

    return {
      'score': score,
      'category': category,
      'reasons': reasons,
      'actions': actions,
    };
  }
}
