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

  int? watchedMovies = 0;
  int? notWatchedMovies = 0;
  int? watchedRuntime = 0;
  int? notWatchedRuntime = 0;

  @override
  void initState() {
    super.initState();

    _loadValues();
  }

  Future<void>   _loadValues() async {
    var respNotWatchedMovies = await  dbMovies.countMoviesByWatchedNoYes(NoYes.NO);
   var respWatchedMovies = await dbMovies.countMoviesByWatchedNoYes(NoYes.YES);
    var respWatchedRuntime =  await  dbMovies.countRuntimeByWatchedNoYes(NoYes.NO);
    var respNotWatchedRuntime =  await dbMovies.countRuntimeByWatchedNoYes(NoYes.YES);

    setState(() {
      watchedMovies = respWatchedMovies ?? 0;
      notWatchedMovies = respNotWatchedMovies ?? 0;
      watchedRuntime = respWatchedRuntime ?? 0;
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
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Watched Movies'),
                  trailing: Text(watchedMovies.toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Watched Runtime'),
                  trailing: Text(watchedRuntime.toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Not Watched Movies'),
                  trailing: Text(notWatchedMovies.toString()),
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Not Watched Movies'),
                  trailing: Text(notWatchedRuntime.toString()),
                ),

                const SizedBox(
                  height: 50,
                ),
              ],
            ),
    );
  }
}
/*

Widget cardEstatisticas(String title, int? valorLendo, int? valorParaLer,
    int? valorLidos, Color accent) {
  TextStyle styleTrailing = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
  );
  int soma = (valorLidos! + valorParaLer! + valorLendo!);

  return Column(
    children: [
      ListTile(
        title: Text(title,
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500, color: accent)),
      ),
      ListTile(
        leading: const Icon(Icons.book_outlined),
        title: const Text('Lendo'),
        trailing: Text(valorLendo.toString(), style: styleTrailing),
      ),
      ListTile(
        leading: const Icon(Icons.bookmark_outline_outlined),
        title: const Text('Para Ler'),
        trailing: Text(valorParaLer.toString(), style: styleTrailing),
      ),
      ListTile(
        leading: const Icon(Icons.task_outlined),
        title: const Text('Lidos'),
        trailing: Text(valorLidos.toString(), style: styleTrailing),
      ),
      ListTile(
        leading: const Icon(Icons.format_list_bulleted_outlined),
        title: const Text('Total'),
        trailing: Text(
          soma.toString(),
          style: styleTrailing,
        ),
      ),
    ],
  );}
*/


