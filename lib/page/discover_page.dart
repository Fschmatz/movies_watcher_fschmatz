import 'package:flutter/material.dart';

import '../entity/movie.dart';
import '../service/api_service.dart';
import '../widget/movie_list_tab_view.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> with SingleTickerProviderStateMixin {
  bool _loadingTrending = true;
  List<Movie> _trendingMovies = [];
  bool _loadingNowPlaying = true;
  List<Movie> _nowPlayingMovies = [];
  bool _loadingUpcoming = true;
  List<Movie> _upcomingMovies = [];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialMovies() async {
    final searchResultTrending = await ApiService().getTrendingMovies();
    if (mounted) {
      setState(() {
        _trendingMovies = searchResultTrending?.getSearch() ?? [];
        _loadingTrending = false;
      });
    }
    final searchResultNowPlaying = await ApiService().getNowPlayingMovies();
    if (mounted) {
      setState(() {
        _nowPlayingMovies = searchResultNowPlaying?.getSearch() ?? [];
        _loadingNowPlaying = false;
      });
    }
    final searchResultUpcoming = await ApiService().getUpcomingMovies();
    if (mounted) {
      setState(() {
        _upcomingMovies = searchResultUpcoming?.getSearch() ?? [];
        _loadingUpcoming = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text("Discover"),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: "Trending"),
            Tab(text: "Now Playing"),
            Tab(text: "Upcoming"),
          ],
        ),
      ),
      body: Builder(
        builder: (context) {
          if (_tabController.index == 0) {
            return MovieListTabView(key: const ValueKey(0), loading: _loadingTrending, movies: _trendingMovies);
          } else if (_tabController.index == 1) {
            return MovieListTabView(key: const ValueKey(1), loading: _loadingNowPlaying, movies: _nowPlayingMovies);
          } else {
            return MovieListTabView(key: const ValueKey(2), loading: _loadingUpcoming, movies: _upcomingMovies);
          }
        },
      ),
    );
  }
}
