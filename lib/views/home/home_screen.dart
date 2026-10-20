import 'dart:math';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/tarot_card.dart';
import '../../services/db_helper.dart';
import '../../services/sensor_service.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  List<TarotCard> _allCards = [];
  List<TarotCard> _filteredCards = [];
  TarotCard? _dailyCard;

  String _searchQuery = "";
  String _selectedElement = "Semua";
  final List<String> _elements = ["Semua", "Fire", "Water", "Air", "Earth"];

  double _tiltPitch = 0.0;
  double _tiltRoll = 0.0;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _loadCards();
    _initSensors();
  }

  Future<void> _loadCards() async {
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

  void _initSensors() {
    // Accelerometer: Shake to Shuffle
    SensorService.instance.startShakeDetection(
      onShake: () {
        if (mounted) {
          _drawNewRandomCard(isShake: true);
        }
      },
    );

    // Gyroscope: 3D Holographic Parallax Tilt
    SensorService.instance.startGyroscopeTilt(
      onTilt: (pitch, roll) {
        if (mounted) {
          setState(() {
            _tiltPitch = pitch;
            _tiltRoll = roll;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    SensorService.instance.stopAll();
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
    setState(() {
      _filteredCards = _allCards.where((card) {
        final matchesQuery = card.name.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesElement = _selectedElement == "Semua" || card.element.toLowerCase() == _selectedElement.toLowerCase();
        return matchesQuery && matchesElement;
      }).toList();
    });
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
                      // Photo/Image Container with Fallback
                      Container(
                        width: 110,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.mysticButton,
                          border: Border.all(color: AppColors.arcaneSilver.withValues(alpha: 0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(color: AppColors.neonPurple.withValues(alpha: 0.4), blurRadius: 15),
                          ],
                        ),
                        child: Center(
                          child: Text(card.symbol, style: const TextStyle(fontSize: 54)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "${card.number}. ${card.name}",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 22,
                              color: AppColors.arcaneSilver,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${card.arcanaType} • Elemen ${card.element}",
                        style: const TextStyle(color: AppColors.celestialCyan, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 20),

                      // Afirmasi Santai
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
                              const Text("✨ AFIRMASI HARI INI ✨", style: TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 12)),
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
            // Header Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null ? "Hai, ${user.username} ✨" : "Hai Sahabat! 🌌",
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, color: AppColors.arcaneSilver),
                        ),
                        Text(
                          user != null ? "Zodiak: ${user.zodiacSign}" : "Mode Tamu • Selamat mengeksplorasi!",
                          style: TextStyle(
                            color: user != null ? AppColors.brightLavender : AppColors.shimmerSilver,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.vibration, size: 14, color: AppColors.celestialCyan),
                          SizedBox(width: 4),
                          Text("Shake / Gyro Aktif", style: TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Daily Card (Shake to Shuffle + Gyroscope 3D Tilt)
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
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppColors.brightLavender, size: 20),
                          tooltip: "Kocok Kartu Baru",
                          onPressed: () => _drawNewRandomCard(isShake: false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // 3D Parallax Tilt Widget
                    Center(
                      child: Transform(
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_tiltPitch * 0.15)
                          ..rotateY(_tiltRoll * 0.15),
                        alignment: Alignment.center,
                        child: GestureDetector(
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
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "#${_dailyCard!.number} ${_dailyCard!.name}",
                                            style: const TextStyle(
                                              color: AppColors.arcaneSilver,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.neonPurple.withValues(alpha: 0.3),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _dailyCard!.element,
                                              style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        _dailyCard!.symbol,
                                        style: const TextStyle(fontSize: 60),
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
                                          const Icon(Icons.vibration, size: 14, color: AppColors.shimmerSilver),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Goyang HP kamu untuk kocok kartu!",
                                            style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.8), fontSize: 11),
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
                        hintText: "Cari nama kartu (misal: The Fool, The Lovers)...",
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

            // Grid of Tarot Cards: ONLY Name & Symbol (NO Raw Array list!)
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
                        childAspectRatio: 0.95, // Clean square-like card
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final card = _filteredCards[index];
                          return GestureDetector(
                            onTap: () => _showCardDetailModal(card),
                            child: Container(
                              padding: const EdgeInsets.all(14),
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
                                  // Card Photo / Symbol Placeholder
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.cardSurfaceLight,
                                      border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.3)),
                                    ),
                                    child: Center(
                                      child: Text(card.symbol, style: const TextStyle(fontSize: 30)),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Clean Name Only (No raw arrays!)
                                  Text(
                                    "${card.number}. ${card.name}",
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
                                      style: const TextStyle(color: AppColors.celestialCyan, fontSize: 10),
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
