import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../Models/eventModel.dart';

class EventDatabase {
  static final EventDatabase instance = EventDatabase._init();
  static Database? _database;

  EventDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    final path = join(await getDatabasesPath(), 'events.db');
    _database = await openDatabase(path, version: 1, onCreate: _createDB);
    return _database!;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');
  }

  Future<Event> create(Event event) async {
    final db = await instance.database;
    final id = await db.insert('events', event.toMap());
    return event.copyWith(id: id);
  }

  Future<List<Event>> readAll() async {
    final db = await instance.database;
    final result = await db.query('events');
    return result.map((e) => Event.fromMap(e)).toList();
  }

  Future<List<Event>> readByDate(DateTime date) async {
    final db = await instance.database;
    final result = await db.query(
      'events',
      where: 'date = ?',
      whereArgs: [date.toIso8601String()],
    );
    return result.map((e) => Event.fromMap(e)).toList();
  }

  Future<int> delete(int id) async {
    final db = await instance.database;
    return db.delete('events', where: 'id = ?', whereArgs: [id]);
  }
}
