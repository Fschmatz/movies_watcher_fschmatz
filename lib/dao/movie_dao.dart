import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../enum/no_yes.dart';

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

  Future<List<Map<String, dynamic>>> queryAllByWatchedNoYesAndOrderBy(NoYes noYes, String selectedOrderBy) async {
    Database db = await instance.database;

    return await db.rawQuery(
        'SELECT * FROM $table WHERE $columnWatched=\'${noYes.id}\' ORDER BY $selectedOrderBy');
  }

  Future<int?> countMoviesByWatchedNoYes(NoYes noYes) async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT IFNULL(COUNT(*), 0) FROM $table WHERE $columnWatched=\'${noYes.id}\''));
  }

  Future<int?> sumRuntimeByWatchedNoYes(NoYes noYes) async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT IFNULL(SUM($columnRuntime), 0) FROM $table WHERE $columnWatched=\'${noYes.id}\''));
  }

  Future<int?> sumRuntimeWatchedCurrentMonth() async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT IFNULL(SUM($columnRuntime), 0) FROM $table WHERE $columnWatched=\'Y\' AND strftime(\'%Y-%m\', $columnDateWatched) = strftime(\'%Y-%m\', \'now\')'));
  }

  Future<int?> countMovieWatchedCurrentMonth() async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT IFNULL(COUNT(*), 0) FROM $table WHERE $columnWatched=\'Y\' AND strftime(\'%Y-%m\', $columnDateWatched) = strftime(\'%Y-%m\', \'now\')'));
  }

  Future<int?> countMovieAddedCurrentMonth() async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery('SELECT IFNULL(COUNT(*), 0) FROM $table WHERE strftime(\'%Y-%m\', $columnDateAdded) = strftime(\'%Y-%m\', \'now\')'));
  }

  Future<int> deleteAll() async {
    Database db = await instance.database;
    return await db.delete(table);
  }

  Future<void> insertBatchForBackup(List<Map<String, dynamic>> list) async {
    Database db = await instance.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final data in list) {
        batch.insert(table, data);
      }

      await batch.commit(noResult: true);
    });
  }

  Future<List<Map<String, dynamic>>> findWatchedByYear(String year) async {
    Database db = await instance.database;

    return await db.rawQuery('''
      SELECT * 
      FROM $table
      WHERE substr($columnDateWatched, 1, 4) = '$year'
      AND $columnWatched='Y'
      ORDER BY $columnTitle
      ''');
  }

  Future<List<String>> findAllYearsWithWatchedMovies() async {
    Database db = await instance.database;

    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT DISTINCT substr($columnDateWatched, 1, 4) AS year
      FROM $table
      WHERE $columnWatched = 'Y';
    ''');

    return result.map((row) => row['year'] as String).toList();
  }

  Future<bool> existsByImdbId(String imdbID) async {
    Database db = await instance.database;

    final result = await db.rawQuery('SELECT 1 FROM $table WHERE $columnImdbID = ?', [imdbID]);

    return result.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> queryAllByWatchedForStatsPage(NoYes noYes) async {
    Database db = await instance.database;

    return await db.rawQuery(
      '''
    SELECT 
      $columnId, 
      $columnTitle,
      $columnRuntime, 
      $columnImdbID, 
      $columnWatched, 
      $columnDateAdded, 
      $columnDateWatched 
    FROM $table 
    WHERE $columnWatched = ?
    ORDER BY $columnTitle
    ''',
      [noYes.id],
    );
  }

}
