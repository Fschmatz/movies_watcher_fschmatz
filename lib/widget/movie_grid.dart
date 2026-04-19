import 'package:flutter/material.dart';

import '../entity/movie.dart';
import '../util/app_constants.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;
  final bool showMovieName;
  final bool showRuntimeChip;
  final bool isFromWatched;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.isLoading,
    required this.showMovieName,
    required this.showRuntimeChip,
    this.isFromWatched = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.movieListAnimationDuration,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(children: [
              movies.isEmpty
                  ? const SizedBox(height: 5)
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisExtent: showMovieName ? 215 : 188,
                        ),
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: movies.length,
                        itemBuilder: (context, index) {
                          Movie movie = movies[index];

                          return MovieCard(
                            key: ValueKey(movie.getId()),
                            movie: movie,
                            isFromWatched: isFromWatched,
                            showMovieName: showMovieName,
                            showRuntimeChip: showRuntimeChip,
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 75)
            ]),
    );
  }
}
