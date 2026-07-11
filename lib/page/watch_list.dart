import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings.dart';
import 'package:movies_watcher_fschmatz/page/stats.dart';
import 'package:movies_watcher_fschmatz/page/watched_list.dart';
import 'package:movies_watcher_fschmatz/util/app_constants.dart';

import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';
import '../main.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../widget/movie_grid.dart';

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
        title: Text(AppConstants.appNameHomePage),
        actions: [
          IconButton(
            tooltip: 'Add Movie',
            icon: const Icon(Icons.add_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => SearchMovie()),
              );
            },
          ),
          MenuAnchor(
            builder: (BuildContext context, MenuController controller,
                Widget? child) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                icon: const Icon(Icons.more_vert_outlined),
              );
            },
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.visibility_outlined),
                onPressed: () {
                  store.dispatch(LoadWatchedListAction());
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => WatchedList()),
                  );
                },
                child: const Text('Watched'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.analytics_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => const Stats()),
                  );
                },
                child: const Text('Stats'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => Settings()),
                  );
                },
                child: const Text('Settings'),
              ),
              const PopupMenuDivider(),
              SubmenuButton(
                leadingIcon: const Icon(Icons.sort_outlined),
                menuChildren: SortOption.values.map((sortOption) {
                  final bool isSelected =
                      selectSelectedHomeSortOption(store.state) == sortOption;
                  return MenuItemButton(
                    leadingIcon: Icon(
                      Icons.check,
                      color: isSelected ? null : Colors.transparent,
                    ),
                    onPressed: () {
                      _onSortListSelected(sortOption);
                    },
                    child: Text(sortOption.name),
                  );
                }).toList(),
                child: const Text('Sort By'),
              ),
            ],
          ),
        ],
      ),
      body: StoreConnector<
          AppState,
          ({
            bool isLoadingWatchList,
            List<Movie> movies,
            bool showMovieNameOnCard,
            bool showRuntimeChipOnCard
          })>(
        converter: (store) {
          return (
            isLoadingWatchList: store.state.isLoadingWatchList,
            movies: store.state.watchList,
            showMovieNameOnCard: selectParameterValueByKeyAsBoolean(
                store.state, AppConstants.showMovieNameOnCardAppParameter),
            showRuntimeChipOnCard: selectParameterValueByKeyAsBoolean(
                store.state, AppConstants.showRuntimeChipOnCardAppParameter),
          );
        },
        builder: (BuildContext context,
            ({
              bool isLoadingWatchList,
              List<Movie> movies,
              bool showMovieNameOnCard,
              bool showRuntimeChipOnCard
            }) viewData) {
          return MovieGrid(
            movies: viewData.movies,
            isLoading: viewData.isLoadingWatchList,
            showMovieName: viewData.showMovieNameOnCard,
            showRuntimeChip: viewData.showRuntimeChipOnCard,
          );
        },
      ),
      /* floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => SearchMovie(),
              ));
        },
        icon: const Icon(Icons.search_outlined),
        label: const Text(
          "Add Movie",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),*/
    );
  }
}
