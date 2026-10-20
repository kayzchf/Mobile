import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/blockchain_service.dart';
import 'views/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService.instance.init();

  // Ensure blockchain genesis block is generated
  await BlockchainService.instance.ensureGenesisBlock();

  // Check persisted user session (if any)
  await AuthService.instance.restoreSession();

  // Open directly to dashboard (Guest by default if not logged in)
  runApp(const ArcanovaApp());
}

class ArcanovaApp extends StatelessWidget {
  const ArcanovaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Arcanova - Tarot Reading',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationScreen(),
    );
  }
}
