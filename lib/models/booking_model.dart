class TarotService {
  final int id;
  final String title;
  final int durationMinutes;
  final int priceIdr;
  final double priceUsd;
  final double priceGbp;
  final String description;
  final String iconSymbol;

  const TarotService({
    required this.id,
    required this.title,
    required this.durationMinutes,
    required this.priceIdr,
    required this.priceUsd,
    required this.priceGbp,
    required this.description,
    required this.iconSymbol,
  });

  static const List<TarotService> defaultServices = [
    TarotService(
      id: 1,
      title: "Love Reading",
      durationMinutes: 30,
      priceIdr: 175000,
      priceUsd: 11.20,
      priceGbp: 8.90,
      description: "Bedah santai dinamika asmara kamu dan dia, rahasia hati pasangan, potensi jodoh, serta tips melewati masa ragu.",
      iconSymbol: "💖",
    ),
    TarotService(
      id: 2,
      title: "Career & Finance Reading",
      durationMinutes: 30,
      priceIdr: 150000,
      priceUsd: 9.60,
      priceGbp: 7.60,
      description: "Yuk intip arah karir impianmu, kelancaran bisnis, momentum cuan, serta peluang rezeki yang lagi terbuka lebar.",
      iconSymbol: "🔮",
    ),
    TarotService(
      id: 3,
      title: "General Reading",
      durationMinutes: 30,
      priceIdr: 150000,
      priceUsd: 9.60,
      priceGbp: 7.60,
      description: "Obrolan santai tentang energi hidup kamu saat ini, hal-hal yang perlu kamu lepaskan, dan pesan baik dari semesta.",
      iconSymbol: "✨",
    ),
    TarotService(
      id: 4,
      title: "Full Life Reading",
      durationMinutes: 60,
      priceIdr: 300000,
      priceUsd: 19.20,
      priceGbp: 15.20,
      description: "Sesi komprehensif 60 menit kupas tuntas seluruh aspek hidup: cinta, rezeki, ketenangan batin, hingga peta takdir masa depan.",
      iconSymbol: "👑",
    ),
  ];
}

class BookingModel {
  final String id;
  final int userId;
  final int serviceId;
  final String serviceTitle;
  final int durationMinutes;
  final int sessionsCount;
  final String sessionDate;
  final String sessionTimeWib;
  final String userTimezone;
  final double totalPrice;
  final String currencyUsed;
  final String paymentStatus; // 'PENDING_PAYMENT', 'CONFIRMED', 'COMPLETED'
  final String qrisReference;
  final int reminderMinutes; // 5 or 10 minutes
  final bool reminderNotified;
  final String createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.serviceId,
    required this.serviceTitle,
    required this.durationMinutes,
    required this.sessionsCount,
    required this.sessionDate,
    required this.sessionTimeWib,
    required this.userTimezone,
    required this.totalPrice,
    required this.currencyUsed,
    this.paymentStatus = 'PENDING_PAYMENT',
    required this.qrisReference,
    this.reminderMinutes = 10,
    this.reminderNotified = false,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'service_id': serviceId,
      'service_title': serviceTitle,
      'duration_minutes': durationMinutes,
      'sessions_count': sessionsCount,
      'session_date': sessionDate,
      'session_time_wib': sessionTimeWib,
      'user_timezone': userTimezone,
      'total_price': totalPrice,
      'currency_used': currencyUsed,
      'payment_status': paymentStatus,
      'qris_reference': qrisReference,
      'reminder_minutes': reminderMinutes,
      'reminder_notified': reminderNotified ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    return BookingModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      serviceId: map['service_id'] as int,
      serviceTitle: map['service_title'] as String,
      durationMinutes: map['duration_minutes'] as int,
      sessionsCount: map['sessions_count'] as int,
      sessionDate: map['session_date'] as String,
      sessionTimeWib: map['session_time_wib'] as String,
      userTimezone: map['user_timezone'] as String? ?? 'WIB',
      totalPrice: (map['total_price'] as num).toDouble(),
      currencyUsed: map['currency_used'] as String? ?? 'IDR',
      paymentStatus: map['payment_status'] as String? ?? 'PENDING_PAYMENT',
      qrisReference: map['qris_reference'] as String? ?? '',
      reminderMinutes: map['reminder_minutes'] as int? ?? 10,
      reminderNotified: (map['reminder_notified'] as int?) == 1,
      createdAt: map['created_at'] as String?,
    );
  }

  BookingModel copyWith({
    String? id,
    int? userId,
    int? serviceId,
    String? serviceTitle,
    int? durationMinutes,
    int? sessionsCount,
    String? sessionDate,
    String? sessionTimeWib,
    String? userTimezone,
    double? totalPrice,
    String? currencyUsed,
    String? paymentStatus,
    String? qrisReference,
    int? reminderMinutes,
    bool? reminderNotified,
    String? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      serviceId: serviceId ?? this.serviceId,
      serviceTitle: serviceTitle ?? this.serviceTitle,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      sessionDate: sessionDate ?? this.sessionDate,
      sessionTimeWib: sessionTimeWib ?? this.sessionTimeWib,
      userTimezone: userTimezone ?? this.userTimezone,
      totalPrice: totalPrice ?? this.totalPrice,
      currencyUsed: currencyUsed ?? this.currencyUsed,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      qrisReference: qrisReference ?? this.qrisReference,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      reminderNotified: reminderNotified ?? this.reminderNotified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
