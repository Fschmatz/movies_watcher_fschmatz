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
  List<Map<String, dynamic>> moviesList = [];
  final dbMovies = MovieDAO.instance;
  bool loading = true;

  @override
  void initState() {
    getLivrosState();
    super.initState();
  }

  void getLivrosState() async {
    var resp = await dbMovies.queryAllByWatchedNoYes(widget.watched);
    moviesList = resp;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ListView(
          children: [
            (loading)
                ? const Center(child: SizedBox.shrink())
                : (moviesList.isEmpty)
                    ? const Center(
                        child: SizedBox(
                        height: 5,
                      ))
                    : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 5
                        ),
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: moviesList.length,
                        itemBuilder: (context, index) {
                          final movie = moviesList[index];
                          return MovieTile(key: UniqueKey(),movie: Movie.fromMap(movie));
                        },
                      ),
                    ),
          ],
        ));
  }
}

