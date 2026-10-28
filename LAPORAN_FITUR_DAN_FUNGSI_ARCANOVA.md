# 📑 LAPORAN ANALISIS TEKNIS KODE & FITUR APLIKASI ARCANOVA
**Mata Kuliah:** Pemrograman Aplikasi Mobile (PAM)  
**Teknologi:** Flutter (Dart), SQLite (Local DB), PostgreSQL (Cloud DB), REST API, Hardware Sensors (Gyroscope & GPS), Cryptographic Blockchain (SHA-256), AI NLP Engine.

---

## DAFTAR ISI
1. [Arsitektur & Struktur Direktori](#1-arsitektur--struktur-direktori)
2. [Modul Autentikasi & Keamanan Sesi](#2-modul-autentikasi--keamanan-sesi)
3. [Modul Database Lokal (SQLite) & Cloud (PostgreSQL)](#3-modul-database-lokal-sqlite--cloud-postgresql)
4. [Modul Multi-Timezone & Konversi Mata Uang Otomatis](#4-modul-multi-timezone--konversi-mata-uang-otomatis)
5. [Modul Pemesanan & Auto-Blocking Multi-Slot Jadwal](#5-modul-pemesanan--auto-blocking-multi-slot-jadwal)
6. [Modul Live Chat Real-Time & POV Tarot Reader (Dua Role)](#6-modul-live-chat-real-time--pov-tarot-reader-dua-role)
7. [Modul AI Chat Curhat Batin & Contextual NLP](#7-modul-ai-chat-curhat-batin--contextual-nlp)
8. [Modul Fitur Blockchain "The Destiny Chain"](#8-modul-fitur-blockchain-the-destiny-chain)
9. [Modul Sensor Perangkat Keras (Gyroscope 3D & GPS Sanctuary)](#9-modul-sensor-perangkat-keras-gyroscope-3d--gps-sanctuary)
10. [Modul Kesan & Saran Kuliah (Sinkronisasi Cloud)](#10-modul-kesan--saran-kuliah-sinkronisasi-cloud)

---

## 1. Arsitektur & Struktur Direktori

Aplikasi ARCANOVA dibangun dengan arsitektur modular yang memisahkan model data (`models/`), logika bisnis & akses data (`services/`), antarmuka pengguna (`views/`), serta konstanta desain (`constants/`):

```
lib/
├── constants/
│   ├── app_colors.dart         # Palet warna tema Cyber-Mystic
│   └── tarot_data.dart         # Master dataset 22 kartu Major Arcana
├── models/
│   ├── user_model.dart         # Struktur data pengguna & reader
│   ├── booking_model.dart      # Struktur data pemesanan sesi konsultasi
│   ├── tarot_card.dart         # Model kartu tarot & interpretasi kosmis
│   ├── blockchain_block.dart   # Model blok kriptografi transaksi
│   └── feedback_model.dart     # Model kesan dan saran mata kuliah
├── services/
│   ├── auth_service.dart       # Autentikasi, enkripsi SHA-256, session listener
│   ├── biometric_service.dart  # Otentikasi sensor sidik jari (Fingerprint)
│   ├── db_helper.dart          # Local database SQLite & relasi query
│   ├── online_cloud_service.dart # Cloud PostgreSQL (pgAdmin laptop) & REST fallback
│   ├── timezone_service.dart   # Konversi waktu WIB, WITA, London & slotting
│   ├── currency_service.dart   # Konversi dinamis IDR, USD, GBP
│   ├── ai_service.dart         # Mesin NLP AI Madame Arcanova & filter ruang lingkup
│   ├── sensor_service.dart     # Stream Gyroscope / Accelerometer
│   ├── location_service.dart   # GPS Geolocation & reverse geocoding kota/provinsi
│   ├── blockchain_service.dart # Proof-of-Work SHA-256 mining & integrity validator
│   └── notification_service.dart # Pengingat notifikasi lokal sesi konsultasi
└── views/
    ├── main_navigation.dart    # Bottom navigation (5 tab utama) & auto-logout 5 menit
    ├── auth/                   # Layanan login (klien & reader jadi satu) & register
    ├── home/                   # 3D Gyroscope Tarot Deck & Kartu Harian
    ├── booking/                # Layanan, Booking multi-sesi, QRIS, & The Destiny Chain
    ├── live_chat/              # WhatsApp-style chat room synced PostgreSQL
    ├── reader_portal/          # Dashboard eksklusif POV Tarot Reader
    ├── ai_chat/                # Interactive curhat chat dengan AI Arcanova
    ├── games/                  # Ramalan cinta dinamis & Sanctuary GPS Maps
    ├── profile/                # Edit profil, zona waktu, biometric switch, ledger
    └── feedback/               # Form kesan dan saran mahasiswa
```

---

## 2. Modul Autentikasi & Keamanan Sesi

### 2.1 Enkripsi Password (SHA-256 + Salt)
* **File:** `lib/services/auth_service.dart`
* **Fungsi:** `hashPassword(String password)`
* **Penjelasan:** Mengamankan kata sandi pengguna sebelum disimpan ke database menggunakan algoritma *hash* satu arah SHA-256 yang digabungkan dengan nilai unik (*salt* rahasia), sehingga kata sandi tidak dapat didekripsi bahkan jika database diakses langsung.

```dart
// Lokasi: lib/services/auth_service.dart (Baris 23-28)
static const String _salt = "ARCANOVA_COSMIC_SALT_9999_MYSTIC";

String hashPassword(String password) {
  final salted = '$password:$_salt';
  final bytes = utf8.encode(salted);
  return sha256.convert(bytes).toString();
}
```

---

### 2.2 Autentikasi Sidik Jari (Biometric Fingerprint)
* **File:** `lib/services/biometric_service.dart`
* **Fungsi:** `authenticateWithFingerprint()`
* **Penjelasan:** Memanfaatkan sensor biometrik perangkat keras ponsel melalui pustaka `local_auth`. Memverifikasi apakah sensor biometrik tersedia dan memicu dialog sidik jari bawaan OS Android.

```dart
// Lokasi: lib/services/biometric_service.dart (Baris 25-45)
Future<Map<String, dynamic>> authenticateWithFingerprint() async {
  try {
    final isAvailable = await isBiometricAvailable();
    if (!isAvailable) {
      return {'success': false, 'message': 'Sensor sidik jari tidak ditemukan pada perangkat ini.'};
    }

    final authenticated = await _auth.authenticate(
      localizedReason: 'Pindai sidik jari Anda untuk masuk ke portal takdir Arcanova',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    return {'success': authenticated};
  } catch (e) {
    return {'success': false, 'message': 'Autentikasi sidik jari gagal: $e'};
  }
}
```

---

### 2.3 Deteksi Sesi 5 Menit di Luar Aplikasi (Auto Logout)
* **File:** `lib/views/main_navigation.dart`
* **Fungsi:** `didChangeAppLifecycleState(AppLifecycleState state)`
* **Penjelasan:** Memantau siklus hidup aplikasi (*lifecycle*). Jika pengguna keluar/meminimalkan aplikasi lebih dari 5 menit (300 detik) dan membuka kembali, sistem secara otomatis mengembalikan akun ke *Mode Tamu* demi menjaga kerahasiaan data pribadi.

```dart
// Lokasi: lib/views/main_navigation.dart (Baris 42-67)
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
    _backgroundTimestamp = DateTime.now();
  } else if (state == AppLifecycleState.resumed) {
    if (_backgroundTimestamp != null) {
      final elapsed = DateTime.now().difference(_backgroundTimestamp!);
      // Jika lebih dari 5 menit (300 detik) di background, otomatis logout
      if (elapsed.inSeconds >= 300 && AuthService.instance.isAuthenticated) {
        AuthService.instance.enterGuestMode();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.neonPurple,
              content: Text("⏳ Sesi kamu telah berakhir (lebih dari 5 menit di luar aplikasi). Akun otomatis logout ke Mode Tamu untuk keamanan."),
            ),
          );
        }
      }
    }
    _backgroundTimestamp = null;
  }
}
```

---

### 2.4 Login Satu Pintu (Deteksi Otomatis Role Reader vs Klien)
* **File:** `lib/views/auth/login_screen.dart`
* **Fungsi:** `_handleLogin()`
* **Penjelasan:** Tidak ada tombol khusus reader di UI. Pengguna dan Tarot Reader resmi (`arcreader` / `readernz`) masuk melalui formulir login yang sama. Sistem mengecek status `user.isReader`, jika reader maka langsung diarahkan ke `TarotReaderPortalScreen()`.

```dart
// Lokasi: lib/views/auth/login_screen.dart (Baris 65-85)
if (res['success'] == true) {
  final user = AuthService.instance.currentUser;
  if (user?.isReader == true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const TarotReaderPortalScreen()),
    );
  } else {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }
}
```

---

## 3. Modul Database Lokal (SQLite) & Cloud (PostgreSQL)

### 3.1 Inisialisasi Database Lokal SQLite & Auto-Seed Reader
* **File:** `lib/services/db_helper.dart`
* **Fungsi:** `_initDB()` & `_ensureReaderAccount()`
* **Penjelasan:** Membuka database lokal SQLite `arcanova_master_v4.db`. Menggunakan callback `onOpen` untuk menjamin akun Tarot Reader (`arcreader`) selalu terdaftar secara otomatis di sistem lokal tanpa resiko deadlock.

```dart
// Lokasi: lib/services/db_helper.dart (Baris 36-46 & 165-195)
Future<Database> _initDB(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);

  return await openDatabase(
    path,
    version: 1,
    onCreate: _createDB,
    onOpen: (db) async {
      await _ensureReaderAccount(db);
    },
  );
}
```

---

### 3.2 Koneksi Cloud PostgreSQL (Laptop pgAdmin) dengan Auto-Detect IP
* **File:** `lib/services/online_cloud_service.dart`
* **Fungsi:** `_getConnection()` & `_tryConnectHost()`
* **Penjelasan:** Menghubungkan aplikasi Flutter langsung ke database online PostgreSQL di laptop pengguna (`pgAdmin`) dengan kredensial `postgres:kaylaneza`. Dilengkapi auto-deteksi: host `10.0.2.2` untuk Android Emulator dan `127.0.0.1` untuk HP fisik yang dihubungkan kabel USB via `adb reverse`.

```dart
// Lokasi: lib/services/online_cloud_service.dart (Baris 14-26 & 36-67)
static const String pgUser = "postgres";
static const String pgPassword = "kaylaneza";
static const String pgDatabase = "arcanova_db";
static const int pgPort = 5432;

static final List<String> candidateHosts = [
  '10.0.2.2',   // Android Emulator
  '127.0.0.1',  // HP Fisik via ADB Reverse
  'localhost',
];

Future<Connection?> _getConnection() async {
  for (final host in candidateHosts) {
    try {
      Connection? conn = await _tryConnectHost(host, pgDatabase);
      if (conn != null) {
        _activeHost = host;
        isPostgresConnected = true;
        await _initDatabaseTables(conn);
        return conn;
      }
    } catch (_) {}
  }
  return null;
}
```

---

### 3.3 Sinkronisasi Pemesanan ke Cloud Database
* **File:** `lib/services/online_cloud_service.dart`
* **Fungsi:** `syncBookingToCloud(BookingModel booking)`
* **Penjelasan:** Mengirim data pemesanan yang telah dikonfirmasi ke tabel `cloud_bookings` di PostgreSQL laptop secara terstruktur menggunakan SQL parameter (@id, @uid, dll).

```dart
// Lokasi: lib/services/online_cloud_service.dart (Baris 250-275)
Future<bool> syncBookingToCloud(BookingModel booking) async {
  Connection? conn = await _getConnection();
  if (conn != null) {
    await conn.execute(
      Sql.named(
        'INSERT INTO cloud_bookings (booking_id, user_id, service_title, session_date, session_time, sessions_count, total_price, currency, payment_status) '
        'VALUES (@id, @uid, @service, @date, @time, @count, @price, @currency, @status) '
        'ON CONFLICT (booking_id) DO UPDATE SET payment_status = @status',
      ),
      parameters: {
        'id': booking.id,
        'uid': booking.userId,
        'service': booking.serviceTitle,
        'date': booking.sessionDate,
        'time': booking.sessionTimeWib,
        'count': booking.sessionsCount,
        'price': booking.totalPrice,
        'currency': booking.currencyUsed,
        'status': booking.paymentStatus,
      },
    );
    await conn.close();
    return true;
  }
  return false;
}
```

---

## 4. Modul Multi-Timezone & Konversi Mata Uang Otomatis

### 4.1 Konversi Zona Waktu Otomatis (WIB, WITA, London GMT)
* **File:** `lib/services/timezone_service.dart`
* **Fungsi:** `convertFromWib(String wibTimeStr, String targetTz)`
* **Penjelasan:** Jadwal master sesi tarot berpusat di WIB (21:00 - 03:00 WIB). Fungsi ini secara matematis menghitung perbedaan selisih UTC (+7 WIB, +8 WITA, +0 London GMT) sehingga jam konsultasi otomatis berubah sesuai zona domisili pengguna tanpa menampilkan zona yang tidak relevan (seperti WIT).

```dart
// Lokasi: lib/services/timezone_service.dart (Baris 16-35)
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
```

---

### 4.2 Sinkronisasi Mata Uang Berdasarkan Zona Waktu Profil
* **File:** `lib/services/currency_service.dart`
* **Fungsi:** `syncWithTimezone(String timezone, {CurrencyType? preferredInternationalCurrency})`
* **Penjelasan:** Mengikuti aturan bisnis aplikasi: Pengguna dengan zona waktu WIB atau WITA otomatis dikenakan Rupiah (IDR). Jika pengguna berzona waktu London (GMT), sistem mengaktifkan mata uang internasional (USD atau GBP) dan mengubah tampilan harga katalog secara otomatis.

```dart
// Lokasi: lib/services/currency_service.dart (Baris 48-60)
void syncWithTimezone(String timezone, {CurrencyType preferredInternationalCurrency = CurrencyType.usd}) {
  if (timezone == 'London (GMT)') {
    _activeCurrency = preferredInternationalCurrency;
  } else {
    // WIB & WITA selalu default Rupiah (IDR)
    _activeCurrency = CurrencyType.idr;
  }
  notifyListeners();
}
```

---

## 5. Modul Pemesanan & Auto-Blocking Multi-Slot Jadwal

### 5.1 Perhitungan Rangkaian Slot Sesi Berturut-turut
* **File:** `lib/services/timezone_service.dart`
* **Fungsi:** `getSlotsForSession(String startWib, int sessionsCount)`
* **Penjelasan:** Menghitung deretan jam slot 30 menit yang terpakai jika user memesan lebih dari 1 sesi. Contoh: Jika user memilih 3 sesi mulai jam 21:00, fungsi mengembalikan `['21:00', '21:30', '22:00']`.

```dart
// Lokasi: lib/services/timezone_service.dart (Baris 123-140)
List<String> getSlotsForSession(String startWib, int sessionsCount) {
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
```

---

### 5.2 Pencegahan Redundansi Jadwal (Multi-Slot Query Lokal & Cloud)
* **File:** `lib/services/db_helper.dart`
* **Fungsi:** `getBookedTimes(String date)`
* **Penjelasan:** Mengambil semua slot yang sudah terisi pada tanggal tertentu dengan memperhitungkan `sessions_count` dari setiap booking yang tersimpan di SQLite lokal maupun tabel PostgreSQL online. Semua jam yang masuk dalam rentang pemesanan ditandai sebagai `occupied` agar tidak dapat dipesan ulang oleh pengguna lain.

```dart
// Lokasi: lib/services/db_helper.dart (Baris 305-334)
Future<List<String>> getBookedTimes(String date) async {
  final Set<String> occupied = {};
  final db = await database;
  if (db != null) {
    final maps = await db.query(
      'bookings',
      columns: ['session_time_wib', 'sessions_count'],
      where: 'session_date = ? AND payment_status != ?',
      whereArgs: [date, 'CANCELLED'],
    );
    for (final row in maps) {
      final start = row['session_time_wib'] as String;
      final count = (row['sessions_count'] as int?) ?? 1;
      final slots = TimezoneService.instance.getSlotsForSession(start, count);
      occupied.addAll(slots);
    }
  }

  // Menggabungkan slot terpesan dari Cloud PostgreSQL
  final cloudSlots = await OnlineCloudService.instance.fetchBookedSlotsForDate(date);
  for (final slot in cloudSlots) {
    occupied.addAll(TimezoneService.instance.getSlotsForSession(slot, 1));
  }
  return occupied.toList();
}
```

---

### 5.3 Tampilan Interaktif Pemilihan Slot & Peringatan Bentrok di UI
* **File:** `lib/views/booking/services_screen.dart`
* **Widget:** `_BookingModalState`
* **Penjelasan:** Saat user memilih jumlah sesi (misal 3 sesi), sistem secara visual langsung memblokir jam-jam selanjutnya dengan label `Sesi 1/3`, `Sesi 2/3`, `Sesi 3/3`. Jika slot awal akan menabrak jam yang sudah dipesan orang lain, kartu jam tersebut otomatis dinonaktifkan dengan status `Bentrok` atau `Penuh`.

```dart
// Lokasi: lib/views/booking/services_screen.dart (Baris 740-805)
final prospectiveChain = TimezoneService.instance.getSlotsForSession(slotWib, _sessionsCount);
final hasConflict = prospectiveChain.length < _sessionsCount ||
    prospectiveChain.any((s) => _bookedSlots.contains(s));

final isPartOfSelected = selectedCoveredSlots.contains(slotWib);
final sessionIndex = isPartOfSelected ? (selectedCoveredSlots.indexOf(slotWib) + 1) : 0;
final bool isDisabled = isBooked || (hasConflict && !isPartOfSelected);

// UI Card menampilkan status:
Text(
  isBooked
      ? "Penuh"
      : isPartOfSelected
          ? "Sesi $sessionIndex/$_sessionsCount"
          : hasConflict
              ? "Bentrok"
              : period,
)
```

---

## 6. Modul Live Chat Real-Time & POV Tarot Reader (Dua Role)

### 6.1 Sinkronisasi Chat Real-Time Dua Perangkat (HP Fisik $\leftrightarrow$ Emulator)
* **File:** `lib/services/online_cloud_service.dart`
* **Fungsi:** `sendLiveChatMessage()` & `fetchLiveChatMessages()`
* **Penjelasan:** Memfasilitasi chatting antar perangkat (misal Klien di Android Emulator dan Tarot Reader di HP Fisik). Setiap pesan yang dikirim dimasukkan ke tabel `cloud_live_reader_chats` di PostgreSQL laptop, dan diambil oleh perangkat penerima secara otomatis.

```dart
// Lokasi: lib/services/online_cloud_service.dart (Baris 280-335)
Future<bool> sendLiveChatMessage({
  required String bookingId,
  required String sender,
  required String message,
  required String sessionDate,
}) async {
  Connection? conn = await _getConnection();
  if (conn != null) {
    await conn.execute(
      Sql.named(
        'INSERT INTO cloud_live_reader_chats (booking_id, sender, message, session_date) '
        'VALUES (@bid, @sender, @msg, @sdate)',
      ),
      parameters: {'bid': bookingId, 'sender': sender, 'msg': message, 'sdate': sessionDate},
    );
    await conn.close();
    return true;
  }
  return false;
}
```

---

### 6.2 Polling Otomatis 2 Detik & Direct Bubble Chat
* **File:** `lib/views/live_chat/reader_chat_screen.dart`
* **Fungsi:** `_loadChatHistory()` & `Timer.periodic`
* **Penjelasan:** Roomchat menjalankan timer periodik setiap 2 detik untuk memeriksa pesan baru dari database PostgreSQL. Posisi bubble chat kanan/kiri beradaptasi secara dinamis tergantung siapa yang membuka layar (Klien vs Reader).

```dart
// Lokasi: lib/views/live_chat/reader_chat_screen.dart (Baris 445-470)
@override
void initState() {
  super.initState();
  _loadChatHistory();
  // Sinkronisasi otomatis setiap 2 detik via PostgreSQL
  _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
    if (mounted) {
      _loadChatHistory(silent: true);
    }
  });
}
```

---

### 6.3 Tombol Floating Chat Klien Hanya Aktif Saat Reader Mulai Duluan
* **File:** `lib/views/booking/services_screen.dart` & `lib/services/db_helper.dart`
* **Fungsi:** `isChatInitiatedByReader(String bookingId)`
* **Penjelasan:** Memenuhi syarat tugas: Tombol floating chat di sisi pelanggan **hanya muncul** jika pengguna sudah memesan sesi dan **Tarot Reader telah mengirim pesan pembuka terlebih dahulu**. Saat diklik, klien langsung dibawa masuk ke ruang obrolan (*direct bubble chat* tanpa daftar sesi).

```dart
// Lokasi: lib/services/db_helper.dart (Baris 380-395)
Future<bool> isChatInitiatedByReader(String bookingId) async {
  await syncCloudChats(bookingId);
  final db = await database;
  if (db != null) {
    final maps = await db.query(
      'live_reader_chats',
      where: 'booking_id = ? AND sender = ?',
      whereArgs: [bookingId, 'reader'],
      limit: 1,
    );
    if (maps.isNotEmpty) return true;
  }
  return false;
}
```

---

### 6.4 Kebijakan Retensi Chat H+3 (Otomatis Dihapus)
* **File:** `lib/services/db_helper.dart`
* **Fungsi:** `cleanupExpiredChatsH3()`
* **Penjelasan:** Sesuai permintaan spesifikasi privasi mistis Arcanova, seluruh riwayat percakapan yang berusia lebih dari 3 hari (H+3) dari tanggal sesi akan dihapus secara otomatis dari database.

```dart
// Lokasi: lib/services/db_helper.dart (Baris 410-425)
Future<int> cleanupExpiredChatsH3() async {
  final db = await database;
  if (db == null) return 0;

  final cutoffDate = DateTime.now().subtract(const Duration(days: 3));
  final cutoffStr = "${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}";

  return await db.delete(
    'live_reader_chats',
    where: 'session_date < ?',
    whereArgs: [cutoffStr],
  );
}
```

---

## 7. Modul AI Chat Curhat Batin & Contextual NLP

### 7.1 Filter Batasan Ruang Lingkup Topik Kehidupan
* **File:** `lib/services/ai_service.dart`
* **Fungsi:** `_isWithinLifeTarotScope(String text)`
* **Penjelasan:** Membatasi topik obrolan AI Madame Arcanova khusus pada masalah kehidupan nyata (asmara, karir, perkuliahan, ketenangan batin, tarot). Jika user menanyakan hal di luar cakupan (misal rumus kalkulus, coding, politik, skor bola), AI dengan sopan menolak.

```dart
// Lokasi: lib/services/ai_service.dart (Baris 61-78)
bool _isWithinLifeTarotScope(String text) {
  final lower = text.toLowerCase();
  final outOfScopeKeywords = [
    'coding', 'flutter', 'javascript', 'python', 'java ', 'sql ',
    'kalkulator', 'hitung rumus', 'turunan integral', 'aljabar',
    'pemilu', 'partai politik', 'presiden ri', 'dpr', 'skor bola',
    'resep masakan', 'spesifikasi laptop', 'service ac',
  ];

  for (final bad in outOfScopeKeywords) {
    if (lower.contains(bad)) return false;
  }
  return true;
}
```

---

### 7.2 Mesin NLP Empatik Gaya Teman Curhat (Bahasa Mengalir)
* **File:** `lib/services/ai_service.dart`
* **Fungsi:** `_generateDeepContextualResponse(...)`
* **Penjelasan:** Menghasilkan tanggapan yang hangat, suportif, dan tidak kaku (seperti sahabat akrab yang mendengarkan curhatan). Menganalisis kata kunci emosi pengguna (misal: *capek*, *skripsi*, *gebetan*, *ragu*) dan mengalirkan kalimat penenang jiwa.

```dart
// Lokasi: lib/services/ai_service.dart (Baris 140-165)
if (lower.contains('kuliah') || lower.contains('tugas') || lower.contains('skripsi')) {
  return "Aduh, aku paham banget rasanya... Kuliah dan rentetan tugas yang nggak ada habisnya emang sering bikin kepala penat dan energi habis. Apalagi kalau ada ekspektasi tinggi yang bikin kamu ngerasa harus serba bisa.\n\n"
      "Tapi inget ya, kamu itu manusia biasa yang butuh jeda istirahat. Nggak apa-apa banget kalau hari ini kamu ngerasa lelah atau belum selesai semuanya. "
      "Coba istirahat sejenak, minum air hangat, atau dengar musik yang tenang. Ada bagian tugas tertentu yang paling bikin kamu pusing sekarang?";
}
```

---

## 8. Modul Fitur Blockchain "The Destiny Chain"

### 8.1 Proof-of-Work Mining & Hash Kriptografi SHA-256
* **File:** `lib/services/blockchain_service.dart`
* **Fungsi:** `mineBlock(int index, Map<String, dynamic> sessionData, String previousHash)`
* **Penjelasan:** Mengimplementasikan teknologi blockchain nyata di dalam aplikasi. Setiap sesi konsultasi ditambang (*mining*) dengan mencari nilai `nonce` yang menghasilkan hash SHA-256 dengan tingkat kesulitan tertentu (*difficulty target prefix* `00`).

```dart
// Lokasi: lib/services/blockchain_service.dart (Baris 24-48)
BlockchainBlock mineBlock({
  required int index,
  required Map<String, dynamic> sessionData,
  required String previousHash,
}) {
  int nonce = 0;
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  String hash = "";

  while (true) {
    final raw = '$index:$previousHash:$timestamp:${jsonEncode(sessionData)}:$nonce';
    hash = sha256.convert(utf8.encode(raw)).toString();
    if (hash.startsWith(difficultyPrefix)) {
      break;
    }
    nonce++;
  }

  return BlockchainBlock(
    index: index,
    timestamp: timestamp,
    sessionData: sessionData,
    previousHash: previousHash,
    nonce: nonce,
    hash: hash,
  );
}
```

---

### 8.2 Tampilan "The Destiny Chain" (Rantai Digital Bercahaya & Salin Kunci)
* **File:** `lib/views/booking/order_history_screen.dart`
* **Widget:** `_OrderHistoryScreenState`
* **Penjelasan:** Sesuai cetak biru *The Destiny Chain*, kartu riwayat dihubungkan oleh garis vertikal bercahaya toska di sisi kiri. Kartu dilengkapi badge `🔒 Terverifikasi Blockchain`. Saat kartu di-tap, detail nomor blok kriptografi dan Transaction Hash muncul bersama tombol **Salin Kunci Validasi** (*copy to clipboard*).

```dart
// Lokasi: lib/views/booking/order_history_screen.dart (Baris 85-130 & 200-240)
// 1. Elemen Penghubung Garis Bercahaya
Container(
  width: 26,
  height: 26,
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(color: AppColors.celestialCyan, width: 2),
    boxShadow: [BoxShadow(color: AppColors.celestialCyan.withValues(alpha: 0.4), blurRadius: 8)],
  ),
  child: const Center(child: Icon(Icons.link, size: 13, color: AppColors.celestialCyan)),
),

// 2. Tombol Salin Kunci Validasi
TextButton.icon(
  onPressed: () {
    Clipboard.setData(ClipboardData(text: blockData['fullHash']!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.successEmerald,
        content: Text("✨ Kunci Validasi Blockchain Tersalin!"),
      ),
    );
  },
  icon: const Icon(Icons.copy, size: 13, color: AppColors.celestialCyan),
  label: const Text("Salin Kunci"),
)
```

---

## 9. Modul Sensor Perangkat Keras (Gyroscope 3D & GPS Sanctuary)

### 9.1 Sensor Gerak Gyroscope 3D Tilt Kartu Tarot
* **File:** `lib/services/sensor_service.dart` & `lib/views/home/home_screen.dart`
* **Fungsi:** `gyroscopeEventStream()` & `Transform`
* **Penjelasan:** Menangkap kemiringan fisik HP (pitch dan roll) menggunakan sensor Gyroscope. Nilai derajat tilt dimasukkan ke matriks `Transform` kartu tarot pada layar beranda, menciptakan efek paralaks 3D holografik kartu mistis yang bergerak dinamis mengikuti gerakan tangan pengguna.

```dart
// Lokasi: lib/views/home/home_screen.dart (Baris 65-80 & 460-485)
_gyroscopeSubscription = SensorService.instance.gyroscopeStream.listen((event) {
  if (mounted) {
    setState(() {
      _tiltPitch = (_tiltPitch + event.y * 0.04).clamp(-0.25, 0.25);
      _tiltRoll = (_tiltRoll - event.x * 0.04).clamp(-0.25, 0.25);
    });
  }
});

// Penerapan Efek 3D Transform
Transform(
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.001) // Efek perspektif kedalaman 3D
    ..rotateX(_tiltPitch)
    ..rotateY(_tiltRoll),
  child: TarotCardWidget(card: card),
)
```

---

### 9.2 Sensor Lokasi GPS & Reverse Geocoding (Deteksi Kota/Provinsi)
* **File:** `lib/services/location_service.dart` & `lib/views/games/mystic_hub_screen.dart`
* **Fungsi:** `getCurrentLocationWithAddress()`
* **Penjelasan:** Meminta koordinat lintang & bujur dari sensor GPS ponsel via `geolocator`. Menggunakan *reverse geocoding* via `geocoding` untuk mendeteksi nama kota dan provinsi pengguna saat ini (contoh: "Semarang, Jawa Tengah") serta menghitung jarak meter ke koordinat kuil Arcanova Sanctuary.

```dart
// Lokasi: lib/services/location_service.dart (Baris 20-55)
Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
  final position = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  List<Placemark> placemarks = await placemarkFromCoordinates(
    position.latitude,
    position.longitude,
  );

  String cityName = "Semarang";
  String provinceName = "Jawa Tengah";

  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    cityName = place.subAdministrativeArea ?? place.locality ?? "Semarang";
    provinceName = place.administrativeArea ?? "Jawa Tengah";
  }

  final distanceMeters = Geolocator.distanceBetween(
    position.latitude,
    position.longitude,
    sanctuaryLatitude,
    sanctuaryLongitude,
  );

  return {
    'latitude': position.latitude,
    'longitude': position.longitude,
    'city': cityName,
    'province': provinceName,
    'distanceKm': (distanceMeters / 1000).toStringAsFixed(1),
  };
}
```

---

## 10. Modul Kesan & Saran Kuliah (Sinkronisasi Cloud)

### 10.1 Penyimpanan Kesan & Saran Mahasiswa (SQLite + PostgreSQL Cloud)
* **File:** `lib/views/feedback/course_feedback_screen.dart`
* **Fungsi:** `_handleSubmitFeedback()`
* **Penjelasan:** Menyimpan testimoni kesan, saran, nama, NIM, dan rating bintang mahasiswa ke tabel lokal SQLite `course_feedback`, serta secara simultan mengirim data ke tabel online `cloud_course_feedback` di PostgreSQL laptop.

```dart
// Lokasi: lib/views/feedback/course_feedback_screen.dart (Baris 80-110)
final feedback = CourseFeedbackModel(
  userId: user?.id,
  studentName: _nameController.text.trim(),
  nim: _nimController.text.trim(),
  kesan: _kesanController.text.trim(),
  saran: _saranController.text.trim(),
  ratingStars: _ratingStars,
  submittedAt: DateTime.now().toIso8601String(),
);

// 1. Simpan ke SQLite lokal
await DatabaseHelper.instance.insertFeedback(feedback);

// 2. Sinkronisasi ke PostgreSQL Laptop (pgAdmin)
OnlineCloudService.instance.syncFeedbackToCloud(feedback);
```

---

## Ringkasan Pemetaan Kriteria Penilaian Ujian

| Kriteria Tugas | Implementasi di ARCANOVA | File & Baris Kode |
| :--- | :--- | :--- |
| **State Management & Navigasi** | `ChangeNotifier` (`AuthService`, `CurrencyService`), 5 Tab Navigation, BottomSheet, TabController | [`main_navigation.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/main_navigation.dart) |
| **Penyimpanan Lokal** | SQLite database `arcanova_master_v4.db` (tabel users, bookings, chats, ledger, cards, feedback) | [`db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart) |
| **Penyimpanan Online / Cloud** | PostgreSQL laptop `arcanova_db` (kredensial `kaylaneza`), auto-detect IP emulator/fisik | [`online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart) |
| **Sensor Hardware** | Gyroscope 3D Tilt Card Parallax (`sensors_plus`) & GPS Lokasi Kuil + Kota/Provinsi (`geolocator`) | [`sensor_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/sensor_service.dart) & [`location_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/location_service.dart) |
| **Fitur Autentikasi** | Register Gender Avatar, SHA-256 + Salt hashing, Biometric Fingerprint, Session Auto Logout 5 Menit | [`auth_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/auth_service.dart) & [`biometric_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/biometric_service.dart) |
| **Multi-Timezone & Konversi** | Auto convert WIB $\rightarrow$ WITA $\rightarrow$ London GMT, Multi-currency IDR / USD / GBP | [`timezone_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/timezone_service.dart) & [`currency_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/currency_service.dart) |
| **Inovasi Blockchain** | Proof-of-Work SHA-256 Mining, The Destiny Chain UI, Glowing Links, Kunci Validasi Copy | [`blockchain_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/blockchain_service.dart) & [`order_history_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/booking/order_history_screen.dart) |
| **Real-Time Live Chat** | 2-Role POV (Tarot Reader `arcreader` vs Client), auto-polling PostgreSQL 2s antar emulator & HP fisik | [`reader_chat_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/live_chat/reader_chat_screen.dart) & [`reader_portal_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/reader_portal/reader_portal_screen.dart) |
| **Kesan & Saran Kuliah** | Form feedback bintang, testimoni mata kuliah terhubung SQLite & PostgreSQL | [`course_feedback_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/feedback/course_feedback_screen.dart) |

