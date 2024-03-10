import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import 'package:movies_watcher_fschmatz/widget/movie_tile.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';

class MovieList extends StatefulWidget {
  NoYes watched;

  MovieList({Key? key, required this.watched}) : super(key: key);

  @override
  _MovieListState createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> _moviesList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    _getAllMoviesByWatched();
  }

  void _getAllMoviesByWatched() async {
    var resp = await dbMovies.queryAllByWatchedNoYes(widget.watched);
    _moviesList = resp;

    setState(() {
      loading = false;
    });
  }

  void refreshMoviesList() async {
    _getAllMoviesByWatched();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          (loading)
              ? const Center(child: SizedBox.shrink())
              : (_moviesList.isEmpty)
                  ? const Center(
                      child: SizedBox(
                      height: 5,
                    ))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 225),
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _moviesList.length,
                        itemBuilder: (context, index) {
                          final movie = _moviesList[index];
                          return MovieTile(
                            key: UniqueKey(),
                            movie: Movie.fromMap(movie),
                            refreshMoviesList: refreshMoviesList,
                            index: index,
                          );
                        },
                      ),
                    ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
