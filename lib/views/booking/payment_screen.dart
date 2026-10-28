import 'dart:async';
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/db_helper.dart';
import '../../services/timezone_service.dart';
import '../../services/online_cloud_service.dart';
import 'session_waiting_screen.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({super.key, required this.booking});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _secondsRemaining = 15 * 60; // 15 minutes
  Timer? _timer;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _handleUpdatePaymentStatus() async {
    setState(() => _isUpdating = true);

    try {
      // 1. Save / Update booking to database as CONFIRMED
      final confirmedBooking = widget.booking.copyWith(paymentStatus: 'CONFIRMED');
      await DatabaseHelper.instance.insertBooking(confirmedBooking);

      // Sync to Cloud PostgreSQL database
      OnlineCloudService.instance.syncBookingToCloud(confirmedBooking);

      await Future.delayed(const Duration(milliseconds: 600));

      if (!mounted) return;
      setState(() => _isUpdating = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.successEmerald,
          content: Text("✨ Hore! Pembayaran berhasil dikonfirmasi. Sesi kamu sudah terjadwal."),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionWaitingScreen(booking: confirmedBooking),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text("Gagal perbarui pembayaran: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only display the specific booked time in user's chosen timezone (clean & no WIT!)
    final formattedUserTime = TimezoneService.instance.formatForUserTimezone(
      widget.booking.sessionTimeWib,
      widget.booking.userTimezone,
    );

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("PEMBAYARAN QRIS", style: TextStyle(color: AppColors.arcaneSilver, letterSpacing: 1.5, fontSize: 17)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.brightLavender),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Expiry countdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.warningOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.warningOrange.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.warningOrange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Selesaikan dalam: $_formattedTime",
                      style: const TextStyle(color: AppColors.warningOrange, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // QRIS Card Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPurple.withValues(alpha: 0.4),
                      blurRadius: 25,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "QRIS",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: 1.5),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text("GPN", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "ARCANOVA SANCTUARY",
                      style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const Text(
                      "NMID: ID1020268899017 • Malioboro, YK",
                      style: TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                    const SizedBox(height: 16),

                    // Static QR Simulation Matrix
                    Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: 64,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              crossAxisSpacing: 3,
                              mainAxisSpacing: 3,
                            ),
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final isCorner = index == 0 || index == 7 || index == 56 || index == 63;
                              final isDot = (index * 7 + 3) % 2 == 0;
                              return Container(
                                color: isCorner
                                    ? Colors.cyanAccent
                                    : (isDot ? Colors.white : Colors.black),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                            child: const Text("🔮", style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Scan pakai BCA, Mandiri, GoPay, OVO, ShopeePay, dll",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Booking Details / Nota
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.35)),
                ),
                child: Column(
                  children: [
                    _buildRowDetail("Kode Pesanan", widget.booking.id),
                    _buildRowDetail("Layanan", widget.booking.serviceTitle),
                    _buildRowDetail("Sesi", "${widget.booking.sessionsCount} Sesi (${widget.booking.durationMinutes} mnt/sesi)"),
                    _buildRowDetail("Tanggal", widget.booking.sessionDate),
                    // Only show the specific booked time in user's timezone!
                    _buildRowDetail("Jam Sesi", formattedUserTime),
                    _buildRowDetail("Pengingat", "${widget.booking.reminderMinutes} Menit Sebelum"),
                    const Divider(color: Colors.white10, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tagihan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          "${widget.booking.currencyUsed} ${widget.booking.totalPrice.toStringAsFixed(widget.booking.currencyUsed == 'IDR' ? 0 : 2)}",
                          style: const TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _isUpdating ? null : _handleUpdatePaymentStatus,
                icon: _isUpdating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _isUpdating ? "Memproses..." : "Perbarui Status Pembayaran",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonPurple,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Setelah transfer via QRIS, klik tombol di atas ya!",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12)),
        ],
      ),
    );
  }
}
