import 'package:movies_watcher_fschmatz/entity/no_yes.dart';

import '../dao/movie_dao.dart';
import '../entity/movie.dart';

class MovieService {

  void insertMovie(Movie movie) async {
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

  void deleteMovie(Movie movie) async {
    final db = MovieDAO.instance;

    await db.delete(movie.getId()!);
  }

  void updateMovie(Movie movie) async {
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

  void setWatched(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnWatched: NoYes.YES.id,
      MovieDAO.columnDateWatched: DateTime.now().toString()
    };

    await db.update(row);
  }

  void setNotWatched(Movie movie) async {
    final db = MovieDAO.instance;

    Map<String, dynamic> row = {
      MovieDAO.columnId: movie.getId(),
      MovieDAO.columnWatched: NoYes.NO.id,
      MovieDAO.columnDateWatched: null
    };

    await db.update(row);
  }

}