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
  String? _rating;
  int? _tmdbID;
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
      String? rating,
      int? tmdbID,
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
        _rating = rating,
        _tmdbID = tmdbID,
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

  String? getRating() => _rating;

  int? getTmdbID() => _tmdbID;

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

  void setRating(String value) {
    _rating = value;
  }

  void setTmdbID(int value) {
    _tmdbID = value;
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
    String? year = json['release_date']?.toString().split('-').first;
    String director = '';
    if (json['credits'] != null && json['credits']['crew'] != null) {
      final crew = json['credits']['crew'] as List;
      final directorMap = crew.firstWhere((c) => c['job'] == 'Director', orElse: () => null);
      if (directorMap != null) {
        director = directorMap['name'];
      }
    }

    String country = '';
    if (json['production_countries'] != null && (json['production_countries'] as List).isNotEmpty) {
      country = json['production_countries'][0]['name'];
    }

    return Movie(
      id: null,
      title: json['title'] ?? '',
      year: year ?? '',
      released: (json['release_date'] != null && json['release_date'].toString().isNotEmpty)
          ? Jiffy.parse(json['release_date']).format(pattern: 'dd/MM/yyyy')
          : '',
      runtime: json['runtime'] ?? 0,
      director: director,
      plot: json['overview'] ?? '',
      country: country,
      poster: json['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}' : 'N/A',
      rating: json['vote_average'] != null
          ? (((json['vote_average'] as num).toDouble() * 10).floorToDouble() / 10).toString()
          : '',
      tmdbID: json['id'],
      watched: NoYes.no,
      dateAdded: null,
      dateWatched: null,
    );
  }

  factory Movie.fromJsonSearchResult(Map<String, dynamic> json) {
    String? year = json['release_date']?.toString().split('-').first;
    return Movie(
      title: json['title'],
      year: year,
      tmdbID: json['id'],
      poster: json['poster_path'] != null ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}' : 'N/A',
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
      rating: map['rating'],
      tmdbID: map['tmdbID'],
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
      'rating': _rating,
      'tmdbID': _tmdbID,
      'watched': _watched == NoYes.yes ? 'Y' : 'N',
      'dateAdded': _dateAdded,
      'dateWatched': _dateWatched,
    };
  }

  @override
  String toString() {
    return 'Movie{_id: $_id, _title: $_title, _year: $_year, _released: $_released, _runtime: $_runtime, _director: $_director, _plot: $_plot, _country: $_country, _rating: $_rating, _tmdbID: $_tmdbID, _watched: $_watched, _dateAdded: $_dateAdded, _dateWatched: $_dateWatched}';
  }

  String get formattedDateAdded => _dateAdded != null
      ? Jiffy.parse(_dateAdded!).format(pattern: 'dd/MM/yyyy')
      : "";

  String get formattedDateWatched => _dateWatched != null
      ? Jiffy.parse(_dateWatched!).format(pattern: 'dd/MM/yyyy')
      : "";

  DateTime? get dateAddedAsDateTime =>
      _dateAdded != null ? Jiffy.parse(_dateAdded!).dateTime : null;

  DateTime? get dateWatchedAsDateTime =>
      _dateWatched != null ? Jiffy.parse(_dateWatched!).dateTime : null;

  bool isMovieWatched() {
    return _watched == NoYes.yes ? true : false;
  }
}
