import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/widget/movie_info_dialog.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class MovieTile extends StatefulWidget {
  @override
  _MovieTileState createState() => _MovieTileState();

  Movie movie;
  Function() refreshMoviesList;
  int index;

  MovieTile({Key? key, required this.movie, required this.refreshMoviesList, required this.index})
      : super(key: key);
}

class _MovieTileState extends State<MovieTile> {
  MovieService movieService = MovieService();
  Movie movie = Movie();
  double posterHeight = 160;
  double posterWidth = 150;
  BorderRadius posterBorder = BorderRadius.circular(8);

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
  }

  void _openMovieInfoDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) => MovieInfoDialog(movie: movie , refreshMoviesList: widget.refreshMoviesList,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: posterBorder,
        onTap: _openMovieInfoDialog,
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
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
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
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500,color: Theme.of(context).hintColor),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
