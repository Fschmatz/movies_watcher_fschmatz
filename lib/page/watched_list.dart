import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:movies_watcher_fschmatz/widget/movie_card.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class WatchedList extends StatefulWidget {
  final Function()? loadNotWatchedMovies;

  const WatchedList({
    super.key,
    this.loadNotWatchedMovies,
  });

  @override
  State<WatchedList> createState() => _WatchedListState();
}

class _WatchedListState extends State<WatchedList> {
  List<Movie> _moviesList = [];
  bool _isLoading = true;
  String _selectedYear = '';
  List<String> _yearsWithWatchedMovies = [];

  @override
  void initState() {
    super.initState();

    _setCurrentYearOnLoad();
    _loadYearsWithWatchedMovies();
    _loadWatchedMoviesOnStart();
  }

  Future<void> _loadWatchedMoviesOnStart() async {
    await _loadWatchedMovies();

    _changeLoadingState(false);
  }

  Future<void> _loadWatchedMovies() async {
    _moviesList = await MovieService().findWatchedByYear(_selectedYear);
  }

  void _setCurrentYearOnLoad() {
    _selectedYear = _getCurrentYear();
  }

  void _loadYearsWithWatchedMovies() async {
    _yearsWithWatchedMovies = await MovieService().findAllYearsWithWatchedMovies();

    if (!_yearsWithWatchedMovies.contains(_getCurrentYear())) {
      _yearsWithWatchedMovies.add(_getCurrentYear());
    }

    if (_yearsWithWatchedMovies.length > 1) {
      _yearsWithWatchedMovies.sort((a, b) => int.parse(b).compareTo(int.parse(a)));
    }
  }

  String _getCurrentYear() {
    return DateTime.now().year.toString();
  }

  Future<void> _onYearSelected(String selectedYear) async {
    _selectedYear = selectedYear;
    _changeLoadingState(true);
    await _loadWatchedMovies();
    _changeLoadingState(false);
  }

  void _changeLoadingState(bool value) {
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Watched - $_selectedYear"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_alt_outlined),
            onSelected: _onYearSelected,
            itemBuilder: (BuildContext context) {
              return _yearsWithWatchedMovies.map((year) {
                return CheckedPopupMenuItem<String>(
                  value: year,
                  checked: _selectedYear == year,
                  child: Text(year),
                );
              }).toList();
            },
          )
        ],
      ),
      body: ListView(
        children: [
          (_isLoading)
              ? const Center(child: SizedBox.shrink())
              : (_moviesList.isEmpty)
              ? const Center(
              child: SizedBox(
                height: 5,
              ))
              : FadeIn(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeIn,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 236),
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: _moviesList.length,
                itemBuilder: (context, index) {
                  return MovieCard(
                    key: UniqueKey(),
                    movie: _moviesList[index],
                    loadWatchedMovies: _loadWatchedMoviesOnStart,
                    loadNotWatchedMovies: widget.loadNotWatchedMovies,
                    isFromWatched: true,
                  );
                },
              ),
            ),
          ),
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
