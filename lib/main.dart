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

  // Requirement: Every time the app opens, start in Guest Mode by default
  // Users with accounts can tap the fingerprint button to quickly log in
  AuthService.instance.enterGuestMode();

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
