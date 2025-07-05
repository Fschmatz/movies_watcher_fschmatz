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
  double posterHeight = 220;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(12);
  String imbdLink = "";
  late Color dominantColorFromPoster;
  late TextStyle titleStyle;

  late TextStyle subtitleStyle;

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

  Widget buildMovieDetailTile(String title, String? value) {
    return ListTile(
      title: Text(title, style: titleStyle),
      subtitle: Text(
        value == null || value.isEmpty ? "-" : value,
        style: subtitleStyle,
      ),
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentScheme = Theme.of(context).brightness == Brightness.light
        ? ColorScheme.fromSeed(seedColor: dominantColorFromPoster)
        : ColorScheme.fromSeed(seedColor: dominantColorFromPoster, brightness: Brightness.dark);
    final theme = Theme.of(context);
    titleStyle = TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.hintColor);
    subtitleStyle = const TextStyle(fontSize: 14);

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
              FadeIn(
                duration: const Duration(milliseconds: 600),
                child: Container(
                  alignment: Alignment.center,
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
              const SizedBox(height: 5,),
              ListTile(
                title: Text(movie.getTitle()!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    )),
              ),
              Visibility(
                visible: movie.getPlot() != null,
                child: ListTile(
                    title: Text(
                  movie.getPlot()!,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: theme.hintColor),
                )),
              ),
              const Divider(
                indent: 16,
                endIndent: 16,
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3,
                children: [
                  buildMovieDetailTile("Runtime", "${movie.getRuntime()!} Min"),
                  buildMovieDetailTile("Year", movie.getYear()!),
                  buildMovieDetailTile("Director", movie.getDirector()),
                  buildMovieDetailTile("Released", movie.getReleased()),
                  buildMovieDetailTile("Country", movie.getCountry()),
                  buildMovieDetailTile("Imdb Rating", movie.getImdbRating()),
                  buildMovieDetailTile("Added", movie.formattedDateAdded),
                  movie.isMovieWatched()
                      ? buildMovieDetailTile("Watched", movie.isMovieWatched() ? movie.formattedDateWatched : null)
                      : const SizedBox.shrink(),
                ],
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
