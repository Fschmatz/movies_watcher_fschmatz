import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../entity/movie.dart';
import '../service/movie_service.dart';
import '../widget/movie_detail_tile.dart';
import 'store_movie.dart';

class MovieDetails extends StatefulWidget {
  final Movie movie;
  final bool? isFromWatched;

  const MovieDetails({
    super.key,
    required this.movie,
    this.isFromWatched,
  });

  @override
  State<MovieDetails> createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  late Movie movie;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
  }

  Future<void> _delete() async {
    await MovieService().deleteMovie(movie);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _markWatched() async {
    await MovieService().setWatched(movie);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _markNotWatched() async {
    await MovieService().setNotWatched(movie);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _shareImdbLink() async {
    Share.share("https://www.imdb.com/title/${movie.getImdbID()}");
  }

  Future<void> _openEditPage(BuildContext context) async {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StoreMovie(
            movie: movie,
            isUpdate: true,
            isFromSearch: false,
          ),
        )).then((_) {
      if (mounted) Navigator.pop(context);
    });
  }

  ImageProvider? _getPosterProvider() {
    final posterUrl = movie.getPoster();
    if (posterUrl != null && posterUrl.isNotEmpty) {
      if (posterUrl.startsWith('http')) {
        return NetworkImage(posterUrl);
      } else {
        try {
          return MemoryImage(base64Decode(posterUrl));
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final posterProvider = _getPosterProvider();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Details"),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_outlined),
            itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
              PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: const [
                    Icon(Icons.share_outlined),
                    SizedBox(width: 12),
                    Text('Share'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: const [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: const [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 12),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
            onSelected: (int value) {
              switch (value) {
                case 0:
                  _shareImdbLink();
                case 1:
                  _openEditPage(context);
                case 2:
                  _delete();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      width: 115,
                      height: 170,
                      child: posterProvider != null
                          ? Image(
                              image: posterProvider,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: colorScheme.surfaceContainerHighest,
                              child: const Center(
                                child: Icon(Icons.movie_outlined, size: 50),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 170,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            movie.getTitle() ?? '',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              height: 1.2,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          /* const SizedBox(height: 6),
                          Text(
                            movie.getYear() ?? '',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),*/
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 16,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "${movie.getRuntime() ?? '-'} Min",
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (movie.getPlot() != null && movie.getPlot()!.isNotEmpty) ...[
                Text(
                  "Plot",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  movie.getPlot()!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                "Details",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                children: [
                  // MovieDetailTile(title: "Runtime", value: "${movie.getRuntime() ?? '-'} Min"),
                  MovieDetailTile(title: "Director", value: movie.getDirector()),
                  MovieDetailTile(title: "Released", value: movie.getReleased()),
                  MovieDetailTile(title: "Country", value: movie.getCountry()),
                  MovieDetailTile(title: "IMDb Rating", value: movie.getImdbRating()),
                  MovieDetailTile(title: "Added", value: movie.formattedDateAdded),
                  if (movie.isMovieWatched())
                    MovieDetailTile(
                      title: "Watched",
                      value: movie.formattedDateWatched,
                    ),
                ],
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: movie.isMovieWatched() ? _markNotWatched : _markWatched,
        icon: Icon(
          movie.isMovieWatched() ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        ),
        label: Text(
          movie.isMovieWatched() ? "Remove from Watched" : "Mark as Watched",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
