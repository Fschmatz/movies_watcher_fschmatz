import 'package:movies_watcher_fschmatz/entity/no_yes.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';

class MovieService {

  Future<void> insertMovie(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnTitle: movie.getTitle(),
      MovieDAO.columnYear: movie.getYear(),
      MovieDAO.columnReleased: movie.getReleased(),
      MovieDAO.columnRuntime: movie.getRuntime(),
      MovieDAO.columnDirector: movie.getDirector(),
      MovieDAO.columnPlot: movie.getPlot(),
      MovieDAO.columnCountry: movie.getCountry(),
      MovieDAO.columnPoster: movie.getPoster(),
      MovieDAO.columnImdbRating: movie.getImdbRating(),
      MovieDAO.columnImdbID: movie.getImdbID(),
      MovieDAO.columnWatched: movie.getWatched()?.id,
      MovieDAO.columnDateAdded: DateTime.now().toString(),
      MovieDAO.columnDateWatched: null
    };

    await db.insert(row);
  }

  Future<void> insertMovieFromBackup(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnTitle: movie.getTitle(),
      MovieDAO.columnYear: movie.getYear(),
      MovieDAO.columnReleased: movie.getReleased(),
      MovieDAO.columnRuntime: movie.getRuntime(),
      MovieDAO.columnDirector: movie.getDirector(),
      MovieDAO.columnPlot: movie.getPlot(),
      MovieDAO.columnCountry: movie.getCountry(),
      MovieDAO.columnPoster: movie.getPoster(),
      MovieDAO.columnImdbRating: movie.getImdbRating(),
      MovieDAO.columnImdbID: movie.getImdbID(),
      MovieDAO.columnWatched: movie.getWatched()?.id,
      MovieDAO.columnDateAdded: movie.getDateAdded(),
      MovieDAO.columnDateWatched: movie.getDateWatched()
    };

    await db.insert(row);
  }

  Future<void> deleteMovie(Movie movie) async {
    final db = MovieDAO.instance;

    await db.delete(movie.getId()!);
  }

  Future<void> updateMovie(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnTitle: movie.getTitle(),
      MovieDAO.columnYear: movie.getYear(),
      MovieDAO.columnReleased: movie.getReleased(),
      MovieDAO.columnRuntime: movie.getRuntime(),
      MovieDAO.columnDirector: movie.getDirector(),
      MovieDAO.columnPlot: movie.getPlot(),
      MovieDAO.columnCountry: movie.getCountry(),
      MovieDAO.columnPoster: movie.getPoster(),
      MovieDAO.columnImdbRating: movie.getImdbRating(),
      MovieDAO.columnImdbID: movie.getImdbID(),
      MovieDAO.columnWatched: movie.getWatched()!.id,
      MovieDAO.columnDateAdded: DateTime.now().toString(),
      MovieDAO.columnDateWatched: movie.getDateWatched()
    };

    await db.update(row);
  }

  Future<void> setWatched(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnWatched: NoYes.YES.id,
      MovieDAO.columnDateWatched: DateTime.now().toString()
    };

    await db.update(row);
  }

  Future<void> setNotWatched(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnWatched: NoYes.NO.id,
      MovieDAO.columnDateWatched: null
    };

    await db.update(row);
  }

  Future<void> insertMoviesFromRestoreBackup(List<dynamic> jsonData)  async {
    for (dynamic item in jsonData) {
      await insertMovieFromBackup(Movie.fromMap(item));
    }
  }

  Future<List<Map<String, dynamic>>> loadAllMovies()  {
    final dbMovies = MovieDAO.instance;
    return dbMovies.queryAllRows();
  }

  Future<void> deleteAllMovies()  async {
    final dbMovies = MovieDAO.instance;
    await dbMovies.deleteAll();
  }

}