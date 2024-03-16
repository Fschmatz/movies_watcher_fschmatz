import 'package:flutter/material.dart';
import '../entity/movie.dart';
import '../page/store_movie.dart';

class SearchResultTile extends StatefulWidget {
  @override
  _SearchResultTileState createState() => _SearchResultTileState();

  Movie movie;
  Function() refreshHome;

  SearchResultTile({Key? key, required this.movie, required this.refreshHome})
      : super(key: key);
}

class _SearchResultTileState extends State<SearchResultTile> {
  Movie movie = Movie();
  double posterHeight = 80;
  double posterWidth = 50;
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
              isFromSearchPage: true,
              refreshHome: widget.refreshHome),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 5, 16, 5),
      child: InkWell(
        borderRadius: posterBorder,
        onTap: _openStoreMoviePage,
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
                  child: Image.network(
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
                  ),
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
                      style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor),
                    ),
                    const SizedBox(height: 5,),
                    Text(
                      movie.getYear()!,
                      style:
                      TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
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
