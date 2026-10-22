import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthDateController = TextEditingController();

  String _selectedTimezone = 'WIB';
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _timezones = ['WIB', 'WITA', 'London (GMT)'];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2002, 5, 15),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardSurface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _birthDateController.text = formatted;
      });
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final res = await AuthService.instance.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      birthDate: _birthDateController.text,
      timezonePref: _selectedTimezone,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.mysticViolet,
          content: Text("✨ Akun Arcanova berhasil dibuat! Selamat datang."),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text(res['message'] ?? "Registrasi gagal."),
        ),
      );
    }
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    "BUAT AKUN ARCANOVA",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.brightLavender,
                          letterSpacing: 1.5,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    "Tuliskan takdirmu dan temukan jalan spiritualmu",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),

                // Username
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: "Nama Pengguna (Username)",
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Username wajib diisi" : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Alamat Email",
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return "Email wajib diisi";
                    if (!v.contains('@')) return "Format email tidak valid";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Kata Sandi (Enkripsi SHA-256)",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.brightLavender,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Kata sandi wajib diisi";
                    if (v.length < 6) return "Kata sandi minimal 6 karakter";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tanggal Lahir (Birth Date)
                TextFormField(
                  controller: _birthDateController,
                  readOnly: true,
                  onTap: _selectBirthDate,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Lahir (Untuk Zodiak & Kosmis)",
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.calendar_month, color: AppColors.brightLavender),
                    hintText: "Pilih tanggal lahir",
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Pilih tanggal lahir Anda" : null,
                ),
                const SizedBox(height: 16),

                // Wilayah / Timezone
                DropdownButtonFormField<String>(
                  initialValue: _selectedTimezone,
                  dropdownColor: AppColors.cardSurface,
                  decoration: const InputDecoration(
                    labelText: "Zona Waktu Domisili Anda",
                    prefixIcon: Icon(Icons.access_time_outlined),
                  ),
                  items: _timezones.map((tz) {
                    return DropdownMenuItem(
                      value: tz,
                      child: Text(tz, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedTimezone = val);
                  },
                ),
                const SizedBox(height: 36),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
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
                          "Daftar & Masuk Gerbang Arcanova",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

