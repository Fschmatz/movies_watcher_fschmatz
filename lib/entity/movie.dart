import 'no_yes.dart';

class Movie {
  final int? _id;
  final String? _title;
  final String? _year;
  final String? _released;
  final String? _runtime;
  final String? _director;
  final String? _plot;
  final String? _country;
  final String? _poster;
  final String? _imdbRating;
  final String? _imdbID;
  final NoYes? _watched;
  final String? _dateAdded;
  final String? _dateWatched;

  Movie(
      {int? id,
        String? title,
        String? year,
        String? released,
        String? runtime,
        String? director,
        String? plot,
        String? country,
        String? poster,
        String? imdbRating,
        String? imdbID,
        NoYes? watched,
        String? dateAdded,
        String? dateWatched})
      : _id = id,
        _title = title,
        _year = year,
        _released = released,
        _runtime = runtime,
        _director = director,
        _plot = plot,
        _country = country,
        _poster = poster,
        _imdbRating = imdbRating,
        _imdbID = imdbID,
        _watched = watched,
        _dateAdded = dateAdded,
        _dateWatched = dateWatched;

  int? getId() => _id;

  String? getTitle() => _title;

  String? getYear() => _year;

  String? getReleased() => _released;

  String? getRuntime() => _runtime;

  String? getDirector() => _director;

  String? getPlot() => _plot;

  String? getCountry() => _country;

  String? getPoster() => _poster;

  String? getImdbRating() => _imdbRating;

  String? getImdbID() => _imdbID;

  NoYes? getWatched() => _watched;

  String? dateWatched() => _dateWatched;

  String? dateAdded() => _dateAdded;

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: null,
      title: json['Title'],
      year: json['Year'],
      released: json['Released'],
      runtime: json['Runtime'],
      director: json['Director'],
      plot: json['Plot'],
      country: json['Country'],
      poster: json['Poster'],
      imdbRating: json['imdbRating'],
      imdbID: json['imdbID'],
      watched: NoYes.NO,
      dateAdded: null,
      dateWatched: null
    );
  }

}
