class UserModel {
  final int? id;
  final String username;
  final String email;
  final String passwordHash;
  final String birthDate;
  final String timezonePref;
  final String avatarUrl;
  final String avatarGender; // 'male' or 'female'
  final bool biometricEnabled;
  final String createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.passwordHash,
    required this.birthDate,
    required this.timezonePref,
    this.avatarUrl = '',
    this.avatarGender = 'male',
    this.biometricEnabled = true,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  String get avatarEmoji => avatarGender == 'female' ? '👩' : '👨';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'password_hash': passwordHash,
      'birth_date': birthDate,
      'timezone_pref': timezonePref,
      'avatar_url': avatarUrl,
      'avatar_gender': avatarGender,
      'biometric_enabled': biometricEnabled ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      email: map['email'] as String,
      passwordHash: map['password_hash'] as String,
      birthDate: map['birth_date'] as String,
      timezonePref: map['timezone_pref'] as String? ?? 'WIB',
      avatarUrl: map['avatar_url'] as String? ?? '',
      avatarGender: map['avatar_gender'] as String? ?? 'male',
      biometricEnabled: (map['biometric_enabled'] as int?) != 0,
      createdAt: map['created_at'] as String?,
    );
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? passwordHash,
    String? birthDate,
    String? timezonePref,
    String? avatarUrl,
    String? avatarGender,
    bool? biometricEnabled,
    String? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      birthDate: birthDate ?? this.birthDate,
      timezonePref: timezonePref ?? this.timezonePref,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarGender: avatarGender ?? this.avatarGender,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Extract zodiac sign from birthDate (YYYY-MM-DD)
  String get zodiacSign {
    try {
      final parts = birthDate.split('-');
      if (parts.length >= 3) {
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries ♈';
        if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus ♉';
        if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini ♊';
        if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer ♋';
        if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo ♌';
        if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo ♍';
        if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra ♎';
        if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio ♏';
        if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius ♐';
        if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn ♑';
        if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius ♒';
        return 'Pisces ♓';
      }
    } catch (_) {}
    return 'Mystic Soul ✨';
  }
}
