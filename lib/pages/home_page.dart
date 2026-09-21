import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_data.dart';
import '../arcanova_db.dart';

import 'about_us.dart';
import 'bantuan.dart';
import 'hijriah.dart';
import 'layanan.dart';
import 'login.dart';
import 'profile.dart';
import 'stopwatch.dart';
import 'weton_saka.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  String namaUser = 'User';
  bool isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final userId = AppData.currentUserId;

    if (userId == null) {
      setState(() {
        namaUser = 'User';
        isLoadingUser = false;
      });
      return;
    }

    try {
      final user = await ArcanovaDB.instance.getUserById(userId);

      if (mounted) {
        setState(() {
          namaUser = user?['nama'] ?? 'User';
          isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          namaUser = 'User';
          isLoadingUser = false;
        });
      }
    }
  }

  void logout() {
    AppData.currentUserId = null;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  //menu utama
  Widget buildHome() {
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
          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        color: Color(0xFFC4B5FD),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 4),

                    isLoadingUser
                        ? const SizedBox(
                            height: 27,
                            width: 27,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFD8B4FE),
                            ),
                          )
                        : Text(
                            namaUser,
                            style: const TextStyle(
                              color: Color(0xFFE9D5FF),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ],
                ),
              ),

              const CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage(
                  'assets/images/Arcanova Logo.jpeg',
                ),
              ),
            ],
          ),

          const SizedBox(height: 35),

          Center(
            child: Text(
              'ARCANOVA',
              style: GoogleFonts.cinzelDecorative(
                color: const Color(0xFFD8B4FE),
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

          const SizedBox(height: 25),

          menuCard(
            icon: Icons.auto_awesome,
            title: 'Get to Know Us',
            subtitle: 'Mengenal Arcanova dan Tarot Reader',
            page: const AboutUsPage(),
          ),

          menuCard(
            icon: Icons.person_outline,
            title: 'Profil User',
            subtitle: 'Edit data akun dan hapus akun',
            page: const ProfilePage(),
          ),

          menuCard(
            icon: Icons.style_outlined,
            title: 'Layanan Tarot',
            subtitle: 'Pilih layanan dan pesan sesi tarot',
            page: const LayananPage(),
          ),

          menuCard(
            icon: Icons.calendar_month,
            title: 'Konversi Hijriah & Umur',
            subtitle: 'Hitung usia secara detail',
            page: const HijriahPage(),
          ),

          menuCard(
            icon: Icons.public,
            title: 'Weton & Saka Bali',
            subtitle: 'Kalender Jawa dan Bali',
            page: const WetonSakaPage(),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }


  Widget menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      color: const Color(0xFF0F172A),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          child: Row(
            children: [

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B0764),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFFD8B4FE),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Color(0xFFA78BFA),
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      const StopwatchPage(),
      BantuanPage(
        onLogout: logout,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[selectedIndex],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Utama',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.timer_outlined,
            ),
            selectedIcon: Icon(
              Icons.timer,
            ),
            label: 'Stopwatch',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.help_outline,
            ),
            selectedIcon: Icon(
              Icons.help,
            ),
            label: 'Bantuan',
          ),
        ],
      ),
    );
  }
}