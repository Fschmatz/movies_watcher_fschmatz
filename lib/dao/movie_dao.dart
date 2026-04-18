import 'package:sqflite/sqflite.dart';

import '../enum/no_yes.dart';
import 'database_helper.dart';

class MovieDAO {
  static const table = DatabaseHelper.tableMovies;
  static const columnId = DatabaseHelper.columnMovieId;
  static const columnTitle = DatabaseHelper.columnMovieTitle;
  static const columnYear = DatabaseHelper.columnMovieYear;
  static const columnReleased = DatabaseHelper.columnMovieReleased;
  static const columnRuntime = DatabaseHelper.columnMovieRuntime;
  static const columnDirector = DatabaseHelper.columnMovieDirector;
  static const columnPlot = DatabaseHelper.columnMoviePlot;
  static const columnCountry = DatabaseHelper.columnMovieCountry;
  static const columnPoster = DatabaseHelper.columnMoviePoster;
  static const columnImdbRating = DatabaseHelper.columnMovieImdbRating;
  static const columnImdbID = DatabaseHelper.columnMovieImdbID;
  static const columnWatched = DatabaseHelper.columnMovieWatched;
  static const columnDateAdded = DatabaseHelper.columnMovieDateAdded;
  static const columnDateWatched = DatabaseHelper.columnMovieDateWatched;

  Future<Database> get database async => await DatabaseHelper.instance.database;

  MovieDAO._privateConstructor();

  static final MovieDAO instance = MovieDAO._privateConstructor();


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

    return await db.rawQuery('SELECT * FROM $table WHERE $columnWatched=\'${noYes.id}\' ORDER BY $columnTitle');
  }

  Future<List<Map<String, dynamic>>> queryAllByWatchedNoYesAndOrderBy(NoYes noYes, String selectedOrderBy) async {
    Database db = await instance.database;

    return await db.rawQuery('SELECT * FROM $table WHERE $columnWatched=\'${noYes.id}\' ORDER BY $selectedOrderBy');
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

    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT IFNULL(SUM($columnRuntime), 0) FROM $table WHERE $columnWatched=\'Y\' AND strftime(\'%Y-%m\', $columnDateWatched) = strftime(\'%Y-%m\', \'now\')'));
  }

  Future<int?> countMovieWatchedCurrentMonth() async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT IFNULL(COUNT(*), 0) FROM $table WHERE $columnWatched=\'Y\' AND strftime(\'%Y-%m\', $columnDateWatched) = strftime(\'%Y-%m\', \'now\')'));
  }

  Future<int?> countMovieAddedCurrentMonth() async {
    Database db = await instance.database;

    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT IFNULL(COUNT(*), 0) FROM $table WHERE strftime(\'%Y-%m\', $columnDateAdded) = strftime(\'%Y-%m\', \'now\')'));
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

  Future<Map<String, int>> findForStats() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
    SELECT
      -- not watched count
      (SELECT IFNULL(COUNT(*), 0)
         FROM $table
        WHERE $columnWatched = 'N') AS countNotWatched,

      -- watched count
      (SELECT IFNULL(COUNT(*), 0)
         FROM $table
        WHERE $columnWatched = 'Y') AS countWatched,

      -- runtime watched
      (SELECT IFNULL(SUM($columnRuntime), 0)
         FROM $table
        WHERE $columnWatched = 'Y') AS runtimeWatched,

      -- runtime not watched
      (SELECT IFNULL(SUM($columnRuntime), 0)
         FROM $table
        WHERE $columnWatched = 'N') AS runtimeNotWatched,

      -- movies watched this month
      (SELECT IFNULL(COUNT(*), 0)
         FROM $table
        WHERE $columnWatched = 'Y'
          AND strftime('%Y-%m', $columnDateWatched) = strftime('%Y-%m', 'now')
      ) AS watchedThisMonth,

      -- runtime watched this month
      (SELECT IFNULL(SUM($columnRuntime), 0)
         FROM $table
        WHERE $columnWatched = 'Y'
          AND strftime('%Y-%m', $columnDateWatched) = strftime('%Y-%m', 'now')
      ) AS runtimeThisMonth
  ''');

    final row = result.first;

    return {
      "countNotWatched": row["countNotWatched"] as int,
      "countWatched": row["countWatched"] as int,
      "runtimeWatched": row["runtimeWatched"] as int,
      "runtimeNotWatched": row["runtimeNotWatched"] as int,
      "watchedThisMonth": row["watchedThisMonth"] as int,
      "runtimeThisMonth": row["runtimeThisMonth"] as int,
    };
  }
}
