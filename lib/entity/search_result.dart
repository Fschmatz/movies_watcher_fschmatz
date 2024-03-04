import 'movie.dart';

class SearchResult {
  List<Movie>? _search;
  String? _totalResults;
  String? _response;

  List<Movie>? getSearch() => _search;

  set search(List<Movie> value) {
    _search = value;
  }

  String? getTotalResults() => _totalResults;

  set totalResults(String value) {
    _totalResults = value;
  }

  String? getResponse() => _response;

  set response(String value) {
    _response = value;
  }

  SearchResult({List<Movie>? search, String? totalResults, String? response}) {
    _search = search;
    _totalResults = totalResults;
    _response = response;
  }

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      search: (json['Search'] as List?)
          ?.map((movie) => Movie.fromJsonSearchResult(movie))
          .toList(),
      totalResults: json['totalResults'],
      response: json['Response'],
    );
  }
}
