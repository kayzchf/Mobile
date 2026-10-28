import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/db_helper.dart';
import '../../services/auth_service.dart';
import '../../services/timezone_service.dart';
import '../../services/ai_service.dart';

class ReaderChatScreen extends StatefulWidget {
  final BookingModel? initialBooking;

  const ReaderChatScreen({super.key, this.initialBooking});

  @override
  State<ReaderChatScreen> createState() => _ReaderChatScreenState();
}

class _ReaderChatScreenState extends State<ReaderChatScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _bookedSessions = [];
  bool _isLoadingSessions = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookedSessions();

    // If navigated with a specific booking, auto-open roomchat
    if (widget.initialBooking != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openRoomchat(widget.initialBooking!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Check if current time is within 09:00 - 18:00 WIB operational hours
  bool get _isOperationalHours {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    return nowWib.hour >= 9 && nowWib.hour < 18;
  }

  Future<void> _loadBookedSessions() async {
    setState(() => _isLoadingSessions = true);
    // Cleanup expired chats older than H+3
    await DatabaseHelper.instance.cleanupExpiredChatsH3();

    final user = AuthService.instance.currentUser;
    List<BookingModel> sessions = [];
    if (user != null && user.id != null) {
      final userBookings = await DatabaseHelper.instance.getBookingsByUser(user.id!);
      sessions = userBookings.where((b) => b.paymentStatus == 'CONFIRMED').toList();
    } else {
      // In guest mode or all confirmed sessions
      sessions = await DatabaseHelper.instance.getAllBookedSessions();
    }

    if (mounted) {
      setState(() {
        _bookedSessions = sessions;
        _isLoadingSessions = false;
      });
    }
  }

  void _openRoomchat(BookingModel booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderRoomchatScreen(booking: booking),
      ),
    ).then((_) => _loadBookedSessions());
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _isOperationalHours;

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141A28),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.arcaneSilver),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "KONSULTASI LIVE READER",
              style: TextStyle(color: AppColors.arcaneSilver, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOnline ? AppColors.successEmerald : AppColors.warningOrange,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  isOnline ? "Reader Online (09:00 - 18:00 WIB)" : "Tutup (09:00 - 18:00 WIB) • AI Bot Siaga",
                  style: TextStyle(
                    color: isOnline ? AppColors.successEmerald : AppColors.shimmerSilver,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.celestialCyan,
          indicatorWeight: 3,
          labelColor: AppColors.brightLavender,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.chat_outlined), text: "Roomchat Reader"),
            Tab(icon: Icon(Icons.calendar_today_outlined), text: "Jadwal Booked"),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildChatThreadsTab(),
            _buildBookedScheduleTab(),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: WHATSAPP-STYLE CHAT LIST THREADS ---
  Widget _buildChatThreadsTab() {
    final isOnline = _isOperationalHours;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Operational Hours Notice Banner
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isOnline ? AppColors.astralIndigo.withValues(alpha: 0.5) : AppColors.cardSurfaceLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isOnline ? AppColors.celestialCyan.withValues(alpha: 0.3) : AppColors.mysticViolet.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Text(isOnline ? "🔮" : "🌙", style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isOnline
                      ? "Tarot Reader asli sedang aktif melayani sesi via chat WhatsApp style hingga 18:00 WIB!"
                      : "Di luar jam 09:00 - 18:00 WIB, pesan kamu akan dibalas oleh AI Bot Madame Arcanova.",
                  style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11, height: 1.3),
                ),
              ),
            ],
          ),
        ),

        // Live Chat Thread with Master Alistair (Senior Tarot Reader)
        InkWell(
          onTap: () {
            if (_bookedSessions.isNotEmpty) {
              _openRoomchat(_bookedSessions.first);
            } else {
              // Create demo / initial consultation booking model
              final defaultBooking = BookingModel(
                id: "DEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                userId: AuthService.instance.currentUser?.id ?? 1,
                serviceId: 1,
                serviceTitle: "Love Tarot Reading (Live Session)",
                durationMinutes: 30,
                sessionsCount: 1,
                sessionDate: "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                sessionTimeWib: "11:00",
                userTimezone: "WIB",
                totalPrice: 175000,
                currencyUsed: "IDR",
                paymentStatus: "CONFIRMED",
                qrisReference: "LIVE-ROOMCHAT-DIRECT",
              );
              _openRoomchat(defaultBooking);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Row(
              children: [
                // Reader Avatar with WhatsApp status ring
                Stack(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cardSurfaceLight,
                        border: Border.all(color: isOnline ? AppColors.successEmerald : AppColors.shimmerSilver, width: 2),
                      ),
                      child: const Center(
                        child: Text("🧙‍♂️", style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.successEmerald : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.voidBlack, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                // Message Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Master Alistair • Reader",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            isOnline ? "Online" : "09:00-18:00",
                            style: TextStyle(
                              color: isOnline ? AppColors.celestialCyan : AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.done_all, size: 14, color: AppColors.celestialCyan),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isOnline
                                  ? "Halo! Kartu tarot sudah aku siapkan. Silakan masuk..."
                                  : "[Bot] Master Alistair sedang offline. Sesi dipandu AI bot...",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        // H+3 Chat Retention Policy Notice
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, color: AppColors.arcaneSilver, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "🔒 Privasi Aman (H+3 Retention Policy): Riwayat chat otomatis terhapus secara permanen 3 hari setelah tanggal sesi konsultasi selesai.",
                  style: TextStyle(color: AppColors.shimmerSilver, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- TAB 2: JADWAL SESI BOOKED ---
  Widget _buildBookedScheduleTab() {
    if (_isLoadingSessions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookedSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📅", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 16),
              const Text(
                "Belum ada jadwal sesi yang booked.",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Pesan sesi tarot di menu Layanan untuk melihat jadwal konsultasi bersama reader di sini.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookedSessions.length,
      itemBuilder: (context, index) {
        final session = _bookedSessions[index];
        final zoneTimes = TimezoneService.instance.getAllZoneTimes(session.sessionTimeWib);

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    session.id,
                    style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successEmerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.successEmerald),
                    ),
                    child: const Text("Booked (Confirmed)", style: TextStyle(color: AppColors.successEmerald, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(session.serviceTitle, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(
                "Tanggal: ${session.sessionDate} • ${session.durationMinutes} Menit",
                style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12),
              ),
              const SizedBox(height: 6),
              // Timezones: WIB, WITA, London GMT (STRICTLY NO WIT!)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.voidBlack.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text("${session.sessionTimeWib} WIB", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    Text(zoneTimes['WITA']!, style: const TextStyle(color: AppColors.brightLavender, fontSize: 11)),
                    Text("🇬🇧 ${zoneTimes['London']!}", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _openRoomchat(session),
                icon: const Icon(Icons.chat, size: 16),
                label: const Text("Mulai Sesi Chat WhatsApp"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(42),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- WHATSAPP STYLE ROOMCHAT SCREEN ---
class ReaderRoomchatScreen extends StatefulWidget {
  final BookingModel booking;

  const ReaderRoomchatScreen({super.key, required this.booking});

  @override
  State<ReaderRoomchatScreen> createState() => _ReaderRoomchatScreenState();
}

class _ReaderRoomchatScreenState extends State<ReaderRoomchatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
    // Real-time synchronization between physical phone & emulator via PostgreSQL
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        _loadChatHistory(silent: true);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isOperationalHours {
    final nowWib = DateTime.now().toUtc().add(const Duration(hours: 7));
    return nowWib.hour >= 9 && nowWib.hour < 18;
  }

  Future<void> _loadChatHistory({bool silent = false}) async {
    final list = await DatabaseHelper.instance.getReaderChats(widget.booking.id);
    if (!mounted) return;

    if (_messages.length != list.length || !silent) {
      setState(() {
        _messages.clear();
        _messages.addAll(list);
      });

      // If viewer is Tarot Reader and room has no messages yet, seed opening message
      if (_messages.isEmpty && AuthService.instance.isTarotReader) {
        final opening = "Halo sahabat! Salam kenal, aku Master Alistair (Tarot Reader Arcanova). Selamat datang di sesi ${widget.booking.serviceTitle}. Kartu-kartu sudah aku tata di mejaku. Coba ceritakan apa yang ingin kamu gali hari ini?";

        await DatabaseHelper.instance.insertReaderChat(
          bookingId: widget.booking.id,
          sender: 'reader',
          message: opening,
          sessionDate: widget.booking.sessionDate,
        );

        final refreshed = await DatabaseHelper.instance.getReaderChats(widget.booking.id);
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(refreshed);
          });
        }
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    _textController.clear();
    setState(() => _isSending = true);

    final isReader = AuthService.instance.isTarotReader;
    final senderRole = isReader ? 'reader' : 'user';

    // 1. Save message to SQLite & PostgreSQL cloud
    await DatabaseHelper.instance.insertReaderChat(
      bookingId: widget.booking.id,
      sender: senderRole,
      message: text,
      sessionDate: widget.booking.sessionDate,
    );

    await _loadChatHistory(silent: true);

    // 2. If client sends message alone and outside operational hours, bot replies as fallback
    if (!isReader && !_isOperationalHours) {
      await Future.delayed(const Duration(milliseconds: 900));
      final aiResponse = await AiTarotService.instance.consultArcanova(userMessage: text);
      final reply = "[🤖 Madame Arcanova - Mode Luar Jam Operasional]\n$aiResponse";

      await DatabaseHelper.instance.insertReaderChat(
        bookingId: widget.booking.id,
        sender: 'bot',
        message: reply,
        sessionDate: widget.booking.sessionDate,
      );

      if (mounted) {
        await _loadChatHistory(silent: true);
      }
    }

    if (mounted) {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = _isOperationalHours;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // WhatsApp dark theme aesthetic
      appBar: AppBar(
        backgroundColor: const Color(0xFF161F2E),
        elevation: 1,
        leadingWidth: 32,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.astralIndigo,
                  child: Text(isOnline ? "🧙‍♂️" : "🤖", style: const TextStyle(fontSize: 20)),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isOnline ? AppColors.successEmerald : Colors.amber,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOnline ? "Master Alistair (Live Reader)" : "Madame Arcanova (AI Bot)",
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isOnline ? "Online • Jam Operasional (09:00 - 18:00 WIB)" : "Offline • Dibalas otomatis oleh Bot",
                    style: TextStyle(
                      color: isOnline ? AppColors.celestialCyan : AppColors.shimmerSilver,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.arcaneSilver, size: 20),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.cardSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: const Text("Info Sesi Konsultasi", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 16)),
                  content: Text(
                    "📌 Layanan: ${widget.booking.serviceTitle}\n"
                    "📅 Tanggal: ${widget.booking.sessionDate}\n"
                    "⏰ Jam: ${widget.booking.sessionTimeWib} WIB\n"
                    "🔒 Privasi: Chat otomatis terhapus H+3 setelah sesi selesai demi menjaga kerahasiaan.",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                  ),
                  actions: [
                    ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Tutup")),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // WhatsApp style encrypted session badge
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2332),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock, size: 12, color: AppColors.shimmerSilver),
                  const SizedBox(width: 6),
                  Text(
                    "Terenkripsi • H+3 Chat Otomatis Dihapus (${widget.booking.sessionDate})",
                    style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 10),
                  ),
                ],
              ),
            ),

            // Chat Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isReaderViewer = AuthService.instance.isTarotReader;
                  final isMe = isReaderViewer ? (msg['sender'] == 'reader') : (msg['sender'] == 'user');
                  final isBot = msg['sender'] == 'bot';
                  final isReaderMsg = msg['sender'] == 'reader';
                  final timeStr = msg['timestamp'] != null
                      ? DateTime.tryParse(msg['timestamp']) != null
                          ? "${DateTime.parse(msg['timestamp']).hour.toString().padLeft(2, '0')}:${DateTime.parse(msg['timestamp']).minute.toString().padLeft(2, '0')}"
                          : ""
                      : "";

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe
                            ? const Color(0xFF5E2B97) // WhatsApp mystic purple
                            : isBot
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF1B2333),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isMe ? 16 : 2),
                          bottomRight: Radius.circular(isMe ? 2 : 16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                isBot
                                    ? "🤖 Madame Arcanova (Bot)"
                                    : isReaderMsg
                                        ? "🧙‍♂️ Master Alistair (Reader)"
                                        : "💬 Klien Arcanova",
                                style: TextStyle(
                                  color: isBot ? AppColors.warningOrange : AppColors.celestialCyan,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            msg['message'] ?? "",
                            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.35),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                timeStr,
                                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.done_all, size: 12, color: AppColors.celestialCyan),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isSending)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Row(
                  children: [
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.celestialCyan)),
                    const SizedBox(width: 8),
                    Text(
                      isOnline ? "Master Alistair sedang mengetik..." : "Bot Madame Arcanova sedang membalas...",
                      style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11),
                    ),
                  ],
                ),
              ),

            // WhatsApp Style Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF161F2E),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF222D3E),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Ketik pesan konsultasi...",
                          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.neonPurple,
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _handleSendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

