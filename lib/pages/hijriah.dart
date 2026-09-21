import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HijriahPage extends StatefulWidget {
  const HijriahPage({super.key});

  @override
  State<HijriahPage> createState() => _HijriahPageState();
}

class _HijriahPageState extends State<HijriahPage> {
  DateTime? tanggalLahir;

  String hasilUmur = '';
  String hasilHijriah = '';

  int totalHari = 0;
  int totalJam = 0;
  int totalMenit = 0;
  int totalDetik = 0;

  final List<String> bulanMasehi = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  final List<String> bulanHijriah = [
    'Muharram',
    'Safar',
    'Rabiul Awal',
    'Rabiul Akhir',
    'Jumadil Awal',
    'Jumadil Akhir',
    'Rajab',
    'Syaban',
    'Ramadan',
    'Syawal',
    'Zulkaidah',
    'Zulhijah',
  ];

  String formatAngka(int angka) {
    return angka
        .toString()
        .replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        );
  }

  //pilih tanggal
  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: tanggalLahir ?? DateTime(2000),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              surface: Color(0xFF1E1B4B),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        tanggalLahir = picked;

        hasilUmur = '';
        hasilHijriah = '';

        totalHari = 0;
        totalJam = 0;
        totalMenit = 0;
        totalDetik = 0;
      });
    }
  }

  //tanggal Masehi
  String formatTanggal(DateTime tanggal) {
    return '${tanggal.day} '
        '${bulanMasehi[tanggal.month - 1]} '
        '${tanggal.year}';
  }

  //Rumus konversi Hijriah
  Map<String, int> masehiKeHijriah(DateTime date) {
    final int hari = date.day;
    final int bulan = date.month;
    final int tahun = date.year;

    final int a = (14 - bulan) ~/ 12;
    final int y = tahun + 4800 - a;
    final int m = bulan + (12 * a) - 3;
    final int jd =
        hari +
        ((153 * m + 2) ~/ 5) +(365 * y) + (y ~/ 4) - (y ~/ 100) + (y ~/ 400) -32045;

    int l = jd - 1948440 + 10632;

    final int n = (l - 1) ~/ 10631;

    l = l - (10631 * n) + 354;

    final int j =
        (((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719)) 
        +
        ((l ~/ 5670) * ((43 * l) ~/ 15238));

    l =
        l -
        (((30 - j) ~/ 15) * ((17719 * j) ~/ 50)) 
        -
        ((j ~/ 16) * ((15238 * j) ~/ 43)) 
        + 29;

    final int bulanHijri =
        (24 * l) ~/ 709;

    final int hariHijri =
        l - ((709 * bulanHijri) ~/ 24);

    final int tahunHijri =
        (30 * n) + j - 30;

    return {
      'hari': hariHijri,
      'bulan': bulanHijri,
      'tahun': tahunHijri,
    };
  }

  //hitung umur
  void hitungUmur() {
    if (tanggalLahir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih tanggal lahir terlebih dahulu.',
          ),
        ),
      );

      return;
    }

    final sekarang = DateTime.now();

    if (tanggalLahir!.isAfter(sekarang)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal lahir tidak boleh lebih besar dari hari ini.',
          ),
        ),
      );

      return;
    }

    //detail umur
    int tahun =
        sekarang.year - tanggalLahir!.year;

    int bulan =
        sekarang.month - tanggalLahir!.month;

    int hari =
        sekarang.day - tanggalLahir!.day;

    if (hari < 0) {
      bulan--;

      final int hariBulanSebelumnya = DateTime(
        sekarang.year,
        sekarang.month,
        0,
      ).day;

      hari += hariBulanSebelumnya;
    }

    if (bulan < 0) {
      tahun--;
      bulan += 12;
    }

    final durasi =
        sekarang.difference(tanggalLahir!);

    totalHari = durasi.inDays;

    totalJam = durasi.inHours;

    totalMenit = durasi.inMinutes;

    totalDetik = durasi.inSeconds;

    //konversi hijriah
    final hijri =
        masehiKeHijriah(tanggalLahir!);

    final int nomorBulanHijri =
        hijri['bulan']!;

    final String namaBulanHijri =
        bulanHijriah[nomorBulanHijri - 1];

    setState(() {
      hasilUmur =
          '$tahun tahun $bulan bulan $hari hari';

      hasilHijriah =
          '${hijri['hari']} '
          '$namaBulanHijri '
          '${hijri['tahun']} H';
    });
  }

  //card detail umur
  Widget infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: const Color(0xFF21145E),

        borderRadius:
            BorderRadius.circular(16),

        border: Border.all(
          color: const Color(0xFF7C3AED)
              .withOpacity(0.35),
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: const Color(0xFF4C1D95),

              borderRadius:
                  BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: const Color(0xFFD8B4FE),
              size: 21,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hijriah & Umur',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        backgroundColor:
            const Color(0xFF1E1B4B),

        foregroundColor: Colors.white,

        elevation: 0,
      ),

      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Color(0xFF211B5B),
              Color(0xFF171342),
              Color(0xFF08071F),
            ],
          ),
        ),

        child: ListView(
          padding: const EdgeInsets.all(20),

          children: [
            Container(
              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,

                  colors: [
                    Color(0xFF312E81),
                    Color(0xFF4C1D95),
                  ],
                ),

                borderRadius:
                    BorderRadius.circular(22),

                boxShadow: [
                  BoxShadow(
                    color:
                        const Color(0xFF7C3AED)
                            .withOpacity(0.25),

                    blurRadius: 20,

                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                children: [
                  // ICON
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFFE9D5FF),
                    size: 42,
                  ),

                  const SizedBox(height: 10),

                  // JUDUL
                  Text(
                    'Temukan Usia &\nTanggal Hijriah',

                    textAlign:
                        TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 7),

                  // DESKRIPSI
                  Text(
                    'Masukkan tanggal lahirmu untuk '
                    'melihat usia dan kalender Hijriah.',

                    textAlign:
                        TextAlign.center,

                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //input tanggal
            Container(
              padding:
                  const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color(0xFF071B35),

                borderRadius:
                    BorderRadius.circular(20),

                border: Border.all(
                  color:
                      const Color(0xFF6D28D9)
                          .withOpacity(0.4),
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(
                      0.2,
                    ),

                    blurRadius: 12,

                    offset:
                        const Offset(0, 5),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  // LABEL
                  Text(
                    'Tanggal Lahir',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // DATE PICKER
                  InkWell(
                    onTap: pilihTanggal,

                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),

                    child: Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 15,
                        vertical: 15,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF0F2948,
                        ),

                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),

                      child: Row(
                        children: [
                          const Icon(
                            Icons
                                .calendar_month,
                            color:
                                Color(0xFFD8B4FE),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child: Text(
                              tanggalLahir ==
                                      null
                                  ? 'Pilih tanggal lahir'
                                  : formatTanggal(
                                      tanggalLahir!,
                                    ),

                              style:
                                  GoogleFonts
                                      .poppins(
                                color:
                                    tanggalLahir ==
                                            null
                                        ? Colors
                                            .white38
                                        : Colors
                                            .white,

                                fontSize: 15,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons
                                .keyboard_arrow_down,
                            color:
                                Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,

                    child:
                        FilledButton.icon(
                      onPressed:
                          hitungUmur,

                      icon: const Icon(
                        Icons.auto_awesome,
                      ),

                      label: Text(
                        'HITUNG USIA',
                        style:
                            GoogleFonts.poppins(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),

                      style:
                          FilledButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF7C3AED,
                        ),

                        foregroundColor:
                            Colors.white,

                        padding:
                            const EdgeInsets
                                .symmetric(
                          vertical: 15,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //hasil
            if (hasilUmur.isNotEmpty) ...[
              const SizedBox(height: 24),

              Text(
                'Hasil Perhitungan',

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient:
                      const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,

                    colors: [
                      Color(0xFF4C1D95),
                      Color(0xFF312E81),
                    ],
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),

                  boxShadow: [
                    BoxShadow(
                      color:
                          const Color(
                        0xFF7C3AED,
                      ).withOpacity(0.2),

                      blurRadius: 15,

                      offset:
                          const Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.cake_outlined,
                      color:
                          Color(0xFFE9D5FF),
                      size: 35,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Usia Saat Ini',

                      style:
                          GoogleFonts.poppins(
                        color:
                            Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      hasilUmur,

                      textAlign:
                          TextAlign.center,

                      style:
                          GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              //hijriah
              Container(
                padding:
                    const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFF071B35),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),

                  border: Border.all(
                    color:
                        const Color(
                      0xFFD8B4FE,
                    ).withOpacity(0.25),
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,

                      decoration:
                          BoxDecoration(
                        color:
                            const Color(
                          0xFF4C1D95,
                        ),

                        borderRadius:
                            BorderRadius
                                .circular(
                          14,
                        ),
                      ),

                      child: const Icon(
                        Icons.mosque_outlined,
                        color:
                            Color(0xFFE9D5FF),
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,

                        children: [
                          Text(
                            'Tanggal Lahir Hijriah',

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white54,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Text(
                            hasilHijriah,

                            style:
                                GoogleFonts
                                    .poppins(
                              color:
                                  Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              //detail umur
              Text(
                'Detail Usia',

                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      icon:
                          Icons.calendar_today,

                      title: 'Total Hari',

                      value:
                          '${formatAngka(totalHari)} hari',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: infoCard(
                      icon: Icons.schedule,

                      title: 'Total Jam',

                      value:
                          '${formatAngka(totalJam)} jam',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ROW 2
              Row(
                children: [
                  Expanded(
                    child: infoCard(
                      icon:
                          Icons.access_time,

                      title: 'Total Menit',

                      value:
                          '${formatAngka(totalMenit)} menit',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: infoCard(
                      icon:
                          Icons.timer_outlined,

                      title: 'Total Detik',

                      value:
                          '${formatAngka(totalDetik)} detik',
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}