import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'currency_service.dart';
import 'db_helper.dart';

class AuthService extends ChangeNotifier {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  static const String _salt = "ARCANOVA_COSMIC_SALT_9999_MYSTIC";
  static const String _prefUserIdKey = "arcanova_session_user_id";
  static const String _prefTokenKey = "arcanova_session_token";
  static const String _prefLastUsernameKey = "arcanova_last_username";

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isTarotReader => _currentUser?.isReader ?? false;

  // Hashing password with SHA-256 + Salt
  String hashPassword(String password) {
    final salted = '$password:$_salt';
    final bytes = utf8.encode(salted);
    return sha256.convert(bytes).toString();
  }

  String _generateToken(String identifier) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final raw = '$identifier:$timestamp:$_salt';
    return sha256.convert(utf8.encode(raw)).toString();
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String birthDate,
    required String timezonePref,
    String avatarGender = 'male',
    String role = 'client',
    String currencyPref = 'IDR',
  }) async {
    try {
      final existingUser = await DatabaseHelper.instance.getUserByUsernameOrEmail(username);
      if (existingUser != null) {
        return {'success': false, 'message': 'Username ini sudah dipakai. Coba username lain ya!'};
      }

      final existingEmail = await DatabaseHelper.instance.getUserByUsernameOrEmail(email);
      if (existingEmail != null) {
        return {'success': false, 'message': 'Email ini sudah terdaftar. Silakan langsung login ya!'};
      }

      final hashedPassword = hashPassword(password);
      final newUser = UserModel(
        username: username.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: hashedPassword,
        birthDate: birthDate,
        timezonePref: timezonePref,
        avatarGender: avatarGender,
        role: role,
        currencyPref: currencyPref,
        biometricEnabled: true,
      );

      final id = await DatabaseHelper.instance.insertUser(newUser);
      _currentUser = newUser.copyWith(id: id);

      // Save user ID & username to prefs for quick fingerprint login
      await _saveSession(id, _generateToken(username));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastUsernameKey, username.trim());

      CurrencyService.instance.syncWithTimezone(
        timezonePref,
        preferredInternationalCurrency: currencyPref == 'USD' ? CurrencyType.usd : CurrencyType.gbp,
      );

      notifyListeners();
      return {'success': true, 'user': _currentUser};
    } catch (e) {
      return {'success': false, 'message': 'Oops, gagal daftar: $e'};
    }
  }

  // Login with Username or Email
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      final user = await DatabaseHelper.instance.getUserByUsernameOrEmail(usernameOrEmail);
      if (user == null) {
        return {'success': false, 'message': 'Akun dengan username/email ini tidak ditemukan.'};
      }

      final inputHash = hashPassword(password);
      if (user.passwordHash != inputHash) {
        return {'success': false, 'message': 'Kata sandi belum tepat. Cek lagi ya!'};
      }

      _currentUser = user;
      await _saveSession(user.id!, _generateToken(user.username));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastUsernameKey, user.username);

      CurrencyService.instance.syncWithTimezone(
        user.timezonePref,
        preferredInternationalCurrency: user.currencyPref == 'USD' ? CurrencyType.usd : CurrencyType.gbp,
      );

      notifyListeners();
      return {'success': true, 'user': _currentUser};
    } catch (e) {
      return {'success': false, 'message': 'Oops, gagal masuk: $e'};
    }
  }

  // Quick Login as Official Tarot Reader
  Future<Map<String, dynamic>> loginAsReader() async {
    return await login(usernameOrEmail: 'arcreader', password: 'readernz');
  }

  // Biometric Direct Login
  Future<bool> loginWithBiometrics(int userId) async {
    try {
      final user = await DatabaseHelper.instance.getUserById(userId);
      if (user != null) {
        _currentUser = user;
        await _saveSession(user.id!, _generateToken(user.username));
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefLastUsernameKey, user.username);

        CurrencyService.instance.syncWithTimezone(
          user.timezonePref,
          preferredInternationalCurrency: user.currencyPref == 'USD' ? CurrencyType.usd : CurrencyType.gbp,
        );

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Quick switch back to Guest Mode
  void enterGuestMode() {
    _currentUser = null;
    CurrencyService.instance.syncWithTimezone('WIB');
    notifyListeners();
  }

  // Save Session
  Future<void> _saveSession(int userId, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefUserIdKey, userId);
    await prefs.setString(_prefTokenKey, token);
  }

  // Get Last Registered or Logged In User Id (with SQLite fallback)
  Future<int?> getLastSessionUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_prefUserIdKey);
    if (id != null) return id;

    // Check if any user exists in SQLite
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final users = await db.query('users', where: "role = 'client'", orderBy: 'id DESC', limit: 1);
      if (users.isNotEmpty) {
        final lastId = users.first['id'] as int;
        await prefs.setInt(_prefUserIdKey, lastId);
        return lastId;
      }
    }
    return null;
  }

  Future<String?> getLastUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_prefLastUsernameKey);
    if (u != null && u.isNotEmpty) return u;

    // Check if any user exists in SQLite
    final db = await DatabaseHelper.instance.database;
    if (db != null) {
      final users = await db.query('users', where: "role = 'client'", orderBy: 'id DESC', limit: 1);
      if (users.isNotEmpty) {
        final lastUsername = users.first['username'] as String;
        await prefs.setString(_prefLastUsernameKey, lastUsername);
        return lastUsername;
      }
    }
    return null;
  }

  // Update Full User Profile (Username, Email, Password, Avatar Gender, Timezone, Currency)
  Future<bool> updateFullProfile({
    required String username,
    required String email,
    String? newPassword,
    required String avatarGender,
    String? birthDate,
    String? timezonePref,
    String? currencyPref,
  }) async {
    if (_currentUser == null || _currentUser!.id == null) return false;

    String passwordHash = _currentUser!.passwordHash;
    if (newPassword != null && newPassword.trim().isNotEmpty) {
      passwordHash = hashPassword(newPassword.trim());
    }

    final updatedTimezone = timezonePref ?? _currentUser!.timezonePref;
    final updatedCurrency = currencyPref ?? _currentUser!.currencyPref;

    final updated = _currentUser!.copyWith(
      username: username.trim(),
      email: email.trim().toLowerCase(),
      passwordHash: passwordHash,
      avatarGender: avatarGender,
      birthDate: birthDate ?? _currentUser!.birthDate,
      timezonePref: updatedTimezone,
      currencyPref: updatedCurrency,
    );

    final rows = await DatabaseHelper.instance.updateUser(updated);
    if (rows > 0) {
      _currentUser = updated;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastUsernameKey, username.trim());

      CurrencyService.instance.syncWithTimezone(
        updatedTimezone,
        preferredInternationalCurrency: updatedCurrency == 'USD' ? CurrencyType.usd : CurrencyType.gbp,
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  // Delete User Account
  Future<bool> deleteAccount() async {
    if (_currentUser == null || _currentUser!.id == null) return false;
    final rows = await DatabaseHelper.instance.deleteUser(_currentUser!.id!);
    if (rows > 0) {
      await logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefUserIdKey);
      await prefs.remove(_prefLastUsernameKey);
      return true;
    }
    return false;
  }

  // Update Biometric Setting
  Future<void> toggleBiometric(bool enabled) async {
    if (_currentUser?.id != null) {
      await DatabaseHelper.instance.updateUserBiometric(_currentUser!.id!, enabled);
      _currentUser = _currentUser!.copyWith(biometricEnabled: enabled);
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefTokenKey);
    CurrencyService.instance.syncWithTimezone('WIB');
    notifyListeners();
  }
}
