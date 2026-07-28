import 'package:flutter/material.dart';
import '../entity/movie.dart';
import 'search_result_tile.dart';

class MovieListTabView extends StatelessWidget {
  final bool loading;
  final List<Movie> movies;

  const MovieListTabView({
    super.key,
    required this.loading,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (movies.isEmpty) {
      return const SizedBox.shrink();
    }
    return ListView.builder(
      primary: false,
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return SearchResultTile(
          key: ValueKey(movies[index].getTmdbID()),
          movie: movies[index],
        );
      },
    );
  }
}
