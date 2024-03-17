import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings.dart';
import 'package:movies_watcher_fschmatz/page/statistics.dart';
import 'package:movies_watcher_fschmatz/page/watched.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../util/app_details.dart';
import '../widget/movie_card.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({Key? key}) : super(key: key);

  @override
  _WatchlistState createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> with SingleTickerProviderStateMixin {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> _moviesList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();

    loadNotWatchedMovies();
  }

  void loadNotWatchedMovies() async {
    var resp = await dbMovies.queryAllByWatchedNoYes(NoYes.NO);
    _moviesList = resp;

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppDetails.appNameHomePage),
        actions: [
          IconButton(
              icon: const Icon(
                Icons.search_outlined,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SearchMovie(loadNotWatchedMovies: loadNotWatchedMovies),
                    ));
              }),
          PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                    const PopupMenuItem<int>(value: 0, child: Text('Watched')),
                    const PopupMenuItem<int>(value: 1, child: Text('Statistics')),
                    const PopupMenuItem<int>(value: 2, child: Text('Settings')),
                  ],
              onSelected: (int value) {
                switch (value) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Watched(
                            loadNotWatchedMovies: loadNotWatchedMovies,
                          ),
                        ));
                  case 1:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const Statistics(),
                        ));
                  case 2:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => Settings(
                            loadNotWatchedMovies: loadNotWatchedMovies,
                          ),
                        ));
                }
              })
        ],
      ),
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
                            return MovieCard(key: UniqueKey(), movie: Movie.fromMap(movie), loadNotWatchedMovies: loadNotWatchedMovies );
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
