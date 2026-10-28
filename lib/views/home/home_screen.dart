import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/tarot_card.dart';
import '../../services/db_helper.dart';
import '../../services/sensor_service.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<TarotCard> _allCards = [];
  List<TarotCard> _filteredCards = [];
  TarotCard? _dailyCard;

  String _searchQuery = "";
  String _selectedElement = "Semua";
  final List<String> _elements = ["Semua", "Fire", "Water", "Air", "Earth"];

  double _tiltPitch = 0.0;
  double _tiltRoll = 0.0;
  bool _isSensorsActive = true;
  late AnimationController _flipController;

  String? _rememberedUsername;
  int? _rememberedUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadCards();
    _checkRememberedAccount();
    AuthService.instance.addListener(_onAuthChanged);
    _startSensors();
  }

  void _onAuthChanged() {
    _checkRememberedAccount();
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only use sensors when app is resumed / active!
    if (state == AppLifecycleState.resumed) {
      if (_isSensorsActive) _startSensors();
    } else {
      _stopSensors();
    }
  }

  Future<void> _checkRememberedAccount() async {
    final username = await AuthService.instance.getLastUsername();
    final uid = await AuthService.instance.getLastSessionUserId();
    if (mounted) {
      setState(() {
        _rememberedUsername = username;
        _rememberedUserId = uid;
      });
    }
  }

  Future<void> _loadCards() async {
    await DatabaseHelper.instance.refreshTarotImages();
    final cards = await DatabaseHelper.instance.getAllTarotCards();
    if (mounted) {
      setState(() {
        _allCards = cards;
        _filteredCards = cards;
        if (cards.isNotEmpty) {
          final dayIndex = DateTime.now().day % cards.length;
          _dailyCard = cards[dayIndex];
        }
      });
    }
  }

  void _startSensors() {
    // Accelerometer: Shake to Shuffle
    SensorService.instance.startShakeDetection(
      onShake: () {
        if (mounted && _isSensorsActive) {
          _drawNewRandomCard(isShake: true);
        }
      },
    );

    // Gyroscope: 3D Holographic Parallax Tilt
    SensorService.instance.startGyroscopeTilt(
      onTilt: (pitch, roll) {
        if (mounted && _isSensorsActive) {
          setState(() {
            _tiltPitch = pitch;
            _tiltRoll = roll;
          });
        }
      },
    );
  }

  void _stopSensors() {
    SensorService.instance.stopAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AuthService.instance.removeListener(_onAuthChanged);
    _stopSensors();
    _flipController.dispose();
    super.dispose();
  }

  void _drawNewRandomCard({bool isShake = false}) {
    if (_allCards.isEmpty) return;
    final random = Random();
    final newCard = _allCards[random.nextInt(_allCards.length)];

    setState(() {
      _dailyCard = newCard;
    });

    _flipController.forward(from: 0.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.neonPurple,
        duration: const Duration(seconds: 2),
        content: Text(
          isShake
              ? "✨ [SENSOR GERAK] HP kamu digoyang! Kartu terpilih: ${_dailyCard!.name}"
              : "🔮 Kartu pilihan semesta: ${_dailyCard!.name}",
        ),
      ),
    );
  }

  void _filterCards() {
    final query = _searchQuery.trim().toLowerCase();
    final selectedElement = _selectedElement.toLowerCase();

    setState(() {
      _filteredCards = _allCards.where((card) {
        final name = card.name.toLowerCase();
        final matchesQuery =
            query.isEmpty || name.contains(query);

        final matchesElement =
            _selectedElement == "Semua" ||
            card.element.toLowerCase() == selectedElement;

        return matchesQuery && matchesElement;
      }).toList();
    });
  }

  Future<void> _quickFingerprintLogin() async {
    await _checkRememberedAccount();
    if (_rememberedUserId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.warningOrange,
            content: Text("Belum ada akun tersimpan di HP ini. Silakan daftar atau masuk dulu ya!"),
          ),
        );
      }
      if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    }

    final res = await BiometricService.instance.authenticateWithFingerprint();
    if (res['success'] == true) {
      await AuthService.instance.loginWithBiometrics(_rememberedUserId!);
      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.successEmerald,
          content: Text("✨ Sidik jari terverifikasi! Masuk sebagai ${_rememberedUsername ?? 'Sahabat'}."),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: AppColors.errorCrimson, content: Text(res['message'] ?? "Sidik jari gagal.")),
      );
    }
  }

  Widget buildTarotImage(
    TarotCard card, {
    double? width,
    double? height,
    double fallbackFontSize = 30,
    BoxFit fit = BoxFit.cover,
  }) {
    final imagePath = card.imagePath?.trim();

    if (imagePath == null || imagePath.isEmpty) {
      return Center(
        child: Text(
          card.symbol,
          style: TextStyle(fontSize: 60),
        ),
      );
    }

    return Image.asset(
      imagePath,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Text(
            card.symbol,
            style: TextStyle(fontSize: 60),
          ),
        );
      },
    );
  }

  Color _getElementColor(String element) {
    switch (element.toLowerCase()) {
      case 'fire':
      case 'api':
        return AppColors.errorCrimson; // Merah untuk Api
      case 'water':
      case 'air': 
        return AppColors.celestialCyan; // Biru untuk Air
      case 'earth':
      case 'tanah':
      case 'bumi':
        return AppColors.successEmerald; // Hijau untuk Tanah/Bumi
      case 'wind': // Jika menggunakan elemen udara/angin
      case 'udara':
        return Colors.amber; // Kuning/Emas untuk Udara // Warna default jika tidak cocok
      default:
        return Colors.grey;
    }
  }

  void _showCardDetailModal(TarotCard card) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(color: AppColors.mysticViolet, blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Photo/Image Placeholder for Tarot Card
                      Container(
                        width: 160,
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.arcaneSilver.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.neonPurple.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: buildTarotImage(
                          card,
                          width: 150,
                          height: 200,
                          fallbackFontSize: 54,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        card.name.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              color: AppColors.arcaneSilver,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${card.arcanaType} • Elemen ${card.element}",
                        style: TextStyle(color: _getElementColor(card.element), fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),

                      if (card.affirmation.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.voidBlack.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            children: [
                              const Text("✨ AFIRMASI ✨", style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 6),
                              Text(
                                "\"${card.affirmation}\"",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.white, fontStyle: FontStyle.italic, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 20),

                      _buildDetailSection("Makna Tegak", card.uprightMeaning, Icons.arrow_upward, AppColors.successEmerald),
                      _buildDetailSection("Makna Terbalik", card.reversedMeaning, Icons.arrow_downward, AppColors.errorCrimson),
                      _buildDetailSection("Tips Asmara", card.loveAdvice, Icons.favorite, AppColors.brightLavender),
                      _buildDetailSection("Tips Karir & Cuan", card.careerAdvice, Icons.work_outline, AppColors.celestialCyan),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 6),
          Text(content, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null
                              ? "Hai, ${user.username} ${user.avatarEmoji}"
                              : "Hai Querent! 🌌",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            color: AppColors.arcaneSilver,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null
                              ? "Zodiak: ${user.zodiacSign}"
                              : "Mode Tamu • Selamat mengeksplorasi!",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: user != null
                                ? AppColors.brightLavender
                                : AppColors.shimmerSilver,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (user == null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _quickFingerprintLogin,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurfaceLight,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.celestialCyan,
                          ),
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          size: 20,
                          color: AppColors.celestialCyan,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginScreen(),
                        ),
                      ),
                      child: const Text(
                        "Masuk",
                        style: TextStyle(
                          color: AppColors.arcaneSilver,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              ),
            ),

            // Daily Card (Only page with active sensor!)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "KARTU HARI INI",
                          style: TextStyle(
                            color: AppColors.arcaneSilver,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isSensorsActive ? Icons.sensors : Icons.sensors_off,
                                color: _isSensorsActive ? AppColors.celestialCyan : AppColors.textMuted,
                                size: 18,
                              ),
                              tooltip: _isSensorsActive ? "Sensor Aktif" : "Sensor Mati",
                              onPressed: () {
                                setState(() {
                                  _isSensorsActive = !_isSensorsActive;
                                  if (_isSensorsActive) {
                                    _startSensors();
                                  } else {
                                    _stopSensors();
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh, color: AppColors.brightLavender, size: 20),
                              tooltip: "Kocok Kartu Baru",
                              onPressed: () => _drawNewRandomCard(isShake: false),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Gyroscope Real-time Telemetry HUD Chip
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.voidBlack.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (_tiltPitch.abs() > 0.05 || _tiltRoll.abs() > 0.05)
                              ? AppColors.celestialCyan
                              : AppColors.mysticViolet.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.screen_rotation,
                            size: 16,
                            color: (_tiltPitch.abs() > 0.05 || _tiltRoll.abs() > 0.05)
                                ? AppColors.celestialCyan
                                : AppColors.brightLavender,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "🧭 Gyroscope Tilt: X: ${_tiltRoll.toStringAsFixed(2)} | Y: ${_tiltPitch.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: AppColors.shimmerSilver,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _isSensorsActive ? AppColors.successEmerald.withValues(alpha: 0.2) : Colors.white10,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isSensorsActive ? "LIVE SENSOR" : "OFF",
                              style: TextStyle(
                                color: _isSensorsActive ? AppColors.successEmerald : AppColors.textMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 3D Parallax Tilt Widget (Gyroscope + Interactive Pan Fallback)
                    Center(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_tiltPitch * 0.25)
                          ..rotateY(_tiltRoll * 0.25),
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            setState(() {
                              _tiltRoll = (_tiltRoll + details.delta.dx * 0.015).clamp(-1.2, 1.2);
                              _tiltPitch = (_tiltPitch - details.delta.dy * 0.015).clamp(-1.2, 1.2);
                            });
                          },
                          onPanEnd: (_) {
                            setState(() {
                              _tiltPitch = 0.0;
                              _tiltRoll = 0.0;
                            });
                          },
                          onTap: () {
                            if (_dailyCard != null) _showCardDetailModal(_dailyCard!);
                          },
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 360),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.cardSurface,
                                  AppColors.astralIndigo.withValues(alpha: 0.9),
                                  AppColors.deepViolet.withValues(alpha: 0.4),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.mysticViolet.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mysticViolet.withValues(alpha: 0.35),
                                  blurRadius: 20,
                                  offset: Offset(_tiltRoll * 8, _tiltPitch * 8),
                                ),
                              ],
                            ),
                            child: _dailyCard == null
                                ? const Center(child: CircularProgressIndicator())
                                : Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _dailyCard!.name.toUpperCase(),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.arcaneSilver,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.neonPurple.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _dailyCard!.element,
                                              style: TextStyle(
                                                color: _getElementColor(_dailyCard!.element),
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: 180,
                                        height: 230,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: buildTarotImage(_dailyCard!),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _dailyCard!.uprightMeaning,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.screen_rotation, size: 14, color: AppColors.celestialCyan),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.vibration, size: 14, color: AppColors.brightLavender),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Miringkan HP (Gyroscope 3D) • Goyang (Kocok Kartu)",
                                            style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.9), fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Search & Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "KATALOG KARTU TAROT",
                      style: TextStyle(
                        color: AppColors.arcaneSilver,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Search Input
                    TextField(
                      onChanged: (val) {
                        _searchQuery = val;
                        _filterCards();
                      },
                      decoration: InputDecoration(
                        hintText: "Cari nama kartu (The Fool, The Lovers, ...)",
                        hintStyle: const TextStyle(color: AppColors.mutedSilver, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: AppColors.shimmerSilver),
                        fillColor: AppColors.cardSurfaceLight.withValues(alpha: 0.6),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Element Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _elements.map((el) {
                          final isSelected = _selectedElement == el;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(el),
                              selected: isSelected,
                              selectedColor: AppColors.neonPurple,
                              checkmarkColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.shimmerSilver,
                                fontSize: 12,
                              ),
                              backgroundColor: AppColors.cardSurfaceLight,
                              onSelected: (_) {
                                setState(() {
                                  _selectedElement = el;
                                  _filterCards();
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // Grid of Tarot Cards (Name & Symbol ONLY, clean!)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              sliver: _filteredCards.isEmpty
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: Center(
                          child: Text("Kartu tidak ditemukan.", style: TextStyle(color: AppColors.textMuted)),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = _filteredCards[index];
                          return GestureDetector(
                            onTap: () => _showCardDetailModal(card),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.cardSurface.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.voidBlack.withValues(alpha: 0.6),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    height: 105,
                                    decoration: BoxDecoration(
                                      color: AppColors.cardSurfaceLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.mysticViolet.withValues(alpha: 0.6),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.neonPurple.withValues(alpha: 0.15),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: buildTarotImage(
                                      card,
                                      fallbackFontSize: 30,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    card.name.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.voidBlack,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      card.element,
                                      style: TextStyle(color: _getElementColor(card.element), fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: _filteredCards.length,
                      ),
                    ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}
