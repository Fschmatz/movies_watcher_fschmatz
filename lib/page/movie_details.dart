import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../entity/movie.dart';
import '../redux/app_state.dart';
import '../redux/build_context_extension.dart';
import '../redux/selectors.dart';
import '../service/movie_service.dart';
import '../util/app_constants.dart';
import '../util/utils_functions.dart';
import '../widget/movie_detail_chip.dart';
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
  ImageProvider? _posterProvider;

  @override
  void initState() {
    super.initState();
    movie = widget.movie;
    _initPosterProvider();
  }

  void _initPosterProvider() {
    final posterUrl = movie.getPoster();
    if (posterUrl != null && posterUrl.isNotEmpty) {
      if (posterUrl.startsWith('http')) {
        _posterProvider = NetworkImage(posterUrl);
      } else {
        try {
          _posterProvider = MemoryImage(base64Decode(posterUrl));
        } catch (e) {
          _posterProvider = null;
        }
      }
    } else {
      _posterProvider = null;
    }
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

  Future<void> _openEditPage(BuildContext context) async {
    await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StoreMovie(
            movie: movie,
            isUpdate: true,
            isFromSearch: false,
          ),
        ));

    if (mounted) {
      Movie? updatedMovie = await MovieService().getMovieById(movie.getId()!);
      if (updatedMovie != null) {
        setState(() {
          movie = updatedMovie;
          _initPosterProvider();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final posterProvider = _posterProvider;
    final formatRuntime = context.select((AppState state) => selectParameterValueByKeyAsBoolean(state, AppConstants.formatRuntimeAppParameter));

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 350.0,
          pinned: true,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          backgroundColor: theme.scaffoldBackgroundColor,
          flexibleSpace: FlexibleSpaceBar(
            background: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Blurred Background
                  if (posterProvider != null)
                    Transform.scale(
                      scale: 1.1,
                      child: ImageFiltered(
                        imageFilter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                        child: Image(
                          image: posterProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(color: colorScheme.surfaceContainerHighest),

                  // Gradient overlay to blend into scaffold
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.4),
                          theme.scaffoldBackgroundColor,
                        ],
                        stops: const [0.4, 0.95],
                      ),
                    ),
                  ),

                  // Solid color at bottom to ensure no gaps
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 10,
                    child: Container(color: theme.scaffoldBackgroundColor),
                  ),

                  // Centered Crisp Poster
                  if (posterProvider != null)
                    Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Hero(
                          tag: 'poster_${movie.getId()}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image(
                              image: posterProvider,
                              height: 220,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(Icons.movie_outlined, size: 80),
                    ),
                ],
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Transform.translate(
              offset: const Offset(0, 1),
              child: Container(
                height: 2.0,
                color: theme.scaffoldBackgroundColor,
              ),
            ),
          ),
          actions: [
            PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                PopupMenuItem<int>(
                  value: 0,
                  child: Row(
                    children: const [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<int>(
                  value: 1,
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
                    _openEditPage(context);
                  case 1:
                    _delete();
                }
              },
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: theme.scaffoldBackgroundColor,
                  blurRadius: 0.0,
                  spreadRadius: 0.0,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie.getTitle() ?? '',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    MovieDetailChip(
                      icon: Icons.access_time_outlined,
                      text: movie.getRuntime() != null ? UtilsFunctions.formatRuntime(movie.getRuntime()!, formatRuntime) : '-',
                    ),
                    if (movie.getYear() != null && movie.getYear()!.isNotEmpty)
                      MovieDetailChip(
                        icon: Icons.calendar_today_outlined,
                        text: movie.getYear()!,
                      ),
                  ],
                ),
                const SizedBox(height: 32),
                if (movie.getPlot() != null && movie.getPlot()!.isNotEmpty) ...[
                  Text(
                    "Plot",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    movie.getPlot()!,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Text(
                  "Details",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MovieDetailTile(title: "Director", value: movie.getDirector(), icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    MovieDetailTile(title: "Released", value: movie.getReleased(), icon: Icons.calendar_month_outlined),
                    const SizedBox(height: 12),
                    MovieDetailTile(title: "Country", value: movie.getCountry(), icon: Icons.public_outlined),
                    const SizedBox(height: 12),
                    MovieDetailTile(title: "Rating", value: movie.getRating(), icon: Icons.star_border_outlined),
                    const SizedBox(height: 12),
                    MovieDetailTile(title: "Added", value: movie.formattedDateAdded, icon: Icons.library_add_outlined),
                    if (movie.isMovieWatched()) ...[
                      const SizedBox(height: 12),
                      MovieDetailTile(
                        title: "Watched",
                        value: movie.formattedDateWatched,
                        icon: Icons.visibility_outlined,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ]),
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
