import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/blockchain_block.dart';
import '../../services/auth_service.dart';
import '../../services/blockchain_service.dart';
import '../../services/online_cloud_service.dart';
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
    String selectedTimezone = user.timezonePref;
    String selectedCurrency = user.currencyPref;

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
                const SizedBox(height: 14),

                // Zona Waktu
                const Text("Zona Waktu Domisili:", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: selectedTimezone,
                  dropdownColor: AppColors.cardSurface,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.public, color: AppColors.celestialCyan, size: 20),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'WIB', child: Text("WIB (Indonesia Barat)", style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: 'WITA', child: Text("WITA (Indonesia Tengah)", style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: 'WIT', child: Text("WIT (Indonesia Timur)", style: TextStyle(color: Colors.white, fontSize: 13))),
                    DropdownMenuItem(value: 'London (GMT)', child: Text("London (GMT - UTC+0)", style: TextStyle(color: Colors.white, fontSize: 13))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedTimezone = val;
                        if (selectedTimezone != 'London (GMT)') {
                          selectedCurrency = 'IDR';
                        } else if (selectedCurrency == 'IDR') {
                          selectedCurrency = 'USD';
                        }
                      });
                    }
                  },
                ),

                // Mata Uang Internasional (Khusus London GMT)
                if (selectedTimezone == 'London (GMT)') ...[
                  const SizedBox(height: 12),
                  const Text("Mata Uang Pembayaran Internasional:", style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("USD (\$)")),
                          selected: selectedCurrency == 'USD',
                          selectedColor: AppColors.neonPurple,
                          labelStyle: TextStyle(color: selectedCurrency == 'USD' ? Colors.white : AppColors.shimmerSilver, fontSize: 12),
                          backgroundColor: AppColors.cardSurfaceLight,
                          onSelected: (_) => setDialogState(() => selectedCurrency = 'USD'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("GBP (£)")),
                          selected: selectedCurrency == 'GBP',
                          selectedColor: AppColors.neonPurple,
                          labelStyle: TextStyle(color: selectedCurrency == 'GBP' ? Colors.white : AppColors.shimmerSilver, fontSize: 12),
                          backgroundColor: AppColors.cardSurfaceLight,
                          onSelected: (_) => setDialogState(() => selectedCurrency = 'GBP'),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 6),
                  const Text("🇮🇩 Zona Indonesia otomatis terkunci ke mata uang Rupiah (IDR).", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
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
        timezonePref: selectedTimezone,
        currencyPref: selectedCurrency,
      );

      if (mounted) {
        if (success) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.successEmerald,
              content: Text("✨ Profil, zona waktu, dan preferensi mata uang berhasil disimpan!"),
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

  Future<void> _mineSpiritualBlockDialog() async {
    final user = AuthService.instance.currentUser;
    final intentionController = TextEditingController(text: "Penyelarasan Aura & Sertifikat Pembacaan Jiwa");

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Row(
          children: [
            Text("⛏️", style: TextStyle(fontSize: 22)),
            SizedBox(width: 8),
            Expanded(child: Text("Tambang Blok Baru", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 16, fontWeight: FontWeight.bold))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Fitur blockchain aktif: Tambang blok baru dengan komputasi Proof-of-Work (PoW) dan enkripsi SHA-256.",
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: intentionController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Catatan Konsultasi / Niat Jiwa",
                hintText: "Contoh: Bimbingan Karir & Aura",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal", style: TextStyle(color: AppColors.textMuted))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
            child: const Text("Mulai Tambang (PoW)"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoadingLedger = true);
      final newBlock = await BlockchainService.instance.mineSpiritualBlock(
        userId: user?.id ?? 1,
        userName: user?.username ?? "Tamu Arcanova",
        intention: intentionController.text.trim().isEmpty ? "Penyelarasan Aura Batin" : intentionController.text.trim(),
      );

      // Cloud sync
      await OnlineCloudService.instance.syncBlockToCloud(newBlock);

      await _loadLedger();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.successEmerald,
            content: Text("⛏️ Blok #${newBlock.index} berhasil ditambang & dicatat di ledger!"),
          ),
        );
      }
    }
  }

  void _showBlockDetailModal(BlockchainBlock block) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.token, color: AppColors.celestialCyan, size: 22),
            const SizedBox(width: 8),
            Text("Detail Kriptografi Blok #${block.index}", style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBlockField("Status Segel:", "IMMUTABLE (Tidak Bisa Diubah)", AppColors.successEmerald),
              _buildBlockField("Proof-of-Work Nonce:", "${block.nonce}", AppColors.celestialCyan),
              _buildBlockField("Timestamp:", "${block.timestamp}", AppColors.shimmerSilver),
              _buildBlockField("SHA-256 Hash:", block.hash, AppColors.arcaneSilver),
              _buildBlockField("Previous Hash:", block.previousHash, AppColors.textMuted),
              _buildBlockField("Data Payload:", block.sessionData.toString(), Colors.white),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonPurple),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockField(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: color, fontSize: 12, fontFamily: 'monospace')),
        ],
      ),
    );
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
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: _mineSpiritualBlockDialog,
                            icon: const Icon(Icons.add_circle_outline, size: 14, color: AppColors.brightLavender),
                            label: const Text("Tambang", style: TextStyle(color: AppColors.brightLavender, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          TextButton.icon(
                            onPressed: _verifyBlockchain,
                            icon: const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.celestialCyan),
                            label: const Text("Verifikasi", style: TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "📌 Fitur blockchain aktif: Sertifikat digital sesi ramalan & afirmasi batin yang terenkripsi SHA-256 dan immutable. Ketuk tombol 'Tambang' untuk menambahkan blok baru!",
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
                InkWell(
                  onTap: () => _showBlockDetailModal(block),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.deepSpace,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text("Nonce: ${block.nonce}", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 10, fontFamily: 'monospace')),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Event: ${block.sessionData['event'] ?? block.sessionData['service_title'] ?? 'Sertifikat Sesi'}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text("Hash: ${block.hash.substring(0, 24)}...", style: const TextStyle(color: AppColors.textMuted, fontFamily: 'monospace', fontSize: 10)),
                            ),
                            const Text("Lihat Detail >", style: TextStyle(color: AppColors.brightLavender, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
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
