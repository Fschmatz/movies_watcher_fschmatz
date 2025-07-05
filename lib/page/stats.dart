import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../enum/no_yes.dart';
import '../service/movie_service.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
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
  int watchedMoviesCurrentYear = 0;
  int watchedRuntimeCurrentYear = 0;

  @override
  void initState() {
    super.initState();

    _loadValues();
  }

  Future<void> _loadValues() async {
    final results = await Future.wait([
      dbMovies.countMoviesByWatchedNoYes(NoYes.no),
      dbMovies.countMoviesByWatchedNoYes(NoYes.yes),
      dbMovies.sumRuntimeByWatchedNoYes(NoYes.yes),
      dbMovies.sumRuntimeByWatchedNoYes(NoYes.no),
      dbMovies.countMovieWatchedCurrentMonth(),
      dbMovies.sumRuntimeWatchedCurrentMonth(),
      //dbMovies.countMovieAddedCurrentMonth(),
    ]);

    countNotWatchedMovies = results[0] as int;
    countWatchedMovies = results[1] as int;
    watchedRuntime = results[2] as int;
    notWatchedRuntime = results[3] as int;
    watchedMoviesCurrentMonth = results[4] as int;
    watchedRuntimeCurrentMonth = results[5] as int;
    //addedMoviesCurrentMonth = results[6] as int;

    await _generateMapMoviesByMonthAndYear();
    await _sortMoviesByMonthAndYear();
    await _setCurrentYearStats();

    setState(() => loading = false);
  }

  Future<void> _generateMapMoviesByMonthAndYear() async {
    List<Movie> watchedMoviesList = await MovieService().queryAllByWatchedForStatsPage(NoYes.yes);

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

  Future<void> _setCurrentYearStats() async {
    String currentYear = DateTime.now().year.toString();

    moviesByMonthAndYear.forEach((key, movies) {
      if (key.endsWith(currentYear)) {
        for (Movie movie in movies) {
          watchedRuntimeCurrentYear += movie.getRuntime()!;
          watchedMoviesCurrentYear++;
        }
      }
    });
  }

  void _showMoviesWatchedOnMonthAndYearDialog(BuildContext context, String monthYear, List<Movie> movies) {
    int sumRuntimesMonthYear = movies.fold<int>(0, (sum, movie) => sum + (movie.getRuntime() ?? 0));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("$monthYear - $sumRuntimesMonthYear Min"),
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

  Widget buildCompactListTile(String title, String trailingText) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(title),
      trailing: Text(trailingText, style: styleTrailing),
    );
  }

  Widget buildCompactListTileTitle(String title, TextStyle style) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      title: Text(title, style: style),
    );
  }

  Widget buildStatusCard(Color backgroundColor, Color textColor, String title, int? movies, int? runtime) {
    return SizedBox(
      height: 110,
      child: Card(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "$movies movie${movies == 1 ? "" : "s"}",
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
              SizedBox(height: 6),
              Text(
                "$runtime minute${runtime == 1 ? "" : "s"}",
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color accent = Theme.of(context).colorScheme.primary;
    Color cardBackgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
    Color cardTextColor = Theme.of(context).colorScheme.onTertiaryContainer;
    Color currentCardBackgroundColor = Theme.of(context).colorScheme.primaryContainer;
    Color currentCardTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    TextStyle titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stats"),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: loading
            ? const Center(child: SizedBox.shrink())
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Expanded(child: buildStatusCard(cardBackgroundColor, cardTextColor, 'Total watched', countWatchedMovies, watchedRuntime)),
                        SizedBox(width: 4),
                        Expanded(
                            child:
                                buildStatusCard(cardBackgroundColor, cardTextColor, 'Total not watched', countNotWatchedMovies, notWatchedRuntime)),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                            child: buildStatusCard(currentCardBackgroundColor, currentCardTextColor, 'Watched current month', watchedMoviesCurrentMonth,
                                watchedRuntimeCurrentMonth)),
                        SizedBox(width: 4),
                        Expanded(
                            child: buildStatusCard(currentCardBackgroundColor, currentCardTextColor, 'Watched current year', watchedMoviesCurrentYear,
                                watchedRuntimeCurrentYear)),
                      ],
                    ),
                  ),

                  // buildCompactListTileTitle('Not Watched', titleTextStyle),
                  // buildCompactListTile('Movies', countNotWatchedMovies.toString()),
                  // buildCompactListTile('Runtime - Min', notWatchedRuntime.toString()),
                  // const Divider(),
                  // buildCompactListTileTitle('Watched Current Year', titleTextStyle),
                  // buildCompactListTile('Movies Watched', watchedMoviesCurrentYear.toString()),
                  // buildCompactListTile('Runtime Watched - Min', watchedRuntimeCurrentYear.toString()),
                  // const Divider(),
                  // buildCompactListTileTitle('Watched Current Month', titleTextStyle),
                  // buildCompactListTile('Movies Watched', watchedMoviesCurrentMonth.toString()),
                  // buildCompactListTile('Runtime Watched - Min', watchedRuntimeCurrentMonth.toString()),
                  // buildCompactListTile('Movies Added', addedMoviesCurrentMonth.toString()),
                  // const Divider(),
                  // buildCompactListTileTitle('Watched All', titleTextStyle),
                  // buildCompactListTile('Movies', countWatchedMovies.toString()),
                  // buildCompactListTile('Runtime - Min', watchedRuntime.toString()),
                  SizedBox(height: 12),
                  const Divider(),
                  buildCompactListTileTitle('Watched by Month/Year', titleTextStyle),
                  Column(
                    children: moviesByMonthAndYear.entries.map((entry) {
                      String monthYear = entry.key;
                      List<Movie> moviesOnThisMonthYear = entry.value;
                      return ListTile(
                        title: Text(monthYear),
                        trailing: Text('${moviesOnThisMonthYear.length}', style: styleTrailing),
                        onTap: () => _showMoviesWatchedOnMonthAndYearDialog(context, monthYear, moviesOnThisMonthYear),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 75,
                  ),
                ],
              ),
      ),
    );
  }
}
