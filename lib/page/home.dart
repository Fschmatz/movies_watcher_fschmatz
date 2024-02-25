import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/page/settings/settings_page.dart';
import 'package:movies_watcher_fschmatz/page/statistics.dart';

import '../util/app_details.dart';
import 'movies.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;
  List<Widget> _pageList = [
    Movies(
      key: UniqueKey(),
      bookState: 1,
    ),
    Movies(
      key: UniqueKey(),
      bookState: 2,
    ),
    const Statistics()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                title: Text(AppDetails.appName),
                pinned: false,
                floating: true,
                snap: true,
                actions: [
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
              transitionBuilder: (child, animation, secondaryAnimation) =>
                  FadeThroughTransition(
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    child: child,
                  ),
              child: _pageList[_currentIndex]),
        ),
      ),
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
            label: 'Watch',
          ),
          NavigationDestination(
            icon: Icon(Icons.visibility_off_outlined),
            selectedIcon: Icon(
              Icons.visibility_off,
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
