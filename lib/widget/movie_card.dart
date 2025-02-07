import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/widget/movie_info_dialog.dart';
import 'package:palette_generator/palette_generator.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class MovieCard extends StatefulWidget {
  @override
  State<MovieCard> createState() => _MovieCardState();

  final Movie movie;
  final Function()? loadWatchedMovies;
  final Function()? loadNotWatchedMovies;
  final bool? isFromWatched;

  const MovieCard({super.key, required this.movie, this.loadWatchedMovies, this.loadNotWatchedMovies, this.isFromWatched});
}

class _MovieCardState extends State<MovieCard> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 172;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(12);
  late Uint8List? imageBytes;
  Image? posterImage;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    _loadPosterImage();
  }

  void _loadPosterImage() {
    imageBytes = movie.getPoster() != null || movie.getPoster()!.isNotEmpty ? base64Decode(movie.getPoster()!) : null;
    posterImage = imageBytes != null
        ? Image.memory(
            imageBytes!,
            fit: BoxFit.fill,
            gaplessPlayback: true,
          )
        : null;
  }

  void _openMovieInfoDialog() async {
    Color dominantColorFromPoster = Colors.blue;
    if (imageBytes != null) {
      dominantColorFromPoster = await _generateDominantColorFromPoster();
    }

    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return MovieInfoDialog(
            movie: movie,
            loadWatchedMovies: widget.loadWatchedMovies,
            loadNotWatchedMovies: widget.loadNotWatchedMovies,
            isFromWatched: widget.isFromWatched,
            dominantColorFromPoster: dominantColorFromPoster,
            posterImage: posterImage,
          );
        },
        fullscreenDialog: true));
  }

  Future<Color> _generateDominantColorFromPoster() async {
    final ImageProvider imageProvider = MemoryImage(imageBytes!);
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
      imageProvider,
    );

    return paletteGenerator.dominantColor?.color ?? Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: posterBorder,
        onTap: _openMovieInfoDialog,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          const SizedBox(
            height: 3,
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                movie.getTitle()!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
          Flexible(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                "${movie.getRuntime()!} Min",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.hintColor),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
