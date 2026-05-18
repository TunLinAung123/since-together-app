import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _plugin.initialize(settings: settings);

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.requestNotificationsPermission();

    await androidPlugin?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleDailyCountdown({
    required int daysTogether,
    required int? daysUntilAnniversary,
  }) async {
    await _plugin.cancel(id: 1);

    final String body = daysUntilAnniversary != null
        ? '$daysTogether days together • Anniversary in $daysUntilAnniversary days 🎉'
        : '$daysTogether days together 💕';
    await _plugin.zonedSchedule(
      id: 1,
      title: '💕 Since Together',
      body: body,
      scheduledDate: _nextInstanceOf9AM(),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'countdown_channel',
          'Countdown',
          channelDescription: 'Daily countdown notifications',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: false,
          playSound: false,
          enableVibration: false,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> testNotification() async {
    await _plugin.show(
      id: 999,
      title: 'Test Notification',
      body: 'Hello from Since Together 💕',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test',
          channelDescription: 'Test notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  static tz.TZDateTime _nextInstanceOf9AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(seconds: 10));
    }

    return scheduled;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
