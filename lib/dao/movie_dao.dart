import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../entity/no_yes.dart';

class MovieDAO {
  static const _databaseName = "MovieTracker.db";
  static const _databaseVersion = 1;

  static const table = 'movies';
  static const columnId = 'id';
  static const columnTitle = 'title';
  static const columnYear = 'year';
  static const columnReleased = 'released';
  static const columnRuntime = 'runtime';
  static const columnDirector = 'director';
  static const columnPlot = 'plot';
  static const columnCountry = 'country';
  static const columnPoster = 'poster';
  static const columnImdbRating = 'imdbRating';
  static const columnImdbID = 'imdbID';
  static const columnWatched = 'watched';
  static const columnDateAdded = 'dateAdded';
  static const columnDateWatched = 'dateWatched';

  static Database? _database;

  Future<Database> get database async => _database ??= await _initDatabase();

  MovieDAO._privateConstructor();

  static final MovieDAO instance = MovieDAO._privateConstructor();

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,            
            $columnTitle TEXT NOT NULL,
            $columnYear TEXT,
            $columnReleased TEXT,  
            $columnRuntime INTEGER NOT NULL, 
            $columnDirector TEXT, 
            $columnPlot TEXT,   
            $columnCountry TEXT,   
            $columnPoster BLOB,
            $columnImdbRating TEXT, 
            $columnImdbID TEXT NOT NULL, 
            $columnWatched TEXT NOT NULL,
            $columnDateAdded TEXT NOT NULL,
            $columnDateWatched TEXT                  
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> delete(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryAllByWatchedNoYes(NoYes noYes) async {
    Database db = await instance.database;
    return await db.rawQuery(
        'SELECT * FROM $table WHERE $columnWatched=\'${noYes.id}\' ORDER BY $columnTitle');
  }

  Future<int?> countMoviesByWatchedNoYes(NoYes noYes) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $table WHERE $columnWatched=\'${noYes.id}\''));
  }

  Future<int?> countRuntimeByWatchedNoYes(NoYes noYes) async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT SUM($columnRuntime) FROM $table WHERE $columnWatched=\'${noYes.id}\''));
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

}
