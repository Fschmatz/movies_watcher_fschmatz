import 'package:jiffy/jiffy.dart';

import '../enum/no_yes.dart';

class Movie {
  int? _id;
  String? _title;
  String? _year;
  String? _released;
  int? _runtime;
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
      int? runtime,
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

  int? getRuntime() => _runtime;

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

  void setRuntime(int value) {
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
    String? runtimeString = json['Runtime'];
    int runtimeInt = 0;

    if (runtimeString != null) {
      List<String> parts = runtimeString.split(' ');
      if (parts.isNotEmpty) {
        String firstPart = parts.first;
        try {
          runtimeInt = int.parse(firstPart);
        } catch (e) {
          runtimeInt = 0;
        }
      }
    }

    return Movie(
      id: null,
      title: json['Title'],
      year: json['Year'],
      released: json['Released'],
      runtime: runtimeInt,
      director: json['Director'],
      plot: json['Plot'],
      country: json['Country'],
      poster: json['Poster'],
      imdbRating: json['imdbRating'],
      imdbID: json['imdbID'],
      watched: NoYes.no,
      dateAdded: null,
      dateWatched: null,
    );
  }

  factory Movie.fromJsonSearchResult(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      year: json['Year'],
      imdbID: json['imdbID'],
      poster: json['Poster'],
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
      watched: map['watched'] == 'Y' ? NoYes.yes : NoYes.no,
      dateAdded: map['dateAdded'],
      dateWatched: map['dateWatched'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'title': _title,
      'year': _year,
      'released': _released,
      'runtime': _runtime,
      'director': _director,
      'plot': _plot,
      'country': _country,
      'poster': _poster,
      'imdbRating': _imdbRating,
      'imdbID': _imdbID,
      'watched': _watched == NoYes.yes ? 'Y' : 'N',
      'dateAdded': _dateAdded,
      'dateWatched': _dateWatched,
    };
  }


  @override
  String toString() {
    return 'Movie{_id: $_id, _title: $_title, _year: $_year, _released: $_released, _runtime: $_runtime, _director: $_director, _plot: $_plot, _country: $_country, _imdbRating: $_imdbRating, _imdbID: $_imdbID, _watched: $_watched, _dateAdded: $_dateAdded, _dateWatched: $_dateWatched}';
  }

  String get formattedDateAdded => _dateAdded != null ? Jiffy.parse(_dateAdded!).format(pattern: 'dd/MM/yyyy') : "";

  String get formattedDateWatched => _dateWatched != null ? Jiffy.parse(_dateWatched!).format(pattern: 'dd/MM/yyyy') : "";

  DateTime? get dateAddedAsDateTime => _dateAdded != null ? Jiffy.parse(_dateAdded!).dateTime : null;

  DateTime? get dateWatchedAsDateTime => _dateWatched != null ? Jiffy.parse(_dateWatched!).dateTime : null;

  bool isMovieWatched(){
    return _watched == NoYes.yes ? true : false;
  }
}
