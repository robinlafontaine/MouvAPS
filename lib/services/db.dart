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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      readOnly: false,
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    db.execute('''
        CREATE TABLE IF NOT EXISTS exercises (
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

    db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        name TEXT,
        time_mins INTEGER,
        video_url TEXT,
        price_points INTEGER,
        created_at TEXT DEFAULT (datetime('now')),
        difficulty REAL CHECK (difficulty >= 0 AND difficulty <= 3),
        thumbnail_url TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE recipe_ingredient (
        ingredient_id INTEGER,
        quantity INTEGER,
        recipe_id INTEGER,
        PRIMARY KEY (ingredient_id, recipe_id),
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
          ON DELETE CASCADE ON UPDATE NO ACTION,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id)
          ON DELETE CASCADE ON UPDATE NO ACTION
      )
    ''');

    db.execute('''
        CREATE TABLE ingredients (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          image_url TEXT
        )
    ''');
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS exercises');
      await db.execute('DROP TABLE IF EXISTS recipes');
      await db.execute('DROP TABLE IF EXISTS recipe_ingredient');
      await db.execute('DROP TABLE IF EXISTS ingredients');
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

  Future<Map<String, dynamic>> queryRow(String table, int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(table, where: 'id = ?', whereArgs: [id]);
    return result.first;
  }

}
