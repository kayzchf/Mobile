# 📚 PANDUAN LENGKAP KODE DASAR, API, DATABASE & ALUR BACKEND-FRONTEND
**Aplikasi:** ARCANOVA (Aplikasi Konsultasi Tarot, Spiritual, & Astrologi)  
**Tujuan Dokumen:** Membantu mahasiswa memahami, menjelaskan, dan menjawab pertanyaan dosen penguji saat presentasi/evaluasi tugas akhir mengenai bagaimana setiap baris kode dasar (API, Database, Backend, Frontend) bekerja.

---

## DAFTAR ISI
1. [Pemanggilan API & Web Service (Daftar Link, File & Kode)](#1-pemanggilan-api--web-service-daftar-link-file--kode)
2. [Operasi Database Lengkap (CRUD: SQLite Lokal & PostgreSQL Cloud)](#2-operasi-database-lengkap-crud-sqlite-lokal--postgresql-cloud)
3. [Alur Integrasi Frontend ke Backend (Form $\leftrightarrow$ Controller $\leftrightarrow$ DB)](#3-alur-integrasi-frontend-ke-backend-form--controller--db)
4. [Akses Sensor Perangkat Keras (Gyroscope 3D & GPS Geocoding)](#4-akses-sensor-perangkat-keras-gyroscope-3d--gps-geocoding)
5. [State Management & Penyimpanan Sesi (Shared Preferences & ChangeNotifier)](#5-state-management--penyimpanan-sesi-shared-preferences--changenotifier)
6. [Tabel Tanya-Jawab Cepat Saat Dosen Bertanya](#6-tabel-tanya-jawab-cepat-saat-dosen-bertanya)

---

## 1. Pemanggilan API & Web Service (Daftar Link, File & Kode)

Di aplikasi ARCANOVA, terdapat **3 layanan Web Service / API Eksternal** yang digunakan untuk memenuhi kriteria integrasi jaringan:

### 1.1 Google Gemini AI Language Model API
* **Tujuan:** Menghasilkan respons percakapan cerdas yang kontekstual dan empatik pada fitur AI Chat Konsultasi Madame Arcanova.
* **File Sumber:** [`lib/services/ai_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/ai_service.dart)
* **File Tampilan (Frontend):** [`lib/views/ai_chat/ai_chat_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/ai_chat/ai_chat_screen.dart)
* **Link Endpoint API:**  
  `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key={API_KEY}`
* **Metode HTTP:** `POST`
* **Header:** `Content-Type: application/json`

#### Potongan Kode Backend (`ai_service.dart`):
```dart
// Lokasi: lib/services/ai_service.dart
Future<String?> _callGeminiApi(
  String userMessage,
  TarotCard? drawnCard,
  String? userZodiac,
) async {
  final url = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
  );

  String systemContext = "Kamu adalah Madame Arcanova, konsultan spiritual dan pembaca tarot...";
  if (userZodiac != null) systemContext += "Zodiak user: $userZodiac. ";

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": "$systemContext\n\nCurhatan Sahabat: \"$userMessage\"\n\nTanggapan Hangat:"}
          ]
        }
      ]
    }),
  ).timeout(const Duration(seconds: 8));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'];
    return text;
  }
  return null;
}
```

#### Cara Menampilkan di Frontend (`ai_chat_screen.dart`):
```dart
// Frontend memanggil service saat tombol kirim ditekan
final reply = await AiTarotService.instance.consultArcanova(
  userMessage: messageText,
  drawnCard: _attachedCard,
  userZodiac: _userZodiac,
);

// Menambahkan balasan ke list dan render bubble chat
setState(() {
  _messages.add(ChatMessage(text: reply, isUser: false));
  _isAiTyping = false;
});
```

---

### 1.2 REST API Cloud Fallback untuk Kesan & Saran (JSONPlaceholder)
* **Tujuan:** Layanan web online publik untuk mem-backup pengiriman form testimoni mahasiswa jika database PostgreSQL laptop sedang offline.
* **File Sumber:** [`lib/services/online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart)
* **File Tampilan (Frontend):** [`lib/views/feedback/course_feedback_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/feedback/course_feedback_screen.dart)
* **Link Endpoint API:**  
  `https://jsonplaceholder.typicode.com/posts`
* **Metode HTTP:** `POST`
* **Payload:** `student_name`, `nim`, `kesan`, `saran`, `rating_stars`, `timestamp`

#### Potongan Kode Backend (`online_cloud_service.dart`):
```dart
// Lokasi: lib/services/online_cloud_service.dart
static const String feedbackCloudEndpoint = "https://jsonplaceholder.typicode.com/posts";

final response = await http.post(
  Uri.parse(feedbackCloudEndpoint),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'table': 'course_feedback_cloud',
    'student_name': feedback.studentName,
    'nim': feedback.nim,
    'kesan': feedback.kesan,
    'saran': feedback.saran,
    'rating_stars': feedback.ratingStars,
    'timestamp': feedback.submittedAt,
  }),
).timeout(const Duration(seconds: 4));

return response.statusCode == 201 || response.statusCode == 200;
```

---

### 1.3 REST API Cloud Fallback untuk Transaksi & Blockchain (HttpBin)
* **Tujuan:** Memvalidasi dan menyimpan stempel cryptographic hash transaksi pemesanan ke cloud web service independen.
* **File Sumber:** [`lib/services/online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart)
* **File Tampilan (Frontend):** [`lib/views/booking/order_history_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/booking/order_history_screen.dart)
* **Link Endpoint API:**  
  `https://httpbin.org/post`
* **Metode HTTP:** `POST`

#### Potongan Kode Backend (`online_cloud_service.dart`):
```dart
// Lokasi: lib/services/online_cloud_service.dart
static const String blockchainCloudEndpoint = "https://httpbin.org/post";

final response = await http.post(
  Uri.parse(blockchainCloudEndpoint),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'table': 'arcanova_blockchain_cloud',
    'block_index': block.index,
    'hash': block.hash,
    'previous_hash': block.previousHash,
    'nonce': block.nonce,
    'session_data': block.sessionData,
  }),
).timeout(const Duration(seconds: 4));
```

---

## 2. Operasi Database Lengkap (CRUD: SQLite Lokal & PostgreSQL Cloud)

Aplikasi ARCANOVA menerapkan **Dual-Database System**:
1. **SQLite (`DatabaseHelper`)**: Penyimpanan lokal di perangkat ponsel (luring).
2. **PostgreSQL (`OnlineCloudService`)**: Penyimpanan terpusat di server laptop (`pgAdmin`), memungkinkan pertukaran data real-time antar perangkat (misal Emulator Klien $\leftrightarrow$ HP Fisik Reader).

Berikut adalah bedah sintaks lengkap bagaimana data dimasukkan, dipanggil, diperbarui, dan dihapus:

---

### 2.1 CREATE / INSERT (Memasukkan Data ke Database)

#### A. Registrasi Pengguna Baru ke SQLite:
* **Backend:** `DatabaseHelper.insertUser(UserModel user)`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Backend (db_helper.dart):
Future<int> insertUser(UserModel user) async {
  final db = await database;
  if (db == null) return 1;
  return await db.insert('users', user.toMap());
}
```

* **Frontend Pemanggil:** `RegisterScreen._handleRegister()`
* **File:** [`lib/views/auth/register_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/auth/register_screen.dart)
```dart
// Frontend (register_screen.dart):
final res = await AuthService.instance.register(
  username: _usernameController.text,
  email: _emailController.text,
  password: _passwordController.text,
  birthDate: _birthDateController.text,
  timezonePref: _selectedTimezone,
  avatarGender: _selectedGender, // 'male' atau 'female'
);
```

---

#### B. Memasukkan Pemesanan Baru ke SQLite & PostgreSQL Cloud:
* **Backend:** `DatabaseHelper.insertBooking()` & `OnlineCloudService.syncBookingToCloud()`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart) & [`lib/services/online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart)
```dart
// 1. Simpan Lokal SQLite:
await db.insert('bookings', booking.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

// 2. Simpan Online PostgreSQL (online_cloud_service.dart):
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
```

* **Frontend Pemanggil:** `PaymentScreen._handleUpdatePaymentStatus()`
* **File:** [`lib/views/booking/payment_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/booking/payment_screen.dart)
```dart
// Saat user klik tombol "Perbarui Status Pembayaran":
final confirmedBooking = widget.booking.copyWith(paymentStatus: 'CONFIRMED');
await DatabaseHelper.instance.insertBooking(confirmedBooking);
OnlineCloudService.instance.syncBookingToCloud(confirmedBooking);
```

---

#### C. Mengirim Pesan Chat Live Reader ke SQLite & Cloud:
* **Backend:** `DatabaseHelper.insertReaderChat()`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Menyimpan pesan chat lokal dan broadcast ke cloud:
Future<int> insertReaderChat({
  required String bookingId,
  required String sender,
  required String message,
  required String sessionDate,
}) async {
  final db = await database;
  int res = 1;
  if (db != null) {
    res = await db.insert('live_reader_chats', {
      'booking_id': bookingId,
      'sender': sender,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'session_date': sessionDate,
    });
  }

  // Otomatis sinkronisasi ke PostgreSQL cloud laptop:
  OnlineCloudService.instance.sendLiveChatMessage(
    bookingId: bookingId,
    sender: sender,
    message: message,
    sessionDate: sessionDate,
  );

  return res;
}
```

* **Frontend Pemanggil:** `_ReaderRoomchatScreenState._handleSendMessage()`
* **File:** [`lib/views/live_chat/reader_chat_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/live_chat/reader_chat_screen.dart)
```dart
// Frontend: Mengirim teks dari input chat controller:
await DatabaseHelper.instance.insertReaderChat(
  bookingId: widget.booking.id,
  sender: AuthService.instance.isTarotReader ? 'reader' : 'user',
  message: text,
  sessionDate: widget.booking.sessionDate,
);
```

---

### 2.2 READ / SELECT (Memanggil Data dari Database)

#### A. Memanggil Pengguna Berdasarkan Username/Email (Proses Login):
* **Backend:** `DatabaseHelper.getUserByUsernameOrEmail(String identifier)`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Backend (db_helper.dart):
Future<UserModel?> getUserByUsernameOrEmail(String identifier) async {
  final db = await database;
  if (db == null) return null;
  final clean = identifier.trim().toLowerCase();
  final maps = await db.query(
    'users',
    where: 'LOWER(username) = ? OR LOWER(email) = ?',
    whereArgs: [clean, clean],
  );
  if (maps.isNotEmpty) {
    return UserModel.fromMap(maps.first);
  }
  return null;
}
```

* **Frontend Pemanggil:** `LoginScreen._handleLogin()`
* **File:** [`lib/views/auth/login_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/auth/login_screen.dart)
```dart
// Frontend (login_screen.dart):
final res = await AuthService.instance.login(
  usernameOrEmail: _usernameController.text,
  password: _passwordController.text,
);
```

---

#### B. Memanggil Jadwal Jam yang Sudah Terisi (Cek Redundansi):
* **Backend:** `DatabaseHelper.getBookedTimes(String date)`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Backend: Mengambil semua slot yang terisi pada tanggal tertentu:
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

  // Ambil juga slot dari PostgreSQL cloud laptop:
  final cloudSlots = await OnlineCloudService.instance.fetchBookedSlotsForDate(date);
  for (final slot in cloudSlots) {
    occupied.addAll(TimezoneService.instance.getSlotsForSession(slot, 1));
  }
  return occupied.toList();
}
```

* **Frontend Pemanggil:** `_BookingModalState._loadBookedSlots()`
* **File:** [`lib/views/booking/services_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/booking/services_screen.dart)
```dart
// Frontend: Mengisi variabel _bookedSlots untuk menonaktifkan kartu jam
final booked = await DatabaseHelper.instance.getBookedTimes(dateStr);
setState(() {
  _bookedSlots = booked;
});
```

---

#### C. Memanggil Riwayat Chat Real-Time dari PostgreSQL Cloud:
* **Backend:** `OnlineCloudService.fetchLiveChatMessages(String bookingId)`
* **File:** [`lib/services/online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart)
```dart
// Backend: Query SQL SELECT langsung ke database laptop:
Future<List<Map<String, dynamic>>> fetchLiveChatMessages(String bookingId) async {
  Connection? conn = await _getConnection();
  if (conn != null) {
    final result = await conn.execute(
      Sql.named(
        'SELECT booking_id, sender, message, session_date, created_at '
        'FROM cloud_live_reader_chats '
        'WHERE booking_id = @bid '
        'ORDER BY id ASC',
      ),
      parameters: {'bid': bookingId},
    );
    final list = <Map<String, dynamic>>[];
    for (final row in result) {
      list.add({
        'booking_id': row[0],
        'sender': row[1],
        'message': row[2],
        'session_date': row[3],
        'timestamp': row[4]?.toString() ?? DateTime.now().toIso8601String(),
      });
    }
    await conn.close();
    return list;
  }
  return [];
}
```

* **Frontend Pemanggil:** `_ReaderRoomchatScreenState._loadChatHistory()`
* **File:** [`lib/views/live_chat/reader_chat_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/live_chat/reader_chat_screen.dart)
```dart
// Frontend dipanggil setiap 2 detik oleh Timer:
final list = await DatabaseHelper.instance.getReaderChats(widget.booking.id);
setState(() {
  _messages.clear();
  _messages.addAll(list);
});
```

---

### 2.3 UPDATE (Memperbarui Data di Database)

#### A. Memperbarui Data Pengguna (Edit Profil):
* **Backend:** `DatabaseHelper.updateUser(UserModel user)`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Backend: Update profil username, email, password, gender avatar:
Future<int> updateUser(UserModel user) async {
  final db = await database;
  if (db == null) return 1;
  return await db.update(
    'users',
    user.toMap(),
    where: 'id = ?',
    whereArgs: [user.id],
  );
}
```

* **Frontend Pemanggil:** `ProfileScreen._showEditProfileDialog()`
* **File:** [`lib/views/profile/profile_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/profile/profile_screen.dart)

---

### 2.4 DELETE (Menghapus Data dari Database)

#### A. Penghapusan Otomatis Chat yang Kadaluarsa (Retensi H+3):
* **Backend:** `DatabaseHelper.cleanupExpiredChatsH3()`
* **File:** [`lib/services/db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart)
```dart
// Backend: Menghapus chat yang tanggal sesinya lebih lama dari 3 hari lalu:
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

## 3. Alur Integrasi Frontend ke Backend (Form $\leftrightarrow$ Controller $\leftrightarrow$ DB)

Ketika Anda ditanya oleh dosen: *"Bagaimana alur dari saat user mengklik tombol di layar hingga data tersimpan di database?"*, jelaskan alur 4 tahap berikut:

```
[1. TAMPILAN (UI)]                  [2. VALIDASI & STATE]             [3. LOGIKA BISNIS]              [4. DATABASE]
TextFormField (Input)       --->    _formKey.currentState.validate()  ---> AuthService.register()    ---> SQLite (users table)
ElevatedButton (onPressed)          TextEditingController.text             sha256(password + salt)         PostgreSQL (cloud)
```

### Contoh Nyata pada Form Booking & Pembayaran:
1. **Frontend Input (`services_screen.dart`)**:
   Pengguna memilih paket tarot, menambah jumlah sesi (misal 3 sesi), dan memilih slot jam `21:00`.
2. **Validasi & State**:
   Sistem mengecek ketersediaan dengan `TimezoneService.instance.getSlotsForSession("21:00", 3)`. Jika ada slot bentrok, tombol pembayaran ditahan dan muncul SnackBar peringatan.
3. **Pembayaran & QRIS (`payment_screen.dart`)**:
   Nota dibuat khusus berdasarkan zona waktu pemesan (misal `21.00 - 22.30 WIB`). Timer hitung mundur 15 menit berjalan.
4. **Penyimpanan Ganda**:
   Saat status dikonfirmasi, objek `BookingModel` dikirim ke `DatabaseHelper.insertBooking` (SQLite lokal) dan `OnlineCloudService.syncBookingToCloud` (PostgreSQL laptop).

---

## 4. Akses Sensor Perangkat Keras (Gyroscope 3D & GPS Geocoding)

### 4.1 Sensor Gyroscope untuk Efek 3D Tilt Kartu
* **Pustaka:** `sensors_plus`
* **File Layanan:** [`lib/services/sensor_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/sensor_service.dart)
* **File Tampilan:** [`lib/views/home/home_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/home/home_screen.dart)

#### Kode Backend Sensor (`sensor_service.dart`):
```dart
// Membuka stream gyroscope bawaan Android:
Stream<GyroscopeEvent> get gyroscopeStream => gyroscopeEventStream();
```

#### Kode Frontend Penerima (`home_screen.dart`):
```dart
// Mengonversi sudut gerak HP ke nilai rotasi Matrix4:
_gyroscopeSubscription = SensorService.instance.gyroscopeStream.listen((event) {
  if (mounted) {
    setState(() {
      _tiltPitch = (_tiltPitch + event.y * 0.04).clamp(-0.25, 0.25);
      _tiltRoll = (_tiltRoll - event.x * 0.04).clamp(-0.25, 0.25);
    });
  }
});

// Merender kartu 3D holografik yang merespons kemiringan HP:
Transform(
  transform: Matrix4.identity()
    ..setEntry(3, 2, 0.001) // Efek perspektif 3 dimensi
    ..rotateX(_tiltPitch)
    ..rotateY(_tiltRoll),
  child: TarotCardWidget(card: card),
)
```

---

### 4.2 Sensor GPS & Reverse Geocoding (Deteksi Nama Kota & Provinsi)
* **Pustaka:** `geolocator` & `geocoding`
* **File Layanan:** [`lib/services/location_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/location_service.dart)
* **File Tampilan:** [`lib/views/games/mystic_hub_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/games/mystic_hub_screen.dart)

#### Kode Backend Lokasi (`location_service.dart`):
```dart
// 1. Ambil koordinat GPS perangkat:
final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

// 2. Reverse geocoding: Ubah koordinat menjadi nama kota & provinsi nyata:
List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
String cityName = placemarks.first.subAdministrativeArea ?? "Semarang";
String provinceName = placemarks.first.administrativeArea ?? "Jawa Tengah";

// 3. Hitung jarak meter ke koordinat kuil Arcanova Sanctuary:
final distanceMeters = Geolocator.distanceBetween(
  position.latitude, position.longitude, sanctuaryLatitude, sanctuaryLongitude,
);
```

---

## 5. State Management & Penyimpanan Sesi (Shared Preferences & ChangeNotifier)

### 5.1 State Management `ChangeNotifier` & Listener
Aplikasi tidak menggunakan pustaka pihak ketiga yang rumit, melainkan pola standar resmi Flutter: `ChangeNotifier` dengan Singleton pattern:
* [`AuthService.instance`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/auth_service.dart): Memberitahu seluruh antarmuka saat user login, logout, atau beralih ke mode tamu.
* [`CurrencyService.instance`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/currency_service.dart): Memberitahu katalog layanan untuk me-render ulang seluruh harga saat zona waktu atau preferensi mata uang berubah.

```dart
// Di layar View (contoh: services_screen.dart):
@override
void initState() {
  super.initState();
  CurrencyService.instance.addListener(_onCurrencyChanged);
}

void _onCurrencyChanged() {
  if (mounted) setState(() {}); // Render ulang otomatis saat mata uang berganti
}
```

---

### 5.2 Penyimpanan Sesi Ringan (SharedPreferences)
* **File:** [`lib/services/auth_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/auth_service.dart)
* **Tujuan:** Menyimpan ID pengguna terakhir dan token sesi agar saat aplikasi dibuka kembali, pengguna bisa langsung masuk dengan **1-Tap Sidik Jari** tanpa harus mengetik username kembali.

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setInt("arcanova_session_user_id", userId);
await prefs.setString("arcanova_last_username", username);
```

---

## 6. Tabel Tanya-Jawab Cepat Saat Dosen Bertanya

| Pertanyaan Dosen | Jawaban Singkat & Tepat | Lokasi File Kode |
| :--- | :--- | :--- |
| **"Di mana kalian memanggil API eksternal dan linknya apa?"** | "Di file `ai_service.dart` memanggil REST API Google Gemini (`generativelanguage.googleapis.com`), serta di `online_cloud_service.dart` memanggil `jsonplaceholder.typicode.com` dan `httpbin.org` untuk backup cloud." | [`ai_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/ai_service.dart) & [`online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart) |
| **"Database lokal pakai apa dan apa yang disimpan?"** | "Pakai SQLite (`sqflite`). Menyimpan data akun pengguna, 22 kartu tarot, transaksi pemesanan, riwayat chat, ledger blockchain lokal, dan kesan-saran kuliah." | [`db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart) |
| **"Database online pakai apa dan bagaimana menghubungkannya?"** | "Pakai PostgreSQL (pgAdmin di laptop). Aplikasi Flutter terhubung lewat port 5432. IP `10.0.2.2` untuk emulator dan `127.0.0.1` untuk HP fisik dengan `adb reverse tcp:5432 tcp:5432`." | [`online_cloud_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/online_cloud_service.dart) |
| **"Bagaimana cara mencegah jadwal pemesanan ganda (bentrok)?"** | "Fungsi `getBookedTimes` memeriksa `sessions_count`. Jika ada sesi 30 menit x 3 jam mulai 21:00, slot 21:00, 21:30, dan 22:00 otomatis ditandai penuh baik di database lokal maupun cloud." | [`timezone_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/timezone_service.dart) & [`db_helper.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/db_helper.dart) |
| **"Bagaimana peran dua role Klien dan Reader?"** | "Form login sama, tapi reader memiliki kredensial resmi `arcreader` / `readernz`. Saat login, reader langsung diarahkan ke Reader Portal untuk membuka obrolan sesi pelanggan yang aktif." | [`login_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/auth/login_screen.dart) & [`reader_portal_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/reader_portal/reader_portal_screen.dart) |
| **"Bagaimana teknologi blockchain diterapkan di aplikasi ini?"** | "Menggunakan algoritma Proof-of-Work SHA-256 (`blockchain_service.dart`). Setiap transaksi pemesanan menghasilkan hash unik yang dicatat permanen di menu riwayat 'The Destiny Chain'." | [`blockchain_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/blockchain_service.dart) & [`order_history_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/booking/order_history_screen.dart) |
| **"Di mana sensor gyroscope digunakan?"** | "Di layar Beranda (`home_screen.dart`). Stream event kemiringan HP mengubah matrix Transform `rotateX` dan `rotateY` kartu tarot sehingga terlihat seperti kartu 3D holografik." | [`sensor_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/sensor_service.dart) & [`home_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/home/home_screen.dart) |
| **"Bagaimana GPS mendeteksi nama kota pengguna?"** | "Sensor GPS mengambil koordinat latitude dan longitude lewat pustaka `geolocator`, lalu fungsi `placemarkFromCoordinates` dari `geocoding` menerjemahkannya ke nama kota & provinsi (misal: 'Semarang, Jawa Tengah')." | [`location_service.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/services/location_service.dart) & [`mystic_hub_screen.dart`](file:///c:/Users/ASUS/OneDrive/Documents/Semester5/Mobile/finalproject/lib/views/games/mystic_hub_screen.dart) |

