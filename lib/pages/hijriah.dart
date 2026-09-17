import 'package:flutter/material.dart';

class HijriahPage extends StatefulWidget {
  const HijriahPage({super.key});

  @override
  State<HijriahPage> createState() => _HijriahPageState();
}

class _HijriahPageState extends State<HijriahPage> {
  DateTime? tanggalLahir;
  String hasil = '';

  Future<void> pilihTanggal() async {
    final tanggal = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime(2002),
    );

    if (tanggal != null) {
      setState(() {
        tanggalLahir = tanggal;
      });
    }
  }

  void hitungUmur() {
    if (tanggalLahir == null) return;

    final sekarang = DateTime.now();
    final selisih = sekarang.difference(tanggalLahir!);

    final totalDetik = selisih.inSeconds;
    final totalMenit = selisih.inMinutes;
    final totalJam = selisih.inHours;
    final totalHari = selisih.inDays;

    final tahun = (totalHari / 365.25).floor();
    final bulan =
        ((totalHari - (tahun * 365.25)) / 30.44).floor();

    final hari =
        totalHari - (tahun * 365.25).floor();

    setState(() {
      hasil =
          'Rincian Umur\n\n'
          'Tahun: $tahun tahun\n'
          'Bulan: $bulan bulan\n'
          'Total Hari: $hari hari\n'
          'Total Jam: $totalJam jam\n'
          'Total Menit: $totalMenit menit\n'
          'Total Detik: $totalDetik detik';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hijriah & Umur',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: const Color(0xFF0F172A),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  ListTile(
                    title: const Text(
                      'Tanggal Lahir',
                    ),
                    subtitle: Text(
                      tanggalLahir == null
                          ? 'Belum dipilih'
                          : '${tanggalLahir!.day}/'
                              '${tanggalLahir!.month}/'
                              '${tanggalLahir!.year}',
                    ),
                    trailing: const Icon(
                      Icons.calendar_month,
                    ),
                    onTap: pilihTanggal,
                  ),

                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: hitungUmur,
                      child: const Text(
                        'HITUNG UMUR',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (hasil.isNotEmpty) ...[
            const SizedBox(height: 20),

            Card(
              color: const Color(0xFF2E1065),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Text(
                  hasil,
                  style: const TextStyle(
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}