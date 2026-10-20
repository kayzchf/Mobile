class TimezoneService {
  static final TimezoneService instance = TimezoneService._init();
  TimezoneService._init();

  // Supported Timezones: WIB, WITA, London (WIT removed as requested)
  static const List<String> supportedTimezones = ['WIB', 'WITA', 'London (GMT)'];

  static int getUtcOffsetHours(String tz) {
    if (tz.contains('WITA')) return 8;
    if (tz.contains('London') || tz.contains('GMT')) return 0;
    return 7; // WIB default
  }

  // Convert time string "HH:mm" from WIB to target timezone
  String convertFromWib(String wibTimeStr, String targetTz) {
    try {
      final parts = wibTimeStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      const wibOffset = 7;
      final targetOffset = getUtcOffsetHours(targetTz);
      final diff = targetOffset - wibOffset;

      int newHour = (hour + diff) % 24;
      if (newHour < 0) newHour += 24;

      final hourStr = newHour.toString().padLeft(2, '0');
      final minStr = minute.toString().padLeft(2, '0');
      return '$hourStr:$minStr $targetTz';
    } catch (_) {
      return '$wibTimeStr $targetTz';
    }
  }

  // Get neat comparative times (WIB, WITA, London only - NO WIT)
  Map<String, String> getAllZoneTimes(String wibTimeStr) {
    return {
      'WIB': '$wibTimeStr WIB',
      'WITA': convertFromWib(wibTimeStr, 'WITA'),
      'London': convertFromWib(wibTimeStr, 'London (GMT)'),
    };
  }

  // Convert for specific user timezone display
  String formatForUserTimezone(String wibTimeStr, String userTimezone) {
    if (userTimezone.contains('London') || userTimezone.contains('GMT')) {
      return convertFromWib(wibTimeStr, 'London (GMT)');
    } else if (userTimezone.contains('WITA')) {
      return convertFromWib(wibTimeStr, 'WITA');
    }
    return '$wibTimeStr WIB';
  }

  // Standard interactive booking slots
  static const List<Map<String, String>> sessionSlots = [
    {
      'wib': '09:00',
      'period': 'Pagi',
      'icon': '🌅',
    },
    {
      'wib': '11:00',
      'period': 'Siang',
      'icon': '☀️',
    },
    {
      'wib': '13:30',
      'period': 'Siang',
      'icon': '✨',
    },
    {
      'wib': '15:00',
      'period': 'Sore',
      'icon': '🌤️',
    },
    {
      'wib': '16:30',
      'period': 'Sore',
      'icon': '🌇',
    },
    {
      'wib': '19:00',
      'period': 'Malam',
      'icon': '🌙',
    },
    {
      'wib': '20:30',
      'period': 'Malam',
      'icon': '🔮',
    },
  ];

  static List<String> get availableSlotTimesWib =>
      sessionSlots.map((s) => s['wib']!).toList();
}
