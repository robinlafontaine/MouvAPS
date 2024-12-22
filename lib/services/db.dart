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
    Batch batch = db.batch();

    batch.execute("DROP TABLE IF EXISTS exercises");
    batch.execute("DROP TABLE IF EXISTS recipes");

    batch.execute('''        
        CREATE TABLE exercises (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          url TEXT NOT NULL,
          thumbnail_url TEXT NOT NULL,
          duration INTEGER NOT NULL,
          reward_points INTEGER NOT NULL,
          is_unlocked INTEGER NOT NULL,
          tags JSONB
        )
    ''');

    batch.execute('''
        CREATE TABLE recipes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          ingredients TEXT NOT NULL,
          video_url TEXT NOT NULL,
          thumbnail_url TEXT NOT NULL,
          time_mins INTEGER NOT NULL,
          price_points INTEGER NOT NULL,
          difficulty REAL NOT NULL,
          tags JSONB,
          created_at TEXT
        )
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
