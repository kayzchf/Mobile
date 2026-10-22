import 'package:flutter/material.dart';
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
      // In guest mode, load all bookings for test presentation
      final all = await DatabaseHelper.instance.getAllBookedSessions();
      if (mounted) {
        setState(() {
          _bookings = all;
          _isLoading = false;
        });
      }
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
          "RIWAYAT PEMESANAN",
          style: TextStyle(color: AppColors.arcaneSilver, letterSpacing: 1.5, fontSize: 17),
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
                          const Text("🔮", style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          const Text(
                            "Belum ada sesi yang kamu pesan.",
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Yuk jelajahi 4 paket layanan pembacaan tarot kami di menu Layanan!",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final item = _bookings[index];
                      final zoneTimes = TimezoneService.instance.getAllZoneTimes(item.sessionTimeWib);
                      final isConfirmed = item.paymentStatus == 'CONFIRMED';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.cardSurface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isConfirmed ? AppColors.celestialCyan.withValues(alpha: 0.5) : AppColors.mysticViolet.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item.id,
                                  style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isConfirmed ? AppColors.successEmerald.withValues(alpha: 0.2) : AppColors.warningOrange.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isConfirmed ? AppColors.successEmerald : AppColors.warningOrange),
                                  ),
                                  child: Text(
                                    isConfirmed ? "Confirmed" : item.paymentStatus,
                                    style: TextStyle(
                                      color: isConfirmed ? AppColors.successEmerald : AppColors.warningOrange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.serviceTitle,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${item.sessionsCount} Sesi • ${item.durationMinutes} mnt/sesi",
                              style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12),
                            ),
                            const Divider(color: Colors.white10, height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Jadwal: ${item.sessionDate}", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                    Text("${item.sessionTimeWib} WIB • ${zoneTimes['London']}", style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                  ],
                                ),
                                Text(
                                  "${item.currencyUsed} ${item.totalPrice.toStringAsFixed(item.currencyUsed == 'IDR' ? 0 : 2)}",
                                  style: const TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ],
                            ),
                            if (isConfirmed) ...[
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReaderChatScreen(initialBooking: item),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                label: const Text("Masuk Roomchat Tarot Reader"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.neonPurple,
                                  minimumSize: const Size.fromHeight(40),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
