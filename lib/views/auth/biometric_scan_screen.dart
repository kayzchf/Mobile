import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/biometric_service.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';

class BiometricScanScreen extends StatefulWidget {
  final int userId;

  const BiometricScanScreen({super.key, required this.userId});

  @override
  State<BiometricScanScreen> createState() => _BiometricScanScreenState();
}

class _BiometricScanScreenState extends State<BiometricScanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scanAnimation;
  bool _isAuthenticating = false;
  String _statusText = "Arahkan wajah Anda ke lingkaran kosmis...";

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: -100.0, end: 100.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Auto-trigger biometric scan after brief delay for visual experience
    Future.delayed(const Duration(milliseconds: 600), _startFaceScan);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startFaceScan() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
      _statusText = "Memindai frekuensi biometrik wajah...";
    });

    final success = await BiometricService.instance.authenticateWithFace();

    if (!mounted) return;

    if (success) {
      final loginSuccess = await AuthService.instance.loginWithBiometrics(widget.userId);
      if (loginSuccess && mounted) {
        setState(() {
          _statusText = "Aura Wajah Terverifikasi! Membuka Portal...";
        });
        await Future.delayed(const Duration(milliseconds: 700));
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
            (route) => false,
          );
        }
        return;
      }
    }

    setState(() {
      _isAuthenticating = false;
      _statusText = "Autentikasi wajah gagal atau dibatalkan. Coba lagi.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brightLavender),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "ARCANOVA BIOMETRIC",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.celestialCyan,
                      letterSpacing: 2.0,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                "Verifikasi Wajah Jiwa Pemilik",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),

              // Mystic Scanner Ring
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neonPurple.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.mysticViolet.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.celestialCyan.withOpacity(0.7),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural,
                      size: 90,
                      color: AppColors.brightLavender,
                    ),
                  ),

                  // Animated Scanning Laser Line
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _scanAnimation.value),
                        child: Container(
                          width: 180,
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.celestialCyan,
                                Colors.white,
                                AppColors.celestialCyan,
                                Colors.transparent,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.celestialCyan.withOpacity(0.8),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 40),
              Text(
                _statusText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isAuthenticating ? AppColors.celestialCyan : AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton.icon(
                onPressed: _isAuthenticating ? null : _startFaceScan,
                icon: const Icon(Icons.fingerprint),
                label: const Text("Pindai Ulang"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cardSurfaceLight,
                  side: const BorderSide(color: AppColors.neonPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

