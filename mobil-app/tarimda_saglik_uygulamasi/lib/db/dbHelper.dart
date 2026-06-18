import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tarla.dart';
import '../models/islem.dart';
import '../models/hastalik.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() => _instance;
  DbHelper._internal();
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }
  Future<Database> _initDb() async {
    String yol = join(await getDatabasesPath(), 'tarim_saglik.db');
    return await openDatabase(
      yol,
      version: 1,
      onCreate: _onCreate,
    );
  }
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Tarla (
        tarlaID INTEGER PRIMARY KEY AUTOINCREMENT,
        tarlaAdi TEXT,
        dekar REAL,
        mevki TEXT,
        mahsul TEXT,
        verim REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE Islem (
        islemID INTEGER PRIMARY KEY AUTOINCREMENT,
        islemAdi TEXT,
        islemTuru TEXT,
        tarih TEXT,
        hatirlatma TEXT,
        tarlaID INTEGER,
        FOREIGN KEY (tarlaID) REFERENCES Tarla (tarlaID) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE Hastalik (
        hastalikID INTEGER PRIMARY KEY AUTOINCREMENT,
        hastalikAdi TEXT,
        tarih TEXT,
        tarlaID INTEGER,
        FOREIGN KEY (tarlaID) REFERENCES Tarla (tarlaID) ON DELETE CASCADE
      )
    ''');
  }


  Future<int> insertTarla(Tarla tarla) async {
    Database db = await database;
    return await db.insert('Tarla', tarla.toMap());
  }

  Future<int> insertIslem(Islem islem, int tarlaID) async {
    Database db = await database;
    var map = islem.toMap();
    map['tarlaID'] = tarlaID;
    return await db.insert('Islem', map);
  } 


  Future<List<Map<String, dynamic>>> getTarlalar() async {
    Database db = await database;
    return await db.query('Tarla');
  }

  Future<List<Map<String, dynamic>>> getIslemlerByTarla(int tarlaID) async {
    Database db = await database;
    return await db.query('Islem', where: 'tarlaID = ?', whereArgs: [tarlaID]);
  }

  Future<int> deleteIslem(int id) async {
    Database db = await database;
    return await db.delete('Islem', where: 'islemID = ?', whereArgs: [id]);
  }

}