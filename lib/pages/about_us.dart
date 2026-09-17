import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get to Know Us'),
      ),
      body: Container(
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
            const SizedBox(height: 10),

            // LOGO / ICON
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/Arcanova Logo.jpeg'),
              ),
            ),

            const SizedBox(height: 20),

            // NAMA APLIKASI
            Center(
              child: Text(
              'ARCANOVA',
                style: GoogleFonts.cinzelDecorative(
                  color: Color(0xFFD8B4FE),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  ),
              ),
            ),

          const SizedBox(height: 8),

          Center(
            child: Text(
              'Your Story, Written in the Cards',
              style: GoogleFonts.cormorantGaramond(
                color: Colors.white54,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

            const SizedBox(height: 30),

            // ABOUT ARCANOVA
            Card(
              color: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tentang Arcanova',
                      style: TextStyle(
                        color: Color(0xFFD8B4FE),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'Arcanova adalah aplikasi pembacaan kartu tarot '
                      'digital interaktif yang dirancang untuk membimbing '
                      'perjalanan spiritual, cinta, karier, dan masa depan Anda.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Melalui Arcanova, pengguna dapat memilih layanan '
                      'pembacaan tarot sesuai dengan kebutuhan dan melakukan '
                      'pemesanan sesi bersama Tarot Reader.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // TAROT READERS
            const Text(
              'Tarot Readers',
              style: TextStyle(
                color: Color(0xFFD8B4FE),
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: readerCard(
                    nama: 'Aliya W Laila',
                    nim: '124240012',
                    imagePath: 'assets/images/aliya.jpg',
                  ),
                ),
                const SizedBox(width: 12), // Jarak antar card
                Expanded(
                  child: readerCard(
                    nama: 'Kayla Zachfatuneza',
                    nim: '124240087',
                    imagePath: 'assets/images/neza.jpeg',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // TAGLINE
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2E1065).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.4),
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    '"Your Story, Written in the Cards."',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFE9D5FF),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Setiap kartu memiliki cerita.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget readerCard({
    required String nama,
    required String nim,
    required String imagePath, 
  }) {
    return Card(
      color: const Color(0xFF0F172A),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Foto Tarot Reader (Lingkaran di atas)
            CircleAvatar(
              radius: 35,
              backgroundColor: const Color(0xFF3B0764),
              backgroundImage: AssetImage(imagePath), // Masukkan asset gambar di sini
            ),
            
            const SizedBox(height: 12),

            // Nama Tarot Reader
            Text(
              nama,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // NIM
            Text(
              'NIM: $nim',
              style: const TextStyle(
                color: Color(0xFFA78BFA),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 2),

            // Keterangan tambahan
            const Text(
              'Tarot Reader',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}