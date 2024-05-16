import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/widget/movie_info_dialog.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class MovieCard extends StatefulWidget {
  @override
  _MovieCardState createState() => _MovieCardState();

  Movie movie;
  Function()? loadWatchedMovies;
  Function()? loadNotWatchedMovies;
  bool? isFromWatched;

  MovieCard({Key? key, required this.movie, this.loadWatchedMovies, this.loadNotWatchedMovies, this.isFromWatched}) : super(key: key);
}

class _MovieCardState extends State<MovieCard> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 170;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(12);

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
  }

  void _openMovieInfoDialog() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return MovieInfoDialog(
            movie: movie,
            loadWatchedMovies: widget.loadWatchedMovies,
            loadNotWatchedMovies: widget.loadNotWatchedMovies,
            isFromWatched: widget.isFromWatched,
          );
        },
        fullscreenDialog: true));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: posterBorder,
        onTap: _openMovieInfoDialog,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          (movie.getPoster() == null || movie.getPoster()!.isEmpty)
              ? SizedBox(
                  height: posterHeight,
                  width: posterWidth,
                  child: Icon(
                    Icons.movie_outlined,
                    size: 30,
                    color: Theme.of(context).hintColor,
                  ),
                )
              : SizedBox(
                  height: posterHeight,
                  width: posterWidth,
                  child: ClipRRect(
                    borderRadius: posterBorder,
                    child: Image.memory(
                      base64Decode(movie.getPoster()!),
                      fit: BoxFit.fill,
                      gaplessPlayback: true,
                    ),
                  ),
                ),
          const SizedBox(
            height: 3,
          ),
          Flexible(
            flex: 3,
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
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                "${movie.getRuntime()!} Min",
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Theme.of(context).hintColor),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
