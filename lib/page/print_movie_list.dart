import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies_watcher_fschmatz/dao/movie_dao.dart';
import 'package:movies_watcher_fschmatz/enum/no_yes.dart';

class PrintMovieList extends StatefulWidget {
  const PrintMovieList({super.key});

  @override
  State<PrintMovieList> createState() => _PrintMovieListState();
}

class _PrintMovieListState extends State<PrintMovieList> {

  final dbMovie = MovieDAO.instance;
  bool loading = true;
  String formattedList = '';

  @override
  void initState() {
    super.initState();

    getPlaylists();
  }

  void getPlaylists() async {
    List<Map<String, dynamic>> listMoviesWatched = await dbMovie.queryAllByWatchedNoYes(NoYes.no);
    List<Map<String, dynamic>> listMoviesNotWatched = await dbMovie.queryAllByWatchedNoYes(NoYes.yes);

    formattedList += 'NOT WATCHED - ${listMoviesWatched.length} Movie(s)\n';
    for (int i = 0; i < listMoviesWatched.length; i++) {
      formattedList += "\n• ${listMoviesWatched[i]['title']}\n";
      formattedList += listMoviesWatched[i]['imdbID'] + "\n";
    }

    formattedList += '\n#######\n\n';

    formattedList += 'WATCHED - ${listMoviesNotWatched.length} Movie(s)\n';
    for (int i = 0; i < listMoviesNotWatched.length; i++) {
      formattedList += "\n• ${listMoviesNotWatched[i]['title']}\n";
      formattedList += listMoviesNotWatched[i]['imdbID'] + "\n";
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Print movies'),
        actions: [
          TextButton(
            child: const Text(
              "Copy",
            ),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: formattedList));
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        children: [
          (loading)
              ? const SizedBox.shrink()
              : SelectableText(
                  formattedList,
                  style: const TextStyle(fontSize: 16),
                ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
