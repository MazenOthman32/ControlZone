import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/waterLogModel.dart';

class WaterDatabase {
  static final WaterDatabase instance = WaterDatabase._init();
  static Database? _database;

  WaterDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'water.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE water_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<WaterLog> create(WaterLog log) async {
    final db = await instance.database;
    final id = await db.insert('water_logs', log.toMap());
    return log.copyWith(id: id);
  }

  Future<List<WaterLog>> getTodayLogs() async {
    final db = await instance.database;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final end = start.add(Duration(days: 1));

    final result = await db.query(
      'water_logs',
      where: 'date >= ? AND date < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
    );

    return result.map((e) => WaterLog.fromMap(e)).toList();
  }

  Future<int> deleteAllLogs() async {
    final db = await instance.database;
    return await db.delete('water_logs');
  }
}
