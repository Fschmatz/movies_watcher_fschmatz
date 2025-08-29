import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings.dart';
import 'package:movies_watcher_fschmatz/page/stats.dart';
import 'package:movies_watcher_fschmatz/page/watched_list.dart';

import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';
import '../main.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../util/app_details.dart';
import '../widget/movie_card.dart';

class WatchList extends StatefulWidget {
  const WatchList({super.key});

  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  Future<void> _onSortListSelected(SortOption optionSelected) async {
    await store.dispatch(ChangeWatchListSortAction(optionSelected));
    await store.dispatch(LoadWatchListAction());
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
                      builder: (BuildContext context) => SearchMovie(),
                    ));
              }),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort_outlined),
            onSelected: _onSortListSelected,
            itemBuilder: (BuildContext context) {
              return SortOption.values.map((sortOption) {
                return CheckedPopupMenuItem<SortOption>(
                  value: sortOption,
                  checked: selectSelectedHomeSortOption() == sortOption,
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
                    store.dispatch(LoadWatchedListAction());
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => WatchedList(),
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
                          builder: (BuildContext context) => Settings(),
                        ));
                }
              })
        ],
      ),
      body: StoreConnector<AppState, ({bool isLoadingWatchList, List<Movie> movies})>(
        converter: (store) => (
          isLoadingWatchList: store.state.isLoadingWatchList,
          movies: store.state.watchList,
        ),
        builder: (BuildContext context, ({bool isLoadingWatchList, List<Movie> movies}) viewData) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            child: viewData.isLoadingWatchList
                ? const Center(child: CircularProgressIndicator())
                : ListView(children: [
                    viewData.movies.isEmpty
                        ? SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: GridView.builder(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 215,
                              ),
                              physics: const ScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: viewData.movies.length,
                              itemBuilder: (context, index) {
                                return MovieCard(
                                  key: UniqueKey(),
                                  movie: viewData.movies[index],
                                );
                              },
                            ),
                          ),
                    const SizedBox(height: 75)
                  ]),
          );
        },
      ),
    );
  }
}
