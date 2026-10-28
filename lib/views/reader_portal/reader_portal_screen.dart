import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/db_helper.dart';
import '../../services/timezone_service.dart';
import '../../services/notification_service.dart';
import '../live_chat/reader_chat_screen.dart';
import '../auth/login_screen.dart';

class TarotReaderPortalScreen extends StatefulWidget {
  const TarotReaderPortalScreen({super.key});

  @override
  State<TarotReaderPortalScreen> createState() => _TarotReaderPortalScreenState();
}

class _TarotReaderPortalScreenState extends State<TarotReaderPortalScreen> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _activeClientSessions = [];
  List<BookingModel> _allBookedSchedule = [];
  bool _isLoading = true;
  bool _isReaderReady = true;

  @override
  void initState() {
    super.initState();
    _loadReaderData();
  }

  Future<void> _loadReaderData() async {
    setState(() => _isLoading = true);
    await DatabaseHelper.instance.cleanupExpiredChatsH3();

    final sessions = await DatabaseHelper.instance.getActiveReaderSessions();
    final allBookings = await DatabaseHelper.instance.getAllBookedSessions();

    if (mounted) {
      setState(() {
        _activeClientSessions = sessions;
        _allBookedSchedule = allBookings;
        _isLoading = false;
      });
    }
  }

  void _openChatWithClient(String bookingId, String serviceTitle, String sessionDate, String sessionTime) {
    final booking = BookingModel(
      id: bookingId,
      userId: 1,
      serviceId: 1,
      serviceTitle: serviceTitle,
      durationMinutes: 30,
      sessionsCount: 1,
      sessionDate: sessionDate,
      sessionTimeWib: sessionTime,
      userTimezone: "WIB",
      totalPrice: 175000,
      currencyUsed: "IDR",
      paymentStatus: "CONFIRMED",
      qrisReference: "QRIS-CONFIRMED-LIVE",
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReaderRoomchatScreen(booking: booking),
      ),
    ).then((_) => _loadReaderData());
  }

  Future<void> _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF161F2E),
        elevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF222D3E),
              ),
              child: const Text("🧙‍♂️", style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "PORTAL TAROT READER",
                  style: TextStyle(color: AppColors.arcaneSilver, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _isReaderReady ? AppColors.successEmerald : AppColors.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isReaderReady ? "Status: Siap Konsultasi (Online)" : "Status: Istirahat (Offline)",
                      style: TextStyle(
                        color: _isReaderReady ? AppColors.successEmerald : AppColors.shimmerSilver,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.celestialCyan),
            tooltip: "Segarkan Data",
            onPressed: _loadReaderData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.errorCrimson),
            tooltip: "Keluar Portal",
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildActiveChatsTab(),
            _buildScheduleTab(),
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF161F2E),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.neonPurple.withValues(alpha: 0.4),
          elevation: 0,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.chat_bubble, color: AppColors.celestialCyan),
              label: "Chat Aktif",
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.calendar_month, color: AppColors.brightLavender),
              label: "Jadwal Konsultasi",
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: AppColors.textMuted),
              selectedIcon: Icon(Icons.person, color: AppColors.arcaneSilver),
              label: "Profil Reader",
            ),
          ],
        ),
      ),
    );
  }

  // --- TAB 1: CHAT AKTIF (SEDANG DALAM SESI) ---
  Widget _buildActiveChatsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.celestialCyan));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Reader Operational Notice
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Text("🌙", style: TextStyle(fontSize: 24)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Jadwal Konsultasi Malam: 21:00 - 03:00 WIB", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(height: 2),
                    Text("Sesi obrolan dengan pelanggan otomatis terhapus setelah 3 hari (Kebijakan H+3).", style: TextStyle(color: AppColors.shimmerSilver, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_activeClientSessions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              children: [
                const Text("🔮", style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                const Text("Belum Ada Klien yang Mulai Sesi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                const Text(
                  "Ketika pelanggan memesan layanan dan jam sesi tiba, roomchat aktif akan otomatis muncul di sini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Seed demo chat for testing
                    _openChatWithClient(
                      "DEMO-LIVE-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}",
                      "Love Tarot Reading",
                      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}",
                      "21:00",
                    );
                  },
                  icon: const Icon(Icons.add_comment),
                  label: const Text("Buka Simulasi Obrolan Klien"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          )
        else
          for (final session in _activeClientSessions)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF161F2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.25)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: AppColors.astralIndigo,
                  child: Text(session['client_gender'] == 'female' ? "👩" : "👨", style: const TextStyle(fontSize: 22)),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session['client_name'] ?? "Klien Arcanova",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "${session['session_time_wib']} WIB",
                      style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      session['service_title'] ?? "Sesi Konsultasi Tarot",
                      style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 12, color: AppColors.warningOrange),
                        const SizedBox(width: 4),
                        Text(
                          "H+3: Terhapus otomatis pada ${session['session_date']}",
                          style: const TextStyle(color: AppColors.warningOrange, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.chevron_right, color: AppColors.brightLavender),
                onTap: () {
                  _openChatWithClient(
                    session['booking_id'],
                    session['service_title'] ?? "Sesi Konsultasi Tarot",
                    session['session_date'] ?? "2026-10-24",
                    session['session_time_wib'] ?? "21:00",
                  );
                },
              ),
            ),
      ],
    );
  }

  // --- TAB 2: JADWAL KONSULTASI (BOOKED SCHEDULE) ---
  Widget _buildScheduleTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.celestialCyan));
    }

    if (_allBookedSchedule.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("📅", style: TextStyle(fontSize: 48)),
              const SizedBox(height: 14),
              const Text("Belum Ada Jadwal Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text("Ketika ada klien yang membayar pesanan sesi, daftar jadwal akan muncul otomatis di sini.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allBookedSchedule.length,
      itemBuilder: (context, index) {
        final b = _allBookedSchedule[index];
        final zoneTimes = TimezoneService.instance.getAllZoneTimes(b.sessionTimeWib);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161F2E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successEmerald.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.successEmerald),
                    ),
                    child: const Text("Confirmed Booked", style: TextStyle(color: AppColors.successEmerald, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  Text(b.id, style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 8),
              Text(b.serviceTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Text("Tanggal: ${b.sessionDate} • Durasi: ${b.durationMinutes} Menit", style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.voidBlack.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("⏰ ${b.sessionTimeWib} WIB", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text("WITA: ${zoneTimes['WITA']}", style: const TextStyle(color: AppColors.brightLavender, fontSize: 11)),
                    Text("🇬🇧 ${zoneTimes['London']}", style: const TextStyle(color: AppColors.celestialCyan, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  _openChatWithClient(b.id, b.serviceTitle, b.sessionDate, b.sessionTimeWib);
                },
                icon: const Icon(Icons.chat, size: 16),
                label: const Text("Buka Roomchat Sesi Ini"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: PROFIL READER ---
  Widget _buildProfileTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Reader Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: AppColors.celestialCyan, width: 2),
                ),
                child: const Center(child: Text("🧙‍♂️", style: TextStyle(fontSize: 34))),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Master Alistair", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                    SizedBox(height: 2),
                    Text("Senior Tarot Reader • Arcanova", style: TextStyle(color: AppColors.celestialCyan, fontSize: 12)),
                    SizedBox(height: 4),
                    Text("Spesialis: Love, Career & Astral Path", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Settings
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161F2E),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("Status Siap Konsultasi", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: Text(_isReaderReady ? "Klien dapat melihat Anda Online" : "Status Offline", style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                secondary: const Icon(Icons.circle, color: AppColors.successEmerald, size: 16),
                value: _isReaderReady,
                activeThumbColor: AppColors.arcaneSilver,
                onChanged: (val) => setState(() => _isReaderReady = val),
              ),
              const Divider(color: Colors.white10, height: 1),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined, color: AppColors.celestialCyan),
                title: const Text("Uji Notifikasi Masuk", style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text("Kirim notifikasi tes konsultasi baru", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                onTap: () async {
                  await NotificationService.instance.showNotification(
                    title: "🔔 Klien Baru Siap Konsultasi!",
                    body: "Sesi Love Reading bersama Klien dijadwalkan pukul 21:00 WIB malam ini.",
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: AppColors.successEmerald, content: Text("Notifikasi tes terkirim!")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        OutlinedButton.icon(
          onPressed: _handleLogout,
          icon: const Icon(Icons.logout, color: AppColors.shimmerSilver),
          label: const Text("Keluar dari Portal Reader", style: TextStyle(color: Colors.white)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

