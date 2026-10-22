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
  CurrencyType _selectedCurrency = CurrencyService.instance.currentCurrency;
  int? _expandedServiceId = 1; // Default first service expanded

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

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
          // Currency Switcher Dropdown (IDR, USD, GBP)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.cardSurfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.shimmerSilver.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<CurrencyType>(
                value: _selectedCurrency,
                dropdownColor: AppColors.cardSurface,
                icon: const Icon(Icons.currency_exchange, color: AppColors.shimmerSilver, size: 16),
                items: const [
                  DropdownMenuItem(value: CurrencyType.idr, child: Text("IDR (Rp)", style: TextStyle(fontSize: 12, color: Colors.white))),
                  DropdownMenuItem(value: CurrencyType.usd, child: Text("USD (\$)", style: TextStyle(fontSize: 12, color: Colors.white))),
                  DropdownMenuItem(value: CurrencyType.gbp, child: Text("GBP (£)", style: TextStyle(fontSize: 12, color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCurrency = val;
                      CurrencyService.instance.setCurrency(val);
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Attractive Mystic Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.astralIndigo, AppColors.cardSurface],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.mysticViolet.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(color: AppColors.mysticViolet.withValues(alpha: 0.2), blurRadius: 16),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.mysticButton,
                    ),
                    child: const Center(child: Text("🔮", style: TextStyle(fontSize: 26))),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Pilih Sesi Pembacaan Jiwa",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user != null
                              ? "Hai ${user.username}, sesi konsultasi dipandu Reader berpengalaman."
                              : "Mode Tamu • Pilih layanan untuk pesan sesi pribadimu!",
                          style: TextStyle(
                            color: user != null ? AppColors.celestialCyan : AppColors.shimmerSilver,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Live Reader Consultation Banner (WhatsApp Style)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReaderChatScreen()),
                );
              },
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF111827)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.celestialCyan.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(color: AppColors.celestialCyan.withValues(alpha: 0.1), blurRadius: 10),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurfaceLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.celestialCyan),
                      ),
                      child: const Text("🧙‍♂️", style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Konsultasi Live Reader (WA Style)",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Online 09:00 - 18:00 WIB • Lihat jadwal & roomchat",
                            style: TextStyle(color: AppColors.shimmerSilver, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.celestialCyan),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

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
    );
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
          content: Text("Mohon pilih tanggal sesi terlebih dahulu ya!"),
        ),
      );
      return;
    }

    if (_selectedSlotWib == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.errorCrimson,
          content: Text("Mohon pilih jam sesi yang kamu inginkan!"),
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
                        Text("$_sessionsCount Sesi Konsultasi", style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.brightLavender),
                              onPressed: _sessionsCount > 1 ? () => setState(() => _sessionsCount--) : null,
                            ),
                            Text("$_sessionsCount", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: AppColors.celestialCyan),
                              onPressed: _sessionsCount < 5 ? () => setState(() => _sessionsCount++) : null,
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

                  // 3. Jam Sesi Menarik (Card Pills - NO WIT!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("3. Pilih Jam Sesi (Tersedia)", style: TextStyle(color: AppColors.arcaneSilver, fontSize: 14, fontWeight: FontWeight.bold)),
                      if (_isLoadingSlots) const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text("Format jam: WIB • London (GMT). Mudah dibaca tanpa WIT:", style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(height: 10),

                  // Interactive Time Slot Cards
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: TimezoneService.sessionSlots.map((slot) {
                      final slotWib = slot['wib']!;
                      final icon = slot['icon']!;
                      final period = slot['period']!;
                      final isBooked = _bookedSlots.contains(slotWib);
                      final isSelected = _selectedSlotWib == slotWib;
                      final londonTime = TimezoneService.instance.convertFromWib(slotWib, 'London (GMT)');

                      return InkWell(
                        onTap: isBooked ? null : () => setState(() => _selectedSlotWib = slotWib),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: (MediaQuery.of(context).size.width - 56) / 2, // 2 columns
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isBooked
                                ? AppColors.voidBlack.withValues(alpha: 0.5)
                                : isSelected
                                    ? AppColors.neonPurple.withValues(alpha: 0.35)
                                    : AppColors.cardSurfaceLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.white10
                                  : isSelected
                                      ? AppColors.celestialCyan
                                      : AppColors.mysticViolet.withValues(alpha: 0.3),
                              width: isSelected ? 2 : 1,
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
                                    isBooked ? "Penuh" : period,
                                    style: TextStyle(
                                      color: isBooked ? AppColors.errorCrimson : AppColors.shimmerSilver,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "$slotWib WIB",
                                style: TextStyle(
                                  color: isBooked ? AppColors.textMuted : Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  decoration: isBooked ? TextDecoration.lineThrough : null,
                                ),
                              ),
                              Text(
                                "🇬🇧 $londonTime",
                                style: TextStyle(
                                  color: isBooked ? AppColors.textMuted : AppColors.brightLavender,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
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
