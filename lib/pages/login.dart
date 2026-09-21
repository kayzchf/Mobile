import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../arcanova_db.dart';
import '../app_data.dart';

import 'register.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username dan password harus diisi!',
          ),
        ),
      );

      return;
    }

    final user = await ArcanovaDB.instance.loginUser(
      username: username,
      password: password,
    );

    if (user != null) {
      // Simpan ID user yang sedang login
      AppData.currentUserId = user['id'] as int;

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );

      return;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Username atau password salah!',
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,

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

        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 430,
              ),

              child: Column(
                children: [
                  const Text(
                    '🔮',
                    style: TextStyle(
                      fontSize: 60,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

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

                  const SizedBox(
                    height: 30,
                  ),

                  Card(
                    color: const Color(0xFF0F172A),

                    child: Padding(
                      padding: const EdgeInsets.all(22),

                      child: Column(
                        children: [
                          TextField(
                            controller: usernameController,

                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(
                                Icons.person,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 15,
                          ),

                          TextField(
                            controller: passwordController,

                            obscureText: true,

                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock,
                              ),
                            ),
                          ),

                          const SizedBox(
                            height: 20,
                          ),

                          SizedBox(
                            width: double.infinity,

                            child: FilledButton(
                              onPressed: login,

                              child: const Text(
                                'MASUK',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  const Text(
                    'Belum memiliki akun?',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },

                    child: const Text(
                      'Daftar Akun Baru',
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Text(
                    'Silakan gunakan akun yang sudah terdaftar.',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
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