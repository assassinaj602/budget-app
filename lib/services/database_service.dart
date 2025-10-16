import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    return openDatabase(
      join(path, 'budget_app.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE transactions(
            id TEXT PRIMARY KEY,
            amount REAL NOT NULL,
            title TEXT NOT NULL,
            date TEXT NOT NULL,
            category TEXT NOT NULL,
            type TEXT NOT NULL,
            note TEXT
          )
        ''');
        
        await db.execute('''
          CREATE TABLE categories(
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            icon TEXT NOT NULL,
            color INTEGER NOT NULL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
