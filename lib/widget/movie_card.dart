import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/widget/runtime_chip.dart';

import '../entity/movie.dart';
import '../service/movie_service.dart';
import 'movie_info_bottom_sheet.dart';

class MovieCard extends StatefulWidget {
  @override
  State<MovieCard> createState() => _MovieCardState();

  final Movie movie;
  final bool? isFromWatched;

  const MovieCard({super.key, required this.movie, this.isFromWatched});
}

class _MovieCardState extends State<MovieCard> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 180;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12));
  BorderRadius cardBorder = BorderRadius.circular(12);
  late Uint8List? imageBytes;
  Image? posterImage;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    _loadPosterImage();
  }

  void _loadPosterImage() {
    imageBytes = (movie.getPoster() != null && movie.getPoster()!.isNotEmpty) ? base64Decode(movie.getPoster()!) : null;
    posterImage = imageBytes != null
        ? Image.memory(
            imageBytes!,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          )
        : null;
  }

  Future<void> showMovieBottomSheet() {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return MovieInfoBottomSheet(
          movie: movie,
          isFromWatched: widget.isFromWatched,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHigh,
      child: InkWell(
        borderRadius: cardBorder,
        onTap: showMovieBottomSheet,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                (posterImage == null)
                    ? SizedBox(
                        height: posterHeight,
                        width: posterWidth,
                        child: Icon(
                          Icons.movie_outlined,
                          size: 30,
                          color: theme.hintColor,
                        ),
                      )
                    : SizedBox(
                        height: posterHeight,
                        width: posterWidth,
                        child: ClipRRect(
                          borderRadius: posterBorder,
                          child: posterImage,
                        ),
                      ),
                if (movie.getRuntime() != null)
                  RuntimeChip(
                    runtime: movie.getRuntime()!,
                  ),
              ],
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
                child: Text(
                  movie.getTitle()!,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
