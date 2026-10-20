import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../services/lbs_service.dart';
import '../../services/notification_service.dart';

class MysticHubScreen extends StatefulWidget {
  const MysticHubScreen({super.key});

  @override
  State<MysticHubScreen> createState() => _MysticHubScreenState();
}

class _MysticHubScreenState extends State<MysticHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 1. Creative Love Matcher State
  final _p1NameController = TextEditingController();
  final _p2NameController = TextEditingController();
  String _p1Gender = "Pria";
  String _p2Gender = "Wanita";
  DateTime _p1BirthDate = DateTime(2002, 3, 25);
  DateTime _p2BirthDate = DateTime(2003, 7, 28);

  bool _hasCalculatedLove = false;
  int _lovePercentage = 0;
  String _loveTitle = "";
  String _loveDescription = "";
  String _loveAdvice = "";

  // 2. Feng Shui State
  bool _fengShuiDailyNotif = true;

  // 3. LBS Sanctuary State
  double? _distanceKm;
  bool _isLoadingDistance = false;
  bool _isAuraZone = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkSanctuaryDistance();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _p1NameController.dispose();
    _p2NameController.dispose();
    super.dispose();
  }

  Future<void> _checkSanctuaryDistance() async {
    setState(() => _isLoadingDistance = true);
    final dist = await LbsService.instance.getDistanceToSanctuaryKm();
    if (mounted) {
      setState(() {
        _distanceKm = dist;
        _isAuraZone = (dist != null && dist <= 1.5);
        _isLoadingDistance = false;
      });
    }
  }

  String _getZodiac(DateTime date) {
    final m = date.month;
    final d = date.day;
    if ((m == 3 && d >= 21) || (m == 4 && d <= 19)) return 'Aries ♈ (Api)';
    if ((m == 4 && d >= 20) || (m == 5 && d <= 20)) return 'Taurus ♉ (Tanah)';
    if ((m == 5 && d >= 21) || (m == 6 && d <= 20)) return 'Gemini ♊ (Udara)';
    if ((m == 6 && d >= 21) || (m == 7 && d <= 22)) return 'Cancer ♋ (Air)';
    if ((m == 7 && d >= 23) || (m == 8 && d <= 22)) return 'Leo ♌ (Api)';
    if ((m == 8 && d >= 23) || (m == 9 && d <= 22)) return 'Virgo ♍ (Tanah)';
    if ((m == 9 && d >= 23) || (m == 10 && d <= 22)) return 'Libra ♎ (Udara)';
    if ((m == 10 && d >= 23) || (m == 11 && d <= 21)) return 'Scorpio ♏ (Air)';
    if ((m == 11 && d >= 22) || (m == 12 && d <= 21)) return 'Sagittarius ♐ (Api)';
    if ((m == 12 && d >= 22) || (m == 1 && d <= 19)) return 'Capricorn ♑ (Tanah)';
    if ((m == 1 && d >= 20) || (m == 2 && d <= 18)) return 'Aquarius ♒ (Udara)';
    return 'Pisces ♓ (Air)';
  }

  void _calculateLoveMatch() {
    if (_p1NameController.text.trim().isEmpty || _p2NameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warningOrange,
          content: Text("Yuk tulis nama kamu dan pasangan dulu ya!"),
        ),
      );
      return;
    }

    final combined = "${_p1NameController.text.toLowerCase()}&${_p2NameController.text.toLowerCase()}";
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash += combined.codeUnitAt(i);
    }
    hash += _p1BirthDate.day + _p2BirthDate.day;

    final score = 78 + (hash % 21); // Score 78% to 98%
    final z1 = _getZodiac(_p1BirthDate);
    final z2 = _getZodiac(_p2BirthDate);

    setState(() {
      _hasCalculatedLove = true;
      _lovePercentage = score;
      if (score >= 90) {
        _loveTitle = "Soulmate Sejati! 💖";
        _loveDescription = "Koneksi batin kalian ($z1 & $z2) selaras banget! Tanpa perlu banyak kata, kalian saling mengerti perasaan satu sama lain.";
        _loveAdvice = "Saran Hubungan: Luangkan waktu ngobrol santai tanpa gadget biar chemistry kalian makin awet!";
      } else if (score >= 84) {
        _loveTitle = "Pasangan Harmonis ✨";
        _loveDescription = "Perpaduan energi $z1 dan $z2 saling melengkapi dengan manis. Kadang ada beda pendapat, tapi kalian selalu bisa cari jalan tengah.";
        _loveAdvice = "Saran Hubungan: Berikan apresiasi kecil dan perhatian sederhana ke pasangan setiap hari.";
      } else {
        _loveTitle = "Gairah Penuh Warna 🔥";
        _loveDescription = "Hubungan yang seru dan gak ngebosenin antara $z1 dan $z2. Sifat kalian yang sama-sama kuat bikin dinamika asmara jadi seru!";
        _loveAdvice = "Saran Hubungan: Saat emosi lagi panas, dinginkan kepala dulu ya sebelum lanjut ngobrol.";
      }
    });
  }

  Future<void> _pickBirthDate(bool isP1) async {
    final current = isP1 ? _p1BirthDate : _p2BirthDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonPurple,
              surface: AppColors.cardSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isP1) {
          _p1BirthDate = picked;
        } else {
          _p2BirthDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "MYSTIC HUB",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.arcaneSilver,
                letterSpacing: 2,
              ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.celestialCyan,
          indicatorWeight: 3,
          labelColor: AppColors.brightLavender,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: "Cinta"),
            Tab(icon: Icon(Icons.wb_sunny_outlined), text: "Feng Shui"),
            Tab(icon: Icon(Icons.place_outlined), text: "Sanctuary"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildCreativeLoveMatcherTab(),
            _buildFengShuiTab(),
            _buildLbsSanctuaryTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: CREATIVE LOVE COMPATIBILITY MATCHER ---
  Widget _buildCreativeLoveMatcherTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Creative Header Banner with Avatar Connection
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.astralIndigo, AppColors.deepViolet.withValues(alpha: 0.6)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Partner 1 Avatar
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardSurfaceLight,
                          border: Border.all(color: AppColors.celestialCyan, width: 2),
                        ),
                        child: Center(
                          child: Text(_p1Gender == "Pria" ? "👨" : "👩", style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _p1NameController.text.isNotEmpty ? _p1NameController.text : "Kamu",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),

                  // Animated Connecting Heart Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.pinkAccent.withValues(alpha: 0.2),
                      border: Border.all(color: Colors.pinkAccent),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 28),
                  ),

                  // Partner 2 Avatar
                  Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cardSurfaceLight,
                          border: Border.all(color: Colors.pinkAccent, width: 2),
                        ),
                        child: Center(
                          child: Text(_p2Gender == "Pria" ? "👨" : "👩", style: const TextStyle(fontSize: 32)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _p2NameController.text.isNotEmpty ? _p2NameController.text : "Dia",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                "Yuk cek seberapa cocok frekuensi kalian berdua!",
                style: TextStyle(color: AppColors.shimmerSilver, fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Creative Form with Visual Controls
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Insan 1
              const Row(
                children: [
                  Icon(Icons.person, color: AppColors.celestialCyan, size: 18),
                  SizedBox(width: 8),
                  Text("Data Diri Kamu", style: TextStyle(color: AppColors.celestialCyan, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _p1NameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: "Nama Lengkap Kamu", hintText: "Misal: Arga"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Gender Toggle with Icons
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _p1Gender = "Pria"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _p1Gender == "Pria" ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text("👨 Pria", style: TextStyle(fontSize: 12, color: Colors.white))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _p1Gender = "Wanita"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _p1Gender == "Wanita" ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text("👩 Wanita", style: TextStyle(fontSize: 12, color: Colors.white))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Birthday Picker
                  OutlinedButton.icon(
                    onPressed: () => _pickBirthDate(true),
                    icon: const Icon(Icons.cake, size: 15, color: AppColors.brightLavender),
                    label: Text("${_p1BirthDate.day}/${_p1BirthDate.month}/${_p1BirthDate.year}", style: const TextStyle(fontSize: 11, color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      side: BorderSide(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text("Zodiak: ${_getZodiac(_p1BirthDate)}", style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11)),

              const Divider(color: Colors.white12, height: 28),

              // Insan 2
              const Row(
                children: [
                  Icon(Icons.favorite_border, color: Colors.pinkAccent, size: 18),
                  SizedBox(width: 8),
                  Text("Data Si Dia", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _p2NameController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: "Nama Dia", hintText: "Misal: Nova"),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  // Gender Toggle with Icons
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _p2Gender = "Pria"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _p2Gender == "Pria" ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text("👨 Pria", style: TextStyle(fontSize: 12, color: Colors.white))),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _p2Gender = "Wanita"),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _p2Gender == "Wanita" ? AppColors.neonPurple : AppColors.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(child: Text("👩 Wanita", style: TextStyle(fontSize: 12, color: Colors.white))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Birthday Picker
                  OutlinedButton.icon(
                    onPressed: () => _pickBirthDate(false),
                    icon: const Icon(Icons.cake, size: 15, color: AppColors.brightLavender),
                    label: Text("${_p2BirthDate.day}/${_p2BirthDate.month}/${_p2BirthDate.year}", style: const TextStyle(fontSize: 11, color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      side: BorderSide(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text("Zodiak: ${_getZodiac(_p2BirthDate)}", style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11)),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _calculateLoveMatch,
                icon: const Icon(Icons.favorite, color: Colors.pinkAccent),
                label: const Text("Hitung Kecocokan Cinta"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),

        // Love Result Card
        if (_hasCalculatedLove) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.astralIndigo, AppColors.deepViolet.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.6), width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.pinkAccent.withValues(alpha: 0.3), blurRadius: 20),
              ],
            ),
            child: Column(
              children: [
                Text("$_lovePercentage%", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.pinkAccent)),
                const Text("Tingkat Kecocokan Jiwa", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 14),
                Text(_loveTitle, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Text(_loveDescription, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4)),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.voidBlack.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.3)),
                  ),
                  child: Text(_loveAdvice, style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // --- TAB 2: DAILY ASTRAL FENG SHUI ---
  Widget _buildFengShuiTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Daily Morning Notification Toggle Card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Notifikasi Feng Shui Pagi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      Text("Kirimkan tips energi setiap pagi hari", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  Switch(
                    value: _fengShuiDailyNotif,
                    activeThumbColor: AppColors.arcaneSilver,
                    activeTrackColor: AppColors.neonPurple,
                    onChanged: (val) {
                      setState(() => _fengShuiDailyNotif = val);
                      if (val) {
                        NotificationService.instance.sendDailyFengShuiNotification();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppColors.neonPurple,
                            content: Text("✨ Notifikasi Feng Shui harian diaktifkan! Contoh notifikasi telah dikirim."),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        _buildFengShuiCard(
          title: "Warna Pakaian Keberuntungan",
          icon: Icons.checkroom,
          color: AppColors.celestialCyan,
          content: "Ungu Indigo & Silver Elegan. Menghadirkan ketenangan pikiran, fokus, serta memancarkan aura positif saat berinteraksi dengan orang lain.",
        ),
        _buildFengShuiCard(
          title: "Aktivitas Penyelaras Energi",
          icon: Icons.self_improvement,
          color: AppColors.brightLavender,
          content: "Berjalan santai di pagi hari, mendengarkan musik santai, dan journaling singkat. Hindari perdebatan yang menguras energi hari ini.",
        ),
        _buildFengShuiCard(
          title: "Santapan Penyeimbang",
          icon: Icons.restaurant,
          color: AppColors.arcaneSilver,
          content: "Minuman hangat seperti teh chamomile atau jahe madu, serta kacang-kacangan segar. Membantu sistem pencernaan dan menenangkan pikiran.",
        ),
        _buildFengShuiCard(
          title: "Arah Energi Terbaik",
          icon: Icons.explore,
          color: AppColors.successEmerald,
          content: "Timur Laut (Northeast). Tempatkan ruang kerja atau meja belajar menghadap cahaya alami untuk mengalirkan ide kreatif.",
        ),
      ],
    );
  }

  Widget _buildFengShuiCard({required String title, required IconData icon, required Color color, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  // --- TAB 3: LBS OFFLINE SANCTUARY MALIOBORO WITH MAP IMAGE ---
  Widget _buildLbsSanctuaryTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
            boxShadow: [
              BoxShadow(color: AppColors.celestialCyan.withValues(alpha: 0.15), blurRadius: 20),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("LOKASI OFFLINE SANCTUARY", style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 13)),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: AppColors.celestialCyan, size: 20),
                    onPressed: _checkSanctuaryDistance,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(LbsService.sanctuaryName, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(LbsService.sanctuaryAddress, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),

              // Visual Map Preview Image of Malioboro Sanctuary
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      "https://images.unsplash.com/photo-1596402184320-417e7178b2cd?auto=format&fit=crop&w=700&q=80",
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 150,
                        color: AppColors.cardSurfaceLight,
                        child: const Center(child: Icon(Icons.map, size: 50, color: AppColors.celestialCyan)),
                      ),
                    ),
                    Container(
                      height: 150,
                      color: AppColors.voidBlack.withValues(alpha: 0.4),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.white, size: 24),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.voidBlack.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Malioboro, Yogyakarta", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Distance & Radar
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.deepSpace,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.5)),
                    ),
                    child: const Icon(Icons.radar, color: AppColors.celestialCyan, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Jarak GPS Anda saat ini:", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        _isLoadingDistance
                            ? const Text("Mencari sinyal GPS...", style: TextStyle(color: AppColors.celestialCyan, fontSize: 13))
                            : Text(
                                _distanceKm != null ? "$_distanceKm km dari Malioboro" : "Aktifkan Izin Lokasi HP",
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_isAuraZone)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.celestialCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.celestialCyan),
                  ),
                  child: const Row(
                    children: [
                      Text("✨", style: TextStyle(fontSize: 22)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Kamu ada di sekitar Malioboro! Dapatkan Diskon 20% untuk Walk-in Reading di Sanctuary kami hari ini!",
                          style: TextStyle(color: AppColors.celestialCyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => LbsService.instance.openSanctuaryInMaps(),
                icon: const Icon(Icons.directions),
                label: const Text("Buka Rute di Google Maps"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
