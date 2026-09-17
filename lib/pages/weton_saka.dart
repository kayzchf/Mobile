import 'package:flutter/material.dart';

class WetonSakaPage extends StatefulWidget {
  const WetonSakaPage({super.key});

  @override
  State<WetonSakaPage> createState() =>
      _WetonSakaPageState();
}

class _WetonSakaPageState
    extends State<WetonSakaPage> {
  DateTime? tanggal;
  String hasil = '';

  final List<String> pasaran = [
    'Wage',
    'Kliwon',
    'Legi',
    'Pahing',
    'Pon',
  ];

  final List<String> hari = [
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
  ];

  Future<void> pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      initialDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        tanggal = picked;
      });
    }
  }

  void hitung() {
    if (tanggal == null) return;

    final tanggalAcuan = DateTime(1970, 1, 1);

    final selisihHari = tanggal!.difference(tanggalAcuan).inDays;

    final indexHari = selisihHari%7;
    final indexPasaran = selisihHari%5;

    final namaHari = hari[indexHari];
    final namaPasaran = pasaran[indexPasaran];

    // Tahun Saka
    final tahunSaka = tanggal!.year - 78;

    setState(() {
      hasil =
          'Hasil Perhitungan\n\n'
          'Hari          : $namaHari\n'
          'Pasaran       : $namaPasaran\n'
          'Weton         : $namaHari $namaPasaran\n'
          'Kalender Saka : Saka $tahunSaka';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weton & Saka Bali',
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
                      'Pilih Tanggal',
                    ),
                    subtitle: Text(
                      tanggal == null
                          ? 'Belum dipilih'
                          : '${tanggal!.day}/'
                              '${tanggal!.month}/'
                              '${tanggal!.year}',
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
                      onPressed: hitung,
                      child: const Text(
                        'CEK WETON & SAKA',
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