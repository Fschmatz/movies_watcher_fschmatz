import 'package:animations/animations.dart';
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

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<Widget> _pageList = [
    MovieList(
      key: UniqueKey(),
      watched: NoYes.NO,
    ),
    MovieList(
      key: UniqueKey(),
      watched: NoYes.YES,
    ),
    Statistics(
      key: UniqueKey()
    )
  ];

  Future<void> refreshHome() async{
    setState(() {
      _pageList = [
        MovieList(
          key: UniqueKey(),
          watched: NoYes.NO,
        ),
        MovieList(
          key: UniqueKey(),
          watched: NoYes.YES,
        ),
         Statistics(
          key: UniqueKey(),
        )
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text(AppDetails.appNameHomePage),
                surfaceTintColor: Theme.of(context).colorScheme.background,
                pinned: false,
                floating: true,
                snap: true,
                actions: [
                  IconButton(
                      icon: const Icon(
                        Icons.search_outlined,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SearchMovie(
                                      refreshHome: refreshHome),
                            ));
                      }),
                  PopupMenuButton<int>(
                      icon: const Icon(Icons.more_vert_outlined),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<int>>[
                            const PopupMenuItem<int>(
                                value: 0, child: Text('Add with IMDb ID')),
                            const PopupMenuItem<int>(
                                value: 1, child: Text('Settings')),
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
                                  builder: (BuildContext context) =>
                                      Settings(
                                    refreshHome: refreshHome,),
                                ));
                        }
                      })
                ],
              ),
            ];
          },
          body: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 650),
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
              child: _pageList[_currentIndex]),
        ),
      ),
     /* floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) =>
                    SearchMovie(
                        refreshHome: refreshHome),
              ));
        },
        child: const Icon(
          Icons.search_outlined,
        ),
      ),*/
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(
              Icons.movie,
            ),
            label: 'Movies',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(
              Icons.fact_check,
            ),
            label: 'Watched',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined),
            selectedIcon: Icon(
              Icons.insert_chart,
            ),
            label: 'Statistics',
          ),
        ],
      ),
    );
  }
}
