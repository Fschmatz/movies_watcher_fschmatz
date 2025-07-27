import 'package:async_redux/async_redux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/redux/actions.dart';
import 'package:movies_watcher_fschmatz/widget/movie_card.dart';

import '../entity/movie.dart';
import '../main.dart';
import '../redux/app_state.dart';
import '../redux/selectors.dart';
import '../service/movie_service.dart';

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
        body: StoreConnector<AppState, List<Movie>>(
          converter: (store) {
            return selectWatchedListMovies();
          },
          builder: (context, movies) {
            return ListView(
              children: [
                (movies.isEmpty)
                    ? const Center(
                        child: SizedBox(
                        height: 5,
                      ))
                    : FadeIn(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 180),
                            physics: const ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: movies.length,
                            itemBuilder: (context, index) {
                              return MovieCard(
                                key: UniqueKey(),
                                movie: movies[index],
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
            );
          },
        ));
  }
}
