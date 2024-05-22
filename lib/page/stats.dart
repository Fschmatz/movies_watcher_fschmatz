import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../service/movie_service.dart';

class Stats extends StatefulWidget {
  const Stats({Key? key}) : super(key: key);

  @override
  _StatsState createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> moviesList = [];
  Map<String, List<Movie>> moviesByMonthAndYear = {};
  bool loading = true;
  TextStyle styleTrailing = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  int? countWatchedMovies = 0;
  int? countNotWatchedMovies = 0;
  int? watchedRuntime = 0;
  int? notWatchedRuntime = 0;
  int? watchedMoviesCurrentMonth = 0;
  int? watchedRuntimeCurrentMonth = 0;
  int? addedMoviesCurrentMonth = 0;

  @override
  void initState() {
    super.initState();

    _loadValues();
  }

  Future<void> _loadValues() async {
    countNotWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.NO);
    countWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.YES);
    watchedRuntime = await dbMovies.sumRuntimeByWatchedNoYes(NoYes.YES);
    notWatchedRuntime = await dbMovies.sumRuntimeByWatchedNoYes(NoYes.NO);
    watchedMoviesCurrentMonth = await dbMovies.countMovieWatchedCurrentMonth();
    watchedRuntimeCurrentMonth = await dbMovies.sumRuntimeWatchedCurrentMonth();
    addedMoviesCurrentMonth = await dbMovies.countMovieAddedCurrentMonth();

    await _generateMapMoviesByMonthAndYear();
    await _sortMoviesByMonthAndYear();

    setState(() {
      loading = false;
    });
  }

  Future<void> _generateMapMoviesByMonthAndYear() async {
    List<Movie> watchedMoviesList = await MovieService().queryAllByWatchedNoYesAndConvertToList(NoYes.YES);

    for (Movie movie in watchedMoviesList) {
      String yearMonthKey = Jiffy.parse(movie.getDateWatched()!).format(pattern: 'MM/yyyy');
      if (!moviesByMonthAndYear.containsKey(yearMonthKey)) {
        moviesByMonthAndYear[yearMonthKey] = [];
      }
      moviesByMonthAndYear[yearMonthKey]!.add(movie);
    }
  }

  Future<void> _sortMoviesByMonthAndYear() async {
    List<String> keys = moviesByMonthAndYear.keys.toList();
    keys.sort((a, b) => Jiffy.parse(b, pattern: 'MM/yyyy').isBefore(Jiffy.parse(a, pattern: 'MM/yyyy')) ? -1 : 1);

    Map<String, List<Movie>> sortedMoviesByMonthAndYear = {};
    for (String key in keys) {
      sortedMoviesByMonthAndYear[key] = moviesByMonthAndYear[key]!;
    }

    moviesByMonthAndYear = sortedMoviesByMonthAndYear;
  }

  void _showMoviesWatchedOnMonthAndYearDialog(BuildContext context, String monthYear, List<Movie> movies) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(monthYear),
          content: SizedBox(
            height: 250,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text("• ${movies[index].getTitle()!}"),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Color accent = Theme.of(context).colorScheme.primary;

    StreamController<Map<String, List<Movie>>> moviesStreamController = StreamController<Map<String, List<Movie>>>();
    moviesStreamController.add(moviesByMonthAndYear);
    moviesStreamController.close();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: loading
            ? const Center(child: SizedBox.shrink())
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      child: Column(
                        children: [
                          ListTile(
                            title: Text("Current Month", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
                          ),
                          ListTile(
                            title: const Text('Movies Watched'),
                            trailing: Text(watchedMoviesCurrentMonth.toString(), style: styleTrailing),
                          ),
                          ListTile(
                            title: const Text('Runtime Watched - Min'),
                            trailing: Text(watchedRuntimeCurrentMonth.toString(), style: styleTrailing),
                          ),
                          ListTile(
                            title: const Text('Movies Added'),
                            trailing: Text(addedMoviesCurrentMonth.toString(), style: styleTrailing),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text("Not Watched", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.movie_outlined),
                    title: const Text('Movies'),
                    trailing: Text(countNotWatchedMovies.toString(), style: styleTrailing),
                  ),
                  ListTile(
                    leading: const Icon(Icons.watch_later_outlined),
                    title: const Text('Runtime - Min'),
                    trailing: Text(notWatchedRuntime.toString(), style: styleTrailing),
                  ),
                  ListTile(
                    title: Text("Watched", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
                  ),
                  ListTile(
                    leading: const Icon(Icons.movie_outlined),
                    title: const Text('Movies'),
                    trailing: Text(countWatchedMovies.toString(), style: styleTrailing),
                  ),
                  ListTile(
                    leading: const Icon(Icons.watch_later_outlined),
                    title: const Text('Runtime - Min'),
                    trailing: Text(watchedRuntime.toString(), style: styleTrailing),
                  ),
                  moviesByMonthAndYear.isEmpty
                      ? const SizedBox.shrink()
                      : const ListTile(
                          leading: Icon(Icons.calendar_month_outlined),
                          title: Text('Movies by Month/Year'),
                        ),
                  StreamBuilder<Map<String, List<Movie>>>(
                    stream: moviesStreamController.stream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      Map<String, List<Movie>> moviesByYearAndMonth = snapshot.data!;
                      return ListView.builder(
                        itemCount: moviesByYearAndMonth.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          String monthYear = moviesByYearAndMonth.keys.elementAt(index);
                          List<Movie> moviesOnThisMonthYear = moviesByYearAndMonth[monthYear]!;

                          return ListTile(
                            leading: const Text(""),
                            title: Text(monthYear),
                            trailing: Text('${moviesOnThisMonthYear.length}', style: styleTrailing),
                            onTap: () {
                              _showMoviesWatchedOnMonthAndYearDialog(context, monthYear, moviesOnThisMonthYear);
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 100,
                  ),
                ],
              ),
      ),
    );
  }
}
