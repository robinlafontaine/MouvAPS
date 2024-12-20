import 'package:sqflite/sqflite.dart';

class ContentDatabase {
  static final ContentDatabase instance = ContentDatabase._internal();

  static Database? _database;

  ContentDatabase._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/content.db';
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    return await db.execute('''        
        CREATE TABLE exercises (
          id BIGINT PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          url TEXT NOT NULL,
          thumbnail_url TEXT NOT NULL,
          duration BIGINT NOT NULL,
          reward_points INTEGER NOT NULL,
          is_unlocked BOOLEAN NOT NULL,
          tags JSONB,
        );
        
        CREATE TABLE recipes (
          id BIGINT PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          video_url TEXT NOT NULL,
          thumbnail_url TEXT NOT NULL,
          time_mins SMALLINT NOT NULL,
          price_points INTEGER NOT NULL,
          difficulty REAL NOT NULL,
          tags TEXT,
        );
      ''');
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await instance.database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> queryAllRows(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

}
