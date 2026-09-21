import 'package:flutter/material.dart';

import '../app_data.dart';
import '../arcanova_db.dart';

class LayananPage extends StatefulWidget {
  const LayananPage({super.key});

  @override
  State<LayananPage> createState() => _LayananPageState();
}

class _LayananPageState extends State<LayananPage> {

  List<Map<String, dynamic>> services = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  String formatRupiah(int angka) {
    return 'Rp ${angka.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
        )}';
  }

  //baca dari database
  Future<void> loadServices() async {
    try {
      final data = await ArcanovaDB.instance.getServices();

      if (!mounted) return;

      setState(() {
        services = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memuat layanan: $e',
          ),
        ),
      );
    }
  }

  //Pesan layanan
  void pesanLayanan(Map<String, dynamic> layanan) {
    final userId = AppData.currentUserId;

    // Pastikan user sudah login
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Silakan login terlebih dahulu.',
          ),
        ),
      );
      return;
    }

    int jumlahSesi = 1;

    final voucherController = TextEditingController();

    int discountPercent = 0;
    int discountAmount = 0;

    String? voucherCodeUsed;
    bool isCheckingVoucher = false;

    final int harga = (layanan['price'] as num).toInt();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final int subtotal = harga * jumlahSesi;

            discountAmount =
                (subtotal * discountPercent / 100).round();

            final int total = subtotal - discountAmount;

            // =========================
            // CEK VOUCHER
            // =========================

            Future<void> cekVoucher() async {
              final code =
                  voucherController.text.trim().toLowerCase();

              if (code.isEmpty) {
                setDialogState(() {
                  discountPercent = 0;
                  discountAmount = 0;
                  voucherCodeUsed = null;
                });
                return;
              }

              setDialogState(() {
                isCheckingVoucher = true;
              });

              try {
                final voucher =
                    await ArcanovaDB.instance.getVoucherByCode(code);

                if (voucher == null) {
                  setDialogState(() {
                    discountPercent = 0;
                    discountAmount = 0;
                    voucherCodeUsed = null;
                    isCheckingVoucher = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Kode voucher tidak ditemukan.',
                      ),
                    ),
                  );

                  return;
                }

                final int percent =
                    (voucher['discount_percent'] as num).toInt();

                setDialogState(() {
                  discountPercent = percent;
                  discountAmount =
                      (subtotal * percent / 100).round();
                  voucherCodeUsed = code;
                  isCheckingVoucher = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Voucher berhasil digunakan: $percent%',
                    ),
                  ),
                );
              } catch (e) {
                setDialogState(() {
                  isCheckingVoucher = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Gagal mengecek voucher: $e',
                    ),
                  ),
                );
              }
            }

            return AlertDialog(
              title: Text(
                'Pesan Layanan',
                style: Theme.of(context)
                    .dialogTheme
                    .titleTextStyle,
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      layanan['name'] ?? 'Layanan Tarot',
                      style: const TextStyle(
                        color: Color(0xFFE9D5FF),
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
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
                          '${layanan['duration_minutes']} menit',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${formatRupiah(harga)} / sesi',
                      style: const TextStyle(
                        color: Color(0xFFD8B4FE),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'Jumlah Sesi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Row(
                      children: [
                        IconButton(
                          onPressed: jumlahSesi > 1
                              ? () {
                                  setDialogState(() {
                                    jumlahSesi--;
                                  });
                                }
                              : null,
                          icon: const Icon(
                            Icons.remove_circle_outline,
                          ),
                          color: const Color(0xFFD8B4FE),
                        ),

                        Container(
                          width: 45,
                          alignment: Alignment.center,
                          child: Text(
                            '$jumlahSesi',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: jumlahSesi < 10
                              ? () {
                                  setDialogState(() {
                                    jumlahSesi++;
                                  });
                                }
                              : null,
                          icon: const Icon(
                            Icons.add_circle_outline,
                          ),
                          color: const Color(0xFFD8B4FE),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: voucherController,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        setDialogState(() {
                          voucherCodeUsed = null;
                          discountPercent = 0;
                          discountAmount = 0;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Kode Voucher',
                        hintText: 'Contoh: arcanova15',
                        prefixIcon: Icon(
                          Icons.discount_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            isCheckingVoucher ? null : cekVoucher,
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              const Color(0xFFD8B4FE),
                          side: const BorderSide(
                            color: Color(0xFFA78BFA),
                          ),
                        ),
                        child: isCheckingVoucher
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFFD8B4FE),
                                ),
                              )
                            : const Text(
                                'Gunakan Voucher',
                              ),
                      ),
                    ),

                    if (voucherCodeUsed != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        'Voucher "$voucherCodeUsed" '
                        'berhasil digunakan ($discountPercent%).',
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1065),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jumlah Sesi: $jumlahSesi',
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 5),

                          Text(
                            'Subtotal: ${formatRupiah(subtotal)}',
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),

                          if (discountAmount > 0) ...[
                            const SizedBox(height: 5),

                            Text(
                              'Diskon: -${formatRupiah(discountAmount)}',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                              ),
                            ),
                          ],

                          const Divider(
                            color: Colors.white24,
                          ),

                          Text(
                            'Total: ${formatRupiah(total)}',
                            style: const TextStyle(
                              color: Color(0xFFE9D5FF),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
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
                  child: const Text(
                    'Batal',
                  ),
                ),

                FilledButton(
                  onPressed: () async {
                    final currentUserId =
                        AppData.currentUserId;

                    if (currentUserId == null) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Sesi login sudah berakhir. '
                            'Silakan login kembali.',
                          ),
                        ),
                      );

                      return;
                    }

                    String? finalVoucherCode;

                    if (voucherController.text
                        .trim()
                        .isNotEmpty) {
                      final code = voucherController.text
                          .trim()
                          .toLowerCase();

                      final voucher =
                          await ArcanovaDB.instance
                              .getVoucherByCode(code);

                      if (voucher == null) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Voucher tidak valid.',
                            ),
                          ),
                        );

                        return;
                      }

                      final int percent =
                          (voucher['discount_percent']
                                  as num)
                              .toInt();

                      discountAmount =
                          (subtotal * percent / 100).round();

                      finalVoucherCode = code;
                    }

                    final int finalTotal =
                        subtotal - discountAmount;

                    final int serviceId =
                        (layanan['id'] as num).toInt();

                    //simpan ke database
                    try {
                      await ArcanovaDB.instance.addBooking(
                        userId: currentUserId,
                        serviceId: serviceId,
                        voucherCode: finalVoucherCode,
                        quantity: jumlahSesi,
                        subtotal: subtotal,
                        discountAmount: discountAmount,
                        totalPrice: finalTotal,
                      );

                      if (!context.mounted) return;

                      Navigator.pop(dialogContext);

                      showDialog(
                        context: context,
                        builder: (successContext) {
                          return AlertDialog(
                            title: const Text(
                              '🎉 Pesanan Berhasil!',
                            ),

                            content: Text(
                              'Pemesanan layanan '
                              '${layanan['name']} berhasil '
                              'disimpan.\n\n'
                              'Jumlah sesi: $jumlahSesi\n'
                              'Subtotal: '
                              '${formatRupiah(subtotal)}\n'
                              '${discountAmount > 0 ? 'Diskon: -${formatRupiah(discountAmount)}\n' : ''}'
                              'Total: '
                              '${formatRupiah(finalTotal)}',
                            ),

                            actions: [
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(
                                    successContext,
                                  );
                                },
                                child: const Text(
                                  'Tutup',
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            'Gagal menyimpan pesanan: $e',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'Pesan Sekarang',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Widget serviceCard(Map<String, dynamic> layanan) {
    final int harga =
        (layanan['price'] as num).toInt();

    final int durasi =
        (layanan['duration_minutes'] as num).toInt();

    return Card(
      color: const Color(0xFF0F172A),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              layanan['name'] ?? 'Layanan Tarot',
              style: const TextStyle(
                color: Color(0xFFE9D5FF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
                  '$durasi Menit',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              layanan['description'] ??
                  'Pembacaan tarot untuk membantu '
                  'memahami berbagai aspek kehidupan.',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatRupiah(harga),
                  style: const TextStyle(
                    color: Color(0xFFD8B4FE),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Layanan Tarot',
        ),
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

        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD8B4FE),
                ),
              )
            : services.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada layanan tarot.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadServices,
                    color: const Color(0xFF7C3AED),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return serviceCard(
                          services[index],
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}