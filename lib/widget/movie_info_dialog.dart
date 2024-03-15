import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jiffy/jiffy.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../page/store_movie.dart';
import '../service/movie_service.dart';

class MovieInfoDialog extends StatefulWidget {
  Movie movie;
  Function() refreshMoviesList;

  MovieInfoDialog({super.key, required this.movie, required this.refreshMoviesList});

  @override
  State<MovieInfoDialog> createState() => _MovieInfoDialogState();
}

class _MovieInfoDialogState extends State<MovieInfoDialog> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 190;
  double posterWidth = 160;
  BorderRadius posterBorder = BorderRadius.circular(8);
  String imbdLink = "";
  bool _isMovieWatched = false;

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    imbdLink = "https://www.imdb.com/title/${movie.getImdbID()}";
    _isMovieWatched = movie.getWatched() == NoYes.YES ? true : false;
  }

  _launchBrowser() {
    launchUrl(
      Uri.parse(imbdLink),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _delete() async {
    await movieService.deleteMovie(movie);
    widget.refreshMoviesList();
  }

  void _markWatched() {
    movieService.setWatched(movie);
  }

  void _markNotWatched() {
    movieService.setNotWatched(movie);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle titleStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.hintColor);
    TextStyle subtitleStyle = const TextStyle(fontSize: 16);
    String formattedAddedDate = movie.getDateAdded() != null ? Jiffy.parse(movie.getDateAdded()!).format(pattern: 'dd/MM/yyyy') : "";
    String formattedWatchedDate = movie.getDateWatched() != null ? Jiffy.parse(movie.getDateWatched()!).format(pattern: 'dd/MM/yyyy') : "";

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
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
                              isFromSearchPage: false,
                              refreshHome: widget.refreshMoviesList,
                            ),
                          ));
                      break;
                    case 2:
                      _delete().then((_) => Navigator.of(context).pop());
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
                    flex: 2,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: (movie.getPoster() == null)
                          ? SizedBox(
                              height: posterHeight,
                              width: posterWidth,
                              child: Icon(
                                Icons.image_outlined,
                                size: 30,
                                color: theme.hintColor,
                              ),
                            )
                          : SizedBox(
                              height: posterHeight,
                              width: posterWidth,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(movie.getPoster()!),
                                  fit: BoxFit.fill,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
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
              visible: formattedAddedDate.isNotEmpty,
              child: ListTile(
                  title: Text(
                    "Date added",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    formattedAddedDate,
                    style: subtitleStyle,
                  )),
            ),
            Visibility(
              visible: formattedWatchedDate.isNotEmpty && _isMovieWatched,
              child: ListTile(
                  title: Text(
                    "Date watched",
                    style: titleStyle,
                  ),
                  subtitle: Text(
                    formattedWatchedDate,
                    style: subtitleStyle,
                  )),
            ),
            const Divider(),
            Visibility(
              visible: _isMovieWatched,
              child: ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text(
                  "Mark Not Watched",
                ),
                onTap: () {
                  _markNotWatched();
                  widget.refreshMoviesList();
                  Navigator.of(context).pop();
                },
              ),
            ),
            Visibility(
              visible: !_isMovieWatched,
              child: ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text(
                  "Mark Watched",
                ),
                onTap: () {
                  _markWatched();
                  widget.refreshMoviesList();
                  Navigator.of(context).pop();
                },
              ),
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
