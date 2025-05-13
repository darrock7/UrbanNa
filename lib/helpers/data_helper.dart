import 'package:sqflite/sqflite.dart';


class DataHelper {
  static final dataStorage = "urbanNa.db";
  static final tableName = "urbanNaReports";
  static final columnId = "id";

  static final columnName = "name";
  static final columnEmail = "email";

  static final columnCategory = "category";
  static final columnType = "type";

  static final columnDescription = "description";
  static final columnLocation = "location";

      DataHelper._privateConstructor();
  static final DataHelper instance = DataHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String databasesPath = await getDatabasesPath();
    String path = "$databasesPath/$dataStorage";
    return await openDatabase(path, onCreate: _onCreate, version: 1);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCategory TEXT NOT NULL,
        $columnType TEXT NOT NULL,
        $columnDescription TEXT NOT NULL,
        $columnLocation TEXT NOT NULL
      )
    ''');
  }
  Future<int> insertReport(Map<String, dynamic> report) async {
    Database db = await instance.database;
    return await db.insert(tableName, report);
  }

  Future<List<Map<String, dynamic>>> queryAllReports() async {
    Database db = await instance.database;
    return await db.query(tableName);
  }

  Future close() async {
    Database db = await instance.database;
    db.close();
  }

}