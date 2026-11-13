import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/discover_page.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings.dart';
import 'package:movies_watcher_fschmatz/page/stats.dart';
import 'package:movies_watcher_fschmatz/page/watched_list.dart';
import 'package:movies_watcher_fschmatz/util/app_constants.dart';

import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';
import '../enum/watch_list_filter.dart';
import '../main.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../redux/build_context_extension.dart';
import '../redux/selectors.dart';
import '../widget/movie_grid.dart';
import '../widget/watch_list_filter_chips.dart';

class WatchList extends StatefulWidget {
  const WatchList({super.key});

  @override
  State<WatchList> createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  WatchListFilter _selectedFilter = WatchListFilter.all;

  List<Movie> _filterMovies(List<Movie> movies) {
    if (_selectedFilter == WatchListFilter.all) return movies;
    return movies.where((m) => _selectedFilter.matches(m)).toList();
  }

  Future<void> _onSortListSelected(SortOption optionSelected) async {
    await store.dispatch(ChangeWatchListSortAction(optionSelected));
    await store.dispatch(LoadWatchListAction());
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewData = context.select((AppState state) => (
          isLoadingWatchList: state.isLoadingWatchList,
          movies: state.watchList,
          showMovieNameOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.showMovieNameOnCardAppParameter),
          showRuntimeChipOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.showRuntimeChipOnCardAppParameter),
          formatRuntimeOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.formatRuntimeAppParameter),
          gridSize: selectParameterValueByKeyAsInt(state, AppConstants.gridSizeAppParameter, defaultValue: 3),
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.appNameHomePage),
        actions: [
          IconButton(
            tooltip: 'Search Movie',
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => const SearchMovie()),
              );
            },
          ),
          IconButton(
            tooltip: 'Discover',
            icon: const Icon(Icons.trending_up_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (BuildContext context) => const DiscoverPage()),
              );
            },
          ),
          MenuAnchor(
            builder: (BuildContext context, MenuController controller, Widget? child) {
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
              /*   MenuItemButton(
                leadingIcon: const Icon(Icons.search_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => const SearchMovie()),
                  );
                },
                child: const Text('Search'),
              ),*/
              MenuItemButton(
                leadingIcon: const Icon(Icons.visibility_outlined),
                onPressed: () {
                  store.dispatch(LoadWatchedListAction());
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => WatchedList()),
                  );
                },
                child: const Text('Watched'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.analytics_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => const Stats()),
                  );
                },
                child: const Text('Stats'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(Icons.settings_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (BuildContext context) => Settings()),
                  );
                },
                child: const Text('Settings'),
              ),
              const PopupMenuDivider(),
              SubmenuButton(
                leadingIcon: const Icon(Icons.sort_outlined),
                menuChildren: SortOption.values.map((sortOption) {
                  final bool isSelected = selectSelectedHomeSortOption(store.state) == sortOption;
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
      body: MovieGrid(
        animationKey: _selectedFilter,
        header: WatchListFilterChips(
          selectedFilter: _selectedFilter,
          onFilterChanged: (newFilter) {
            setState(() {
              _selectedFilter = newFilter;
            });
          },
        ),
        movies: _filterMovies(viewData.movies),
        isLoading: viewData.isLoadingWatchList,
        showMovieName: viewData.showMovieNameOnCard,
        showRuntimeChip: viewData.showRuntimeChipOnCard,
        formatRuntime: viewData.formatRuntimeOnCard,
        gridSize: viewData.gridSize,
      ),
    );
  }
}
