import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/entity/no_yes.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

import '../entity/movie.dart';
import '../service/movie_service.dart';

class MovieTile extends StatefulWidget {
  @override
  _MovieTileState createState() => _MovieTileState();

  Movie movie;
  Function() refreshMovieList;
  Function(int) removeMovieFromList;
  int index;

  MovieTile({Key? key, required this.movie, required this.refreshMovieList, required this.removeMovieFromList, required this.index})
      : super(key: key);
}

class _MovieTileState extends State<MovieTile> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 170;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(8);
  bool deleteAfterTimer = true;
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

  void _delete() async {
    movieService.deleteMovie(movie);
    widget.refreshMovieList();
  }

  void _markWatched() {
    movieService.setWatched(movie);
  }

  void _markNotWatched() {
    movieService.setNotWatched(movie);
  }

  void openBottomMenu() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    title: Text(
                      movie.getTitle()!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(),
                  Visibility(
                    visible: movie.getWatched() == NoYes.NO,
                    child: ListTile(
                      leading: const Icon(Icons.visibility_outlined),
                      title: const Text(
                        "Mark Watched",
                      ),
                      onTap: () {
                        _markWatched();
                        widget.refreshMovieList();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  Visibility(
                    visible: movie.getWatched() == NoYes.YES,
                    child: ListTile(
                      leading: const Icon(Icons.visibility_off_outlined),
                      title: const Text(
                        "Mark Not Watched",
                      ),
                      onTap: () {
                        _markNotWatched();
                        widget.refreshMovieList();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.share_outlined),
                    title: const Text(
                      "Share",
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      Share.share(imbdLink);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.open_in_new_outlined),
                    title: const Text(
                      "View in IMDb",
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      _launchBrowser();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.movie_edit),
                    title: const Text(
                      "Edit",
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                     /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => StoreMovie(
                              movie: movie,
                              isUpdate: true,
                              isFromSearchPage: false,
                              refreshHome: widget.refreshMovieList,
                            ),
                          ));*/
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_outlined),
                    title: const Text(
                      "Delete",
                    ),
                    onTap: () {
                      widget.removeMovieFromList(widget.index);
                      Navigator.of(context).pop();
                      _showSnackBar();

                      Timer(const Duration(seconds: 5), () {
                        if (deleteAfterTimer) {
                          _delete();
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Movie deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            deleteAfterTimer = false;
            widget.refreshMovieList();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: posterBorder,
        onTap: openBottomMenu,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          (movie.getPoster() == null)
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
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Theme.of(context).hintColor),
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
                style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
