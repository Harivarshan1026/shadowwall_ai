/// Permission risk analysis rules.
library;

class PermissionRules {
  PermissionRules._();

  static Map<String, dynamic> analyze(List<String> permissions, String appName) {
    double score = 0;
    final reasons = <String>[];
    final actions = <String>[];

    final dangerousPermissions = {
      'android.permission.CAMERA': {
        'risk': 15,
        'reason': '📷 Camera access: App can take photos and record video',
      },
      'android.permission.RECORD_AUDIO': {
        'risk': 20,
        'reason': '🎤 Microphone access: App can record audio at any time',
      },
      'android.permission.ACCESS_FINE_LOCATION': {
        'risk': 18,
        'reason': '📍 Precise location: App can track your exact location',
      },
      'android.permission.ACCESS_COARSE_LOCATION': {
        'risk': 10,
        'reason': '📍 Approximate location: App can determine your general area',
      },
      'android.permission.READ_CONTACTS': {
        'risk': 15,
        'reason': '📒 Contacts access: App can read your contact list',
      },
      'android.permission.READ_CALL_LOG': {
        'risk': 18,
        'reason': '📞 Call log access: App can see your call history',
      },
      'android.permission.READ_SMS': {
        'risk': 20,
        'reason': '💬 SMS access: App can read your text messages',
      },
      'android.permission.SEND_SMS': {
        'risk': 25,
        'reason': '💬 Send SMS: App can send text messages (may incur charges)',
      },
      'android.permission.READ_EXTERNAL_STORAGE': {
        'risk': 12,
        'reason': '📁 Storage access: App can read files on your device',
      },
      'android.permission.WRITE_EXTERNAL_STORAGE': {
        'risk': 14,
        'reason': '📁 Storage write: App can modify or delete files',
      },
      'android.permission.READ_PHONE_STATE': {
        'risk': 12,
        'reason': '📱 Phone state: App can access device identifiers',
      },
      'android.permission.SYSTEM_ALERT_WINDOW': {
        'risk': 20,
        'reason': '🪟 Overlay permission: App can display over other apps',
      },
      'android.permission.REQUEST_INSTALL_PACKAGES': {
        'risk': 25,
        'reason': '⬇️ Install apps: App can install other applications',
      },
      'android.permission.ACCESS_BACKGROUND_LOCATION': {
        'risk': 22,
        'reason': '📍 Background location: App tracks you even when closed',
      },
      'android.permission.MANAGE_EXTERNAL_STORAGE': {
        'risk': 20,
        'reason': '📁 Full storage: App has unrestricted access to all files',
      },
    };

    int dangerousCount = 0;

    for (final perm in permissions) {
      final info = dangerousPermissions[perm];
      if (info != null) {
        dangerousCount++;
        score += (info['risk'] as int).toDouble();
        reasons.add(info['reason'] as String);
      }
    }

    // Determine category and actions
    String category;
    if (score <= 15) {
      category = 'Safe';
      if (reasons.isEmpty) {
        reasons.add('✅ No dangerous permissions requested');
      }
      actions.add('This app has minimal permissions');
    } else if (score <= 40) {
      category = 'Low Risk';
      actions.add('Review if all permissions are necessary for the app\'s function');
    } else if (score <= 70) {
      category = 'Medium Risk';
      actions.add('Consider revoking unnecessary permissions in Settings');
      actions.add('Look for alternative apps with fewer permissions');
    } else {
      category = 'High Risk';
      actions.add('This app requests an excessive number of dangerous permissions');
      actions.add('Consider uninstalling and finding a safer alternative');
    }

    score = score.clamp(0, 100);

    return {
      'score': score,
      'category': category,
      'reasons': reasons,
      'actions': actions,
      'dangerousCount': dangerousCount,
      'totalPermissions': permissions.length,
    };
  }
}
