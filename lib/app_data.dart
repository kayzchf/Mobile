class ArcanovaUser {
  String nama;
  String username;
  String email;
  String password;

  ArcanovaUser({
    required this.nama,
    required this.username,
    required this.email,
    required this.password,
  });
}

class TarotService {
  String nama;
  int durasi;
  int harga;
  String deskripsi;

  TarotService({
    required this.nama,
    required this.durasi,
    required this.harga,
    required this.deskripsi,
  });
}

class AppData {
  static ArcanovaUser? currentUser;

  static final List<ArcanovaUser> users = [];

  static final List<TarotService> services = [
    TarotService(
      nama: 'Love Reading',
      durasi: 30,
      harga: 175000,
      deskripsi: 'Membahas kehidupan dan hubungan percintaan.',
    ),
    TarotService(
      nama: 'Career & Finance Reading',
      durasi: 30,
      harga: 150000,
      deskripsi: 'Membahas karier dan kondisi finansial.',
    ),
    TarotService(
      nama: 'General Reading',
      durasi: 30,
      harga: 150000,
      deskripsi: 'Pembacaan tarot secara umum.',
    ),
    TarotService(
      nama: 'Full Life Reading',
      durasi: 60,
      harga: 300000,
      deskripsi: 'Pembacaan berbagai aspek kehidupan secara menyeluruh.',
    ),
  ];
}