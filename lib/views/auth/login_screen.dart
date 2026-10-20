import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../main_navigation.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.mysticViolet,
          content: Text("✨ Halo sahabat, senang melihatmu kembali!"),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
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
    // 1. Check if an account is registered
    if (_rememberedUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warningOrange,
          content: Text("Belum ada akun tersimpan di HP ini. Silakan daftar atau login manual dulu ya!"),
        ),
      );
      return;
    }

    // 2. Trigger native fingerprint prompt
    final result = await BiometricService.instance.authenticateWithFingerprint();

    if (!mounted) return;

    if (result['success'] == true) {
      final loggedIn = await AuthService.instance.loginWithBiometrics(_rememberedUserId!);
      if (loggedIn && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successEmerald,
            content: Text("✨ Sidik jari cocok! Selamat datang, ${_rememberedUsername ?? 'Sahabat'}."),
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        );
        return;
      }
    }

    // Show error or guidance
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Center(
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.mysticButton,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.mysticViolet.withValues(alpha: 0.5),
                            blurRadius: 25,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text("🔮", style: TextStyle(fontSize: 42)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  Center(
                    child: Text(
                      "ARCANOVA",
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            letterSpacing: 3.5,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      "Yuk masuk ke akun kamu!",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.shimmerSilver,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Username
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      hintText: "Ketik username akunmu...",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Username wajib diisi ya!" : null,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Kata Sandi",
                      hintText: "Masukkan kata sandimu...",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.shimmerSilver,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? "Kata sandi wajib diisi ya!" : null,
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppColors.neonPurple,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            "Masuk Sekarang",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                  ),
                  const SizedBox(height: 14),

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
                      padding: const EdgeInsets.symmetric(vertical: 14),
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
          ),
        ),
      ),
    );
  }
}
