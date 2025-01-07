import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/util/utils.dart';
import 'package:share_plus/share_plus.dart';
import '../entity/movie.dart';
import '../page/store_movie.dart';
import '../service/movie_service.dart';

class MovieInfoDialog extends StatefulWidget {
  final Movie movie;
  final Function()? loadWatchedMovies;
  final Function()? loadNotWatchedMovies;
  final bool? isFromWatched;
  final Color dominantColorFromPoster;
  final Image? posterImage;

  const MovieInfoDialog(
      {super.key,
      required this.movie,
      this.loadWatchedMovies,
      this.loadNotWatchedMovies,
      this.isFromWatched,
      required this.dominantColorFromPoster,
      required this.posterImage});

  @override
  State<MovieInfoDialog> createState() => _MovieInfoDialogState();
}

class _MovieInfoDialogState extends State<MovieInfoDialog> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 200;
  double posterWidth = 200;
  BorderRadius posterBorder = BorderRadius.circular(12);
  String imbdLink = "";
  late Color dominantColorFromPoster;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    dominantColorFromPoster = widget.dominantColorFromPoster;
    imbdLink = "https://www.imdb.com/title/${movie.getImdbID()}";
  }

  Future<void> _delete() async {
    await movieService.deleteMovie(movie);
    await _reloadMoviesList();
  }

  Future<void> _markWatched() async {
    await movieService.setWatched(movie);
    await _reloadMoviesList();
  }

  Future<void> _markNotWatched() async {
    await movieService.setNotWatched(movie);
    await _reloadMoviesList();
  }

  Future<void> _reloadMoviesList() async {
    if (widget.loadWatchedMovies != null) {
      await widget.loadWatchedMovies!();
    }
    if (widget.loadNotWatchedMovies != null) {
      await widget.loadNotWatchedMovies!();
    }
  }

  showDialogConfirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Confirm",
          ),
          content: const Text(
            "Delete ?",
          ),
          actions: [
            TextButton(
              child: const Text(
                "Yes",
              ),
              onPressed: () {
                _delete().then((_) => Navigator.of(context).pop()).then((_) => Navigator.of(context).pop());
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentScheme = Theme.of(context).brightness == Brightness.light
        ? ColorScheme.fromSeed(seedColor: dominantColorFromPoster)
        : ColorScheme.fromSeed(seedColor: dominantColorFromPoster, brightness: Brightness.dark);
    final theme = Theme.of(context);
    TextStyle titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor);
    TextStyle subtitleStyle = const TextStyle(fontSize: 16);

    return Theme(
      data: ThemeData(
        colorScheme: currentScheme,
        useMaterial3: true,
      ),
      child: Dialog.fullscreen(
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: theme.colorScheme.background,
            title: const Text(''),
            actions: [
              IconButton(
                  icon: const Icon(
                    Icons.share_outlined,
                  ),
                  onPressed: () {
                    Share.share(imbdLink);
                  }),
              PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert_outlined),
                  itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                        const PopupMenuItem<int>(value: 0, child: Text('View in IMDb')),
                        const PopupMenuItem<int>(value: 1, child: Text('Edit')),
                        const PopupMenuItem<int>(value: 2, child: Text('Delete')),
                      ],
                  onSelected: (int value) {
                    switch (value) {
                      case 0:
                        Utils().launchBrowser(imbdLink);
                      case 1:
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => StoreMovie(
                                movie: movie,
                                isUpdate: true,
                                isFromSearch: false,
                                loadWatchedMovies: widget.loadWatchedMovies,
                                loadNotWatchedMovies: widget.loadNotWatchedMovies,
                              ),
                            ));
                        break;
                      case 2:
                        showDialogConfirmDelete(context);
                    }
                  })
            ],
          ),
          body: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FadeIn(
                        duration: const Duration(seconds: 1),
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: (widget.posterImage == null)
                              ? SizedBox(
                                  height: posterHeight,
                                  width: posterWidth,
                                  child: Card(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 30,
                                      color: theme.hintColor,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: posterHeight,
                                  width: posterWidth,
                                  child: Card(
                                    child: ClipRRect(
                                      borderRadius: posterBorder,
                                      child: widget.posterImage,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.getTitle()!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            Text(
                              "${movie.getRuntime()!} Min",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor),
                            ),
                            Text(
                              movie.getYear()!,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Visibility(
                visible: movie.getPlot() != null,
                child: ListTile(
                    title: Text(
                  movie.getPlot()!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: theme.hintColor),
                )),
              ),
              Visibility(
                visible: movie.getDirector() != null,
                child: ListTile(
                    title: Text(
                      "Director",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.getDirector()!,
                      style: subtitleStyle,
                    )),
              ),
              Visibility(
                visible: movie.getReleased() != null,
                child: ListTile(
                    title: Text(
                      "Released",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.getReleased()!,
                      style: subtitleStyle,
                    )),
              ),
              Visibility(
                visible: movie.getCountry() != null,
                child: ListTile(
                    title: Text(
                      "Country",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.getCountry()!,
                      style: subtitleStyle,
                    )),
              ),
              Visibility(
                visible: movie.getImdbRating() != null,
                child: ListTile(
                    title: Text(
                      "Imdb Rating",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.getImdbRating()!,
                      style: subtitleStyle,
                    )),
              ),
              Visibility(
                visible: movie.formattedDateWatched.isNotEmpty && movie.isMovieWatched(),
                child: ListTile(
                    title: Text(
                      "Date watched",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.formattedDateWatched,
                      style: subtitleStyle,
                    )),
              ),
              Visibility(
                visible: movie.formattedDateAdded.isNotEmpty,
                child: ListTile(
                    title: Text(
                      "Added to watchlist",
                      style: titleStyle,
                    ),
                    subtitle: Text(
                      movie.formattedDateAdded,
                      style: subtitleStyle,
                    )),
              ),
              const SizedBox(
                height: 50,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              (movie.isMovieWatched() ? _markNotWatched() : _markWatched()).then((_) => Navigator.of(context).pop());
            },
            child: Icon(movie.isMovieWatched() ? Icons.visibility_off_outlined : Icons.visibility_outlined),
          ),
        ),
      ),
    );
  }
}
