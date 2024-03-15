import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/search_movie.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings.dart';
import 'package:movies_watcher_fschmatz/page/statistics.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../util/app_details.dart';
import 'movie_list.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  late List<Widget> _pageList;

  @override
  void initState() {
    super.initState();

    _loadHomeTabs();
  }

  void _loadHomeTabs() {
    _pageList = [
      MovieList(
        key: UniqueKey(),
        watched: NoYes.NO,
      ),
    ];
  }

  Future<void> refreshHome() async {
    _loadHomeTabs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppDetails.appNameHomePage),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.search_outlined,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => SearchMovie(refreshHome: refreshHome),
                      ));
                }),
            IconButton(
                icon: const Icon(
                  Icons.fact_check_outlined,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => MovieList(
                          watched: NoYes.YES,
                        ),
                      ));
                }),
            PopupMenuButton<int>(
                icon: const Icon(Icons.more_vert_outlined),
                itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                      const PopupMenuItem<int>(value: 0, child: Text('Add with IMDb ID')),
                      const PopupMenuItem<int>(value: 1, child: Text('Statistics')),
                      const PopupMenuItem<int>(value: 2, child: Text('Settings')),
                    ],
                onSelected: (int value) {
                  switch (value) {
                    case 0:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => StoreMovie(
                              key: UniqueKey(),
                              isUpdate: false,
                              refreshHome: refreshHome,
                              movie: Movie(),
                              isFromSearchPage: false,
                            ),
                          ));
                      break;
                    case 1:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const Statistics(),
                          ));
                    case 2:
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => Settings(
                              refreshHome: refreshHome,
                            ),
                          ));
                  }
                })
          ],
        ),
        body: _pageList[0]);
  }
}
