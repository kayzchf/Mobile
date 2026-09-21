import 'package:flutter/material.dart';

class WetonSakaPage extends StatefulWidget {
  const WetonSakaPage({super.key});

  @override
  State<WetonSakaPage> createState() => _WetonSakaPageState();
}

class _WetonSakaPageState extends State<WetonSakaPage> {
  DateTime? tanggal;

  String hasilHari = '-';
  String hasilPasaran = '-';
  String hasilWeton = '-';
  String hasilSaka = '-';

  final List<String> hari = [
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
  ];

  final List<String> pasaran = [
    'Wage',
    'Kliwon',
    'Legi',
    'Pahing',
    'Pon',
  ];

  Future<void> pilihTanggal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: tanggal ?? DateTime(2006, 2, 17),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF211B4D),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        tanggal = picked;
      });
    }
  }

  void hitungWeton() {
    if (tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan pilih tanggal terlebih dahulu.',
          ),
        ),
      );

      return;
    }

    //tanggal acuan
    final DateTime tanggalAcuan = DateTime(1970, 1, 1);

    // Hitung berapa hari jaraknya dari tanggal acuan
    final int selisihHari =
        tanggal!.difference(tanggalAcuan).inDays;

    //hitung hari
    int indexHari = selisihHari % 7;

    // Untuk tanggal sebelum 1 Januari 1970
    if (indexHari < 0) {
      indexHari += 7;
    }

    final String namaHari = hari[indexHari];

    //hitung pasaran
    int indexPasaran = selisihHari % 5;

    // Untuk tanggal sebelum 1 Januari 1970
    if (indexPasaran < 0) {
      indexPasaran += 5;
    }

    final String namaPasaran =
        pasaran[indexPasaran];

    final String weton =
        '$namaHari $namaPasaran';

    final int tahunSaka =
        tanggal!.year - 78;

    //simpan ke database
    setState(() {
      hasilHari = namaHari;
      hasilPasaran = namaPasaran;
      hasilWeton = weton;
      hasilSaka = 'Saka $tahunSaka';
    });
  }

  String formatTanggal(DateTime date) {
    const List<String> namaBulan = [
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

    return '${date.day} '
        '${namaBulan[date.month - 1]} '
        '${date.year}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF15133F),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: const Text(
          'Weton & Saka',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          24,
          10,
          24,
          30,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: const Color(0xFF00253D),

                borderRadius:
                    BorderRadius.circular(28),

                border: Border.all(
                  color: const Color(0xFF4437A8),
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.25),

                    blurRadius: 15,

                    offset:
                        const Offset(0, 8),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PILIH TANGGAL

                  InkWell(
                    onTap: pilihTanggal,

                    borderRadius:
                        BorderRadius.circular(18),

                    child: Container(
                      width: double.infinity,

                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 18,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF063653),

                        borderRadius:
                            BorderRadius.circular(18),
                      ),

                      child: Row(
                        children: [

                          const Icon(
                            Icons.calendar_month,
                            color:
                                Color(0xFFD8B4FE),
                            size: 25,
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              tanggal == null
                                  ? 'Pilih tanggal'
                                  : formatTanggal(
                                      tanggal!,
                                    ),

                              style:
                                  const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            color: Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // BUTTON CEK

                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton(
                      onPressed: hitungWeton,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF8338EC),

                        foregroundColor:
                            Colors.white,

                        elevation: 0,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            30,
                          ),
                        ),
                      ),

                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Text(
                            '✦',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(width: 10),

                          Text(
                            'CEK WETON & SAKA',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Hasil Perhitungan',

              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            //hasil weton
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.symmetric(
                vertical: 25,
                horizontal: 20,
              ),

              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    Color(0xFF5121A8),
                    Color(0xFF38318A),
                  ],

                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),

                borderRadius:
                    BorderRadius.circular(26),
              ),

              child: Column(
                children: [

                  const Text(
                    '✦',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Weton Kamu',

                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    hasilWeton,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            //hari & pasaran
            Row(
              children: [

                Expanded(
                  child: _infoCard(
                    icon:
                        Icons.calendar_today_rounded,

                    title: 'Hari',

                    value: hasilHari,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _infoCard(
                    icon:
                        Icons.auto_awesome,

                    title: 'Pasaran',

                    value: hasilPasaran,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //saka
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(22),

              decoration: BoxDecoration(
                color:
                    const Color(0xFF24195E),

                borderRadius:
                    BorderRadius.circular(22),

                border: Border.all(
                  color:
                      const Color(0xFF5438A8),
                ),
              ),

              child: Row(
                children: [

                  Container(
                    width: 52,
                    height: 52,

                    decoration: BoxDecoration(
                      color:
                          const Color(0xFF5424A8),

                      borderRadius:
                          BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons
                          .wb_sunny_outlined,

                      color:
                          Color(0xFFE9D5FF),

                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 16),

                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          'Kalender Saka',

                          style: TextStyle(
                            color:
                                Colors.white60,
                            fontSize: 14,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Tahun Saka',

                          style: TextStyle(
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

                  Text(
                    hasilSaka,

                    style: const TextStyle(
                      color:
                          Color(0xFFD8B4FE),

                      fontSize: 18,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            //keterangan acuan
            Container(
              width: double.infinity,

              padding:
                  const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color:
                    const Color(0xFF1D194A),

                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: const Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Icon(
                    Icons.info_outline_rounded,

                    color:
                        Color(0xFFD8B4FE),

                    size: 21,
                  ),

                  SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      'Acuan perhitungan: '
                      '1 Januari 1970 = Kamis Wage. '
                      'Urutan hari dimulai dari Kamis '
                      'dan urutan pasaran dimulai dari Wage.',

                      style: TextStyle(
                        color:
                            Colors.white60,

                        fontSize: 13,

                        height: 1.5,
                      ),
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


  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color:
            const Color(0xFF24195E),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              const Color(0xFF5438A8),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color:
                  const Color(0xFF5424A8),

              borderRadius:
                  BorderRadius.circular(13),
            ),

            child: Icon(
              icon,

              color:
                  const Color(0xFFE9D5FF),

              size: 21,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            title,

            style: const TextStyle(
              color:
                  Colors.white60,

              fontSize: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,

            style: const TextStyle(
              color:
                  Colors.white,

              fontSize: 17,

              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}