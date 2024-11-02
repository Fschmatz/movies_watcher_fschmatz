import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings.dart';
import 'package:movies_watcher_fschmatz/page/stats.dart';
import 'package:movies_watcher_fschmatz/page/watched_list.dart';
import 'package:movies_watcher_fschmatz/service/movie_service.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../util/app_details.dart';
import '../widget/movie_card.dart';

class WatchList extends StatefulWidget {
  const WatchList({super.key});

  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {

  List<Movie> _moviesList = [];
  bool loading = true;
  List<String> optionsOrderBy = [
    "title asc",
    "title desc",
    "runtime asc",
    "runtime desc",
    "year asc",
    "year desc",
    "dateAdded asc",
    "dateAdded desc"
  ];

  @override
  void initState() {
    super.initState();

    loadNotWatchedMovies();
  }

  void loadNotWatchedMovies() async {
    _moviesList = await MovieService().queryAllByWatchedNoYesAndConvertToList(NoYes.NO);

    setState(() {
      loading = false;
    });
  }

  void sortListByOption(int optionSelected) async {
    setState(() {
      loading = true;
    });

    _moviesList = await MovieService().queryAllByWatchedNoYesAndOrderByAndConvertToList(NoYes.NO, optionsOrderBy[optionSelected]);

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
                Icons.add_outlined,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => SearchMovie(loadNotWatchedMovies: loadNotWatchedMovies),
                    ));
              }),
          PopupMenuButton<int>(
              icon: const Icon(Icons.sort_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                    const PopupMenuItem<int>(value: 0, child: Text('Title Asc')),
                    const PopupMenuItem<int>(value: 1, child: Text('Title Desc')),
                    const PopupMenuItem<int>(value: 2, child: Text('Runtime Asc')),
                    const PopupMenuItem<int>(value: 3, child: Text('Runtime Desc')),
                    const PopupMenuItem<int>(value: 4, child: Text('Year Asc')),
                    const PopupMenuItem<int>(value: 5, child: Text('Year Desc')),
                    const PopupMenuItem<int>(value: 6, child: Text('Date Added Asc')),
                    const PopupMenuItem<int>(value: 7, child: Text('Date Added Desc')),
                  ],
              onSelected: (int value) {
                switch (value) {
                  case 0:
                    sortListByOption(value);
                  case 1:
                    sortListByOption(value);
                  case 2:
                    sortListByOption(value);
                  case 3:
                    sortListByOption(value);
                  case 4:
                    sortListByOption(value);
                  case 5:
                    sortListByOption(value);
                  case 6:
                    sortListByOption(value);
                  case 7:
                    sortListByOption(value);
                }
              }),
          PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                    const PopupMenuItem<int>(value: 0, child: Text('Watched')),
                    const PopupMenuItem<int>(value: 1, child: Text('Stats')),
                    const PopupMenuItem<int>(value: 2, child: Text('Settings')),
                  ],
              onSelected: (int value) {
                switch (value) {
                  case 0:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => WatchedList(
                            loadNotWatchedMovies: loadNotWatchedMovies,
                          ),
                        ));
                  case 1:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const Stats(),
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
                            return MovieCard(key: UniqueKey(), movie: _moviesList[index], loadNotWatchedMovies: loadNotWatchedMovies);
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
