import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings.dart';
import 'package:movies_watcher_fschmatz/page/stats.dart';
import 'package:movies_watcher_fschmatz/page/watched_list.dart';
import 'package:movies_watcher_fschmatz/service/movie_service.dart';
import '../entity/movie.dart';
import '../enum/no_yes.dart';
import '../enum/sort_watch_list_option.dart';
import '../util/app_details.dart';
import '../widget/movie_card.dart';

class WatchList extends StatefulWidget {
  const WatchList({super.key});

  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  List<Movie> _moviesList = [];
  bool _isLoading = true;
  SortOption _sortOptionSelected = SortOption.titleAsc;

  @override
  void initState() {
    super.initState();

    _loadNotWatchedMoviesOnStart();
  }

  Future<void> _loadNotWatchedMoviesOnStart() async {
    await _loadNotWatchedMovies();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadNotWatchedMovies() async {
    _moviesList = await MovieService().queryAllByWatchedNoYesAndOrderByAndConvertToList(NoYes.no, _sortOptionSelected.sqlOrderBy);
  }

  Future<void> sortListByOption(SortOption optionSelected) async {
    setState(() {
      _isLoading = true;
    });

    _sortOptionSelected = optionSelected;
    await _loadNotWatchedMovies();

    setState(() {
      _isLoading = false;
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
                      builder: (BuildContext context) => SearchMovie(loadNotWatchedMovies: _loadNotWatchedMoviesOnStart),
                    ));
              }),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_outlined),
            onSelected: sortListByOption,
            itemBuilder: (BuildContext context) {
              return SortOption.values.map((sortOption) {
                return CheckedPopupMenuItem<SortOption>(
                  value: sortOption,
                  checked: _sortOptionSelected == sortOption,
                  child: Text(sortOption.name),
                );
              }).toList();
            },
          ),
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
                            loadNotWatchedMovies: _loadNotWatchedMoviesOnStart,
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
                            loadNotWatchedMovies: _loadNotWatchedMoviesOnStart,
                          ),
                        ));
                }
              })
        ],
      ),
      body: ListView(
        children: [
          (_isLoading)
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
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 185),
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: _moviesList.length,
                itemBuilder: (context, index) {
                  return MovieCard(key: UniqueKey(), movie: _moviesList[index], loadNotWatchedMovies: _loadNotWatchedMoviesOnStart);
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
