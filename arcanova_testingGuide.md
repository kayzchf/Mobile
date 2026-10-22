# 🎓 PANDUAN PRESENTASI & LEMBAR PENGUJIAN APLIKASI ARCANOVA
> **Mata Kuliah**: Pemrograman Aplikasi Mobile (PAM)  
> **Aplikasi**: ARCANOVA - Tarot Reading  
> **Tema Desain**: Mystic Cosmic Indigo & Neon Violet (`#0B0C1E`, `#131238`, `#8A2BE2`, `#00D2FF`, `#FFD700`)

---

## 1. Skenario Demonstrasi di Depan Dosen (Step-by-Step Demo)

| Langkah | Fitur yang Didemokan | Tindakan yang Ditampilkan | Respon Aplikasi |
|---|---|---|---|
| **1** | **Mode Tamu (Unregistered)** | Buka aplikasi saat pertama kali diinstal (tanpa login). Pilih kartu harian di katalog. | User dapat melihat katalog 22 kartu Major Arcana dan maknanya secara gratis. |
| **2** | **Proteksi Layanan (Session Guard)** | Buka tab **Layanan**, lalu klik tombol **Pesan Sesi**. | Muncul dialog mistis: *"Akun Jiwa Diperlukan"* yang mengarahkan user untuk Register/Login terlebih dahulu. |
| **3** | **Registrasi & Enkripsi Password** | Masukkan: Username, Email, Password, Tanggal Lahir (DatePicker), dan Zona Waktu (WIB). Klik Daftar. | Password dienkripsi dengan **SHA-256 + Salt** dan disimpan ke SQLite (`users`). Zodiak dihitung otomatis dari tanggal lahir! |
| **4** | **Login Biometrik Wajah** | Logout, lalu di layar login klik *"Masuk dengan Biometrik Wajah"*. | Membuka layar pemindaian wajah (*Biometric Scanner*) dengan efek animasi laser pendar neon, mendeteksi wajah via `local_auth`. |
| **5** | **Sensor Accelerometer (Shake to Shuffle)** | Pada tab **Deck**, goyangkan smartphone secara fisik (di emulator: klik menu Sensor $\rightarrow$ Accelerometer). | Terasa getaran haptic feedback dan kartu tarot harian otomatis terkocok dan terambil kartu baru! |
| **6** | **Sensor Gyroscope (3D Holographic Tilt)** | Miringkan smartphone ke atas/bawah/kiri/kanan. | Kartu harian bergoyang secara 3D (*Perspective Matrix4*) mengikuti sudut kemiringan HP. |
| **7** | **Pencarian & Filter Ensiklopedia** | Ketik *"The Lovers"* di Search Bar, atau klik chip filter *"Fire"*. | Grid kartu otomatis menyaring daftar Major Arcana secara realtime. Klik kartu untuk melihat modal arti tegak, terbalik, asmara, dan karir. |
| **8** | **Pemesanan Multi-Kurs & Multi-Timezone** | Buka tab **Layanan**. Ubah kurs ke **USD ($)** atau **GBP (£)**. Klik Pesan Sesi. | Seluruh harga terkonversi otomatis! Pilih tanggal dan jam: tertera konversi waktu berdampingan **WIB, WITA, WIT, dan London (GMT)**. Slot yang sudah dibooking terkunci (*Booked*). |
| **9** | **Pembayaran QRIS Statis & Countdown** | Masuk halaman checkout pembayaran. | Tampil QRIS statis *Arcanova Sanctuary Malioboro* dengan countdown 15 menit. Klik *"Perbarui Status Pembayaran"*, status terupdate jadi `CONFIRMED`. |
| **10** | **Landing Page Menunggu Sesi & Notifikasi** | Masuk ke halaman tunggu sesi. Klik tombol *"Uji Notifikasi Reminder H-10 Menit Sekarang"*. | Muncul push notifikasi di bar status HP: *"🔮 Sesi Tarot Dimulai 10 Menit Lagi!"*. |
| **11** | **Mini Games Asmara & Feng Shui** | Buka tab **Games**. Masukkan nama Anda dan pasangan + tanggal lahir. Klik Kalkulasi. | Muncul persentase kecocokan cinta, analisis elemen zodiak, dan saran hubungan. Tab Feng Shui menampilkan outfit lucky color dan lucky food hari ini. |
| **12** | **LBS Sanctuary Malioboro (GPS Radar)** | Buka sub-tab **Sanctuary**. Aplikasi membaca GPS user via `geolocator`. | Menampilkan jarak realtime ke Malioboro. Jika jarak $\le 1.5\text{ km}$, muncul banner *"Secret Aura Diskon 20%"*. Tombol *"Buka Rute di Google Maps"* mengarahkan rute jalan. |
| **13** | **AI Spiritual Confidante (Madame Arcanova)** | Buka tab **AI Chat**. Kirim curhat atau klik tombol tarik kartu di pojok kanan atas. | AI Madame Arcanova menjawab dengan empati mendalam, bahasa puitis, dan nasihat bijak. |
| **14** | **Blockchain Reading Ledger** | Buka tab **Profil**, lihat daftar blok rantai pembacaan. Klik tombol *"Verifikasi Hash"*. | Sistem memverifikasi ulang seluruh rantai hash SHA-256 dari Genesis Block `#0` dan menyatakan rantai valid (*Immutable*). |
| **15** | **Saran & Kesan Matkul PAM & Logout** | Pada tab **Profil**, klik menu *"Saran & Kesan Matkul PAM"*. Isi bintang rating, NIM, kesan, dan saran. Terakhir, klik **Logout**. | Data tersimpan rapi di SQLite dan sesi token terhapus secara aman. |

---

## 2. Lembar Evaluasi & Pengujian Perangkat Lunak (Black Box Testing)

Tabel ini siap dicantumkan langsung ke dalam **BAB IV Laporan Tugas Akhir**:

| ID Uji | Modul / Fitur | Skenario Pengujian | Masukan (Input) | Hasil yang Diharapkan | Hasil Pengujian | Status |
|---|---|---|---|---|---|---|
| **TC-01** | Autentikasi | Registrasi akun baru | Email valid, password $\ge 6$ karakter, tanggal lahir | Akun tersimpan dengan password ter-hash SHA-256 di SQLite | Akun tersimpan dan otomatis login | **PASS** |
| **TC-02** | Autentikasi | Login password salah | Email terdaftar, password acak | Menampilkan SnackBar peringatan kata sandi salah | SnackBar muncul, login ditolak | **PASS** |
| **TC-03** | Biometrik | Login Face Biometric | Menekan tombol biometrik wajah | Membuka scanner dan mengotentikasi via `local_auth` | Berhasil autentikasi dan masuk ke beranda | **PASS** |
| **TC-04** | Sensor 1 | Shake to Shuffle Kartu | Menggoyangkan perangkat ($g > 14\text{ m/s}^2$) | Terjadi haptic feedback dan kartu harian baru terpilih | Kartu baru terkocok dan SnackBar muncul | **PASS** |
| **TC-05** | Sensor 2 | 3D Holographic Parallax | Memiringkan orientasi HP (Pitch & Roll) | Matrix4 rotasi kartu berubah sudut kemiringannya | Kartu bergerak 3D secara dinamis | **PASS** |
| **TC-06** | Database | Search & Filter Kartu | Mengetik "Fool" dan filter "Air" | Hanya kartu The Fool yang tampil di grid | Hasil pencarian instan dan akurat | **PASS** |
| **TC-07** | Konversi Kurs | Pengubahan Mata Uang | Memilih opsi USD (\$) atau GBP (£) | Tarif 4 layanan tarot terkonversi dari basis IDR | Angka harga berubah sesuai kurs terpilih | **PASS** |
| **TC-08** | Konversi Waktu | Pemilihan Slot Jadwal | Memilih slot jam 19:00 WIB | Tampil konversi ke WITA (20:00), WIT (21:00), dan London (12:00) | Seluruh 4 zona waktu tertera jelas | **PASS** |
| **TC-09** | Transaksi | Pembayaran QRIS Statis | Menekan "Perbarui Status Pembayaran" | Status booking di SQLite berubah menjadi `CONFIRMED` | Status terupdate dan diarahkan ke landing page | **PASS** |
| **TC-10** | Notifikasi | Reminder H-10 Menit | Jadwal sesi atau uji notifikasi demo | Local notification muncul di status bar perangkat | Notifikasi muncul dengan judul & pesan mistis | **PASS** |
| **TC-11** | Mini Games | Kecocokan Cinta Asmara | Memasukkan 2 nama dan tanggal lahir | Menghasilkan skor %, analisis zodiak, dan saran hubungan | Hasil kalkulasi tampil dalam kartu glowing | **PASS** |
| **TC-12** | LBS | Radar Sanctuary Malioboro | Mengaktifkan GPS lokasi | Menghitung jarak km ke Jl. Malioboro No. 56 Yogyakarta | Jarak terhitung dan tombol rute Maps aktif | **PASS** |
| **TC-13** | AI & LLM | Konsultasi Madame Arcanova | Mengirim pesan curhat masalah karir | AI membalas dengan respon spiritual empatik dan solutif | Pesan balasan tampil rapi di bubble chat | **PASS** |
| **TC-14** | Blockchain | Verifikasi Keaslian Rantai | Menekan tombol "Verifikasi Hash" | Validasi kesesuaian `previousHash` dan perhitungan SHA-256 | Dialog konfirmasi seluruh blok terverifikasi valid | **PASS** |
| **TC-15** | Feedback | Input Saran & Kesan Matkul | Rating 5 bintang, NIM, Kesan, Saran | Tersimpan ke tabel SQLite `course_feedback` | Tersimpan dan muncul di riwayat masukan | **PASS** |
| **TC-16** | Session | Logout Aplikasi | Menekan tombol Logout di profil | Menghapus token session aktif di storage | Sesi berakhir dan kembali ke halaman login | **PASS** |
