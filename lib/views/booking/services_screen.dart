import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/currency_service.dart';
import '../../services/timezone_service.dart';
import '../../services/db_helper.dart';
import '../auth/login_screen.dart';
import 'payment_screen.dart';
import '../live_chat/reader_chat_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final List<TarotService> _services = TarotService.defaultServices;
  int? _expandedServiceId = 1; // Default first service expanded
  bool _hasActiveBookings = false;
  BookingModel? _activeReadyBooking;
  final int _unreadReaderCount = 1; // Unread message badge from Reader

  @override
  void initState() {
    super.initState();
    _checkActiveBookings();
    CurrencyService.instance.addListener(_onCurrencyChanged);
    AuthService.instance.addListener(_checkActiveBookings);
  }

  @override
  void dispose() {
    CurrencyService.instance.removeListener(_onCurrencyChanged);
    AuthService.instance.removeListener(_checkActiveBookings);
    super.dispose();
  }

  void _onCurrencyChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _checkActiveBookings() async {
    final user = AuthService.instance.currentUser;
    if (user != null && user.id != null) {
      final bookings = await DatabaseHelper.instance.getUserBookings(user.id!);
      final confirmed = bookings.where((b) => b.paymentStatus == 'CONFIRMED').toList();
      BookingModel? readyBooking;
      for (final b in confirmed) {
        // Chat button only appears when tarot reader has initiated/opened the chat first
        final initiated = await DatabaseHelper.instance.isChatInitiatedByReader(b.id);
        if (initiated) {
          readyBooking = b;
          break;
        }
      }
      if (mounted) {
        setState(() {
          _activeReadyBooking = readyBooking;
          _hasActiveBookings = readyBooking != null;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _activeReadyBooking = null;
          _hasActiveBookings = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;
    final userCurrency = CurrencyService.instance.currencyCode;
    final userTz = user?.timezonePref ?? 'WIB';

    return Scaffold(
      backgroundColor: AppColors.voidBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "LAYANAN TAROT",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.arcaneSilver,
                letterSpacing: 2,
              ),
        ),
        actions: [
          // Currency & Timezone Badge (Synced with Profile)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.public, size: 14, color: AppColors.celestialCyan),
                const SizedBox(width: 6),
                Text(
                  "$userTz • $userCurrency",
                  style: const TextStyle(
                    color: AppColors.arcaneSilver,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _hasActiveBookings
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonPurple.withValues(alpha: 0.5),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Badge(
                label: Text("$_unreadReaderCount"),
                backgroundColor: AppColors.errorCrimson,
                textColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                child: FloatingActionButton.extended(
                  backgroundColor: AppColors.astralIndigo,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                    side: const BorderSide(color: AppColors.celestialCyan, width: 1.5),
                  ),
                  onPressed: () {
                    if (_activeReadyBooking != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReaderRoomchatScreen(booking: _activeReadyBooking!),
                        ),
                      ).then((_) => _checkActiveBookings());
                    }
                  },
                  icon: const Text("🧙‍♂️", style: TextStyle(fontSize: 20)),
                  label: const Text(
                    "Chat Tarot Reader",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Distinct Hero Banner for "Pilih Sesi Pembacaan Jiwa"
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                gradient: const RadialGradient(
                  center: Alignment(-0.8, -0.6),
                  radius: 1.8,
                  colors: [
                    Color(0xFF3B1E63),
                    Color(0xFF1E113A),
                    Color(0xFF0F081D),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.arcaneSilver.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.mysticViolet.withValues(alpha: 0.4),
                    blurRadius: 22,
                    spreadRadius: 2,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -15,
                    top: -15,
                    child: Opacity(
                      opacity: 0.12,
                      child: const Text("🔮", style: TextStyle(fontSize: 120)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.neonPurple.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.5)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, size: 12, color: AppColors.celestialCyan),
                                  SizedBox(width: 5),
                                  Text(
                                    "PORTAL RESMI SANCTUARY",
                                    style: TextStyle(
                                      color: AppColors.celestialCyan,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                userCurrency,
                                style: const TextStyle(
                                  color: AppColors.arcaneSilver,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Pilih Sesi Pembacaan Jiwa",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user != null
                              ? "Selamat datang, ${user.username}. Pilih layanan bimbingan hidup, asmara, atau karir bersama Master Alistair."
                              : "Jelajahi beragam sesi konsultasi batin. Masuk untuk pesan sesi pribadimu!",
                          style: const TextStyle(
                            color: AppColors.shimmerSilver,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.nightlight_round, size: 14, color: AppColors.brightLavender),
                            const SizedBox(width: 6),
                            Text(
                              "Jadwal Buka: 21.00 - 03.00 WIB (Interval 30 Menit)",
                              style: TextStyle(
                                color: AppColors.brightLavender.withValues(alpha: 0.9),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
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

            // Services Cards (Attractive, Expandable & Clear Pricing)
            for (final service in _services) _buildAttractiveServiceCard(context, service),
          ],
        ),
      ),
    );
  }

  Widget _buildAttractiveServiceCard(BuildContext context, TarotService service) {
    final isExpanded = _expandedServiceId == service.id;
    final formattedPrice = CurrencyService.instance.formatPrice(service.priceIdr);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isExpanded ? AppColors.celestialCyan : AppColors.mysticViolet.withValues(alpha: 0.35),
          width: isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isExpanded ? AppColors.mysticViolet.withValues(alpha: 0.3) : Colors.transparent,
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          setState(() {
            _expandedServiceId = isExpanded ? null : service.id;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Text(service.iconSymbol, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.neonPurple.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${service.durationMinutes} Menit",
                                style: const TextStyle(color: AppColors.brightLavender, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              formattedPrice,
                              style: const TextStyle(color: AppColors.arcaneSilver, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: AppColors.shimmerSilver,
                  ),
                ],
              ),

              // Expanded Details
              if (isExpanded) ...[
                const SizedBox(height: 14),
                const Divider(color: Colors.white12, height: 1),
                const SizedBox(height: 12),
                Text(
                  service.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.45),
                ),
                const SizedBox(height: 14),
                // Service Benefits Checklist
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.celestialCyan),
                    const SizedBox(width: 6),
                    Text("Sesi Live 1-on-1 dengan Reader Asli", style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.9), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.celestialCyan),
                    const SizedBox(width: 6),
                    Text("Tersedia Chat Live WhatsApp Style", style: TextStyle(color: AppColors.shimmerSilver.withValues(alpha: 0.9), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mulai dari", style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        Text(
                          formattedPrice,
                          style: const TextStyle(color: AppColors.arcaneSilver, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _openBookingBottomSheet(service),
                      icon: const Icon(Icons.calendar_month, size: 16),
                      label: const Text("Pesan Sekarang"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.neonPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openBookingBottomSheet(TarotService service) {
    final user = AuthService.instance.currentUser;
    if (user == null) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Halo Sahabat!", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 17, fontWeight: FontWeight.bold)),
          content: const Text(
            "Untuk memesan sesi membaca tarot pribadi, kamu perlu punya akun terlebih dahulu ya. Yuk masuk atau daftar!",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Nanti Aja", style: TextStyle(color: AppColors.textMuted)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text("Masuk / Daftar"),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BookingModal(service: service, user: user),
    ).then((_) => _checkActiveBookings());
  }
}

class _BookingModal extends StatefulWidget {
  final TarotService service;
  final dynamic user;

  const _BookingModal({required this.service, required this.user});

  @override
  State<_BookingModal> createState() => _BookingModalState();
}

class _BookingModalState extends State<_BookingModal> {
  int _sessionsCount = 1;
  DateTime? _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedSlotWib;
  int _reminderMinutes = 10;
  List<String> _bookedSlots = [];
  bool _isLoadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadBookedSlots();
  }

  Future<void> _loadBookedSlots() async {
    if (_selectedDate == null) return;
    setState(() => _isLoadingSlots = true);
    final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    final booked = await DatabaseHelper.instance.getBookedTimes(dateStr);
    if (mounted) {
      setState(() {
        _bookedSlots = booked;
        _isLoadingSlots = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.neonPurple,
              onPrimary: Colors.white,
              surface: AppColors.cardSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedSlotWib = null;
      });
      _loadBookedSlots();
    }
  }

  void _proceedToPayment() {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text("⚠️ Mohon pilih tanggal sesi konsultasi terlebih dahulu ya!"),
        ),
      );
      return;
    }

    if (_selectedSlotWib == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text("⚠️ Mohon pilih salah satu slot jam sesi yang tersedia!"),
        ),
      );
      return;
    }

    final dateStr = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
    final rawTotalIdr = widget.service.priceIdr * _sessionsCount;
    final convertedTotal = CurrencyService.instance.convertFromIdr(rawTotalIdr);
    final bookingId = "ARC-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";

    final newBooking = BookingModel(
      id: bookingId,
      userId: widget.user.id ?? 1,
      serviceId: widget.service.id,
      serviceTitle: widget.service.title,
      durationMinutes: widget.service.durationMinutes,
      sessionsCount: _sessionsCount,
      sessionDate: dateStr,
      sessionTimeWib: _selectedSlotWib!,
      userTimezone: widget.user.timezonePref,
      totalPrice: convertedTotal,
      currencyUsed: CurrencyService.instance.currencyCode,
      reminderMinutes: _reminderMinutes,
      qrisReference: "00020101021226680016ID.CO.ARCANOVA.WWW01189360000000000000005204581253033605802ID5916ARCANOVA SANCTUARY6010YOGYAKARTA6304",
    );

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(booking: newBooking),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyService = CurrencyService.instance;
    final singlePriceStr = currencyService.formatPrice(widget.service.priceIdr);
    final rawTotal = widget.service.priceIdr * _sessionsCount;
    final formattedTotal = currencyService.formatPrice(rawTotal);
    final dateStr = _selectedDate != null ? "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}" : "Pilih Tanggal";
    final userTz = widget.user.timezonePref ?? 'WIB';

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: AppColors.mysticViolet, blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(widget.service.iconSymbol, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                            Text("${widget.service.durationMinutes} mnt/sesi • $singlePriceStr", style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white12, height: 26),

                  // 1. Jumlah Sesi Stepper
                  const Text("1. Mau Berapa Sesi?", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("$_sessionsCount Sesi Konsultasi (${_sessionsCount * widget.service.durationMinutes} Menit)", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.brightLavender),
                              onPressed: _sessionsCount > 1 ? () => setState(() => _sessionsCount--) : null,
                            ),
                            Text("$_sessionsCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.celestialCyan),
                              onPressed: _sessionsCount < 6 ? () => setState(() => _sessionsCount++) : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Pilih Tanggal
                  const Text("2. Pilih Tanggal Konsultasi", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppColors.brightLavender, size: 20),
                              const SizedBox(width: 10),
                              Text(dateStr, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Text("Ganti Tanggal", style: TextStyle(color: AppColors.celestialCyan, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Jam Sesi Menarik (Disesuaikan Zona Waktu Pengguna)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("3. Pilih Jam Sesi ($userTz)", style: const TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (_isLoadingSlots) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Buka 21.00 - 03.00 WIB • Tampilan otomatis disesuaikan ke $userTz:", style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 10),

                  // Interactive Time Slot Cards with Multi-Session Auto Blocking
                  Builder(
                    builder: (context) {
                      final selectedCoveredSlots = _selectedSlotWib != null
                          ? TimezoneService.instance.getSlotsForSession(_selectedSlotWib!, _sessionsCount)
                          : <String>[];

                      return Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: TimezoneService.sessionSlots.map((slot) {
                          final slotWib = slot['wib']!;
                          final icon = slot['icon']!;
                          final period = slot['period']!;
                          final isBooked = _bookedSlots.contains(slotWib);

                          // Check if picking this slot as start would cause a collision or overflow
                          final prospectiveChain = TimezoneService.instance.getSlotsForSession(slotWib, _sessionsCount);
                          final hasConflict = prospectiveChain.length < _sessionsCount ||
                              prospectiveChain.any((s) => _bookedSlots.contains(s));

                          final isPartOfSelected = selectedCoveredSlots.contains(slotWib);
                          final sessionIndex = isPartOfSelected ? (selectedCoveredSlots.indexOf(slotWib) + 1) : 0;
                          final isStartSlot = _selectedSlotWib == slotWib;
                          final userTimeFormatted = TimezoneService.instance.convertFromWib(slotWib, userTz);

                          final bool isDisabled = isBooked || (hasConflict && !isPartOfSelected);

                          return InkWell(
                            onTap: isDisabled ? null : () => setState(() => _selectedSlotWib = slotWib),
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: (MediaQuery.of(context).size.width - 56) / 2, // 2 columns
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isBooked
                                    ? AppColors.voidBlack.withValues(alpha: 0.5)
                                    : isPartOfSelected
                                        ? AppColors.neonPurple.withValues(alpha: 0.45)
                                        : isDisabled
                                            ? const Color(0xFF161224).withValues(alpha: 0.6)
                                            : AppColors.cardSurfaceLight,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isBooked
                                      ? Colors.white10
                                      : isStartSlot
                                          ? AppColors.celestialCyan
                                          : isPartOfSelected
                                              ? AppColors.brightLavender
                                              : isDisabled
                                                  ? Colors.white12
                                                  : AppColors.mysticViolet.withValues(alpha: 0.3),
                                  width: isPartOfSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(icon, style: const TextStyle(fontSize: 16)),
                                      Text(
                                        isBooked
                                            ? "Penuh"
                                            : isPartOfSelected
                                                ? "Sesi $sessionIndex/$_sessionsCount"
                                                : hasConflict
                                                    ? "Bentrok"
                                                    : period,
                                        style: TextStyle(
                                          color: isBooked
                                              ? AppColors.errorCrimson
                                              : isPartOfSelected
                                                  ? AppColors.celestialCyan
                                                  : hasConflict
                                                      ? AppColors.warningOrange
                                                      : AppColors.shimmerSilver,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    userTimeFormatted,
                                    style: TextStyle(
                                      color: isBooked || (isDisabled && !isPartOfSelected)
                                          ? AppColors.textMuted
                                          : Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      decoration: isBooked ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (userTz != 'WIB')
                                    Text(
                                      "($slotWib WIB)",
                                      style: TextStyle(
                                        color: isBooked ? AppColors.textMuted : AppColors.shimmerSilver.withValues(alpha: 0.7),
                                        fontSize: 10,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // Dynamic Time Block Range Display (e.g., 21.00 - 22.30 WIB)
                  if (_selectedSlotWib != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.astralIndigo.withValues(alpha: 0.8),
                            AppColors.neonPurple.withValues(alpha: 0.4),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.celestialCyan),
                        boxShadow: [
                          BoxShadow(color: AppColors.celestialCyan.withValues(alpha: 0.15), blurRadius: 10),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.celestialCyan, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Rentang Waktu $_sessionsCount Sesi Terblokir ($userTz):", style: const TextStyle(color: AppColors.shimmerSilver, fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(
                                  TimezoneService.instance.calculateTimeRange(
                                    startWib: _selectedSlotWib!,
                                    durationMinutesPerSession: widget.service.durationMinutes,
                                    sessionsCount: _sessionsCount,
                                    targetTz: userTz,
                                  ),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),

                  // 4. Pilih Pengingat Notifikasi (5 Menit / 10 Menit)
                  const Text("4. Mau diingatkan berapa menit sebelum sesi?", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("5 Menit Sebelum")),
                          selected: _reminderMinutes == 5,
                          selectedColor: AppColors.neonPurple,
                          labelStyle: TextStyle(color: _reminderMinutes == 5 ? Colors.white : AppColors.shimmerSilver, fontSize: 12),
                          backgroundColor: AppColors.cardSurfaceLight,
                          onSelected: (_) => setState(() => _reminderMinutes = 5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text("10 Menit Sebelum")),
                          selected: _reminderMinutes == 10,
                          selectedColor: AppColors.neonPurple,
                          labelStyle: TextStyle(color: _reminderMinutes == 10 ? Colors.white : AppColors.shimmerSilver, fontSize: 12),
                          backgroundColor: AppColors.cardSurfaceLight,
                          onSelected: (_) => setState(() => _reminderMinutes = 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Breakdown Detail Biaya (175.000 x 2 = 350.000)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.voidBlack,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Rincian Biaya:", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text(
                          "$singlePriceStr × $_sessionsCount sesi = $formattedTotal",
                          style: const TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Tagihan:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(
                              formattedTotal,
                              style: const TextStyle(color: AppColors.celestialCyan, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _proceedToPayment,
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Lanjut ke Pembayaran QRIS"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonPurple,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
