import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';

import '../dao/movie_dao.dart';
import '../entity/movie.dart';
import '../enum/no_yes.dart';
import '../service/movie_service.dart';
import '../widget/stats_month_tile.dart';
import '../widget/stats_old_year_card.dart';
import '../widget/stats_status_card.dart';

class Stats extends StatefulWidget {
  const Stats({super.key});

  @override
  State<Stats> createState() => _StatsState();
}

class _StatsState extends State<Stats> {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> moviesList = [];
  bool loading = true;
  int? countWatchedMovies = 0;
  int? countNotWatchedMovies = 0;
  int? watchedRuntime = 0;
  int? notWatchedRuntime = 0;
  int? watchedMoviesCurrentMonth = 0;
  int? watchedRuntimeCurrentMonth = 0;
  int? addedMoviesCurrentMonth = 0;
  int watchedMoviesCurrentYear = 0;
  int watchedRuntimeCurrentYear = 0;
  Map<String, List<Movie>> currentYearMovies = {};
  Map<String, List<Movie>> olderYearMovies = {};
  Map<String, List<Movie>> olderMoviesByYear = {};

  @override
  void initState() {
    super.initState();
    _loadValues();
  }

  Future<void> _loadValues() async {
    final stats = await dbMovies.findForStats();

    countNotWatchedMovies = stats["countNotWatched"]!;
    countWatchedMovies = stats["countWatched"]!;
    watchedRuntime = stats["runtimeWatched"]!;
    notWatchedRuntime = stats["runtimeNotWatched"]!;
    watchedMoviesCurrentMonth = stats["watchedThisMonth"]!;
    watchedRuntimeCurrentMonth = stats["runtimeThisMonth"]!;

    await _generateMapMoviesByMonthAndYear();
    await _sortMoviesByMonthAndYear();
    await _setCurrentYearStats();
    _groupOlderMoviesByYear();

    setState(() => loading = false);
  }

  Future<void> _generateMapMoviesByMonthAndYear() async {
    final watchedMoviesList = await MovieService().queryAllByWatchedForStatsPage(NoYes.yes);

    final int currentYear = DateTime.now().year;

    currentYearMovies.clear();
    olderYearMovies.clear();

    for (final movie in watchedMoviesList) {
      final date = Jiffy.parse(movie.getDateWatched()!);
      final int movieYear = date.year;
      final String yearMonthKey = date.format(pattern: 'MM/yyyy');

      final targetMap = (movieYear == currentYear) ? currentYearMovies : olderYearMovies;

      targetMap.putIfAbsent(yearMonthKey, () => []);
      targetMap[yearMonthKey]!.add(movie);
    }
  }

  Future<void> _sortMoviesByMonthAndYear() async {
    currentYearMovies = _sortYearMonthMap(currentYearMovies);
    olderYearMovies = _sortYearMonthMap(olderYearMovies);
  }

  Map<String, List<Movie>> _sortYearMonthMap(Map<String, List<Movie>> input) {
    List<String> keys = input.keys.toList();
    keys.sort((a, b) => Jiffy.parse(b, pattern: 'MM/yyyy').isBefore(Jiffy.parse(a, pattern: 'MM/yyyy')) ? -1 : 1);

    Map<String, List<Movie>> sorted = {};
    for (String key in keys) {
      sorted[key] = input[key]!;
    }

    return sorted;
  }

  Future<void> _setCurrentYearStats() async {
    String currentYear = DateTime.now().year.toString();

    currentYearMovies.forEach((key, movies) {
      if (key.endsWith(currentYear)) {
        for (Movie movie in movies) {
          watchedRuntimeCurrentYear += movie.getRuntime()!;
          watchedMoviesCurrentYear++;
        }
      }
    });
  }

  void _groupOlderMoviesByYear() {
    olderMoviesByYear.clear();

    for (final entry in olderYearMovies.entries) {
      // key is "MM/yyyy", extract year part
      final year = entry.key.split('/').last;
      olderMoviesByYear.putIfAbsent(year, () => []);
      olderMoviesByYear[year]!.addAll(entry.value);
    }

    // Sort years descending
    final sortedKeys = olderMoviesByYear.keys.toList()..sort((a, b) => int.parse(b).compareTo(int.parse(a)));

    final sorted = <String, List<Movie>>{};
    for (final key in sortedKeys) {
      sorted[key] = olderMoviesByYear[key]!;
    }
    olderMoviesByYear = sorted;
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
                  child: Text("• ${movies[index].getTitle()!} - ${movies[index].getRuntime()!} Min"),
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
    final Color accent = Theme.of(context).colorScheme.primary;
    final Color cardBackgroundColor = Theme.of(context).colorScheme.tertiaryContainer;
    final Color cardTextColor = Theme.of(context).colorScheme.onTertiaryContainer;
    final Color currentCardBackgroundColor = Theme.of(context).colorScheme.primaryContainer;
    final Color currentCardTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final TextStyle titleTextStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: accent, letterSpacing: 0.5);

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
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsStatusCard(
                            backgroundColor: cardBackgroundColor,
                            textColor: cardTextColor,
                            title: 'Total Watched',
                            movies: countWatchedMovies,
                            runtime: watchedRuntime,
                            icon: Icons.check_circle_outline_rounded,
                          ),
                        ),
                        Expanded(
                          child: StatsStatusCard(
                            backgroundColor: cardBackgroundColor,
                            textColor: cardTextColor,
                            title: 'Total Watchlist',
                            movies: countNotWatchedMovies,
                            runtime: notWatchedRuntime,
                            icon: Icons.hourglass_empty_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: StatsStatusCard(
                            backgroundColor: currentCardBackgroundColor,
                            textColor: currentCardTextColor,
                            title: 'This Month',
                            movies: watchedMoviesCurrentMonth,
                            runtime: watchedRuntimeCurrentMonth,
                            icon: Icons.calendar_month_outlined,
                          ),
                        ),
                        Expanded(
                          child: StatsStatusCard(
                            backgroundColor: currentCardBackgroundColor,
                            textColor: currentCardTextColor,
                            title: 'This Year',
                            movies: watchedMoviesCurrentYear,
                            runtime: watchedRuntimeCurrentYear,
                            icon: Icons.calendar_today_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text('Watched - Current Year by Month', style: titleTextStyle),
                  ),
                  ...currentYearMovies.entries.map((entry) {
                    final monthYear = entry.key;
                    final moviesOnThisMonthYear = entry.value;
                    return StatsMonthTile(
                      monthYear: monthYear,
                      movies: moviesOnThisMonthYear,
                      onTap: () => _showMoviesWatchedOnMonthAndYearDialog(context, monthYear, moviesOnThisMonthYear),
                    );
                  }),
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    title: Text('Watched - Previous Years', style: titleTextStyle),
                  ),
                  if (olderMoviesByYear.isNotEmpty) ...[
                    ...olderMoviesByYear.entries.map((entry) => StatsOldYearCard(
                          year: entry.key,
                          movies: entry.value,
                        )),
                  ],
                  const SizedBox(height: 75),
                ],
              ),
      ),
    );
  }
}
