import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:movies_watcher_fschmatz/key_api.dart';
import 'package:movies_watcher_fschmatz/page/store_movie.dart';
import 'package:movies_watcher_fschmatz/util/app_constants.dart';

import '../entity/movie.dart';
import '../entity/search_result.dart';
import '../widget/search_result_tile.dart';

class SearchMovie extends StatefulWidget {
  const SearchMovie({super.key});

  @override
  State<SearchMovie> createState() => _SearchMovieState();
}

class _SearchMovieState extends State<SearchMovie> {
  bool _isBeforeSearch = true;
  bool _loadingSearch = true;
  String _quantityResults = "0";
  final String apiKey = KeyApi.key;
  TextEditingController controllerMovieName = TextEditingController();
  TextEditingController controllerMovieYear = TextEditingController();
  List<Movie> _moviesList = [];
  int _selectedPage = 1;
  List<int> searchResultsPages = [];

  String _formatApiUrl() {
    final String movieName = controllerMovieName.text.trim();
    final String? year = controllerMovieYear.text.isNotEmpty ? controllerMovieYear.text.trim() : null;
    String apiUrl = '${AppConstants.apiUrl}&s=$movieName&page=$_selectedPage&apikey=$apiKey';

    if (year != null) {
      apiUrl = "$apiUrl&y=$year";
    }

    return apiUrl;
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

      try {
        final response = await http.get(Uri.parse(_formatApiUrl())).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          SearchResult searchResult = SearchResult.fromJson(jsonData);
          String? responseValue = jsonData['Response'];
          bool noResults = responseValue != null && responseValue.toLowerCase() == 'false';

          if (noResults) {
            _showNoResultsFound();
            _clearDropdownMenu();
          } else {
            if (searchResult.getTotalResults() != null && int.parse(searchResult.getTotalResults()!) != 0) {
              searchResultsPages = List.generate((int.parse(searchResult.getTotalResults()!) / 10).ceil(), (index) => (index + 1));
            } else {
              _clearDropdownMenu();
            }

            setState(() {
              _moviesList = searchResult.getSearch()!;
              _quantityResults = searchResult.getTotalResults()!;
              _loadingSearch = false;
            });
          }
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

  void _changePageSearchResults() async {
    if (controllerMovieName.text.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(_formatApiUrl())).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          SearchResult searchResult = SearchResult.fromJson(jsonData);

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

  void _clearDropdownMenu() {
    searchResultsPages.clear();
    _selectedPage = 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
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
                            movie: Movie(),
                            isFromSearch: false,
                          ),
                        ));
                    break;
                }
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
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
                controller: controllerMovieName,
                onChanged: (text) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  border: const OutlineInputBorder(),
                  counterText: "",
                  hintText: "Title",
                  prefixIcon: const Icon(Icons.search_outlined),
                  suffixIcon: controllerMovieName.text.isNotEmpty
                      ? IconButton(
                          onPressed: controllerMovieName.clear,
                          icon: const Icon(
                            Icons.clear_outlined,
                          ))
                      : null,
                ),
                onSubmitted: (_) => {_loseFocus(), _loadSearchResults()},
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 150,
                    child: TextField(
                      maxLength: 4,
                      textInputAction: TextInputAction.go,
                      textCapitalization: TextCapitalization.sentences,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      controller: controllerMovieYear,
                      decoration: InputDecoration(
                          contentPadding: const EdgeInsets.all(16),
                          hintText: "Year",
                          counterText: "",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_outlined)),
                      onSubmitted: (_) => {_loseFocus(), _loadSearchResults()},
                    ),
                  ),
                ],
              ),
            ),
            _isBeforeSearch
                ? const Center(child: SizedBox.shrink())
                : AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    child: _loadingSearch
                        ? const Center(child: CircularProgressIndicator())
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
                                          OutlinedButton.icon(
                                              onPressed: _selectedPage > 1 ? () => {_selectedPage--, _changePageSearchResults()} : null,
                                              icon: const Icon(Icons.navigate_before_outlined),
                                              label: const Text("Previous")),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          OutlinedButton.icon(
                                              onPressed:
                                                  searchResultsPages.isNotEmpty && _selectedPage != searchResultsPages[searchResultsPages.length - 1]
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
