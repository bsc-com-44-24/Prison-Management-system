import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

/// Local SQLite storage (works on Android and in Chrome).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();
  late Database _db;
  String? _remembered;

  Future<void> init() async {
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWebNoWebWorker;
    }
    final path = join(await getDatabasesPath(), 'prison_mgmt.db');
    _db = await openDatabase(path, version: 1, onCreate: (d, _) async {
      await d.execute('''
        CREATE TABLE users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          full_name TEXT NOT NULL,
          email TEXT NOT NULL UNIQUE,
          phone TEXT NOT NULL,
          officer_id TEXT NOT NULL UNIQUE,
          password_hash TEXT NOT NULL)''');
      await d.execute('''
        CREATE TABLE settings(
          key TEXT PRIMARY KEY,
          value TEXT)''');
    });
    final rows = await _db
        .query('settings', where: 'key = ?', whereArgs: ['remembered_user']);
    _remembered = rows.isEmpty ? null : rows.first['value'] as String?;
  }

  // ---------- Remember me ----------
  String? get rememberedUser => _remembered;

  Future<void> setRememberedUser(String? value) async {
    _remembered = value;
    if (value == null) {
      await _db.delete('settings',
          where: 'key = ?', whereArgs: ['remembered_user']);
    } else {
      await _db.insert('settings', {'key': 'remembered_user', 'value': value},
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  // ---------- Auth ----------
  String _hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  /// Returns an error message, or null on success.
  Future<String?> registerUser({
    required String fullName,
    required String email,
    required String phone,
    required String officerId,
    required String password,
  }) async {
    final id = officerId.trim();
    final mail = email.trim().toLowerCase();
    final exists = await _db.query('users',
        where: 'email = ? OR officer_id = ?', whereArgs: [mail, id]);
    if (exists.isNotEmpty) return 'Email or ID number is already registered';
    await _db.insert('users', {
      'full_name': fullName.trim(),
      'email': mail,
      'phone': phone.trim(),
      'officer_id': id,
      'password_hash': _hash(password, id),
    });
    return null;
  }

  /// [identifier] can be email or officer ID.
  Future<Map<String, Object?>?> login(
      String identifier, String password) async {
    final key = identifier.trim();
    final rows = await _db.query('users',
        where: 'email = ? OR officer_id = ?',
        whereArgs: [key.toLowerCase(), key]);
    if (rows.isEmpty) return null;
    final u = rows.first;
    return u['password_hash'] == _hash(password, u['officer_id'] as String)
        ? u
        : null;
  }

  /// Reset: identity confirmed with email + officer ID.
  Future<bool> resetPassword(
      String email, String officerId, String newPassword) async {
    final id = officerId.trim();
    final rows = await _db.query('users',
        where: 'email = ? AND officer_id = ?',
        whereArgs: [email.trim().toLowerCase(), id]);
    if (rows.isEmpty) return false;
    await _db.update('users', {'password_hash': _hash(newPassword, id)},
        where: 'id = ?', whereArgs: [rows.first['id']]);
    return true;
  }
}