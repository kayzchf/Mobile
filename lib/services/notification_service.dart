import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  NotificationService._init();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );

    try {
      await _notificationsPlugin.initialize(
        settings: initializationSettings,
      );
      _isInitialized = true;
    } catch (_) {
      _isInitialized = true;
    }
  }

  // Show immediate notification
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
  }) async {
    await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'arcanova_channel_main',
      'Arcanova Alerts',
      channelDescription: 'Pemberitahuan sesi pembacaan tarot dan feng shui harian',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  // Schedule reminder 5 or 10 minutes before session
  Future<void> scheduleSessionReminder({
    required int id,
    required String serviceTitle,
    required DateTime sessionTime,
    int reminderMinutes = 10,
  }) async {
    await init();

    final reminderTime = sessionTime.subtract(Duration(minutes: reminderMinutes));
    final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'arcanova_session_reminder',
      'Session Reminder',
      channelDescription: 'Pengingat sebelum sesi konsultasi tarot',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '🔮 Sesi $serviceTitle Dimulai dalam $reminderMinutes Menit!',
        body: 'Yuk siapkan ruang yang tenang dan santai sebelum konsultasi dimulai bersama Reader Arcanova.',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {}
  }

  // Daily Morning Feng Shui Notification
  Future<void> sendDailyFengShuiNotification() async {
    await showNotification(
      id: 999,
      title: '☯️ Panduan Feng Shui Hari Ini Sudah Terbit!',
      body: 'Warna keberuntunganmu hari ini: Ungu Indigo & Silver. Makanan cakra: Teh hangat & almond. Yuk cek selengkapnya di Mystic Hub!',
    );
  }
}
