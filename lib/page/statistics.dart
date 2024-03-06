import 'package:flutter/material.dart';
import '../dao/movie_dao.dart';
import '../entity/no_yes.dart';

class Statistics extends StatefulWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  _StatisticsState createState() => _StatisticsState();
}

class _StatisticsState extends State<Statistics> {
  final dbMovies = MovieDAO.instance;
  List<Map<String, dynamic>> moviesList = [];
  bool loading = true;
  TextStyle styleTrailing = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  int? watchedMovies = 0;
  int? notWatchedMovies = 0;
  int? watchedRuntime = 0;
  int? notWatchedRuntime = 0;

  @override
  void initState() {
    super.initState();

    _loadValues();
  }

  Future<void> _loadValues() async {
    var respNotWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.NO);
    var respWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.YES);
    var respWatchedRuntime = await dbMovies.countRuntimeByWatchedNoYes(NoYes.NO);
    var respNotWatchedRuntime = await dbMovies.countRuntimeByWatchedNoYes(NoYes.YES);

    setState(() {
      watchedMovies = respWatchedMovies ?? 0;
      watchedRuntime = respWatchedRuntime ?? 0;

      notWatchedMovies = respNotWatchedMovies ?? 0;
      notWatchedRuntime = respNotWatchedRuntime ?? 0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: loading
          ? const Center(child: SizedBox.shrink())
          : ListView(
              children: [
                ListTile(
                  title: Text("Watched", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
                ),
                ListTile(
                  leading: const Icon(Icons.movie_outlined),
                  title: const Text('Movies'),
                  trailing: Text(watchedMovies.toString(), style: styleTrailing),
                ),
                ListTile(
                  leading: const Icon(Icons.watch_later_outlined),
                  title: const Text('Runtime - Min'),
                  trailing: Text(watchedRuntime.toString(), style: styleTrailing),
                ),
                ListTile(
                  title: Text("Not Watched", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
                ),
                ListTile(
                  leading: const Icon(Icons.movie_outlined),
                  title: const Text('Movies'),
                  trailing: Text(notWatchedMovies.toString(), style: styleTrailing),
                ),
                ListTile(
                  leading: const Icon(Icons.watch_later_outlined),
                  title: const Text('Runtime - Min'),
                  trailing: Text(notWatchedRuntime.toString(), style: styleTrailing),
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
    );
  }
}
