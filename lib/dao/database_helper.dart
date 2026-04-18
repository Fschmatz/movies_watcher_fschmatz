import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = "MovieTracker.db";
  static const _databaseVersion = 2;

  // Movies
  static const tableMovies = 'movies';
  static const columnMovieId = 'id';
  static const columnMovieTitle = 'title';
  static const columnMovieYear = 'year';
  static const columnMovieReleased = 'released';
  static const columnMovieRuntime = 'runtime';
  static const columnMovieDirector = 'director';
  static const columnMoviePlot = 'plot';
  static const columnMovieCountry = 'country';
  static const columnMoviePoster = 'poster';
  static const columnMovieImdbRating = 'imdbRating';
  static const columnMovieImdbID = 'imdbID';
  static const columnMovieWatched = 'watched';
  static const columnMovieDateAdded = 'dateAdded';
  static const columnMovieDateWatched = 'dateWatched';

  // App Parameters
  static const tableAppParameters = 'app_parameters';
  static const columnParamKey = 'key';
  static const columnParamValue = 'value';

  static Database? _database;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Movies
    await db.execute('''
          CREATE TABLE $tableMovies (
            $columnMovieId INTEGER PRIMARY KEY,            
            $columnMovieTitle TEXT NOT NULL,
            $columnMovieYear TEXT,
            $columnMovieReleased TEXT,  
            $columnMovieRuntime INTEGER NOT NULL, 
            $columnMovieDirector TEXT, 
            $columnMoviePlot TEXT,   
            $columnMovieCountry TEXT,   
            $columnMoviePoster BLOB,
            $columnMovieImdbRating TEXT, 
            $columnMovieImdbID TEXT NOT NULL, 
            $columnMovieWatched TEXT NOT NULL,
            $columnMovieDateAdded TEXT NOT NULL,
            $columnMovieDateWatched TEXT                  
          )
          ''');

    // App Parameters
    await db.execute('''
          CREATE TABLE $tableAppParameters (
            $columnParamKey TEXT PRIMARY KEY,
            $columnParamValue TEXT
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
          CREATE TABLE $tableAppParameters (
            $columnParamKey TEXT PRIMARY KEY,
            $columnParamValue TEXT
          )
          ''');
    }
  }
}
