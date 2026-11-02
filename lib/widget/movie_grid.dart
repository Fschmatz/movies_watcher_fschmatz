import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../entity/movie.dart';
import '../util/app_constants.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final bool isLoading;
  final bool showMovieName;
  final bool showRuntimeChip;
  final bool formatRuntime;
  final bool isFromWatched;
  final int gridSize;

  const MovieGrid({
    super.key,
    required this.movies,
    required this.isLoading,
    required this.showMovieName,
    required this.showRuntimeChip,
    this.formatRuntime = false,
    this.isFromWatched = false,
    this.gridSize = 3,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageTransitionSwitcher(
      duration: AppConstants.movieListAnimationDuration,
      transitionBuilder: (child, animation, secondaryAnimation) => FadeThroughTransition(
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      ),
      layoutBuilder: (List<Widget> entries) {
        return Stack(
          alignment: Alignment.topCenter,
          children: entries,
        );
      },
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
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double itemWidth = constraints.maxWidth / gridSize;
                            final double cardInternalWidth = itemWidth - 8.0;
                            final double posterHeight = cardInternalWidth / (2 / 3);
                            final double itemHeight = posterHeight + (showMovieName ? 40.0 : 8.0);

                            return GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridSize,
                                mainAxisExtent: itemHeight,
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
                                  formatRuntime: formatRuntime,
                                  gridSize: gridSize,
                                );
                              },
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
