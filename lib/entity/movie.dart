import 'no_yes.dart';

class Movie {
  int? _id;
  String? _title;
  String? _year;
  String? _released;
  String? _runtime;
  String? _director;
  String? _plot;
  String? _country;
  String? _poster;
  String? _imdbRating;
  String? _imdbID;
  NoYes? _watched;
  String? _dateAdded;
  String? _dateWatched;

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

  String? getDateWatched() => _dateWatched;

  String? getDateAdded() => _dateAdded;

  void setId(int value) {
    _id = value;
  }

  void setTitle(String value) {
    _title = value;
  }

  void setYear(String value) {
    _year = value;
  }

  void setReleased(String value) {
    _released = value;
  }

  void setRuntime(String value) {
    _runtime = value;
  }

  void setDirector(String value) {
    _director = value;
  }

  void setPlot(String value) {
    _plot = value;
  }

  void setCountry(String value) {
    _country = value;
  }

  void setPoster(String value) {
    _poster = value;
  }

  void setImdbRating(String value) {
    _imdbRating = value;
  }

  void setImdbID(String value) {
    _imdbID = value;
  }

  void setWatched(NoYes value) {
    _watched = value;
  }

  void setDateWatched(String value) {
    _dateWatched = value;
  }

  void setDateAdded(String value) {
    _dateAdded = value;
  }

  factory Movie.fromJson(Map<String, dynamic> json) {
    String? runtime = json['Runtime'];

    if (runtime != null) {
      List<String> parts = runtime.split(' ');
      if (parts.isNotEmpty) {
        runtime = parts.first;
      }
    }

    return Movie(
      id: null,
      title: json['Title'],
      year: json['Year'],
      released: json['Released'],
      runtime: runtime,
      director: json['Director'],
      plot: json['Plot'],
      country: json['Country'],
      poster: json['Poster'],
      imdbRating: json['imdbRating'],
      imdbID: json['imdbID'],
      watched: NoYes.NO,
      dateAdded: null,
      dateWatched: null,
    );
  }

  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'],
      title: map['title'],
      year: map['year'],
      released: map['released'],
      runtime: map['runtime'],
      director: map['director'],
      plot: map['plot'],
      country: map['country'],
      poster: map['poster'],
      imdbRating: map['imdbRating'],
      imdbID: map['imdbID'],
      watched: map['watched'] == 'Y' ? NoYes.YES : NoYes.NO,
      dateAdded: map['dateAdded'],
      dateWatched: map['dateWatched'],
    );
  }
}
