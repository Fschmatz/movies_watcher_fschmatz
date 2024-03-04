import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/search_page.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings_page.dart';
import 'package:movies_watcher_fschmatz/page/statistics.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
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
    const Statistics()
  ];

  void refreshHome() {
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
        const Statistics()
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
                              SearchPage(refreshHome: refreshHome),
                            ));
                      }),

                  IconButton(
                      icon: const Icon(
                        Icons.settings_outlined,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const SettingsPage(),
                            ));
                      }),
                ],
              ),
            ];
          },
          body: PageTransitionSwitcher(
              duration: const Duration(milliseconds: 700),
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
              child: _pageList[_currentIndex]),
        ),
      ),
      /*floatingActionButton: Visibility(
        visible: _currentIndex != 2,
        child: FloatingActionButton(
          heroTag: null,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => StoreMovie(
                      key: UniqueKey(),
                      isUpdate: false,
                      refreshHome: refreshHome),
                ));
          },
          child: const Icon(
            Icons.add_outlined,
          ),
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
