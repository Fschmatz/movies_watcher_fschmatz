import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../page/store_movie.dart';
import '../service/movie_service.dart';

class MovieInfoDialog extends StatefulWidget {
  Movie movie;
  Function()? loadWatchedMovies;
  Function()? loadNotWatchedMovies;
  bool? isFromWatched;

  MovieInfoDialog({super.key, required this.movie, this.loadWatchedMovies, this.loadNotWatchedMovies, this.isFromWatched});

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

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    imbdLink = "https://www.imdb.com/title/${movie.getImdbID()}";
    //_isMovieWatched = movie.getWatched() == NoYes.YES ? true : false;
  }

  _launchBrowser() {
    launchUrl(
      Uri.parse(imbdLink),
      mode: LaunchMode.externalApplication,
    );
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
    if (widget.loadNotWatchedMovies != null){
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
    final theme = Theme.of(context);
    TextStyle titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor);
    TextStyle subtitleStyle = const TextStyle(fontSize: 16);
   /* String formattedAddedDate = movie.getDateAdded() != null ? Jiffy.parse(movie.getDateAdded()!).format(pattern: 'dd/MM/yyyy') : "";
    String formattedWatchedDate = movie.getDateWatched() != null ? Jiffy.parse(movie.getDateWatched()!).format(pattern: 'dd/MM/yyyy') : "";*/

    return Dialog.fullscreen(
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
                      _launchBrowser();
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
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: (movie.getPoster() == null || movie.getPoster()!.isEmpty)
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
                                  child: FadeIn(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeIn,
                                    child: Image.memory(
                                      base64Decode(movie.getPoster()!),
                                      fit: BoxFit.fill,
                                      gaplessPlayback: true,
                                    ),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: OutlinedButton.icon(
                  onPressed: () {
                    (movie.isMovieWatched() ? _markNotWatched() : _markWatched()).then((_) => Navigator.of(context).pop());
                  },
                  icon: Icon(movie.isMovieWatched() ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  label: Text(movie.isMovieWatched() ? "Set not watched" : "Set watched")),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
