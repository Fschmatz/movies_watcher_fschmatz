import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/widget/runtime_chip.dart';

import '../entity/movie.dart';
import '../page/movie_details.dart';
import '../service/movie_service.dart';
import 'favorite_chip.dart';

class MovieCard extends StatefulWidget {
  @override
  State<MovieCard> createState() => _MovieCardState();

  final Movie movie;
  final bool? isFromWatched;
  final bool showMovieName;
  final bool showRuntimeChip;
  final bool formatRuntime;
  final int gridSize;

  const MovieCard({
    super.key,
    required this.movie,
    this.isFromWatched,
    required this.showMovieName,
    required this.showRuntimeChip,
    this.formatRuntime = false,
    this.gridSize = 3,
  });
}

class _MovieCardState extends State<MovieCard> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  late BorderRadius posterBorder;
  BorderRadius cardBorder = BorderRadius.circular(20);
  late Uint8List? imageBytes;
  Image? posterImage;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    _loadPosterImage();
    _loadBorders();
  }

  @override
  void didUpdateWidget(MovieCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.showMovieName != widget.showMovieName) {
      setState(() {
        _loadBorders();
      });
    }
  }

  void _loadBorders() {
    bool showName = widget.showMovieName;

    posterBorder = showName ? const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)) : BorderRadius.circular(20);
  }

  void _loadPosterImage() {
    imageBytes = (movie.getPoster() != null && movie.getPoster()!.isNotEmpty) ? base64Decode(movie.getPoster()!) : null;
    posterImage = imageBytes != null
        ? Image.memory(
            imageBytes!,
            fit: BoxFit.cover,
            gaplessPlayback: true,
          )
        : null;
  }

  void navigateToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails(
          movie: movie,
          isFromWatched: widget.isFromWatched,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card.filled(
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: cardBorder,
        side: widget.showMovieName ? BorderSide.none : BorderSide(color: theme.colorScheme.outlineVariant.withAlpha(150), width: 0),
      ),
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        borderRadius: cardBorder,
        onTap: navigateToDetails,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 2 / 3,
                  child: (posterImage == null)
                      ? SizedBox(
                          width: double.infinity,
                          child: Icon(
                            Icons.movie_outlined,
                            size: 30,
                            color: theme.hintColor,
                          ),
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: posterBorder,
                            child: posterImage,
                          ),
                        ),
                ),
                if (movie.getRuntime() != null && widget.showRuntimeChip)
                  RuntimeChip(
                    runtime: movie.getRuntime()!,
                    showMovieName: widget.showMovieName,
                    formatRuntime: widget.formatRuntime,
                    gridSize: widget.gridSize,
                  ),
                if (movie.isFavorite() && !(widget.isFromWatched ?? false)) FavoriteChip(gridSize: widget.gridSize),
              ],
            ),
            if (widget.showMovieName)
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 5, 8, 0),
                  child: Text(
                    movie.getTitle()!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
