import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'eagent.db');

    return await openDatabase(
      path,
      version: 2, 
      onCreate: _createDatabase,
      onUpgrade: _onUpgrade,
    );
  }

  /// CREATE DATABASE
  Future<void> _createDatabase(Database db, int version) async {

    
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        phoneNumber TEXT NOT NULL,
        email TEXT,
        policyType TEXT,
        notes TEXT,
        dateAdded TEXT
      )
    ''');

    
    await db.execute('''
      CREATE TABLE reports (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientId INTEGER,
        policy TEXT,
        riskScore INTEGER,
        riskLevel TEXT,
        premium INTEGER,
        reserveMin INTEGER,
        reserveMax INTEGER,
        createdAt TEXT
      )
    ''');
  }

  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 2) {
      
    }
  }

  
  

  Future<int> addClient(Map<String, dynamic> client) async {
    final db = await database;

    return await db.insert(
      'clients',
      client,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    final db = await database;

    return await db.query(
      'clients',
      orderBy: 'id DESC',
    );
  }

  Future<int> deleteClient(int id) async {
    final db = await database;

    return await db.delete(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
  Future<int> addReport(Map<String, dynamic> report) async {
    final db = await database;

    return await db.insert(
      'reports',
      report,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// REPORTS FOR CLIENT
  Future<List<Map<String, dynamic>>> getReportsByClient(int clientId) async {
    final db = await database;

    return await db.query(
      'reports',
      where: 'clientId = ?',
      whereArgs: [clientId],
      orderBy: 'id DESC',
    );
  }

 
  Future<List<Map<String, dynamic>>> getAllReports() async {
    final db = await database;

    return await db.query(
      'reports',
      orderBy: 'id DESC',
    );
  }

 
  Future<int> deleteReport(int id) async {
    final db = await database;

    return await db.delete(
      'reports',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  
  Future<int> updateReport(int id, Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      'reports',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}