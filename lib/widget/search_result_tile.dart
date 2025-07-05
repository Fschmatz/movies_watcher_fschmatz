import 'package:flutter/material.dart';
import '../entity/movie.dart';
import '../page/store_movie.dart';

class SearchResultTile extends StatefulWidget {
  @override
  State<SearchResultTile> createState() => _SearchResultTileState();

  final Movie movie;
  final Function() loadNotWatchedMovies;

  const SearchResultTile({super.key, required this.movie, required this.loadNotWatchedMovies});
}

class _SearchResultTileState extends State<SearchResultTile> {
  Movie movie = Movie();
  double posterHeight = 110;
  double posterWidth = 70;
  BorderRadius posterBorder = BorderRadius.circular(12);

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
  }

  void _openStoreMoviePage() {
    Navigator.of(context).pop();
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StoreMovie(
            key: UniqueKey(),
            movie: movie,
            isUpdate: false,
            isFromSearch: true,
            loadNotWatchedMovies: widget.loadNotWatchedMovies,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Image? posterImage = Image.network(
      movie.getPoster()!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 30.0,
          ),
        );
      },
    );

    return InkWell(
      onTap: _openStoreMoviePage,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: posterHeight,
                width: posterWidth,
                child: ClipRRect(
                  borderRadius: posterBorder,
                  child: posterImage,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.getTitle()!,
                      maxLines: 3,
                      style: TextStyle(fontWeight: FontWeight.w500, color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      movie.getYear()!,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
