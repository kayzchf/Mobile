class TimezoneService {
  static final TimezoneService instance = TimezoneService._init();
  TimezoneService._init();

  // Supported Timezones: WIB (UTC+7), WITA (UTC+8), WIT (UTC+9), London GMT (UTC+0)
  static const List<String> supportedTimezones = ['WIB', 'WITA', 'WIT', 'London (GMT)'];

  static int getUtcOffsetHours(String tz) {
    if (tz.contains('WITA')) return 8;
    if (tz.contains('WIT')) return 9;
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

  // Get formatted time string in user timezone without trailing timezone label
  String convertTimeOnly(String wibTimeStr, String targetTz) {
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
      return '$hourStr:$minStr';
    } catch (_) {
      return wibTimeStr;
    }
  }

  // Convert for specific user timezone display
  String formatForUserTimezone(String wibTimeStr, String userTimezone) {
    return convertFromWib(wibTimeStr, userTimezone);
  }

  // Calculate session time range block (e.g. 21:00 - 22:30 WIB) based on start slot, duration, and session count
  String calculateTimeRange({
    required String startWib,
    required int durationMinutesPerSession,
    required int sessionsCount,
    required String targetTz,
  }) {
    try {
      final parts = startWib.split(':');
      final startHour = int.parse(parts[0]);
      final startMinute = int.parse(parts[1]);

      final totalMinutes = durationMinutesPerSession * sessionsCount;

      final startDateTimeWib = DateTime(2026, 1, 1, startHour, startMinute);
      final endDateTimeWib = startDateTimeWib.add(Duration(minutes: totalMinutes));

      final startEndWibStr = "${endDateTimeWib.hour.toString().padLeft(2, '0')}:${endDateTimeWib.minute.toString().padLeft(2, '0')}";

      final convertedStart = convertTimeOnly(startWib, targetTz);
      final convertedEnd = convertTimeOnly(startEndWibStr, targetTz);

      return "$convertedStart - $convertedEnd $targetTz";
    } catch (_) {
      return "$startWib $targetTz";
    }
  }

  // Get comparative times
  Map<String, String> getAllZoneTimes(String wibTimeStr) {
    return {
      'WIB': '$wibTimeStr WIB',
      'WITA': convertFromWib(wibTimeStr, 'WITA'),
      'WIT': convertFromWib(wibTimeStr, 'WIT'),
      'London': convertFromWib(wibTimeStr, 'London (GMT)'),
    };
  }

  // Night Consultation Slots: 21:00 WIB to 03:00 WIB with 30-min intervals (Per user specification)
  static const List<Map<String, String>> sessionSlots = [
    {'wib': '21:00', 'period': 'Malam', 'icon': '🌙'},
    {'wib': '21:30', 'period': 'Malam', 'icon': '🌙'},
    {'wib': '22:00', 'period': 'Malam', 'icon': '🌌'},
    {'wib': '22:30', 'period': 'Malam', 'icon': '🌌'},
    {'wib': '23:00', 'period': 'Tengah Malam', 'icon': '✨'},
    {'wib': '23:30', 'period': 'Tengah Malam', 'icon': '✨'},
    {'wib': '00:00', 'period': 'Dini Hari', 'icon': '🔮'},
    {'wib': '00:30', 'period': 'Dini Hari', 'icon': '🔮'},
    {'wib': '01:00', 'period': 'Dini Hari', 'icon': '🕯️'},
    {'wib': '01:30', 'period': 'Dini Hari', 'icon': '🕯️'},
    {'wib': '02:00', 'period': 'Dini Hari', 'icon': '🕯️'},
    {'wib': '02:30', 'period': 'Dini Hari', 'icon': '🕯️'},
    {'wib': '03:00', 'period': 'Dini Hari', 'icon': '🕊️'},
  ];

  static List<String> get availableSlotTimesWib =>
      sessionSlots.map((s) => s['wib']!).toList();

  // Instance method: supports (startWib, sessionsCount)
  List<String> getSlotsForSession(String startWib, int sessionsCount) {
    return calculateSlotsForSession(startWib, sessionsCount);
  }

  // Static method: supports (startWib, sessionsCount)
  static List<String> calculateSlotsForSession(String startWib, int sessionsCount) {
    final allSlots = availableSlotTimesWib;
    final startIndex = allSlots.indexOf(startWib);
    if (startIndex == -1) return [startWib];

    final result = <String>[];
    for (int i = 0; i < sessionsCount; i++) {
      final idx = startIndex + i;
      if (idx < allSlots.length) {
        result.add(allSlots[idx]);
      }
    }
    return result;
  }
}
