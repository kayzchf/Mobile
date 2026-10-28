import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import 'home/home_screen.dart';
import 'booking/services_screen.dart';
import 'games/mystic_hub_screen.dart';
import 'ai_chat/ai_chat_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  DateTime? _backgroundTimestamp;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServicesScreen(),
    MysticHubScreen(),
    AiChatScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AuthService.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _backgroundTimestamp = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_backgroundTimestamp != null) {
        final elapsed = DateTime.now().difference(_backgroundTimestamp!);
        // Criteria: if more than 5 minutes (300 seconds) in background, auto logout
        if (elapsed.inSeconds >= 300 && AuthService.instance.isAuthenticated) {
          AuthService.instance.enterGuestMode();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                backgroundColor: AppColors.neonPurple,
                duration: Duration(seconds: 4),
                content: Text(
                  "⏳ Sesi kamu telah berakhir (lebih dari 5 menit di luar aplikasi). Akun otomatis logout ke Mode Tamu untuk keamanan.",
                ),
              ),
            );
          }
        }
      }
      _backgroundTimestamp = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.voidBlack,
          border: Border(
            top: BorderSide(
              color: AppColors.mysticViolet.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.voidBlack.withValues(alpha: 0.8),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.neonPurple.withValues(alpha: 0.4),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.style_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.style, color: AppColors.brightLavender),
              label: "Deck",
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_awesome_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.auto_awesome, color: AppColors.arcaneSilver),
              label: "Layanan",
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.sports_esports, color: AppColors.celestialCyan),
              label: "Games",
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.chat_bubble, color: AppColors.brightLavender),
              label: "AI Chat",
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.person, color: AppColors.arcaneSilver),
              label: "Profil",
            ),
          ],
        ),
      ),
    );
  }
}
