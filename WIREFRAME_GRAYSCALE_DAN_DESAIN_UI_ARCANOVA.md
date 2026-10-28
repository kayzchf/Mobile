# DOKUMEN WIREFRAME GRAYSCALE & DESAIN TATA LETAK APLIKASI ARCANOVA
**Aplikasi:** ARCANOVA - Sacred Cyber-Mystic Tarot & Astrology  
**Platform:** Mobile (Android & iOS)  
**Pendekatan Desain:** *Low-to-Mid Fidelity Grayscale Wireframe Specification*  
**Palet Warna:** Skala Abu-abu (Monochrome Grayscale: White, 10% Gray, 30% Gray, 50% Gray, 70% Gray, 90% Gray, Black)  

---

## DAFTAR ISI
1. **BAB I: PANDUAN DAN STANDAR WIREFRAME GRAYSCALE**
   - 1.1 Tujuan Pembuatan Wireframe Grayscale
   - 1.2 Notasi Komponen & Simbol Antarmuka
   - 1.3 Skala Warna Grayscale & Hierarki Tipografi
2. **BAB II: WIREFRAME FITUR AUTENTIKASI & ONBOARDING**
   - 2.1 Layar Login Terpadu (`LoginScreen`)
   - 2.2 Layar Registrasi & Pemilih Avatar Gender (`RegisterScreen`)
   - 2.3 Layar Sensor Biometrik Sidik Jari (`BiometricScanScreen`)
3. **BAB III: WIREFRAME FITUR UTAMA & BOTTOM NAVIGATION**
   - 3.1 Layar Beranda: Dek 3D Gyroscope, Shake Card, & Search/Filter (`HomeScreen`)
   - 3.2 Bottom Navigation Bar (5 Tab Utama)
4. **BAB IV: WIREFRAME RESERVASI, MULTI-SLOT & PEMBAYARAN**
   - 4.1 Layar Katalog Layanan, Multi-Slot Picker & Chat FAB (`ServicesScreen`)
   - 4.2 Layar Pembayaran QRIS Dinamis & Timer (`PaymentScreen`)
   - 4.3 Layar Ruang Tunggu Konsultasi (`SessionWaitingScreen`)
5. **BAB V: WIREFRAME BLOCKCHAIN IN-APP (THE DESTINY CHAIN)**
   - 5.1 Layar Riwayat Rantai Blok Bertingkat (`OrderHistoryScreen`)
   - 5.2 Modal Rincian Kriptografi Blok & Salin Hash
6. **BAB VI: WIREFRAME HUB MISTIS & LBS QUEST**
   - 6.1 Mini-Game Cosmic Love Match (Kompatibilitas Zodiak)
   - 6.2 Mini-Game Sanctuary GPS Explorer (Geofencing LBS OpenStreetMap)
7. **BAB VII: WIREFRAME FITUR KOMUNIKASI & AI**
   - 7.1 Layar Chat AI Curhat: Madame Arcanova (`AiChatScreen`)
   - 7.2 Layar Live Chat Real-Time WhatsApp-Style (`ReaderChatScreen`)
8. **BAB VIII: WIREFRAME PROFIL, LEDGER & EVALUASI PERKULIAHAN**
   - 8.1 Layar Profil & Pengaturan Akun (`ProfileScreen`)
   - 8.2 Layar Evaluasi: Saran & Kesan Matkul PAM (`CourseFeedbackScreen`)
9. **BAB IX: WIREFRAME DASHBOARD TAROT READER (READER POV)**
   - 9.1 Layar Tarot Reader Portal (`TarotReaderPortalScreen`)
10. **BAB X: WIREFRAME MODAL DIALOG & FEEDBACK SISTEM**

---

# BAB I: PANDUAN DAN STANDAR WIREFRAME GRAYSCALE

### 1.1 Tujuan Pembuatan Wireframe Grayscale
Wireframe grayscale berfokus pada struktur tata letak (*layout*), hierarki informasi (*information architecture*), alur navigasi (*user flow*), serta penempatan tombol dan komponen fungsional tanpa distraksi warna akhir. 

Wireframe ini merepresentasikan seluruh antarmuka aplikasi **ARCANOVA** untuk memastikan:
- Keterbacaan dan kontras elemen form serta kartu data.
- Kemudahan jangkauan ibu jari (*thumb zone*) pada perangkat smartphone.
- Konsistensi pola UI (*design system*) di 35 file aplikasi.

### 1.2 Notasi Komponen & Simbol Antarmuka
| Simbol / Notasi | Arti Komponen | Keterangan Fungsional |
|:---:|:---|:---|
| `[  X  ]` | Gambar / Ilustrasi / Avatar | Kotak dengan tanda silang diagonal menunjukkan elemen grafis. |
| `[ Button Name ]` | Tombol Aksi Utama (*CTA*) | Tombol dengan latar belakang abu-abu gelap dan teks putih. |
| `( Button Name )` | Tombol Sekunder / Outlined | Tombol berbingkai tipis tanpa isian padat. |
| `[ ___Input Text___ ]` | Kolom Input Teks (*TextField*) | Area masukan teks dengan garis tepi atau latar belakang abu-abu terang. |
| `( * ) / (   )` | Radio Button | Opsi pemilih tunggal. |
| `[ v ] / [   ]` | Checkbox / Toggle Switch | Pemilih aktif / nonaktif. |
| `[ ─── o ─── ]` | Switch Toggle | Toggle saklar on/off (misal: Biometrik). |
| `|───o───|` | Garis Rantai Blockchain | Rantai penghubung vertikal pada riwayat blok. |
| `[ ⭐ ⭐ ⭐ ⭐ ⭐ ]` | Rating Star Bar | Komponen penilaian kepuasan / bintang. |
| `[ < ]  [ > ]` | Navigasi Kembali / Maju | Ikon panah kontrol. |

### 1.3 Skala Warna Grayscale (Monochrome Palette)
- **Grayscale 0 (Putih - `#FFFFFF`):** Latar belakang kanvas terang, teks pada tombol gelap.
- **Grayscale 1 (Abu Sangat Terang - `#F3F4F6`):** Latar belakang kartu (*card surface*), gelembung chat masuk.
- **Grayscale 2 (Abu Terang - `#E5E7EB`):** Border kartu, pembatas garis (*divider*), kolom input kosong.
- **Grayscale 3 (Abu Sedang - `#9CA3AF`):** Teks sekunder, label placeholder, ikon non-aktif.
- **Grayscale 4 (Abu Tua - `#4B5563`):** Teks penjelas penting, bingkai tombol sekunder.
- **Grayscale 5 (Abu Gelap - `#1F2937`):** Tombol aksi utama (*CTA*), header bar, gelembung chat keluar.
- **Grayscale 6 (Hitam - `#111827` / `#000000`):** Judul utama (*headings*), teks tebal, navigasi bawah.

---

# BAB II: WIREFRAME FITUR AUTENTIKASI & ONBOARDING

### 2.1 Layar Login Terpadu (`LoginScreen`)
Layar masuk tunggal untuk Klien maupun Tarot Reader (`arcreader`).

```
+-------------------------------------------------------------+
| [Status Bar: 09:41  •  LTE  •  Battery 100%]                |
+-------------------------------------------------------------+
|                                                             |
|                          [  X  ]                            |
|                 (Logo Mistis / Arcane Icon)                 |
|                                                             |
|                          ARCANOVA                           |
|           "Pintu Gerbang Takdir & Konsultasi Jiwa"          |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Masuk ke Akun Anda                                    |  |
|  | Silakan masukkan identitas untuk melanjutkan          |  |
|  |                                                       |  |
|  | Username / Email                                      |  |
|  | [ arcreader / username                              ] |  |
|  |                                                       |  |
|  | Kata Sandi                                            |  |
|  | [ •••••••••••••                                  [o] ] |  |
|  |                                                       |  |
|  |                 [   MASUK KE GERBANG   ]              |  |
|  |                                                       |  |
|  |                       -- ATAU --                      |  |
|  |                                                       |  |
|  |                 [  (o) Masuk Sidik Jari  ]            |  |
|  |                                                       |  |
|  |                 (   Jelajahi Mode Tamu   )            |  |
|  +-------------------------------------------------------+  |
|                                                             |
|              Belum punya akun? [ Daftar Sekarang ]          |
|                                                             |
+-------------------------------------------------------------+
```

### 2.2 Layar Registrasi & Pemilih Avatar Gender (`RegisterScreen`)
Menampilkan form pendaftaran lengkap dengan pemilih avatar jenis kelamin (👨 Pria / 👩 Wanita).

```
+-------------------------------------------------------------+
| [ < ]  REGISTRASI JIWA BARU                                 |
+-------------------------------------------------------------+
|                                                             |
|  Nama Lengkap / Username                                    |
|  [ Kaylaneza                                              ] |
|                                                             |
|  Alamat Email Aktif                                         |
|  [ kayla@example.com                                      ] |
|                                                             |
|  Kata Sandi (Terenkripsi SHA-256 + Salt)                    |
|  [ •••••••••••••                                      [o] ] |
|                                                             |
|  Pilih Avatar Jenis Kelamin:                                |
|  +---------------------------+ +--------------------------+ |
|  |          [  X  ]          | |         [  X  ]          | |
|  |          👨 Pria          | |         👩 Wanita        | |
|  |        (  Dipilih  )      | |        (         )       | |
|  +---------------------------+ +--------------------------+ |
|                                                             |
|  Tanggal Lahir (Untuk Zodiak Otomatis)                      |
|  [ 2004-06-15                                         [📅] ] |
|  (i) Zodiak kamu: Gemini ♊ (Elemen Udara)                    |
|                                                             |
|  [ v ] Saya menyetujui Ketentuan Spiritual & Kebijakan Privasi|
|                                                             |
|               [   DAFTARKAN JIWA SAYA   ]                   |
|                                                             |
|                Sudah punya akun? [ Masuk ]                  |
|                                                             |
+-------------------------------------------------------------+
```

### 2.3 Layar Sensor Biometrik Sidik Jari (`BiometricScanScreen`)
Visualisasi pemindaian sensor fisik jari perangkat.

```
+-------------------------------------------------------------+
| [ < ]                                                       |
+-------------------------------------------------------------+
|                                                             |
|                                                             |
|                   AUTENTIKASI BIOMETRIK                     |
|                                                             |
|                          . - ~ - .                          |
|                       /   .----.   \                        |
|                      |   /  ()  \   |                       |
|                      |  |  (())  |  |                       |
|                      |   \  ()  /   |                       |
|                       \   '----'   /                        |
|                          ' - ~ - '                          |
|                     [ Ikon Sidik Jari ]                     |
|                                                             |
|              Sentuh sensor sidik jari ponsel Anda           |
|            untuk membuka gerbang rahasia Arcanova           |
|                                                             |
|                                                             |
|               (   Gunakan Kata Sandi Saja   )               |
|                                                             |
+-------------------------------------------------------------+
```

---

# BAB III: WIREFRAME FITUR UTAMA & BOTTOM NAVIGATION

### 3.1 Layar Beranda: Dek 3D Gyroscope & Search/Filter (`HomeScreen`)
Layar beranda dengan interaksi 3D kemiringan ponsel dan penarikan kartu harian (*daily draw*).

```
+-------------------------------------------------------------+
| ARCANOVA                      [ 🔔 2 ]  [ 👨 Foto Avatar ]  |
| "Selamat Datang, Kaylaneza"                                 |
+-------------------------------------------------------------+
|                                                             |
|  [ 🔍 Cari kartu tarot (misal: The Fool, Star)...       ]   |
|                                                             |
|  Filter Elemen Semesta:                                     |
|  ( [Semua] )  ( Api ♈ )  ( Air ♋ )  ( Udara ♊ )  ( Tanah ♉ )|
|                                                             |
|  +-------------------------------------------------------+  |
|  |           KARTU TAKDIR HARI INI (DAILY DRAW)          |  |
|  |                                                       |  |
|  |                  +-----------------+                  |  |
|  |                  |      [ X ]      |                  |  |
|  |                  |                 | <--- [3D Gyro]   |  |
|  |                  |    THE STAR     |      (Miringkan  |  |
|  |                  |      XVII       |       ponsel)    |  |
|  |                  +-----------------+                  |  |
|  |                                                       |  |
|  |   "Harapan baru dan inspirasi mengalir dalam jiwa"    |  |
|  |                                                       |  |
|  |           [ 📳 Goyangkan Ponsel Untuk Kocok ]          |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  Katalog 22 Kartu Major Arcana:                             |
|  +--------------------+ +--------------------+ +----------+ |
|  | [ X ] The Magician | | [ X ] High Priest  | | [ X ] ...| |
|  | Elemen: Udara      | | Elemen: Air        | |          | |
|  +--------------------+ +--------------------+ +----------+ |
|                                                             |
+-------------------------------------------------------------+
| [🏠 Beranda] [🔮 Layanan] [✨ Hub] [💬 Chat AI] [👤 Profil] |
+-------------------------------------------------------------+
```

---

# BAB IV: WIREFRAME RESERVASI, MULTI-SLOT & PEMBAYARAN

### 4.1 Layar Katalog Layanan & Multi-Slot Picker (`ServicesScreen`)
Menampilkan katalog ramalan, konversi kurs, pemilihan sesi berturut-turut, pemblokir jam bentrok, dan FAB chat dinamis.

```
+-------------------------------------------------------------+
| KATALOG LAYANAN SPIRITUAL                                   |
+-------------------------------------------------------------+
|                                                             |
|  Konversi Mata Uang:  ( [IDR (Rp)] )  ( USD ($) )  ( GBP (£) )|
|                                                             |
|  Pilih Jenis Layanan:                                       |
|  +-------------------------------------------------------+  |
|  | [ X ] Tarot Asmara & Belahan Jiwa       Rp 150.000    |  |
|  |       Membaca garis takdir hubungan cinta & jodoh     |  |
|  |       ( * Terpilih )                                  |  |
|  +-------------------------------------------------------+  |
|  +-------------------------------------------------------+  |
|  | [ X ] Karir, Rezeki & Finansial         Rp 200.000    |  |
|  |       (   Pilih Layanan Ini )                         |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  Pilih Tanggal Konsultasi:                                  |
|  [ 📅 Rabu, 28 Oktober 2026                            [v] ]|
|                                                             |
|  Jumlah Sesi Berturut-turut:                                |
|  [ 1 Sesi (60m) ]   [ [2 Sesi (120m)] ]   [ 3 Sesi (180m) ] |
|                                                             |
|  Pilih Jam Mulai (WIB):                                     |
|  +---------------+  +---------------+  +---------------+    |
|  | 09:00 WIB     |  | 10:00 WIB     |  | 11:00 WIB     |    |
|  | 02:00 London  |  | [Terpilih S1] |  | [Terpilih S2] |    |
|  +---------------+  +---------------+  +---------------+    |
|  +---------------+  +---------------+  +---------------+    |
|  | 13:00 WIB     |  | 14:00 WIB     |  | 15:00 WIB     |    |
|  | [ X-PENUH ]   |  | [Tersedia]    |  | [Tersedia]    |    |
|  +---------------+  +---------------+  +---------------+    |
|                                                             |
|  (i) Konversi Jam: 10:00 WIB = 11:00 WITA = 03:00 London GMT|
|                                                             |
|  +-------------------------------------------------------+  |
|  | Total Pembayaran: Rp 300.000 ($19.35 USD)             |  |
|  |               [   LANJUT PEMBAYARAN   ]               |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                                           [ 💬 Chat Reader ]|
|                                           (Hanya muncul bila|
|                                            Reader sdh mulai)|
+-------------------------------------------------------------+
| [🏠 Beranda] [🔮 Layanan] [✨ Hub] [💬 Chat AI] [👤 Profil] |
+-------------------------------------------------------------+
```

### 4.2 Layar Pembayaran QRIS Dinamis (`PaymentScreen`)
Layar penyelesaian transaksi dengan simulasi pembayaran dan penambangan blok instan.

```
+-------------------------------------------------------------+
| [ < ]  PEMBAYARAN KONSULTASI                                |
+-------------------------------------------------------------+
|                                                             |
|                  Selesaikan Dalam: 14:59                    |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Rincian Pemesanan:                                    |  |
|  | • Layanan : Tarot Asmara & Belahan Jiwa               |  |
|  | • Jadwal  : 28 Okt 2026, 10:00 - 12:00 WIB (2 Sesi)   |  |
|  | • Reader  : Master Alistair (Official Reader)         |  |
|  | • Total   : Rp 300.000 / $19.35 USD                   |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                     KODE QRIS RESMI                         |
|                 +-----------------------+                   |
|                 | [ X X X X X X X X X ] |                   |
|                 | [ X   [QR CODE]   X ] |                   |
|                 | [ X X X X X X X X X ] |                   |
|                 |      NMID: 938210     |                   |
|                 +-----------------------+                   |
|            Pindai dengan GoPay, OVO, Dana, BCA              |
|                                                             |
|  (i) Setelah pembayaran berhasil, transaksi akan otomatis   |
|      disegel ke dalam blockchain The Destiny Chain.         |
|                                                             |
|             [   SIMULASIKAN PEMBAYARAN LUNAS   ]            |
|                                                             |
|                    (   Batalkan Pesanan   )                 |
|                                                             |
+-------------------------------------------------------------+
```

---

# BAB V: WIREFRAME BLOCKCHAIN IN-APP (THE DESTINY CHAIN)

### 5.1 Layar Riwayat Rantai Blok Bertingkat (`OrderHistoryScreen`)
Menampilkan kartu riwayat yang terhubung garis rantai vertikal dengan badge `🔒 Blockchain Verified`.

```
+-------------------------------------------------------------+
| [ < ]  THE DESTINY CHAIN                                    |
|        Riwayat Terverifikasi Blockchain                     |
+-------------------------------------------------------------+
|                                                             |
|  ( o )--+  +---------------------------------------------+  |
|    |    |  | Tarot Asmara & Belahan Jiwa  [🔒 Terverifikasi] |
|    |    |  | Master Alistair • 28 Okt 2026, 10:00 WIB     |  |
|    |    |  | Total: Rp 300.000 • 2 Sesi Konsultasi        |  |
|    |    |  +---------------------------------------------+  |
|    |                                                        |
|  ( o )--+  +---------------------------------------------+  |
|    |    |  | Konsultasi Penyelarasan Aura [🔒 Terverifikasi] |
|    |    |  | Master Madame Arcanova • 20 Okt 2026, 14:00   |  |
|    |    |  | Total: Rp 150.000 • 1 Sesi                   |  |
|    |    |  | [ v Ketuk untuk Rincian Kriptografi ]       |  |
|    |    |  |                                             |  |
|    |    |  | Nomor Blok   : Block #840291                |  |
|    |    |  | Trans. Hash  : 0x7f8a9b...c1d2              |  |
|    |    |  | Status Segel : IMMUTABLE (Tidak dpt diubah) |  |
|    |    |  |                                             |  |
|    |    |  |            [ 📋 Salin Kunci Validasi ]      |  |
|    |    |  +---------------------------------------------+  |
|    |                                                        |
|  ( * )     +---------------------------------------------+  |
|            | GENESIS BLOCK #0                            |  |
|            | Inaugural Mystic Arcanova Portal Ledger     |  |
|            +---------------------------------------------+  |
|                                                             |
+-------------------------------------------------------------+
```

---

# BAB VI: WIREFRAME HUB MISTIS & LBS QUEST

### 6.1 Mini-Game Cosmic Love Match & GPS Quest (`MysticHubScreen`)
Kombinasi mini-game astrologi dan geofencing LBS OpenStreetMap.

```
+-------------------------------------------------------------+
| HUB MISTIS & PERMAINAN ENERGI                               |
+-------------------------------------------------------------+
|                                                             |
|  +-------------------------------------------------------+  |
|  | MINI-GAME 1: COSMIC LOVE COMPATIBILITY                |  |
|  | Uji kecocokan energi batin dua rasi bintang           |  |
|  |                                                       |  |
|  |  [ Zodiak Kamu: Gemini ♊ ]   [ Pasangan: Libra ♎  [v] ]|  |
|  |                                                       |  |
|  |            SKOR KESELARASAN: 92% (SANGAT COCOK)       |  |
|  |            [ ==============================-- ]       |  |
|  |                                                       |  |
|  |  "Kombinasi elemen Udara & Udara menciptakan ikatan   |  |
|  |   intelektual yang harmonis dan penuh kebebasan."     |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | MINI-GAME 2: SANCTUARY GPS QUEST                      |  |
|  | Pelacak lokasi suci pembacaan energi terdekat         |  |
|  |                                                       |  |
|  |  Koordinat Anda : -7.797064, 110.370529               |  |
|  |  Wilayah Aktual : Danurejan, Kota Yogyakarta (OSM API)|  |
|  |                                                       |  |
|  |  Tempat Suci Terdekat:                                |  |
|  |  • Malioboro Arcane Sanctum   (Jarak: 420 meter)  📍   |  |
|  |  • Tugu Mystic Observatory    (Jarak: 1.2 km)     📍   |  |
|  |                                                       |  |
|  |                 [ 🔄 Perbarui Lokasi GPS ]            |  |
|  +-------------------------------------------------------+  |
|                                                             |
+-------------------------------------------------------------+
| [🏠 Beranda] [🔮 Layanan] [✨ Hub] [💬 Chat AI] [👤 Profil] |
+-------------------------------------------------------------+
```

---

# BAB VII: WIREFRAME FITUR KOMUNIKASI & AI

### 7.1 Layar Chat AI Curhat: Madame Arcanova (`AiChatScreen`)
Antarmuka percakapan AI dengan gaya bahasa hangat empatik dan guardrail tematik.

```
+-------------------------------------------------------------+
| [ < ]  [  X  ] MADAME ARCANOVA                              |
|        Online • Asisten Tarot & Sahabat Curhat Jiwa         |
+-------------------------------------------------------------+
|                                                             |
|  [ Madame Arcanova - 09:42 ]                                |
|  +-------------------------------------------------------+  |
|  | Halo sahabat jiwaku! ✨ Kartu apa yang sedang berbisik |  |
|  | di hatimu hari ini? Ceritakan apa saja yang sedang    |  |
|  | membuat batinmu gundah, aku di sini mendengarkan.     |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                                        [ Anda - 09:43 ]     |
|                               +--------------------------+  |
|                               | Akhir-akhir ini aku lagi |  |
|                               | bingung soal arah karir  |  |
|                               | dan kelulusan kuliahku...|  |
|                               +--------------------------+  |
|                                                             |
|  [ Madame Arcanova - 09:43 ]                                |
|  +-------------------------------------------------------+  |
|  | Wajar banget kalau kamu merasa begitu... 🌿 Kartu     |  |
|  | *The Chariot* hadir mengingatkan bahwa kegigihanmu    |  |
|  | sedang diuji untuk melesat maju. Kamu sudah berusaha  |  |
|  | sangat baik sejauh ini!                               |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  Topik Cepat: ( Ramal Asmara ) ( Arti Kartu ) ( Karir Batin )|
|                                                             |
|  +-------------------------------------------------------+  |
|  | [ Curahkan isi hatimu di sini...                 ] [>] |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

### 7.2 Layar Live Chat Konsultasi WA-Style (`ReaderChatScreen`)
Ruang obrolan langsung antara Klien dan Tarot Reader tersinkronisasi via PostgreSQL laptop.

```
+-------------------------------------------------------------+
| [ < ]  [  X  ] MASTER ALISTAIR (TAROT READER)               |
|        Konsultasi Sesi #BK-8291 • Sesi Live 10:00 - 12:00   |
+-------------------------------------------------------------+
|                                                             |
|                 --- HARI INI, 28 OKT 2026 ---               |
|                                                             |
|  [ Master Alistair - 10:01 ]                                |
|  +-------------------------------------------------------+  |
|  | Halo, salam damai. Saya Master Alistair telah membuka |  |
|  | ruang konsultasi ini. Kartu pertama yang saya tarik   |  |
|  | untuk Anda adalah *Two of Cups*. Silakan ajukan       |  |
|  | pertanyaan fokus pertama Anda.                         |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                                        [ Anda - 10:02 ]     |
|                               +--------------------------+  |
|                               | Terima kasih Master. Saya|  |
|                               | ingin menanyakan prospek |  |
|                               | hubungan saya ke depan.  |  |
|                               |                    10:02 |  |
|                               +--------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | [ Ketik pesan konsultasi ke reader...            ] [>] |  |
|  +-------------------------------------------------------+  |
+-------------------------------------------------------------+
```

---

# BAB VIII: WIREFRAME PROFIL, LEDGER & EVALUASI PERKULIAHAN

### 8.1 Layar Profil & Pengaturan Akun (`ProfileScreen`)
Pusat kendali pengguna, toggle sensor biometrik, ledger blockchain, dan evaluasi PAM.

```
+-------------------------------------------------------------+
| PROFIL SAYA                                                 |
+-------------------------------------------------------------+
|                                                             |
|  +-------------------------------------------------------+  |
|  |  +---------+   Kaylaneza                                  |
|  |  |  [ X ]  |   kayla@example.com                          |
|  |  | 👨 / 👩 |   Zodiak: Gemini ♊ (Elemen Udara)            |
|  |  +---------+   Zona: Asia/Jakarta (WIB)                   |
|  +-------------------------------------------------------+  |
|                                                             |
|  MENU PENGATURAN & LAYANAN:                                 |
|  +-------------------------------------------------------+  |
|  | [🕒] Riwayat Pemesanan (The Destiny Chain)        [ > ]|  |
|  | [💬] Chat Tarot Reader (WhatsApp Style)           [ > ]|  |
|  | [✏️] Edit Profil (Nama, Sandi, Avatar Gender)     [ > ]|  |
|  | [🔒] Login Sidik Jari (Fingerprint)         [─── o ───]|  |
|  | [📝] Saran & Kesan Mata Kuliah PAM                [ > ]|  |
|  +-------------------------------------------------------+  |
|                                                             |
|  BLOCKCHAIN READING LEDGER:                                 |
|  +-------------------------------------------------------+  |
|  | [ ⛓️ ] Total Blok Ditambang: 3 Blok                      |  |
|  |        [ ⛏️ Tambang Blok (PoW) ]   [ 🛡️ Verifikasi ]      |  |
|  +-------------------------------------------------------+  |
|                                                             |
|                 [   KELUAR SESI (LOGOUT)   ]                |
|                                                             |
|                 (   Hapus Akun Permanen   )                 |
|                                                             |
+-------------------------------------------------------------+
| [🏠 Beranda] [🔮 Layanan] [✨ Hub] [💬 Chat AI] [👤 Profil] |
+-------------------------------------------------------------+
```

### 8.2 Layar Evaluasi: Saran & Kesan Matkul PAM (`CourseFeedbackScreen`)
Formulir evaluasi mata kuliah yang tersinkronisasi ke PostgreSQL pgAdmin laptop.

```
+-------------------------------------------------------------+
| [ < ]  SARAN & KESAN MATKUL PAM                             |
+-------------------------------------------------------------+
|                                                             |
|  Nama Mahasiswa:                                            |
|  [ Kaylaneza                                              ] |
|                                                             |
|  Nomor Induk Mahasiswa (NIM):                               |
|  [ 123220000                                              ] |
|                                                             |
|  Penilaian Pengalaman Perkuliahan (Rating):                 |
|  [ ⭐ ⭐ ⭐ ⭐ ⭐ ]  (5.0 / 5.0 Bintang)                    |
|                                                             |
|  Kesan Selama Perkuliahan:                                  |
|  +-------------------------------------------------------+  |
|  | Praktikum dan materi kuliah Pemrograman Aplikasi      |  |
|  | Mobile sangat aplikatif dan menantang, memberikan    |  |
|  | pemahaman menyeluruh tentang Flutter, database, dan   |  |
|  | integrasi sensor mobile.                              |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  Saran untuk Pengembangan Mata Kuliah:                      |
|  +-------------------------------------------------------+  |
|  | Diharapkan modul praktikum dapat ditambah materi      |  |
|  | state management modern dan CI/CD deployment ke store.|  |
|  +-------------------------------------------------------+  |
|                                                             |
|           [   KIRIM MASUKAN KE DATABASE CLOUD   ]           |
|                                                             |
+-------------------------------------------------------------+
```

---

# BAB IX: WIREFRAME DASHBOARD TAROT READER (READER POV)

### 9.1 Layar Tarot Reader Portal (`TarotReaderPortalScreen`)
Dashboard khusus bagi praktisi konsultasi (`arcreader`) untuk mengelola sesi dan memulai chat.

```
+-------------------------------------------------------------+
| PORTAL TAROT READER (MASTER ALISTAIR)           [ Logout ]  |
| Status Praktisi: [🟢 ONLINE & SIAP MEMBIMBING]              |
+-------------------------------------------------------------+
|                                                             |
|  STATISTIK SESI HARI INI:                                   |
|  +--------------------------+  +--------------------------+ |
|  | 2 Sesi Terjadwal         |  | Jam Operasional          | |
|  | Total Klien: 2 Orang     |  | 09:00 - 18:00 WIB        | |
|  +--------------------------+  +--------------------------+ |
|                                                             |
|  DAFTAR KLIEN YANG SUDAH MEMESAN SESI:                      |
|  +-------------------------------------------------------+  |
|  | Klien   : Kaylaneza (#BK-8291)                        |  |
|  | Layanan : Tarot Asmara & Belahan Jiwa                 |  |
|  | Jadwal  : 28 Okt 2026, 10:00 - 12:00 WIB (2 Sesi)    |  |
|  | Status  : LUNAS (Rp 300.000 / $19.35 USD)             |  |
|  |                                                       |  |
|  |           [ 💬 Buka Ruang Konsultasi (WA-Style) ]     |  |
|  |           (Inisiasi pesan pertama agar chat klien on) |  |
|  +-------------------------------------------------------+  |
|                                                             |
|  +-------------------------------------------------------+  |
|  | Klien   : Dimas Putra (#BK-8295)                      |  |
|  | Layanan : Karir & Finansial                           |  |
|  | Jadwal  : 28 Okt 2026, 14:00 - 15:00 WIB (1 Sesi)    |  |
|  |                                                       |  |
|  |           ( 💬 Buka Ruang Konsultasi )                |  |
|  +-------------------------------------------------------+  |
|                                                             |
|             ( 🗑️ Hapus Riwayat Kedaluwarsa >3 Hari )        |
|                                                             |
+-------------------------------------------------------------+
```

---

# BAB X: WIREFRAME MODAL DIALOG & FEEDBACK SISTEM

### 10.1 Modal Penambangan Blok PoW Kriptografi
```
+-------------------------------------------------------------+
|                [ ⛏️ TAMBANG BLOK AFIRMASI ]                  |
|                                                             |
|  Fitur blockchain aktif: Tambang blok baru dengan           |
|  komputasi Proof-of-Work (PoW) dan enkripsi SHA-256.        |
|                                                             |
|  Catatan / Niat Jiwa:                                       |
|  [ Penyelarasan Aura & Bimbingan Jiwa                     ] |
|                                                             |
|  Target Tingkat Kesulitan : 2 (Prefix Hash '00')            |
|                                                             |
|         ( Batal )            [ Mulai Menambang (PoW) ]      |
+-------------------------------------------------------------+
```

### 10.2 Modal Verifikasi Integritas Rantai Blok
```
+-------------------------------------------------------------+
|                 [ 🛡️ HASIL VERIFIKASI RANTAI ]               |
|                                                             |
|  [ v ] Seluruh hash blok valid dan berurutan secara presisi!|
|  [ v ] Previous Hash cocok dari Blok #0 hingga Blok #3.     |
|  [ v ] Tidak terdeteksi manipulasi data lokal atau cloud.   |
|                                                             |
|  Status Rantai: 100% IMMUTABLE & TERVERIFIKASI              |
|                                                             |
|                         [   TUTUP   ]                       |
+-------------------------------------------------------------+
```

---
**Dokumen wireframe grayscale ini memetakan seluruh tata letak arsitektur antarmuka dan interaksi fungsional sistem ARCANOVA secara lengkap dan presisi.**

