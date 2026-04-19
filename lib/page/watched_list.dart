import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import '../redux/actions.dart';
import '../widget/movie_grid.dart';

import '../entity/movie.dart';
import '../main.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../service/movie_service.dart';
import '../util/app_constants.dart';

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
    return selectSelectedYearWatchedList();
  }

  Future<void> _onYearSelected(String selectedYear) async {
    await store.dispatch(ChangeWatchedListSelectedYearAction(selectedYear));
    await store.dispatch(LoadWatchedListAction());
  }

  @override
  Widget build(BuildContext context) {
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
        body: StoreConnector<AppState, ({bool isLoadingWatchedList, List<Movie> movies, bool showMovieNameOnCard, bool showRuntimeChipOnCard})>(
          converter: (store) {
            return (
              isLoadingWatchedList: store.state.isLoadingWatchedList,
              movies: store.state.watchedList,
              showMovieNameOnCard: selectParameterValueByKeyAsBoolean('showMovieNameOnCard'),
              showRuntimeChipOnCard: selectParameterValueByKeyAsBoolean('showRuntimeChipOnCard'),
            );
          },
          builder: (BuildContext context, ({bool isLoadingWatchedList, List<Movie> movies, bool showMovieNameOnCard, bool showRuntimeChipOnCard}) viewData) {
            return MovieGrid(
              movies: viewData.movies,
              isLoading: viewData.isLoadingWatchedList,
              showMovieName: viewData.showMovieNameOnCard,
              showRuntimeChip: viewData.showRuntimeChipOnCard,
              isFromWatched: true,
            );
          },
        ));
  }
}
