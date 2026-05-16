import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/entry.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._();
  static Database? _db;

  DatabaseService._();

  Future<Database> get _database async {
    _db ??= await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dbPath = join(await getDatabasesPath(), 'peanut_budget.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE entries (
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          amount REAL NOT NULL,
          category TEXT NOT NULL,
          is_expense INTEGER NOT NULL,
          date INTEGER NOT NULL
        )
      '''),
    );
  }

  Future<void> insertEntry(Entry entry) async {
    final db = await _database;
    await db.insert(
      'entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Entry>> getAllEntries() async {
    final db = await _database;
    final rows = await db.query('entries', orderBy: 'date DESC');
    return rows.map(Entry.fromMap).toList();
  }

  Future<void> deleteEntry(String id) async {
    final db = await _database;
    await db.delete('entries', where: 'id = ?', whereArgs: [id]);
  }
}
