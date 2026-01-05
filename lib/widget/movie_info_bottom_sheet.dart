import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../entity/movie.dart';
import '../page/store_movie.dart';
import '../service/movie_service.dart';
import 'movie_detail_tile.dart';

class MovieInfoBottomSheet extends StatelessWidget {
  final Movie movie;
  final bool? isFromWatched;

  const MovieInfoBottomSheet({
    super.key,
    required this.movie,
    this.isFromWatched,
  });

  Future<void> _delete() async {
    await MovieService().deleteMovie(movie);
    _addDelay();
  }

  Future<void> _markWatched() async {
    await MovieService().setWatched(movie);
    _addDelay();
  }

  Future<void> _markNotWatched() async {
    await MovieService().setNotWatched(movie);
    _addDelay();
  }

  Future<void> _addDelay() async {
    await Future.delayed(Duration(milliseconds: 250));
  }

  Future<void> _shareImdbLink() async {
    Share.share("https://www.imdb.com/title/${movie.getImdbID()}");
  }

  Future<void> _openEditPage(BuildContext context) async {
    Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StoreMovie(
            movie: movie,
            isUpdate: true,
            isFromSearch: false,
          ),
        ));
  }

  void showDialogConfirmDelete(BuildContext context) {
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
                _delete();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
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
    Color primaryIconButtonColor = theme.colorScheme.onPrimaryContainer;
    Color primaryIconButtonBackground = theme.colorScheme.primaryContainer;
    Color secondaryIconButtonColor = theme.colorScheme.onSecondaryContainer;
    Color secondaryIconButtonBackground = theme.colorScheme.secondaryContainer;
    RoundedRectangleBorder secondaryIconButtonBorderRadius = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    return SafeArea(
      child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Wrap(children: <Widget>[
              ListTile(
                title: Text(movie.getTitle()!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    )),
              ),
              const Divider(
                endIndent: 16,
                indent: 16,
              ),
              Visibility(
                visible: movie.getPlot() != null,
                child: ListTile(
                    title: Text(
                  movie.getPlot()!,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                )),
              ),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 3.5,
                children: [
                  MovieDetailTile(title: "Runtime", value: "${movie.getRuntime()!} Min"),
                  MovieDetailTile(title: "Year", value: movie.getYear()!),
                  MovieDetailTile(title: "Director", value: movie.getDirector()),
                  MovieDetailTile(title: "Released", value: movie.getReleased()),
                  MovieDetailTile(title: "Country", value: movie.getCountry()),
                  MovieDetailTile(title: "Imdb Rating", value: movie.getImdbRating()),
                  MovieDetailTile(title: "Added", value: movie.formattedDateAdded),
                  movie.isMovieWatched()
                      ? MovieDetailTile(title: "Watched", value: movie.isMovieWatched() ? movie.formattedDateWatched : null)
                      : const SizedBox.shrink(),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: Icon(movie.isMovieWatched() ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                        label: Text(movie.isMovieWatched() ? "Not Watched" : "Watched"),
                        onPressed: () {
                          (movie.isMovieWatched() ? _markNotWatched() : _markWatched());
                          Navigator.of(context).pop();
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: primaryIconButtonBackground,
                          foregroundColor: primaryIconButtonColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.share_outlined),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _shareImdbLink();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: secondaryIconButtonBackground,
                        foregroundColor: secondaryIconButtonColor,
                        shape: secondaryIconButtonBorderRadius,
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () {
                        _openEditPage(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: secondaryIconButtonBackground,
                        foregroundColor: secondaryIconButtonColor,
                        shape: secondaryIconButtonBorderRadius,
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton.filledTonal(
                      icon: const Icon(
                        Icons.delete_outline_outlined,
                      ),
                      onPressed: () {
                        showDialogConfirmDelete(context);
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: secondaryIconButtonBackground,
                        foregroundColor: secondaryIconButtonColor,
                        shape: secondaryIconButtonBorderRadius,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          )),
    );
  }
}
