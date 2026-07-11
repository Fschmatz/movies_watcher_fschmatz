import 'dart:convert';
import 'package:http/http.dart' as http;

import '../entity/movie.dart';
import '../entity/search_result.dart';
import '../util/api_configs.dart';

class ApiService {
  Future<SearchResult?> searchMovies(String query, int page, {String? year}) async {
    final String apiKey = ApiConfigs.apiKey;
    String apiUrl = '${ApiConfigs.baseUrl}/search/movie?api_key=$apiKey&query=$query&page=$page';

    if (year != null && year.isNotEmpty) {
      apiUrl = "$apiUrl&primary_release_year=$year";
    }

    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return SearchResult.fromJson(jsonData);
    }
    return null;
  }

  Future<Movie?> getMovieDetails(int tmdbId) async {
    final String apiKey = ApiConfigs.apiKey;
    final String movieId = tmdbId.toString();
    final String apiUrl = '${ApiConfigs.baseUrl}/movie/$movieId?api_key=$apiKey&append_to_response=credits';

    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return Movie.fromJson(jsonData);
    }
    return null;
  }

  Future<SearchResult?> getTrendingMovies() async {
    final String apiKey = ApiConfigs.apiKey;
    final String apiUrl = '${ApiConfigs.baseUrl}/trending/movie/day?api_key=$apiKey';

    final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return SearchResult.fromJson(jsonData);
    }
    return null;
  }
}
