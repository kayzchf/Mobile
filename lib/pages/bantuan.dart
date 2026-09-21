import 'package:flutter/material.dart';

class BantuanPage extends StatelessWidget {
  final VoidCallback onLogout;

  const BantuanPage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2E1065),
            Color(0xFF0F172A),
            Color(0xFF030712),
          ],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Bantuan & Panduan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE9D5FF),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Cara menggunakan aplikasi Arcanova',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 20),

          Card(
            color: const Color(0xFF0F172A),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Petunjuk Penggunaan',
                    style: TextStyle(
                      color: Color(0xFFD8B4FE),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    '1. Menu Utama digunakan untuk mengakses '
                    'fitur utama Arcanova.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '2. Get to Know Us berisi informasi mengenai '
                    'Arcanova dan Tarot Reader.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '3. Profil User digunakan untuk melihat dan '
                    'mengubah informasi akun.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '4. Layanan Tarot digunakan untuk melihat '
                    'layanan tarot yang tersedia dan memesan '
                    'sesi tarot.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '5. Konversi Hijriah & Umur digunakan untuk '
                    'melihat tanggal Hijriah dan menghitung usia '
                    'secara detail.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '6. Weton & Saka Bali digunakan untuk melihat '
                    'informasi kalender tradisional Jawa dan Bali.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    '7. Stopwatch digunakan untuk membantu mencatat '
                    'durasi sesi konsultasi atau aktivitas lainnya.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            color: const Color(0xFF0F172A),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cara Memesan Layanan Tarot',
                    style: TextStyle(
                      color: Color(0xFFD8B4FE),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    '1. Buka menu Layanan Tarot.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '2. Pilih layanan tarot yang ingin dipesan.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '3. Tentukan jumlah sesi yang diinginkan.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '4. Masukkan kode voucher jika memiliki voucher.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '5. Periksa subtotal, diskon, dan total pembayaran.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '6. Tekan "Pesan Sekarang" untuk menyimpan '
                    'pemesanan.',

                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 15),

          Card(
            color: const Color(0xFF2E1065),
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voucher Arcanova',
                    style: TextStyle(
                      color: Color(0xFFE9D5FF),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'arcanova15  →  Diskon 15%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    'arcanova20  →  Diskon 20%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),

                  SizedBox(height: 12),

                  Text(
                    'Masukkan kode voucher saat melakukan '
                    'pemesanan layanan tarot.',

                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          //Logout
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text(
                        'Logout',
                      ),

                      content: const Text(
                        'Apakah kamu yakin ingin keluar '
                        'dari akun Arcanova?',
                      ),

                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          child: const Text(
                            'Batal',
                          ),
                        ),

                        FilledButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            onLogout();
                          },
                          child: const Text(
                            'Logout',
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.logout,
              ),
              label: const Text(
                'LOGOUT',
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}