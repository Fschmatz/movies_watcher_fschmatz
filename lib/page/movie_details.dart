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
import '../widget/movie_detail_tile.dart';
import '../widget/movie_info_card.dart';
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

  Future<void> _toggleFavorite() async {
    await MovieService().toggleFavorite(movie);
    if (mounted) setState(() {});
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

  BorderRadius _getDetailTileRadius(int index, int total) {
    const Radius outer = Radius.circular(20);
    const Radius inner = Radius.circular(4);

    if (total == 1) {
      return const BorderRadius.all(outer);
    }
    if (index == 0) {
      return const BorderRadius.vertical(top: outer, bottom: inner);
    }
    if (index == total - 1) {
      return const BorderRadius.vertical(top: inner, bottom: outer);
    }
    return const BorderRadius.all(inner);
  }

  List<Widget> _buildDetailTiles() {
    final tiles = [
      (title: "Director", value: movie.getDirector(), icon: Icons.person_outline),
      (title: "Released", value: movie.getReleased(), icon: Icons.calendar_month_outlined),
      (title: "Country", value: movie.getCountry(), icon: Icons.public_outlined),
      (title: "Added", value: movie.formattedDateAdded, icon: Icons.library_add_outlined),
      if (movie.isMovieWatched()) (title: "Watched", value: movie.formattedDateWatched, icon: Icons.visibility_outlined),
    ];

    return [
      for (int i = 0; i < tiles.length; i++) ...[
        if (i > 0) const SizedBox(height: 3),
        MovieDetailTile(
          title: tiles[i].title,
          value: tiles[i].value,
          icon: tiles[i].icon,
          borderRadius: _getDetailTileRadius(i, tiles.length),
        ),
      ],
    ];
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
                      scale: 1.25,
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
                          theme.scaffoldBackgroundColor.withValues(alpha: 0.45),
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
                        padding: const EdgeInsets.only(top: 45),
                        child: Hero(
                          tag: 'poster_${movie.getId()}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.posterBorderRadius),
                            child: Image(
                              image: posterProvider,
                              height: 225,
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
            if (!movie.isMovieWatched()) ...[
              IconButton(
                tooltip: movie.isFavorite() ? 'Remove from Favorites' : 'Add to Favorites',
                icon: Icon(
                  movie.isFavorite() ? Icons.star_rounded : Icons.star_border_rounded,
                  color: movie.isFavorite() ? Theme.of(context).colorScheme.primary : null,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
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
                Row(
                  children: [
                    Expanded(
                      child: MovieInfoCard(
                        icon: Icons.schedule_outlined,
                        value: movie.getRuntime() != null ? UtilsFunctions.formatRuntime(movie.getRuntime()!, formatRuntime) : '-',
                        label: "Duration",
                        backgroundColor: colorScheme.tertiaryContainer,
                        foregroundColor: colorScheme.onTertiaryContainer,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MovieInfoCard(
                        icon: Icons.calendar_month_outlined,
                        value: (movie.getYear() != null && movie.getYear()!.isNotEmpty) ? movie.getYear()! : '-',
                        label: "Year",
                        backgroundColor: colorScheme.secondaryContainer,
                        foregroundColor: colorScheme.onSecondaryContainer,
                        // labelColor: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: MovieInfoCard(
                        icon: Icons.star_border_rounded,
                        value: (movie.getRating() != null && movie.getRating()!.isNotEmpty) ? movie.getRating()! : '-',
                        label: "Rating",
                        backgroundColor: colorScheme.surfaceContainerHigh,
                        foregroundColor: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
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
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                Text(
                  "Details",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildDetailTiles(),
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
