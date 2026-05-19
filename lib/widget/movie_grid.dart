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
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: AppConstants.movieListAnimationDuration,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                movies.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withAlpha(102),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isFromWatched ? Icons.history_rounded : Icons.local_movies_outlined,
                                  size: 64,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                isFromWatched ? "No watched movies yet" : "Your watchlist is empty",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                isFromWatched
                                    ? "Movies you mark as watched will appear here. Tap a movie to change its status!"
                                    : "Keep track of movies you want to watch. Tap the '+' button to search and add movies!",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: showMovieName ? 220 : 188,
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
              ],
            ),
    );
  }
}
