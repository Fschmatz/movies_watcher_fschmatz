import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../service/movie_service.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
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

  @override
  void initState() {
    super.initState();

    _loadValues();
  }

  Future<void> _loadValues() async {
    var respCountNotWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.NO);
    var respCountWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.YES);
    var respWatchedRuntime = await dbMovies.countRuntimeByWatchedNoYes(NoYes.YES);
    var respNotWatchedRuntime = await dbMovies.countRuntimeByWatchedNoYes(NoYes.NO);

    await generateMapMoviesByMonthAndYear();

    setState(() {
      countWatchedMovies = respCountWatchedMovies ?? 0;
      watchedRuntime = respWatchedRuntime ?? 0;
      countNotWatchedMovies = respCountNotWatchedMovies ?? 0;
      notWatchedRuntime = respNotWatchedRuntime ?? 0;
      loading = false;
    });
  }

  Future<void> generateMapMoviesByMonthAndYear() async {
    List<Movie> watchedMoviesList = await MovieService().queryAllByWatchedNoYesAndConvertToList(NoYes.YES);

    for (Movie movie in watchedMoviesList) {
      String yearMonthKey = Jiffy.parse(movie.getDateWatched()!).format(pattern: 'MM/yyyy');
      if (!moviesByMonthAndYear.containsKey(yearMonthKey)) {
        moviesByMonthAndYear[yearMonthKey] = [];
      }
      moviesByMonthAndYear[yearMonthKey]!.add(movie);
    }
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
        title: const Text("Statistics"),
      ),
      body: loading
          ? const Center(child: SizedBox.shrink())
          : ListView(
              children: [
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
    );
  }
}
