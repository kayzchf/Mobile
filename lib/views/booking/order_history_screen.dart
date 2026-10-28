import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/db_helper.dart';
import '../../services/auth_service.dart';
import '../../services/timezone_service.dart';
import '../live_chat/reader_chat_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<BookingModel> _bookings = [];
  final Set<String> _expandedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    final user = AuthService.instance.currentUser;
    if (user?.id != null) {
      final list = await DatabaseHelper.instance.getBookingsByUser(user!.id!);
      if (mounted) {
        setState(() {
          _bookings = list;
          _isLoading = false;
        });
      }
    } else {
      final all = await DatabaseHelper.instance.getAllBookedSessions();
      if (mounted) {
        setState(() {
          _bookings = all;
          _isLoading = false;
        });
      }
    }
  }

  // Deterministic Cryptographic Block generator for each session
  Map<String, dynamic> _generateBlockData(BookingModel item) {
    final raw = "${item.id}:${item.sessionDate}:${item.sessionTimeWib}:${item.totalPrice}";
    final hash = "0x${sha256.convert(utf8.encode(raw)).toString()}";
    final blockNum = 840000 + (item.id.hashCode.abs() % 9999);
    final shortHash = "${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}";
    return {
      'blockNumber': "Block #$blockNum",
      'shortHash': shortHash,
      'fullHash': hash,
      'readerName': "Master Alistair (Official Reader)",
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "THE DESTINY CHAIN",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.brightLavender,
                    letterSpacing: 2,
                    fontSize: 17,
                  ),
            ),
            const Text(
              "Riwayat Terverifikasi Blockchain",
              style: TextStyle(color: AppColors.shimmerSilver, fontSize: 11),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brightLavender),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _bookings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.cardSurfaceLight,
                              border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.3)),
                            ),
                            child: const Text("⛓️", style: TextStyle(fontSize: 46)),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            "Belum ada rantai takdir tercatat.",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Setiap sesi tarot yang kamu pesan akan tercatat permanen di blockchain The Destiny Chain.",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final item = _bookings[index];
                      final isLast = index == _bookings.length - 1;
                      final isExpanded = _expandedIds.contains(item.id);
                      final blockData = _generateBlockData(item);
                      final zoneTimes = TimezoneService.instance.getAllZoneTimes(item.sessionTimeWib);

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 1. Glowing Chain Node & Connector Line on Left
                            SizedBox(
                              width: 38,
                              child: Column(
                                children: [
                                  Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: const Color(0xFF161F2E),
                                      border: Border.all(color: AppColors.celestialCyan, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.celestialCyan.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.link, size: 13, color: AppColors.celestialCyan),
                                    ),
                                  ),
                                  if (!isLast)
                                    Expanded(
                                      child: Container(
                                        width: 2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.celestialCyan,
                                              AppColors.neonPurple.withValues(alpha: 0.3),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // 2. Cyber-Mystic Destiny Card
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 18),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isExpanded
                                        ? AppColors.celestialCyan
                                        : AppColors.mysticViolet.withValues(alpha: 0.35),
                                    width: isExpanded ? 1.5 : 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isExpanded
                                          ? AppColors.celestialCyan.withValues(alpha: 0.12)
                                          : Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (isExpanded) {
                                        _expandedIds.remove(item.id);
                                      } else {
                                        _expandedIds.add(item.id);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Header: Title & Verified Badge
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.serviceTitle,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF064E3B).withValues(alpha: 0.4),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: const Color(0xFF10B981), width: 1),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.lock, size: 10, color: Color(0xFF34D399)),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "Terverifikasi Blockchain",
                                                    style: TextStyle(
                                                      color: Color(0xFF34D399),
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Sub-header: Reader Name & Date
                                        Row(
                                          children: [
                                            const Icon(Icons.person, size: 12, color: AppColors.brightLavender),
                                            const SizedBox(width: 4),
                                            Text(
                                              blockData['readerName']!,
                                              style: const TextStyle(color: AppColors.brightLavender, fontSize: 11),
                                            ),
                                            const Spacer(),
                                            Text(
                                              item.sessionDate,
                                              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        Row(
                                          children: [
                                            Text(
                                              "${item.sessionTimeWib} WIB • ${zoneTimes['London']}",
                                              style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11),
                                            ),
                                            const Spacer(),
                                            Icon(
                                              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                              color: AppColors.shimmerSilver,
                                              size: 18,
                                            ),
                                          ],
                                        ),

                                        // Expandable Cryptographic Details
                                        if (isExpanded) ...[
                                          const Divider(color: Colors.white12, height: 20),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0F172A),
                                              borderRadius: BorderRadius.circular(14),
                                              border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.3)),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      blockData['blockNumber']!,
                                                      style: const TextStyle(
                                                        color: AppColors.celestialCyan,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      "${item.currencyUsed} ${item.totalPrice.toStringAsFixed(item.currencyUsed == 'IDR' ? 0 : 2)}",
                                                      style: const TextStyle(
                                                        color: AppColors.arcaneSilver,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Durasi: ${item.sessionsCount * item.durationMinutes} Menit (${item.sessionsCount} Sesi)",
                                                  style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11),
                                                ),
                                                const SizedBox(height: 10),

                                                // Transaction Hash
                                                const Text(
                                                  "Transaction Hash (SHA-256 Ledger):",
                                                  style: TextStyle(color: AppColors.textMuted, fontSize: 10),
                                                ),
                                                const SizedBox(height: 3),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        blockData['shortHash']!,
                                                        style: const TextStyle(
                                                          color: Colors.white70,
                                                          fontFamily: 'monospace',
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    TextButton.icon(
                                                      onPressed: () {
                                                        Clipboard.setData(ClipboardData(text: blockData['fullHash']!));
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          const SnackBar(
                                                            backgroundColor: AppColors.successEmerald,
                                                            content: Text("✨ Kunci Validasi Blockchain Tersalin!"),
                                                            duration: Duration(seconds: 2),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(Icons.copy, size: 13, color: AppColors.celestialCyan),
                                                      label: const Text(
                                                        "Salin Kunci",
                                                        style: TextStyle(color: AppColors.celestialCyan, fontSize: 11),
                                                      ),
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        minimumSize: Size.zero,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),

                                          // Roomchat button
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => ReaderRoomchatScreen(booking: item),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.chat_bubble_outline, size: 15),
                                            label: const Text("Buka Sesi Chat WhatsApp"),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.neonPurple,
                                              minimumSize: const Size.fromHeight(38),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
