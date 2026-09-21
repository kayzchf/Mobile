import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ArcanovaDB {

  static final ArcanovaDB instance = ArcanovaDB._init();

  static Database? _database;

  ArcanovaDB._init();

  //database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('arcanova.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();

    final path = join(
      dbPath,
      fileName,
    );

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  //create database
  Future<void> _createDB(
    Database db,
    int version,
  ) async {

    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nama TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE tarot_services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        price INTEGER NOT NULL,
        description TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT NOT NULL UNIQUE,
        discount_percent INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE bookings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        voucher_code TEXT,
        quantity INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        discount_amount INTEGER NOT NULL,
        total_price INTEGER NOT NULL,
        booking_date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.insert(
      'tarot_services',
      {
        'name': 'Love Reading',
        'duration_minutes': 30,
        'price': 175000,
        'description':
            'Membahas kehidupan dan hubungan percintaan.',
      },
    );

    await db.insert(
      'tarot_services',
      {
        'name': 'Career & Finance Reading',
        'duration_minutes': 30,
        'price': 150000,
        'description':
            'Membahas karier dan kondisi finansial.',
      },
    );

    await db.insert(
      'tarot_services',
      {
        'name': 'General Reading',
        'duration_minutes': 30,
        'price': 150000,
        'description':
            'Pembacaan tarot secara umum.',
      },
    );

    await db.insert(
      'tarot_services',
      {
        'name': 'Full Life Reading',
        'duration_minutes': 60,
        'price': 300000,
        'description':
            'Pembacaan berbagai aspek kehidupan secara menyeluruh.',
      },
    );

    await db.insert(
      'vouchers',
      {
        'code': 'arcanova15',
        'discount_percent': 15,
      },
    );

    await db.insert(
      'vouchers',
      {
        'code': 'arcanova20',
        'discount_percent': 20,
      },
    );
  }

  // REGISTER USER
  Future<int> registerUser({
    required String username,
    required String password,
    required String nama,
    required String email,
  }) async {
    final db = await database;

    return await db.insert(
      'users',
      {
        'username': username.trim(),
        'password': password,
        'nama': nama.trim(),
        'email': email.trim(),
      },
    );
  }

  // LOGIN USER
  Future<Map<String, dynamic>?> loginUser({
    required String username,
    required String password,
  }) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [
        username.trim(),
        password,
      ],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  //ambil id user
  Future<Map<String, dynamic>?> getUserById(
    int id,
  ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  // UPDATE USER
  Future<int> updateUser({
    required int id,
    required String username,
    required String password,
    required String nama,
    required String email,
  }) async {
    final db = await database;

    return await db.update(
      'users',
      {
        'username': username.trim(),
        'password': password,
        'nama': nama.trim(),
        'email': email.trim(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE USER
  Future<int> deleteUser(
    int id,
  ) async {
    final db = await database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getServices() async {
    final db = await database;

    return await db.query(
      'tarot_services',
      orderBy: 'id ASC',
    );
  }

  Future<Map<String, dynamic>?> getVoucherByCode(
    String code,
  ) async {
    final db = await database;

    final result = await db.query(
      'vouchers',
      where: 'code = ?',
      whereArgs: [
        code.trim().toLowerCase(),
      ],
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> addBooking({
    required int userId,
    required int serviceId,
    required String? voucherCode,
    required int quantity,
    required int subtotal,
    required int discountAmount,
    required int totalPrice,
  }) async {
    final db = await database;

    return await db.insert(
      'bookings',
      {
        'user_id': userId,
        'service_id': serviceId,
        'voucher_code': voucherCode?.trim().toLowerCase(),
        'quantity': quantity,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'total_price': totalPrice,
        'booking_date': DateTime.now().toIso8601String(),
        'status': 'Menunggu',
      },
    );
  }

//booking by id user
  Future<List<Map<String, dynamic>>> getUserBookings(
    int userId,
  ) async {
    final db = await database;

    return await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'booking_date DESC',
    );
  }

  //update status book
  Future<int> updateBookingStatus({
    required int id,
    required String status,
  }) async {
    final db = await database;

    return await db.update(
      'bookings',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  //close database
  Future<void> closeDatabase() async {
    final db = await database;

    await db.close();

    _database = null;
  }
}