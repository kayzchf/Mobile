import 'package:flutter/material.dart';

import '../app_data.dart';
import '../arcanova_db.dart';
import 'login.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController namaController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  final passwordController = TextEditingController();

  Map<String, dynamic>? user;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    namaController = TextEditingController();
    usernameController = TextEditingController();
    emailController = TextEditingController();

    loadUser();
  }

  Future<void> loadUser() async {
    final userId = AppData.currentUserId;

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final data = await ArcanovaDB.instance.getUserById(userId);

    if (!mounted) return;

    setState(() {
      user = data;
      isLoading = false;
    });

    if (data != null) {
      namaController.text = data['nama'] ?? '';
      usernameController.text = data['username'] ?? '';
      emailController.text = data['email'] ?? '';
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  //edit profil
  void editProfile() {
    if (user == null) {
      return;
    }

    // Isi controller dengan data terbaru
    namaController.text = user!['nama'] ?? '';
    usernameController.text = user!['username'] ?? '';
    emailController.text = user!['email'] ?? '';
    passwordController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Edit Data Profil',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(
                      Icons.alternate_email,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(
                      Icons.email_outlined,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password Baru',
                    hintText:
                        'Kosongkan jika tidak ingin mengubah',
                    prefixIcon: Icon(
                      Icons.lock_outline,
                    ),
                  ),
                ),
              ],
            ),
          ),

          actions: [
            // BATAL
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
              ),
            ),

            // SIMPAN
            FilledButton(
              onPressed: () {
                updateProfile(dialogContext);
              },
              child: const Text(
                'Simpan',
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> updateProfile(
    BuildContext dialogContext,
  ) async {
    if (user == null) {
      return;
    }

    final userId = AppData.currentUserId;

    if (userId == null) {
      return;
    }

    final nama = namaController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (nama.isEmpty ||
        username.isEmpty ||
        email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama, username, dan email tidak boleh kosong.',
          ),
        ),
      );

      return;
    }

    String passwordFinal = password;

    if (passwordFinal.isEmpty) {
      passwordFinal = user!['password'] ?? '';
    }

    //update data ke database
    try {
      await ArcanovaDB.instance.updateUser(
        id: userId,
        nama: nama,
        username: username,
        email: email,
        password: passwordFinal,
      );

      //ambil data terbaru
      final updatedUser =
          await ArcanovaDB.instance.getUserById(userId);

      if (!mounted) return;

      setState(() {
        user = updatedUser;
      });

      // Kosongkan password controller
      passwordController.clear();

      // Tutup dialog
      Navigator.pop(dialogContext);

      // Notifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Profil berhasil diperbarui!',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Username atau email sudah digunakan oleh akun lain.',
          ),
        ),
      );
    }
  }

  void deleteAccount() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
            size: 45,
          ),

          title: const Text(
            'Hapus Akun?',
            textAlign: TextAlign.center,
          ),

          content: const Text(
            'Apakah kamu benar-benar yakin ingin '
            'menghapus akun ini?\n\n'
            'Data akun yang sudah dihapus tidak dapat '
            'digunakan kembali.',
            textAlign: TextAlign.center,
          ),

          actionsAlignment: MainAxisAlignment.spaceEvenly,

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
              ),
            ),

            //hapus akun
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),

              onPressed: () async {
                final userId = AppData.currentUserId;

                if (userId != null) {
                  await ArcanovaDB.instance.deleteUser(userId);
                }

                // Hapus session sementara
                AppData.currentUserId = null;

                if (!mounted) return;

                // Tutup dialog konfirmasi
                Navigator.pop(dialogContext);

                // Kembali ke login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                  (route) => false,
                );
              },

              child: const Text(
                'Hapus Akun',
              ),
            ),
          ],
        );
      },
    );
  }

  //info profil
  Widget infoProfile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFF3B0764),
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFFD8B4FE),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFFD8B4FE),
          ),
        ),
      );
    }

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Data pengguna tidak ditemukan.',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
        ),
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

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

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [

            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Color(0xFF3B0764),

                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Color(0xFFD8B4FE),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Center(
              child: Text(
                user!['nama'] ?? '',
                style: const TextStyle(
                  color: Color(0xFFE9D5FF),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 5),

            Center(
              child: Text(
                '@${user!['username'] ?? ''}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 30),

            Card(
              color: const Color(0xFF0F172A),
              elevation: 3,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Informasi Akun',
                      style: TextStyle(
                        color: Color(0xFFD8B4FE),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NAMA
                    infoProfile(
                      icon: Icons.person_outline,
                      label: 'Nama Lengkap',
                      value: user!['nama'] ?? '',
                    ),

                    // USERNAME
                    infoProfile(
                      icon: Icons.alternate_email,
                      label: 'Username',
                      value: user!['username'] ?? '',
                    ),

                    // EMAIL
                    infoProfile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user!['email'] ?? '',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            //edit profil
            SizedBox(
              width: double.infinity,

              child: FilledButton.icon(
                onPressed: editProfile,

                icon: const Icon(
                  Icons.edit_outlined,
                ),

                label: const Text(
                  'EDIT DATA PROFIL',
                ),

                style: FilledButton.styleFrom(
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            //hapus akun
            SizedBox(
              width: double.infinity,

              child: OutlinedButton.icon(
                onPressed: deleteAccount,

                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                ),

                label: const Text(
                  'HAPUS AKUN',
                  style: TextStyle(
                    color: Colors.redAccent,
                  ),
                ),

                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),

                  side: const BorderSide(
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}