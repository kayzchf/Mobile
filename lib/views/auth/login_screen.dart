import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../main_navigation.dart';
import '../reader_portal/reader_portal_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _rememberedUsername;
  int? _rememberedUserId;

  @override
  void initState() {
    super.initState();
    _loadRememberedAccount();
  }

  Future<void> _loadRememberedAccount() async {
    final username = await AuthService.instance.getLastUsername();
    final uid = await AuthService.instance.getLastSessionUserId();
    if (mounted && username != null) {
      setState(() {
        _rememberedUsername = username;
        _rememberedUserId = uid;
        _usernameController.text = username;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await AuthService.instance.login(
      usernameOrEmail: _usernameController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      final user = AuthService.instance.currentUser;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.mysticViolet,
          content: Text("✨ Halo ${user?.username ?? 'sahabat'}, senang melihatmu kembali!"),
        ),
      );

      if (user?.isReader == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TarotReaderPortalScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text(res['message'] ?? "Oops, gagal masuk."),
        ),
      );
    }
  }

  Future<void> _handleFingerprintLogin() async {
    await _loadRememberedAccount();
    if (!mounted) return;
    if (_rememberedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warningOrange,
          content: Text("Belum ada akun tersimpan di HP ini. Silakan daftar atau login manual dulu ya!"),
        ),
      );
      return;
    }

    final result = await BiometricService.instance.authenticateWithFingerprint();

    if (!mounted) return;

    if (result['success'] == true) {
      final loggedIn = await AuthService.instance.loginWithBiometrics(_rememberedUserId!);
      if (loggedIn && mounted) {
        final user = AuthService.instance.currentUser;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successEmerald,
            content: Text("✨ Sidik jari cocok! Selamat datang, ${user?.username ?? 'Sahabat'}."),
          ),
        );

        if (user?.isReader == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TarotReaderPortalScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
          );
        }
        return;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.errorCrimson,
        content: Text(result['message'] ?? "Autentikasi sidik jari gagal."),
      ),
    );
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.mysticButton,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.neonPurple.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text("🔮", style: TextStyle(fontSize: 34)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "MASUK KE ARCANOVA",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 4),
              const Text(
                "Buka kembali portal takdir dan peta batinmu",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.shimmerSilver, fontSize: 13),
              ),
              const SizedBox(height: 28),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username atau Email",
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: "Ketik username atau email kamu",
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? "Username atau email wajib diisi ya!" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Kata Sandi",
                        prefixIcon: const Icon(Icons.lock_outline),
                        hintText: "Ketik kata sandi akunmu",
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.shimmerSilver,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (v) => (v == null || v.isEmpty) ? "Kata sandi wajib diisi ya!" : null,
                    ),
                    const SizedBox(height: 22),

                    // Login Button (Pelanggan)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: AppColors.neonPurple,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text(
                              "Masuk Akun",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Fingerprint Biometric Login Button
                    OutlinedButton.icon(
                      onPressed: _handleFingerprintLogin,
                      icon: const Icon(Icons.fingerprint, color: AppColors.celestialCyan, size: 22),
                      label: Text(
                        _rememberedUsername != null
                            ? "Masuk Sidik Jari ($_rememberedUsername)"
                            : "Masuk dengan Sidik Jari",
                        style: const TextStyle(color: AppColors.celestialCyan, fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        side: const BorderSide(color: AppColors.celestialCyan, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Belum punya akun? ",
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          child: const Text(
                            "Daftar di sini yuk!",
                            style: TextStyle(
                              color: AppColors.brightLavender,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
