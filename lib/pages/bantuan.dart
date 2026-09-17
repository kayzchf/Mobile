import 'package:flutter/material.dart';
import '../app_data.dart';
import 'login.dart';

class BantuanPage extends StatelessWidget {
  final VoidCallback onLogout;

  const BantuanPage({
    super.key,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = AppData.currentUser!;

    return ListView(
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
          ),
        ),

        const SizedBox(height: 20),

        Card(
          color: const Color(0xFF0F172A),
          child: const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'Petunjuk Penggunaan\n\n'
              '1. Menu Utama digunakan untuk mengakses fitur utama Arcanova.\n\n'
              '2. Get to Know Us berisi informasi mengenai Arcanova dan Tarot Reader.\n\n'
              '3. Profil User digunakan untuk mengubah informasi akun.\n\n'
              '4. Layanan Tarot digunakan untuk melihat, menambah, mengedit, menghapus, dan memesan layanan tarot.\n\n'
              '5. Konversi Hijriah & Umur digunakan untuk menghitung usia.\n\n'
              '6. Weton & Saka Bali digunakan untuk melihat kalender tradisional.\n\n'
              '7. Stopwatch digunakan untuk membantu mencatat durasi sesi konsultasi.',
              style: TextStyle(
                height: 1.7,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Card(
          color: const Color(0xFF2E1065),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'Akun yang sedang login:\n\n'
              '${user.nama}\n'
              '${user.username}\n'
              '${user.email}',
              style: const TextStyle(
                height: 1.7,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              AppData.currentUser = null;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(),
                ),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('LOGOUT'),
          ),
        ),
      ],
    );
  }
}