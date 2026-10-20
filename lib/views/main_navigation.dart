import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
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

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ServicesScreen(),
    MysticHubScreen(),
    AiChatScreen(),
    ProfileScreen(),
  ];

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
              color: AppColors.mysticViolet.withOpacity(0.25),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.voidBlack.withOpacity(0.8),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.neonPurple.withOpacity(0.4),
          elevation: 0,
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

