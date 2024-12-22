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
      //join(await getDatabasesPath(), 'content.db'),
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE exercises (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          url TEXT NOT NULL,
          thumbnail_url TEXT NOT NULL,
          duration INTEGER NOT NULL,
          reward_points INTEGER NOT NULL,
          is_unlocked INTEGER NOT NULL,
          tags TEXT
        )
    ''');

    await db.execute('''
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
          created_at TEXT
        )
    ''');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
        DROP TABLE IF EXISTS exercises
      ''');

      await db.execute('''
        DROP TABLE IF EXISTS recipes
      ''');
      await _onCreate(db, newVersion);
    }
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
