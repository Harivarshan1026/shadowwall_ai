import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundGuardService {
  BackgroundGuardService._();
  static final instance = BackgroundGuardService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  Future<bool> isGuardActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('background_guard_active') ?? false;
  }

  Future<void> toggleGuard(bool enable) async {
    await init();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('background_guard_active', enable);

    if (enable) {
      _showActiveGuardNotification();
    } else {
      _cancelGuardNotification();
    }
  }

  Future<void> _showActiveGuardNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'shadowwall_guard_channel',
      'ShadowWall Background Guard',
      channelDescription: 'Monitors background web activity and protects user device',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    try {
      await _notificationsPlugin.show(
        888,
        '🛡️ ShadowWall AI Active Guard',
        'Real-time protection enabled. Monitoring browser links (Zero personal data stored).',
        notificationDetails,
      );
    } catch (_) {}
  }

  Future<void> _cancelGuardNotification() async {
    try {
      await _notificationsPlugin.cancel(888);
    } catch (_) {}
  }
}
