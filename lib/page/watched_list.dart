import 'package:flutter/material.dart';

import '../main.dart';
import '../redux/actions.dart';
import '../redux/app_state.dart';
import '../redux/build_context_extension.dart';
import '../redux/selectors.dart';
import '../service/movie_service.dart';
import '../util/app_constants.dart';
import '../widget/movie_grid.dart';

class WatchedList extends StatefulWidget {
  final Function()? loadNotWatchedMovies;

  const WatchedList({
    super.key,
    this.loadNotWatchedMovies,
  });

  @override
  State<WatchedList> createState() => _WatchedListState();
}

class _WatchedListState extends State<WatchedList> {
  List<String> _yearsWithWatchedMovies = [];

  @override
  void initState() {
    super.initState();

    _loadYearsWithWatchedMovies();
  }

  void _loadYearsWithWatchedMovies() async {
    _yearsWithWatchedMovies = await MovieService().findAllYearsWithWatchedMovies();

    if (!_yearsWithWatchedMovies.contains(_getSelectedYear())) {
      _yearsWithWatchedMovies.add(_getSelectedYear());
    }

    if (_yearsWithWatchedMovies.length > 1) {
      _yearsWithWatchedMovies.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    }
  }

  String _getSelectedYear() {
    return selectSelectedYearWatchedList(store.state);
  }

  Future<void> _onYearSelected(String selectedYear) async {
    await store.dispatch(ChangeWatchedListSelectedYearAction(selectedYear));
    await store.dispatch(LoadWatchedListAction());
  }

  @override
  Widget build(BuildContext context) {
    final viewData = context.select((AppState state) => (
          isLoadingWatchedList: state.isLoadingWatchedList,
          movies: state.watchedList,
          showMovieNameOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.showMovieNameOnCardAppParameter),
          showRuntimeChipOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.showRuntimeChipOnCardAppParameter),
          formatRuntimeOnCard: selectParameterValueByKeyAsBoolean(state, AppConstants.formatRuntimeAppParameter),
          gridSize: selectParameterValueByKeyAsInt(state, AppConstants.gridSizeAppParameter, defaultValue: 3),
        ));

    return Scaffold(
        appBar: AppBar(
          title: Text("Watched"),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_alt_outlined),
              onSelected: _onYearSelected,
              itemBuilder: (BuildContext context) {
                return _yearsWithWatchedMovies.map((year) {
                  return CheckedPopupMenuItem<String>(
                    value: year,
                    checked: _getSelectedYear() == year,
                    child: Text(year),
                  );
                }).toList();
              },
            )
          ],
        ),
        body: MovieGrid(
          movies: viewData.movies,
          isLoading: viewData.isLoadingWatchedList,
          showMovieName: viewData.showMovieNameOnCard,
          showRuntimeChip: viewData.showRuntimeChipOnCard,
          formatRuntime: viewData.formatRuntimeOnCard,
          gridSize: viewData.gridSize,
          isFromWatched: true,
        ));
  }
}
