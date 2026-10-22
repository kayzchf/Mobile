import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/notification_service.dart';
import '../../services/timezone_service.dart';
import '../live_chat/reader_chat_screen.dart';
import '../main_navigation.dart';

class SessionWaitingScreen extends StatefulWidget {
  final BookingModel booking;

  const SessionWaitingScreen({super.key, required this.booking});

  @override
  State<SessionWaitingScreen> createState() => _SessionWaitingScreenState();
}

class _SessionWaitingScreenState extends State<SessionWaitingScreen> {
  @override
  void initState() {
    super.initState();
    _scheduleSessionNotification();
  }

  void _scheduleSessionNotification() {
    try {
      final dateParts = widget.booking.sessionDate.split('-');
      final timeParts = widget.booking.sessionTimeWib.split(':');
      final sessionDateTime = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );

      NotificationService.instance.scheduleSessionReminder(
        id: widget.booking.id.hashCode,
        serviceTitle: widget.booking.serviceTitle,
        sessionTime: sessionDateTime,
        reminderMinutes: widget.booking.reminderMinutes,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final zoneTimes = TimezoneService.instance.getAllZoneTimes(widget.booking.sessionTimeWib);
    final userTime = TimezoneService.instance.formatForUserTimezone(
      widget.booking.sessionTimeWib,
      widget.booking.userTimezone,
    );

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Glowing Circle
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.mysticButton,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.celestialCyan.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text("⏳", style: TextStyle(fontSize: 48)),
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "SESI KAMU BERHASIL DIJADWALKAN!",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.arcaneSilver,
                      letterSpacing: 1.5,
                      fontSize: 18,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Santai sejenak ya sahabat, Reader kami siap menyambutmu.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.shimmerSilver, fontSize: 13),
              ),
              const SizedBox(height: 24),

              // Booking Detail Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status Pembayaran", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successEmerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.successEmerald),
                          ),
                          child: const Text(
                            "BERHASIL (Confirmed)",
                            style: TextStyle(color: AppColors.successEmerald, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 24),
                    _buildInfoRow("Layanan", widget.booking.serviceTitle),
                    _buildInfoRow("Tanggal", widget.booking.sessionDate),
                    _buildInfoRow("Waktu Pilihan Kamu", userTime),
                    _buildInfoRow("WIB (Indonesia Barat)", "${widget.booking.sessionTimeWib} WIB"),
                    _buildInfoRow("WITA (Indonesia Tengah)", zoneTimes['WITA']!),
                    _buildInfoRow("🇬🇧 London (GMT)", zoneTimes['London']!),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Clean Notification Announcement
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.deepSpace,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: AppColors.celestialCyan, size: 28),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Pengingat Otomatis (${widget.booking.reminderMinutes} Menit)",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Pemberitahuan akan dikirimkan otomatis ke HP kamu ${widget.booking.reminderMinutes} menit sebelum sesi konsultasi dimulai.",
                            style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.9), fontSize: 12, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // 1. Direct WhatsApp Style Chat with Tarot Reader Button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReaderChatScreen(initialBooking: widget.booking),
                    ),
                  );
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text("Mulai Chat dengan Reader (WA Style)"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 12),

              // 2. Back to Home Button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.home, color: AppColors.shimmerSilver),
                label: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: BorderSide(color: AppColors.mysticViolet.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
