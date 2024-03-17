import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/widget/movie_card.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';

class Watched extends StatefulWidget {
  Function()? loadNotWatchedMovies;

  Watched({Key? key, this.loadNotWatchedMovies,}) : super(key: key);

  @override
  _WatchedState createState() => _WatchedState();
}

class _WatchedState extends State<Watched> {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> _moviesList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadWatchedMovies();
  }

  void loadWatchedMovies() async {
    var resp = await dbMovies.queryAllByWatchedNoYes(NoYes.YES);
    _moviesList = resp;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Watched")),
      body: ListView(
        children: [
          (loading)
              ? const Center(child: SizedBox.shrink())
              : (_moviesList.isEmpty)
                  ? const Center(
                      child: SizedBox(
                      height: 5,
                    ))
                  : FadeIn(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 225),
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _moviesList.length,
                          itemBuilder: (context, index) {
                            final movie = _moviesList[index];
                            return MovieCard(
                              key: UniqueKey(),
                              movie: Movie.fromMap(movie),
                              loadWatchedMovies: loadWatchedMovies,
                              loadNotWatchedMovies: widget.loadNotWatchedMovies,
                              isFromWatched: true,
                            );
                          },
                        ),
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
