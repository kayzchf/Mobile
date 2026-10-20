import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/feedback_model.dart';
import '../../services/db_helper.dart';
import '../../services/auth_service.dart';

class CourseFeedbackScreen extends StatefulWidget {
  const CourseFeedbackScreen({super.key});

  @override
  State<CourseFeedbackScreen> createState() => _CourseFeedbackScreenState();
}

class _CourseFeedbackScreenState extends State<CourseFeedbackScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _kesanController = TextEditingController();
  final _saranController = TextEditingController();

  int _selectedRating = 5;
  bool _isSubmitting = false;
  List<CourseFeedbackModel> _allFeedback = [];
  List<CourseFeedbackModel> _myFeedback = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _prefillUser();
    _loadFeedbackHistory();
  }

  void _prefillUser() {
    final user = AuthService.instance.currentUser;
    if (user != null) {
      _nameController.text = user.username;
    }
  }

  Future<void> _loadFeedbackHistory() async {
    final allList = await DatabaseHelper.instance.getAllFeedback();
    final user = AuthService.instance.currentUser;
    List<CourseFeedbackModel> myList = [];
    if (user?.id != null) {
      myList = await DatabaseHelper.instance.getFeedbackByUser(user!.id!);
    }

    if (mounted) {
      setState(() {
        _allFeedback = allList;
        _myFeedback = myList;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _nimController.dispose();
    _kesanController.dispose();
    _saranController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = AuthService.instance.currentUser;
    final feedback = CourseFeedbackModel(
      userId: user?.id,
      studentName: _nameController.text.trim(),
      nim: _nimController.text.trim(),
      kesan: _kesanController.text.trim(),
      saran: _saranController.text.trim(),
      ratingStars: _selectedRating,
    );

    await DatabaseHelper.instance.insertFeedback(feedback);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _kesanController.clear();
    _saranController.clear();
    _loadFeedbackHistory();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.successEmerald,
        content: Text("✨ Makasih banyak ya! Masukan kamu sudah tersimpan di database."),
      ),
    );
  }

  Future<void> _deleteFeedback(int feedbackId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Hapus Masukan?", style: TextStyle(color: Colors.white, fontSize: 16)),
        content: const Text("Apakah kamu yakin ingin menghapus masukan ini?", style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorCrimson),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteFeedback(feedbackId);
      _loadFeedbackHistory();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.neonPurple,
          content: Text("Masukan berhasil dihapus dari database."),
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
        title: const Text(
          "SARAN & KESAN MATKUL PAM",
          style: TextStyle(color: AppColors.arcaneSilver, letterSpacing: 1.2, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brightLavender),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.celestialCyan,
          indicatorWeight: 3,
          labelColor: AppColors.brightLavender,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.people_outline), text: "Semua Masukan"),
            Tab(icon: Icon(Icons.person_outline), text: "Masukan Saya"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // TAB 1: Form & Semua Masukan Mahasiswa (Public)
            _buildAllFeedbackTab(),

            // TAB 2: Masukan Saya (History pribadi yang BISA DIHAPUS)
            _buildMyFeedbackTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllFeedbackTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      children: [
        // Form Section
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.35)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Tulis Saran & Kesan Matkul PAM",
                  style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),

                // Star Rating
                Row(
                  children: List.generate(5, (index) {
                    final star = index + 1;
                    return IconButton(
                      icon: Icon(
                        star <= _selectedRating ? Icons.star : Icons.star_border,
                        color: AppColors.arcaneSilver,
                        size: 28,
                      ),
                      onPressed: () => setState(() => _selectedRating = star),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nama Kamu", hintText: "Misal: Arga"),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Nama wajib diisi ya!" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nimController,
                  decoration: const InputDecoration(labelText: "NIM (Nomor Induk Mahasiswa)", hintText: "Misal: 123220001"),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "NIM wajib diisi ya!" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _kesanController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Kesan Pembelajaran",
                    hintText: "Ceritain kesan seru kamu selama belajar mobile...",
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Kesan jangan dikosongkan ya!" : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _saranController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: "Saran untuk Mata Kuliah",
                    hintText: "Saran materi atau praktikum ke depan...",
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? "Saran jangan dikosongkan ya!" : null,
                ),
                const SizedBox(height: 18),

                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitFeedback,
                  icon: const Icon(Icons.send_rounded),
                  label: const Text("Kirim Masukan"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        const Text(
          "SEMUA MASUKAN MAHASISWA (DATABASE)",
          style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
        ),
        const SizedBox(height: 10),

        if (_allFeedback.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Text("Belum ada masukan tersimpan di SQLite.", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ),
          )
        else
          for (final fb in _allFeedback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${fb.studentName} (${fb.nim})", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      Row(
                        children: List.generate(
                          fb.ratingStars,
                          (_) => const Icon(Icons.star, color: AppColors.arcaneSilver, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text("💭 Kesan: \"${fb.kesan}\"", style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text("💡 Saran: \"${fb.saran}\"", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 12)),
                ],
              ),
            ),
      ],
    );
  }

  // TAB 2: Masukan Saya yang BISA DIHAPUS
  Widget _buildMyFeedbackTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        const Text(
          "RIWAYAT MASUKAN SAYA (BISA DIHAPUS)",
          style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2),
        ),
        const SizedBox(height: 6),
        const Text(
          "Berikut daftar saran & kesan yang pernah kamu kirimkan dari akun ini:",
          style: TextStyle(color: AppColors.shimmerSilver, fontSize: 12),
        ),
        const SizedBox(height: 16),

        if (_myFeedback.isEmpty)
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Center(
              child: Text(
                "Kamu belum pernah mengirimkan masukan dari akun ini. Yuk tulis di tab 'Semua Masukan'!",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          )
        else
          for (final fb in _myFeedback)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          fb.ratingStars,
                          (_) => const Icon(Icons.star, color: AppColors.arcaneSilver, size: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.errorCrimson, size: 20),
                        tooltip: "Hapus Masukan Ini",
                        onPressed: () => _deleteFeedback(fb.id!),
                      ),
                    ],
                  ),
                  Text("💭 Kesan: \"${fb.kesan}\"", style: const TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text("💡 Saran: \"${fb.saran}\"", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(
                    "Dikirim pada: ${fb.submittedAt.substring(0, 10)}",
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}
