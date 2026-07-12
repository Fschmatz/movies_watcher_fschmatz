import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies_watcher_fschmatz/util/api_configs.dart';

import '../entity/movie.dart';
import '../entity/search_result.dart';
import '../service/api_service.dart';
import '../util/toast_utils.dart';
import '../widget/empty_search_state.dart';
import '../widget/movie_list_tab_view.dart';
import '../widget/search_result_tile.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> with SingleTickerProviderStateMixin {
  bool _isSearchModeActive = false;
  bool _isBeforeSearch = true;
  bool _loadingSearch = true;
  String _quantityResults = "0";
  final String apiKey = ApiConfigs.apiKey;
  TextEditingController controllerMovieName = TextEditingController();
  TextEditingController controllerMovieYear = TextEditingController();
  List<Movie> _moviesList = [];
  int _selectedPage = 1;
  List<int> searchResultsPages = [];
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

  void _loadSearchResults() async {
    if (controllerMovieName.text.isNotEmpty) {
      setState(() {
        _isBeforeSearch = false;
        _selectedPage = 1;

        if (_moviesList.isNotEmpty) {
          _quantityResults = "0";
          _moviesList.clear();
        }
      });

      final String movieName = controllerMovieName.text.trim();
      final String? year = controllerMovieYear.text.isNotEmpty ? controllerMovieYear.text.trim() : null;

      final SearchResult? searchResult = await ApiService().searchMovies(movieName, _selectedPage, year: year);

      if (searchResult != null) {
        bool noResults = searchResult.getResponse() != null && searchResult.getResponse()!.toLowerCase() == 'false';

        if (noResults) {
          _showNoResultsFound();
          _clearDropdownMenu();
        } else {
          if (searchResult.getTotalResults() != null && int.parse(searchResult.getTotalResults()!) != 0) {
            searchResultsPages = List.generate((int.parse(searchResult.getTotalResults()!) / 20).ceil(), (index) => (index + 1));
          } else {
            _clearDropdownMenu();
          }

          setState(() {
            _moviesList = searchResult.getSearch() ?? [];
            _quantityResults = searchResult.getTotalResults() ?? "0";
            _loadingSearch = false;
          });
        }
      } else {
        setState(() {
          _loadingSearch = false;
        });
      }
    } else {
      _showNoResultsFound();
    }
  }

  void _changePageSearchResults() async {
    if (controllerMovieName.text.isNotEmpty) {
      final String movieName = controllerMovieName.text.trim();
      final String? year = controllerMovieYear.text.isNotEmpty ? controllerMovieYear.text.trim() : null;

      final SearchResult? searchResult = await ApiService().searchMovies(movieName, _selectedPage, year: year);

      if (searchResult != null) {
        setState(() {
          _moviesList = searchResult.getSearch() ?? [];
          _quantityResults = searchResult.getTotalResults() ?? "0";
          _loadingSearch = false;
        });
      } else {
        setState(() {
          _loadingSearch = false;
        });
      }
    }
  }

  void _showNoResultsFound() {
    setState(() {
      _loadingSearch = false;
    });

    ToastUtils.show(
      "No Results Found!",
    );
  }

  void _loseFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  void _clearDropdownMenu() {
    searchResultsPages.clear();
    _selectedPage = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSearchModeActive ? "Search" : "Discover"),
        actions: [
          IconButton(
            icon: Icon(_isSearchModeActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchModeActive = !_isSearchModeActive;
                if (!_isSearchModeActive) {
                  controllerMovieName.clear();
                  controllerMovieYear.clear();
                  _isBeforeSearch = true;
                  _moviesList.clear();
                  _quantityResults = "0";
                }
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_isSearchModeActive)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        minLines: 1,
                        maxLines: 1,
                        maxLength: 300,
                        autofocus: true,
                        textInputAction: TextInputAction.go,
                        textCapitalization: TextCapitalization.sentences,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: controllerMovieName,
                        onChanged: (text) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          counterText: "",
                          labelText: "Title",
                          prefixIcon: const Icon(Icons.search_outlined),
                          /* CLEAR
                        suffixIcon: controllerMovieName.text.isNotEmpty
                            ? IconButton(
                                onPressed: controllerMovieName.clear,
                                icon: const Icon(
                                  Icons.clear_outlined,
                                ))
                            : null,
                            */
                        ),
                        onSubmitted: (_) => {_loseFocus(), _loadSearchResults()},
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 120,
                      child: TextField(
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.go,
                        textCapitalization: TextCapitalization.sentences,
                        maxLengthEnforcement: MaxLengthEnforcement.enforced,
                        controller: controllerMovieYear,
                        decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(16), labelText: "Year", counterText: "", prefixIcon: Icon(Icons.calendar_today_outlined)),
                        onSubmitted: (_) => {_loseFocus(), _loadSearchResults()},
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isSearchModeActive)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TabBar(
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
                  const SizedBox(height: 12),
                  Builder(
                    builder: (context) {
                      if (_tabController.index == 0) {
                        return MovieListTabView(loading: _loadingTrending, movies: _trendingMovies);
                      } else if (_tabController.index == 1) {
                        return MovieListTabView(loading: _loadingNowPlaying, movies: _nowPlayingMovies);
                      } else {
                        return MovieListTabView(loading: _loadingUpcoming, movies: _upcomingMovies);
                      }
                    },
                  ),
                ],
              )
            else
              _isBeforeSearch
                  ? const EmptySearchState()
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 450),
                      child: _loadingSearch
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: const Center(child: CircularProgressIndicator()),
                            )
                          : Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: ListTile(
                                          title: Text("$_quantityResults Results",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Theme.of(context).colorScheme.primary,
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: searchResultsPages.isNotEmpty && searchResultsPages.length > 1,
                                        child: Row(
                                          children: [
                                            FilledButton.tonalIcon(
                                                onPressed: _selectedPage > 1 ? () => {_selectedPage--, _changePageSearchResults()} : null,
                                                icon: const Icon(Icons.navigate_before_outlined),
                                                label: const Text("Previous")),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            FilledButton.tonalIcon(
                                                onPressed: searchResultsPages.isNotEmpty &&
                                                        _selectedPage != searchResultsPages[searchResultsPages.length - 1]
                                                    ? () => {_selectedPage++, _changePageSearchResults()}
                                                    : null,
                                                icon: const Icon(Icons.navigate_next_outlined),
                                                label: const Text("Next")),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListView.separated(
                                  separatorBuilder: (BuildContext context, int index) => const Divider(
                                    height: 0,
                                  ),
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _moviesList.length,
                                  itemBuilder: (context, index) {
                                    final movie = _moviesList[index];

                                    return SearchResultTile(
                                      key: UniqueKey(),
                                      movie: movie,
                                    );
                                  },
                                ),
                              ],
                            ),
                    ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
