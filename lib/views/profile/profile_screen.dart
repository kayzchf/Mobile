import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/blockchain_block.dart';
import '../../services/auth_service.dart';
import '../../services/blockchain_service.dart';
import '../auth/login_screen.dart';
import '../feedback/course_feedback_screen.dart';
import '../booking/order_history_screen.dart';
import '../live_chat/reader_chat_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = true;
  List<BlockchainBlock> _ledgerBlocks = [];
  bool _isLoadingLedger = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadLedger();
    AuthService.instance.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (mounted) {
      _loadUserProfile();
      setState(() {});
    }
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _loadUserProfile() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      setState(() {
        _biometricEnabled = user.biometricEnabled;
      });
    }
  }

  Future<void> _loadLedger() async {
    setState(() => _isLoadingLedger = true);
    final blocks = await BlockchainService.instance.getLedgerBlocks();
    if (mounted) {
      setState(() {
        _ledgerBlocks = blocks;
        _isLoadingLedger = false;
      });
    }
  }

  Future<void> _verifyBlockchain() async {
    final res = await BlockchainService.instance.verifyChainIntegrity();
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(
                res['valid'] == true ? Icons.verified : Icons.warning_amber,
                color: res['valid'] == true ? AppColors.successEmerald : AppColors.errorCrimson,
              ),
              const SizedBox(width: 10),
              const Text("Verifikasi Blockchain", style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            res['message'],
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _editProfileDialog() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final passwordController = TextEditingController();
    final birthDateController = TextEditingController(text: user.birthDate);
    String selectedGender = user.avatarGender; // 'male' or 'female'

    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.edit_note, color: AppColors.celestialCyan, size: 24),
              SizedBox(width: 8),
              Text("Edit Profil Kamu", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 17, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pilih Avatar Icon (Cowo / Cewe)
                const Text("Pilih Ikon Avatar Profil:", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setDialogState(() => selectedGender = 'male'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedGender == 'male' ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedGender == 'male' ? AppColors.celestialCyan : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text("👨", style: TextStyle(fontSize: 28)),
                              SizedBox(height: 4),
                              Text("Cowo", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => setDialogState(() => selectedGender = 'female'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedGender == 'female' ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selectedGender == 'female' ? Colors.pinkAccent : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text("👩", style: TextStyle(fontSize: 28)),
                              SizedBox(height: 4),
                              Text("Cewe", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Username
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: "Username",
                    prefixIcon: Icon(Icons.person, color: AppColors.brightLavender, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                // Email
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email_outlined, color: AppColors.celestialCyan, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Baru
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password Baru (Opsional)",
                    hintText: "Kosongkan jika tak ingin ganti",
                    prefixIcon: Icon(Icons.lock_outline, color: AppColors.shimmerSilver, size: 20),
                  ),
                ),
                const SizedBox(height: 12),

                // Tanggal Lahir
                TextField(
                  controller: birthDateController,
                  decoration: const InputDecoration(
                    labelText: "Tanggal Lahir (YYYY-MM-DD)",
                    prefixIcon: Icon(Icons.cake_outlined, color: AppColors.brightLavender, size: 20),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
              child: const Text("Simpan Perubahan"),
            ),
          ],
        ),
      ),
    );

    if (updated == true && usernameController.text.trim().isNotEmpty && emailController.text.trim().isNotEmpty) {
      final success = await AuthService.instance.updateFullProfile(
        username: usernameController.text.trim(),
        email: emailController.text.trim(),
        newPassword: passwordController.text.trim().isEmpty ? null : passwordController.text.trim(),
        avatarGender: selectedGender,
        birthDate: birthDateController.text.trim(),
      );

      if (mounted) {
        if (success) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.successEmerald,
              content: Text("✨ Profil kamu berhasil diperbarui!"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.errorCrimson,
              content: Text("Oops, gagal memperbarui profil. Coba periksa kembali data kamu."),
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteAccountDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hapus Akun?", style: TextStyle(color: AppColors.errorCrimson, fontSize: 17, fontWeight: FontWeight.bold)),
        content: const Text(
          "Apakah kamu yakin ingin menghapus akun ini secara permanen? Semua data pemesanan dan riwayat masukan akan dihapus dari database lokal.",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorCrimson),
            child: const Text("Hapus Akun"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.deleteAccount();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.neonPurple,
          content: Text("Akun kamu telah berhasil dihapus dari database."),
        ),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Keluar Sesi", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 16)),
        content: const Text("Apakah kamu yakin ingin logout dari akun ini?", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorCrimson),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.instance.logout();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "PROFIL SAYA",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.arcaneSilver,
                letterSpacing: 2,
              ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // User Profile Card with Gender Avatar Icon (Cowo / Cewe)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.astralIndigo, AppColors.cardSurface],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  // Photo Avatar with Gender Icon (👨 / 👩)
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardSurfaceLight,
                      border: Border.all(
                        color: user?.avatarGender == 'female' ? Colors.pinkAccent : AppColors.celestialCyan,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (user?.avatarGender == 'female' ? Colors.pinkAccent : AppColors.celestialCyan).withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user != null ? user.avatarEmoji : "👤",
                        style: const TextStyle(fontSize: 38),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.username ?? "Tamu Arcanova",
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? "Belum login • Mode Tamu",
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.deepSpace,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            user != null ? "Zodiak: ${user.zodiacSign}" : "Misteri Jiwa ✨",
                            style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Settings & Features Section (NO "MATA UANG AKTIF" TILE - per user request)
            Material(
              color: AppColors.cardSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  // 1. Riwayat Pemesanan (Order History)
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                      );
                    },
                    leading: const Icon(Icons.history, color: AppColors.celestialCyan),
                    title: const Text("Riwayat Pemesanan Layanan", style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text("Cek daftar sesi konsultasi yang pernah kamu pesan", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.brightLavender),
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  // Chat Tarot Reader Live (WhatsApp Style)
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReaderChatScreen()),
                      );
                    },
                    leading: const Icon(Icons.chat_bubble_outline, color: AppColors.brightLavender),
                    title: const Text("Chat Tarot Reader (WA Style)", style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text("Sesi live 09:00 - 18:00 WIB, jadwal booked & roomchat", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.brightLavender),
                  ),

                  // 2. Edit Profil (Username, Email, Password, Avatar Gender)
                  if (user != null) ...[
                    ListTile(
                      onTap: _editProfileDialog,
                      leading: const Icon(Icons.edit_outlined, color: AppColors.brightLavender),
                      title: const Text("Edit Profil", style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text("Ubah username, email, password, atau icon avatar", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.brightLavender),
                    ),
                    const Divider(color: Colors.white10, height: 1),
                  ],

                  // 3. Biometric Sidik Jari Toggle
                  SwitchListTile(
                    title: const Text("Login Sidik Jari (Fingerprint)", style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: const Text("Masuk cepat menggunakan sensor sidik jari", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    secondary: const Icon(Icons.fingerprint, color: AppColors.celestialCyan),
                    activeThumbColor: AppColors.arcaneSilver,
                    value: _biometricEnabled,
                    onChanged: user == null
                        ? null
                        : (val) async {
                            setState(() => _biometricEnabled = val);
                            await AuthService.instance.toggleBiometric(val);
                          },
                  ),
                  const Divider(color: Colors.white10, height: 1),

                  // 4. SARAN DAN KESAN MATKUL PAM (Kriteria Wajib Tugas)
                  ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CourseFeedbackScreen()),
                      );
                    },
                    leading: const Icon(Icons.rate_review_outlined, color: AppColors.brightLavender),
                    title: const Text(
                      "Saran & Kesan Matkul PAM",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: const Text("Evaluasi & masukan untuk perkuliahan mobile", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.brightLavender),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // BLOCKCHAIN READING LEDGER (Kriteria Wajib Tugas)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.astralIndigo.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.link, color: AppColors.celestialCyan, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "BLOCKCHAIN READING LEDGER",
                            style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: _verifyBlockchain,
                        icon: const Icon(Icons.verified_user_outlined, size: 15, color: AppColors.celestialCyan),
                        label: const Text("Verifikasi Hash", style: TextStyle(color: AppColors.celestialCyan, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "📌 Fitur ini memenuhi kriteria tugas dosen: 'Memiliki fitur blockchain sederhana'. Berfungsi sebagai sertifikat digital sesi ramalan yang terenkripsi SHA-256 dan tidak dapat dimanipulasi (immutable).",
                    style: TextStyle(color: AppColors.shimmerSilver, fontSize: 11, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            if (_isLoadingLedger)
              const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
            else
              for (final block in _ledgerBlocks)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.cardSurfaceLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Blok #${block.index}", style: const TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 13)),
                          Text("Nonce: ${block.nonce}", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text("Event: ${block.sessionData['event'] ?? block.sessionData['service_title'] ?? 'Sertifikat Sesi'}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 3),
                      Text("Hash: ${block.hash.substring(0, 24)}...", style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 10)),
                    ],
                  ),
                ),

            const SizedBox(height: 24),

            // Account Management: Hapus Akun & Logout
            if (user != null) ...[
              OutlinedButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout, color: AppColors.shimmerSilver),
                label: const Text("Keluar Sesi (Logout)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.shimmerSilver.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),

              TextButton.icon(
                onPressed: _deleteAccountDialog,
                icon: const Icon(Icons.delete_forever, color: AppColors.errorCrimson, size: 20),
                label: const Text("Hapus Akun Permanen", style: TextStyle(color: AppColors.errorCrimson, fontSize: 13)),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text("Masuk atau Daftar Akun"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
