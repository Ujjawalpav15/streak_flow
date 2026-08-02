import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  /// Show an instant reminder notification (e.g. Streak at risk!)
  Future<void> showStreakWarningNotification({
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'streak_risk_channel',
      'Streak Loss Risk Warnings',
      channelDescription:
          'Notifications sent when a habit streak is about to break',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      999,
      title,
      body,
      notificationDetails,
    );
  }

  /// Schedule a daily recurring evening reminder to protect streaks
  Future<void> scheduleDailyEveningReminder({
    int id = 100,
    String title = '🔥 Protect Your Habit Streaks!',
    String body = 'Don\'t break your momentum! Check off today\'s habits before midnight.',
  }) async {
    try {
      await init();
      const androidDetails = AndroidNotificationDetails(
        'daily_streak_reminder',
        'Daily Habit Reminders',
        channelDescription: 'Daily evening push notifications to maintain habit streaks',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.daily,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      // Safe fallback if notifications fail on specific Android versions
    }
  }
}
