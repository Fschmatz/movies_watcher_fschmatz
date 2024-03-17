import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import '../api_key.dart';
import '../entity/movie.dart';
import '../entity/search_result.dart';
import '../widget/search_result_tile.dart';

class SearchMovie extends StatefulWidget {
  Function() loadNotWatchedMovies;

  SearchMovie({Key? key, required this.loadNotWatchedMovies}) : super(key: key);

  @override
  _SearchMovieState createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  bool _isBeforeSearch = true;
  bool _loadingSearch = true;
  String _quantityResults = "0";
  TextEditingController ctrlSearch = TextEditingController();
  List<Movie> _moviesList = [];

  void _loadSearchResults() async {
    if (ctrlSearch.text.isNotEmpty) {
      setState(() {
        _isBeforeSearch = false;

        if (_moviesList.isNotEmpty) {
          _quantityResults = "0";
          _moviesList.clear();
        }
      });

      final String apiKey = ApiKey.key;
      final String movieName = ctrlSearch.text.trim();
      final String apiUrl = 'http://www.omdbapi.com/?type=movie&s=$movieName&apikey=$apiKey';

      try {
        final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          SearchResult searchResult = SearchResult.fromJson(jsonData);

          String? responseValue = jsonData['Response'];
          if (responseValue != null && responseValue.toLowerCase() == 'false') {
            _showNoResultsFound();
          }

          setState(() {
            _moviesList = searchResult.getSearch()!;
            _quantityResults = searchResult.getTotalResults()!;
            _loadingSearch = false;
          });
        } else {
          Fluttertoast.showToast(
            msg: "API Error",
          );
        }
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Connection timeout ",
        );
      }
    } else {
      _showNoResultsFound();
    }
  }

  void _showNoResultsFound() {
    setState(() {
      _loadingSearch = false;
    });

    Fluttertoast.showToast(
      msg: "No Results Found!",
    );
  }

  void _loseFocus() {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search movie"),
        surfaceTintColor: Theme.of(context).colorScheme.background,
        actions: [
          PopupMenuButton<int>(
              icon: const Icon(Icons.more_vert_outlined),
              itemBuilder: (BuildContext context) => <PopupMenuItem<int>>[
                    const PopupMenuItem<int>(value: 0, child: Text('Add with IMDb ID')),
                  ],
              onSelected: (int value) {
                switch (value) {
                  case 0:
                    Navigator.of(context).pop();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => StoreMovie(
                            key: UniqueKey(),
                            isUpdate: false,
                            loadNotWatchedMovies: widget.loadNotWatchedMovies,
                            movie: Movie(),
                            isFromSearch: false,
                          ),
                        ));
                    break;
                }
              })
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: TextField(
              minLines: 1,
              maxLines: 3,
              maxLength: 300,
              autofocus: true,
              textInputAction: TextInputAction.go,
              textCapitalization: TextCapitalization.sentences,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: ctrlSearch,
              onChanged: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                counterText: "",
                labelText: "Title",
                suffixIcon: ctrlSearch.text.isNotEmpty
                    ? IconButton(
                        onPressed: ctrlSearch.clear,
                        icon: const Icon(
                          Icons.clear_outlined,
                        ))
                    : null,
              ),
              onSubmitted: (_) => {_loseFocus(), _loadSearchResults()},
            ),
          ),
          _isBeforeSearch
              ? const Center(child: SizedBox.shrink())
              : Flexible(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 750),
                    child: _loadingSearch
                        ? const Center(child: CircularProgressIndicator())
                        : ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              ListTile(
                                title: Text("$_quantityResults Results",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.primary,
                                    )),
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _moviesList.length,
                                itemBuilder: (context, index) {
                                  final movie = _moviesList[index];

                                  return SearchResultTile(
                                    key: UniqueKey(),
                                    movie: movie,
                                    loadNotWatchedMovies: widget.loadNotWatchedMovies,
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                )
        ],
      ),
    );
  }
}
