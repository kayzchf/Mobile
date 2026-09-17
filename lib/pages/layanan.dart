import 'package:flutter/material.dart';

import '../app_data.dart';

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage> {
  // =========================
  // FORMAT RUPIAH
  // =========================

  String formatRupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}';
  }

  // =========================
  // TAMBAH LAYANAN
  // =========================

  void tambahLayanan() {
    final namaController = TextEditingController();
    final durasiController = TextEditingController();
    final hargaController = TextEditingController();
    final deskripsiController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Layanan'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Layanan',
                  ),
                ),

                TextField(
                  controller: durasiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi (menit)',
                  ),
                ),

                TextField(
                  controller: hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                  ),
                ),

                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),

            FilledButton(
              onPressed: () {
                if (namaController.text.isEmpty ||
                    durasiController.text.isEmpty ||
                    hargaController.text.isEmpty) {
                  return;
                }

                setState(() {
                  AppData.services.add(
                    TarotService(
                      nama: namaController.text,
                      durasi: int.parse(durasiController.text),
                      harga: int.parse(hargaController.text),
                      deskripsi: deskripsiController.text,
                    ),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // EDIT LAYANAN
  // =========================

  void editLayanan(int index) {
    final layanan = AppData.services[index];

    final namaController = TextEditingController(
      text: layanan.nama,
    );

    final durasiController = TextEditingController(
      text: layanan.durasi.toString(),
    );

    final hargaController = TextEditingController(
      text: layanan.harga.toString(),
    );

    final deskripsiController = TextEditingController(
      text: layanan.deskripsi,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Layanan'),

          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: namaController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Layanan',
                  ),
                ),

                TextField(
                  controller: durasiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Durasi (menit)',
                  ),
                ),

                TextField(
                  controller: hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Harga',
                  ),
                ),

                TextField(
                  controller: deskripsiController,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                  ),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),

            FilledButton(
              onPressed: () {
                if (namaController.text.isEmpty ||
                    durasiController.text.isEmpty ||
                    hargaController.text.isEmpty) {
                  return;
                }

                setState(() {
                  layanan.nama = namaController.text;
                  layanan.durasi =
                      int.parse(durasiController.text);
                  layanan.harga =
                      int.parse(hargaController.text);
                  layanan.deskripsi =
                      deskripsiController.text;
                });

                Navigator.pop(context);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // HAPUS LAYANAN
  // =========================

  void hapusLayanan(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Layanan'),

          content: Text(
            'Yakin ingin menghapus "${AppData.services[index].nama}"?',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),

            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                setState(() {
                  AppData.services.removeAt(index);
                });

                Navigator.pop(context);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // =========================
  // BOOKING
  // =========================

  void pesanLayanan(TarotService layanan) {
    int jumlahSesi = 1;

    final voucherController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final subtotal =
                layanan.harga * jumlahSesi;

            final voucher =
                voucherController.text.trim().toUpperCase();

            int diskon = 0;

            if (voucher == 'ARCANOVA10' ||
                voucher == 'ARC10') {
              diskon = (subtotal * 0.10).round();
            } else if (voucher == 'ARCANOVA20') {
              diskon = (subtotal * 0.20).round();
            }

            final total = subtotal - diskon;

            return AlertDialog(
              title: Text(
                'Pesan ${layanan.nama}',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${layanan.durasi} menit • '
                      '${formatRupiah(layanan.harga)} / sesi',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Jumlah Sesi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (jumlahSesi > 1) {
                              setDialogState(() {
                                jumlahSesi--;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                        ),

                        Text(
                          '$jumlahSesi',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            if (jumlahSesi < 10) {
                              setDialogState(() {
                                jumlahSesi++;
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.add_circle_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: voucherController,
                      onChanged: (value) {
                        setDialogState(() {});
                      },
                      decoration: const InputDecoration(
                        labelText: 'Kode Voucher',
                        hintText: 'Opsional',
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1065),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah Sesi: $jumlahSesi',
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Subtotal: ${formatRupiah(subtotal)}',
                          ),

                          if (diskon > 0) ...[
                            const SizedBox(height: 5),
                            Text(
                              'Diskon: -${formatRupiah(diskon)}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],

                          const Divider(),

                          Text(
                            'Total: ${formatRupiah(total)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Batal'),
                ),

                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);

                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text(
                            '🎉 Pesanan Berhasil!',
                          ),

                          content: Text(
                            'Pemesanan layanan '
                            '${layanan.nama} berhasil '
                            'dikonfirmasi.\n\n'
                            'Jumlah sesi: $jumlahSesi\n'
                            'Total: ${formatRupiah(total)}',
                          ),

                          actions: [
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Tutup'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Pesan Sekarang'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // =========================
  // BUILD
  // =========================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layanan Tarot'),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: tambahLayanan,
        child: const Icon(Icons.add),
      ),

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E1065),
              Color(0xFF0F172A),
              Color(0xFF030712),
            ],
          ),
        ),

        child: AppData.services.isEmpty
            ? const Center(
                child: Text(
                  'Belum ada layanan tarot.',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: AppData.services.length,
                itemBuilder: (context, index) {
                  final layanan =
                      AppData.services[index];

                  return Card(
                    color: const Color(0xFF0F172A),
                    margin: const EdgeInsets.only(
                      bottom: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(18),

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  layanan.nama,
                                  style: const TextStyle(
                                    color:
                                        Color(0xFFE9D5FF),
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),

                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    editLayanan(index);
                                  }

                                  if (value == 'hapus') {
                                    hapusLayanan(index);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'hapus',
                                    child: Text('Hapus'),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Color(0xFFA78BFA),
                              ),

                              const SizedBox(width: 5),

                              Text(
                                '${layanan.durasi} Menit',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            layanan.deskripsi,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 15),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              Text(
                                formatRupiah(
                                  layanan.harga,
                                ),
                                style: const TextStyle(
                                  color:
                                      Color(0xFFD8B4FE),
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              FilledButton(
                                onPressed: () {
                                  pesanLayanan(layanan);
                                },
                                child: const Text(
                                  'Pesan',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}