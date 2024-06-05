import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/widget/movie_card.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../service/movie_service.dart';

class WatchedList extends StatefulWidget {
  Function()? loadNotWatchedMovies;

  WatchedList({Key? key, this.loadNotWatchedMovies,}) : super(key: key);

  @override
  _WatchedListState createState() => _WatchedListState();
}

class _WatchedListState extends State<WatchedList> {
  List<Movie> _moviesList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadWatchedMovies();
  }

  void loadWatchedMovies() async {
    _moviesList = await MovieService().queryAllByWatchedNoYesAndConvertToList(NoYes.YES);

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
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 236),
                          physics: const ScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: _moviesList.length,
                          itemBuilder: (context, index) {
                            return MovieCard(
                              key: UniqueKey(),
                              movie: _moviesList[index],
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
