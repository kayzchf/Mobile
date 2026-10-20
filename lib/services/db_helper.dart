import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/tarot_card.dart';
import '../models/blockchain_block.dart';
import '../models/feedback_model.dart';
import '../constants/tarot_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database?> get database async {
    try {
      if (_database != null) return _database!;
      _database = await _initDB('arcanova_master_v3.db');
      return _database!;
    } catch (_) {
      return null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Users Table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        birth_date TEXT NOT NULL,
        timezone_pref TEXT NOT NULL,
        avatar_url TEXT,
        avatar_gender TEXT NOT NULL DEFAULT 'male',
        biometric_enabled INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Tarot Cards Table
    await db.execute('''
      CREATE TABLE tarot_cards (
        id INTEGER PRIMARY KEY,
        number INTEGER NOT NULL,
        name TEXT NOT NULL,
        arcana_type TEXT NOT NULL,
        element TEXT NOT NULL,
        upright_meaning TEXT NOT NULL,
        reversed_meaning TEXT NOT NULL,
        love_advice TEXT NOT NULL,
        career_advice TEXT NOT NULL,
        keywords TEXT NOT NULL,
        affirmation TEXT NOT NULL,
        symbol TEXT NOT NULL,
        image_path TEXT
      )
    ''');

    // 3. Bookings Table
    await db.execute('''
      CREATE TABLE bookings (
        id TEXT PRIMARY KEY,
        user_id INTEGER NOT NULL,
        service_id INTEGER NOT NULL,
        service_title TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        sessions_count INTEGER NOT NULL,
        session_date TEXT NOT NULL,
        session_time_wib TEXT NOT NULL,
        user_timezone TEXT NOT NULL,
        total_price REAL NOT NULL,
        currency_used TEXT NOT NULL,
        payment_status TEXT NOT NULL,
        qris_reference TEXT NOT NULL,
        reminder_minutes INTEGER NOT NULL DEFAULT 10,
        reminder_notified INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Live Reader Chats (WhatsApp Style)
    await db.execute('''
      CREATE TABLE live_reader_chats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        booking_id TEXT NOT NULL,
        sender TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        session_date TEXT NOT NULL
      )
    ''');

    // 5. Blockchain Ledger Table
    await db.execute('''
      CREATE TABLE blockchain_ledger (
        block_index INTEGER PRIMARY KEY,
        timestamp INTEGER NOT NULL,
        session_data TEXT NOT NULL,
        previous_hash TEXT NOT NULL,
        nonce INTEGER NOT NULL,
        hash TEXT NOT NULL
      )
    ''');

    // 6. Course Feedback Table
    await db.execute('''
      CREATE TABLE course_feedback (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        student_name TEXT NOT NULL,
        nim TEXT NOT NULL,
        kesan TEXT NOT NULL,
        saran TEXT NOT NULL,
        rating_stars INTEGER NOT NULL,
        submitted_at TEXT NOT NULL
      )
    ''');

    // Seed Tarot Cards
    final batch = db.batch();
    for (var card in TarotDeckData.majorArcanaCards) {
      batch.insert('tarot_cards', card.toMap());
    }
    await batch.commit(noResult: true);
  }

  // --- USER OPERATIONS ---
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    if (db == null) return 1;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByUsernameOrEmail(String identifier) async {
    final db = await database;
    if (db == null) return null;
    final clean = identifier.trim().toLowerCase();
    final maps = await db.query(
      'users',
      where: 'LOWER(username) = ? OR LOWER(email) = ?',
      whereArgs: [clean, clean],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    if (db == null) return null;
    final maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateUser(UserModel user) async {
    final db = await database;
    if (db == null) return 1;
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(int userId) async {
    final db = await database;
    if (db == null) return 1;
    await db.delete('bookings', where: 'user_id = ?', whereArgs: [userId]);
    return await db.delete('users', where: 'id = ?', whereArgs: [userId]);
  }

  Future<int> updateUserBiometric(int userId, bool enabled) async {
    final db = await database;
    if (db == null) return 1;
    return await db.update(
      'users',
      {'biometric_enabled': enabled ? 1 : 0},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  // --- BOOKING OPERATIONS ---
  Future<int> insertBooking(BookingModel booking) async {
    final db = await database;
    if (db == null) return 1;
    return await db.insert('bookings', booking.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BookingModel>> getBookingsByUser(int userId) async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query(
      'bookings',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    return maps.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<List<BookingModel>> getAllBookedSessions() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query(
      'bookings',
      where: 'payment_status = ?',
      whereArgs: ['CONFIRMED'],
      orderBy: 'session_date ASC, session_time_wib ASC',
    );
    return maps.map((e) => BookingModel.fromMap(e)).toList();
  }

  Future<List<String>> getBookedTimes(String date) async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query(
      'bookings',
      columns: ['session_time_wib'],
      where: 'session_date = ? AND payment_status != ?',
      whereArgs: [date, 'CANCELLED'],
    );
    return maps.map((e) => e['session_time_wib'] as String).toList();
  }

  Future<int> updateBookingPaymentStatus(String bookingId, String status) async {
    final db = await database;
    if (db == null) return 1;
    return await db.update(
      'bookings',
      {'payment_status': status},
      where: 'id = ?',
      whereArgs: [bookingId],
    );
  }

  // --- LIVE READER CHATS (POV READER & WHATSAPP STYLE) ---
  Future<int> insertReaderChat({
    required String bookingId,
    required String sender,
    required String message,
    required String sessionDate,
  }) async {
    final db = await database;
    if (db == null) return 1;
    return await db.insert('live_reader_chats', {
      'booking_id': bookingId,
      'sender': sender,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
      'session_date': sessionDate,
    });
  }

  Future<List<Map<String, dynamic>>> getReaderChats(String bookingId) async {
    final db = await database;
    if (db == null) return [];
    // Auto cleanup chats older than H+3
    await cleanupExpiredChatsH3();

    return await db.query(
      'live_reader_chats',
      where: 'booking_id = ?',
      whereArgs: [bookingId],
      orderBy: 'timestamp ASC',
    );
  }

  // Retention Policy: H+3 automatic chat deletion
  Future<int> cleanupExpiredChatsH3() async {
    final db = await database;
    if (db == null) return 0;

    final cutoffDate = DateTime.now().subtract(const Duration(days: 3));
    final cutoffStr = "${cutoffDate.year}-${cutoffDate.month.toString().padLeft(2, '0')}-${cutoffDate.day.toString().padLeft(2, '0')}";

    return await db.delete(
      'live_reader_chats',
      where: 'session_date < ?',
      whereArgs: [cutoffStr],
    );
  }

  // --- TAROT CARD OPERATIONS ---
  Future<List<TarotCard>> getAllTarotCards() async {
    try {
      final db = await database;
      if (db == null) return TarotDeckData.majorArcanaCards;
      final maps = await db.query('tarot_cards', orderBy: 'number ASC');
      if (maps.isEmpty) {
        return TarotDeckData.majorArcanaCards;
      }
      return maps.map((e) => TarotCard.fromMap(e)).toList();
    } catch (_) {
      return TarotDeckData.majorArcanaCards;
    }
  }

  // --- BLOCKCHAIN OPERATIONS ---
  Future<int> insertBlock(BlockchainBlock block) async {
    final db = await database;
    if (db == null) return 1;
    return await db.insert('blockchain_ledger', block.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BlockchainBlock>> getAllBlocks() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('blockchain_ledger', orderBy: 'block_index ASC');
    return maps.map((e) => BlockchainBlock.fromMap(e)).toList();
  }

  // --- FEEDBACK OPERATIONS ---
  Future<int> insertFeedback(CourseFeedbackModel feedback) async {
    final db = await database;
    if (db == null) return 1;
    return await db.insert('course_feedback', feedback.toMap());
  }

  Future<List<CourseFeedbackModel>> getAllFeedback() async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query('course_feedback', orderBy: 'submitted_at DESC');
    return maps.map((e) => CourseFeedbackModel.fromMap(e)).toList();
  }

  Future<List<CourseFeedbackModel>> getFeedbackByUser(int userId) async {
    final db = await database;
    if (db == null) return [];
    final maps = await db.query(
      'course_feedback',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'submitted_at DESC',
    );
    return maps.map((e) => CourseFeedbackModel.fromMap(e)).toList();
  }

  Future<int> deleteFeedback(int id) async {
    final db = await database;
    if (db == null) return 1;
    return await db.delete(
      'course_feedback',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
