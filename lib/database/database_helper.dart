import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'attendance_system.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        profile_picture TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE leave_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        reason TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        profile_picture TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE grades (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        min_days INTEGER NOT NULL,
        max_days INTEGER NOT NULL,
        grade TEXT NOT NULL
      )
    ''');

    await _insertDefaultGrades(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS grades (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          min_days INTEGER NOT NULL,
          max_days INTEGER NOT NULL,
          grade TEXT NOT NULL
        )
      ''');

      final gradesCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM grades'));
      if (gradesCount == 0) {
        await _insertDefaultGrades(db);
      }
    }
  }

  Future<void> _insertDefaultGrades(Database db) async {
    await db.insert('grades', {'min_days': 26, 'max_days': 31, 'grade': 'A'});
    await db.insert('grades', {'min_days': 20, 'max_days': 25, 'grade': 'B'});
    await db.insert('grades', {'min_days': 15, 'max_days': 19, 'grade': 'C'});
    await db.insert('grades', {'min_days': 10, 'max_days': 14, 'grade': 'D'});
    await db.insert('grades', {'min_days': 0, 'max_days': 9, 'grade': 'F'});
  }

  Future<String?> getGradeForAttendance(int attendanceDays) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT grade FROM grades
    WHERE ? BETWEEN min_days AND max_days
  ''', [attendanceDays]);

    if (result.isNotEmpty) {
      return result.first['grade'] as String;
    }

    return null;
  }
}
