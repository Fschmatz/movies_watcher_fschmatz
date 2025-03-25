import 'package:movies_watcher_fschmatz/enum/no_yes.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';

class MovieService {
  final dbMovies = MovieDAO.instance;

  Future<void> insertMovie(Movie movie) async {
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
      MovieDAO.columnDateWatched: movie.isMovieWatched() ? DateTime.now().toString() : null
    };

    await dbMovies.insert(row);
  }

  Future<void> insertMovieFromBackup(Movie movie) async {
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

    await dbMovies.insert(row);
  }

  Future<void> deleteMovie(Movie movie) async {
    await dbMovies.delete(movie.getId()!);
  }

  Future<void> updateMovie(Movie movie) async {
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

    await dbMovies.update(row);
  }

  Future<void> setWatched(Movie movie) async {
    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnWatched: NoYes.yes.id,
      MovieDAO.columnDateWatched: DateTime.now().toString()
    };

    await dbMovies.update(row);
  }

  Future<void> setNotWatched(Movie movie) async {
    Map<String, dynamic> row = {MovieDAO.columnId: movie.getId(), MovieDAO.columnWatched: NoYes.no.id, MovieDAO.columnDateWatched: null};

    await dbMovies.update(row);
  }

  Future<void> insertMoviesFromRestoreBackup(List<dynamic> jsonData) async {
    List<Map<String, dynamic>> listToInsert = jsonData.map((item) {
      return Movie.fromMap(item).toMap();
    }).toList();

    await dbMovies.insertBatchForBackup(listToInsert);
  }

  Future<List<Map<String, dynamic>>> loadAllMovies() {
    return dbMovies.queryAllRows();
  }

  Future<void> deleteAllMovies() async {
    await dbMovies.deleteAll();
  }

  Future<List<Movie>> queryAllByWatchedNoYesAndConvertToList(NoYes noYes) async {
    var resp = await dbMovies.queryAllByWatchedNoYes(noYes);

    return resp.isNotEmpty ? resp.map((map) => Movie.fromMap(map)).toList() : [];
  }

  Future<List<Movie>> queryAllByWatchedNoYesAndOrderByAndConvertToList(NoYes noYes, String optionSelected) async {
    var resp = await dbMovies.queryAllByWatchedNoYesAndOrderBy(noYes, optionSelected);

    return resp.isNotEmpty ? resp.map((map) => Movie.fromMap(map)).toList() : [];
  }

  Future<List<Movie>> findWatchedByYear(String year) async {
    var resp = await dbMovies.findWatchedByYear(year);

    return resp.isNotEmpty ? resp.map((map) => Movie.fromMap(map)).toList() : [];
  }

  Future<List<String>> findAllYearsWithWatchedMovies() async {
    var resp = await dbMovies.findAllYearsWithWatchedMovies();

    return resp.isNotEmpty ? resp : [];
  }

  Future<bool> existsByImdbId(String imdbID) async {
    return await dbMovies.existsByImdbId(imdbID);
  }

  Future<List<Movie>> queryAllByWatchedForStatsPage(NoYes noYes) async {
    var resp = await dbMovies.queryAllByWatchedForStatsPage(noYes);

    return resp.isNotEmpty ? resp.map((map) => Movie.fromMap(map)).toList() : [];
  }

}
