import 'dart:convert';

import 'package:flutter/material.dart';
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
  double posterHeight = 170;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(8);
  String imbdLink = "";

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
    imbdLink = "https://www.imdb.com/title/${movie.getImdbID()}";
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
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
                      Navigator.of(context).pop();
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
            Center(
              child: (movie.getPoster() == null)
                  ? SizedBox(
                      height: posterHeight,
                      width: posterWidth,
                      child: Icon(
                        Icons.image_outlined,
                        size: 30,
                        color: Theme.of(context).hintColor,
                      ),
                    )
                  : SizedBox(
                      height: posterHeight,
                      width: posterWidth,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          base64Decode(movie.getPoster()!),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        ),
                      ),
                    ),
            ),
            Text(movie.toString()),
            const Divider(),
            Visibility(
              visible: movie.getWatched() == NoYes.YES,
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
              visible: movie.getWatched() == NoYes.NO,
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
          ],
        ),
      ),
    );
  }
}
