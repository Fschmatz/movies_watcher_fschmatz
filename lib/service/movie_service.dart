import '../dao/movie_dao.dart';
import '../entity/Movie.dart';

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
    MovieDAO.columnWatched: movie.getWatched(),
    MovieDAO.columnDateAdded: DateTime.now().toString(),
    MovieDAO.columnDateWatched: null
  };

/*
   MovieDAO.columnId: question,
  $columnId INTEGER PRIMARY KEY,
     $columnTitle TEXT NOT NULL,
 $columnYear TEXT,
  columnReleased TEXT,
  columnRuntime TEXT,
  columnDirector TEXT,
  columnPlot TEXT,
  columnCountry TEXT,
  columnPoster BLOB,
  columnImdbRating TEXT,
  columnImdbID TEXT NOT NULL,
  columnWatched TEXT,
  columnDateAdded TEXT  NOT NULL,
  columnDateWatched TEXT*/

  await db.insert(row);
}