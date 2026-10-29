import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/visitor.dart';

class VisitorDatabase {
  // One shared database instance.
  static final VisitorDatabase instance = VisitorDatabase._init();

  static Database? _database;

  VisitorDatabase._init();

  // Open the database or reuse it if already open.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('visitors.db');
    return _database!;
  }

  // Create the database and visitors table.
  Future<Database> _initDB(String fileName) async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE visitors (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        idNumber TEXT NOT NULL,
        phone TEXT NOT NULL,
        relationship TEXT NOT NULL,
        inmateName TEXT NOT NULL,
        purpose TEXT NOT NULL,
        belongings TEXT NOT NULL,
        status TEXT NOT NULL,
        visitDateTime TEXT NOT NULL
      )
    ''');
  }

  // Save a visitor.
  Future<int> insertVisitor(Visitor visitor) async {
    final db = await instance.database;

    return await db.insert(
      'visitors',
      visitor.toMap()..remove('id'),
    );
  }

  // Retrieve all visitors.
  Future<List<Visitor>> getVisitors() async {
    final db = await instance.database;

    final result = await db.query(
      'visitors',
      orderBy: 'visitDateTime DESC',
    );

    return result.map((map) => Visitor.fromMap(map)).toList();
  }

  // Update a visitor's status.
  Future<int> updateVisitorStatus(int id, String status) async {
    final db = await instance.database;

    return await db.update(
      'visitors',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Delete a visitor record.
  Future<int> deleteVisitor(int id) async {
    final db = await instance.database;

    return await db.delete(
      'visitors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close the database when needed.
  Future<void> close() async {
    final db = _database;

    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
