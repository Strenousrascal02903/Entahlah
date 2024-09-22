import 'package:entahlah/Modal/FavoriteModal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final _databaseName = "favorite_tracks.db";
  static final _databaseVersion = 1;

  static final table = 'favorite_tracks';

  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnArtist = 'artist';
  static final columnThumbnailUrl = 'thumbnailUrl';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), _databaseName),
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId TEXT PRIMARY KEY,
        $columnTitle TEXT NOT NULL,
        $columnArtist TEXT NOT NULL,
        $columnThumbnailUrl TEXT NOT NULL
      )
    ''');
  }

  Future<int> insert(FavoriteTrack track) async {
    Database db = await instance.database;
    return await db.insert(table, track.toMap());
  }

  Future<List<FavoriteTrack>> queryAll() async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(table);

    return List.generate(maps.length, (i) {
      return FavoriteTrack.fromMap(maps[i]);
    });
  }

  Future<int> delete(String id) async {
    Database db = await instance.database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}
