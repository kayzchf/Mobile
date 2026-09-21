import 'package:flutter/material.dart';

import '../arcanova_db.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  final namaController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    namaController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    ).hasMatch(email);
  }

  Future<void> register() async {
    // Jangan jalankan proses kedua kali
    if (isLoading) return;

    final nama = namaController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (nama.isEmpty ||
        username.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Semua data harus diisi!',
          ),
        ),
      );

      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format email tidak valid!',
          ),
        ),
      );

      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password minimal 6 karakter!',
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    //simpan ke database
    try {
      await ArcanovaDB.instance.registerUser(
        nama: nama,
        username: username,
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registrasi berhasil! Silakan login.',
          ),
        ),
      );

      // Kembali ke halaman Login
      Navigator.pop(context);
    }

    //error handling
    catch (e) {
      if (!mounted) return;

      String pesan = 'Registrasi gagal. Silakan coba lagi.';

      final error = e.toString();

      // Username atau email sudah ada
      if (error.contains('UNIQUE constraint failed')) {
        if (error.contains('users.username')) {
          pesan = 'Username sudah digunakan!';
        } else if (error.contains('users.email')) {
          pesan = 'Email sudah digunakan!';
        } else {
          pesan = 'Username atau email sudah digunakan!';
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
        ),
      );
    }

    finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registrasi',
        ),
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

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '✨',
                  style: TextStyle(
                    fontSize: 50,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Buat Akun Arcanova',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE9D5FF),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Daftarkan dirimu untuk mulai menggunakan '
                  'layanan Arcanova.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                TextField(
                  controller: namaController,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [
                    AutofillHints.name,
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    labelText: 'Nama Lengkap',
                    hintText: 'Masukkan nama lengkap',
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                    labelText: 'Alamat Email',
                    hintText: 'contoh@email.com',
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextField(
                  controller: usernameController,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.username,
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_circle_outlined,
                    ),
                    labelText: 'Username',
                    hintText: 'Buat username',
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [
                    AutofillHints.newPassword,
                  ],
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  cursorColor: Colors.white,
                  onSubmitted: (_) {
                    register();
                  },
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                    ),
                    labelText: 'Password',
                    hintText: 'Minimal 6 karakter',
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 25,
                ),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLoading ? null : register,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'DAFTAR',
                          ),
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  child: const Text(
                    'Sudah punya akun? Login',
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