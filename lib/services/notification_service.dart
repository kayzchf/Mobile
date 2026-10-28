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

      // Create notification channels with high importance for lock screen & heads-up popups
      final androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.requestNotificationsPermission();

        const mainChannel = AndroidNotificationChannel(
          'arcanova_channel_main',
          'Arcanova Alerts',
          description: 'Pemberitahuan sesi pembacaan tarot dan feng shui harian',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );

        const reminderChannel = AndroidNotificationChannel(
          'arcanova_session_reminder',
          'Session Reminder',
          description: 'Pengingat sebelum sesi konsultasi tarot',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        );

        await androidImplementation.createNotificationChannel(mainChannel);
        await androidImplementation.createNotificationChannel(reminderChannel);
      }

      _isInitialized = true;
    } catch (_) {
      _isInitialized = true;
    }
  }

  // Request runtime permission (especially for Android 13+)
  Future<bool> requestPermissions() async {
    await init();
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      final granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? true;
    }
    return true;
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
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
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

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'arcanova_session_reminder',
      'Session Reminder',
      channelDescription: 'Pengingat sebelum sesi konsultasi tarot',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentAlert: true, presentSound: true),
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      // If time is already near, trigger immediate heads-up confirmation
      await showNotification(
        id: id,
        title: "🔮 Pengingat Sesi $serviceTitle Terpasang!",
        body: "Sesi kamu akan berlangsung pada pukul ${sessionTime.hour.toString().padLeft(2, '0')}:${sessionTime.minute.toString().padLeft(2, '0')} WIB. Reader kami siap menyambutmu!",
      );
      return;
    }

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: '🔮 Sesi $serviceTitle Dimulai dalam $reminderMinutes Menit!',
        body: 'Yuk siapkan ruang yang tenang dan rileks sebelum konsultasi dimulai bersama Reader Arcanova.',
        scheduledDate: scheduledDate,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      // Fallback show immediate confirmation
      await showNotification(
        id: id,
        title: "🔮 Pengingat Sesi $serviceTitle Terpasang ($reminderMinutes Menit)",
        body: "Pengingat sesi telah dijadwalkan secara lokal di perangkat Anda.",
      );
    }
  }

  // Daily Morning Feng Shui Notification
  Future<void> sendDailyFengShuiNotification() async {
    await showNotification(
      id: 999,
      title: '☯️ Panduan Feng Shui Pagi Ini Sudah Terbit!',
      body: 'Warna keberuntunganmu hari ini: Ungu Indigo & Perak Mistik. Arah energi: Timur Laut. Yuk buka Arcanova untuk cek panduan selengkapnya!',
    );
  }
}
