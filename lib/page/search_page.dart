import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../api_key.dart';
import '../entity/movie.dart';
import '../entity/search_result.dart';
import '../widget/search_result_tile.dart';

class SearchPage extends StatefulWidget {
  Function() refreshHome;

  SearchPage({Key? key, required this.refreshHome}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool _isBeforeSearch = true;
  bool _loadingSearch = true;
  String _quantityResults = "0";
  TextEditingController ctrlSearch = TextEditingController();
  List<Movie> _moviesList = [];

  /*
  final List<Item> _itemList = [];

  String resultsText = "";
  List<String> listHistoryString = [];
  bool loadingHistory = true;
  bool _showSearchHistory = true;

  List<Map<String, dynamic>> titleList = [];
 */

  @override
  void initState() {
    super.initState();
  }

  void _loadSearchResults() async {
    if (ctrlSearch.text.isNotEmpty) {
      setState(() {
        _isBeforeSearch = false;
      });

      final String apiKey = ApiKey.key;
      final String movieName = ctrlSearch.text;

      final String apiUrl =
          'http://www.omdbapi.com/?type=movie&s=$movieName&apikey=$apiKey';

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        SearchResult searchResult = SearchResult.fromJson(jsonData);

        String? responseValue = jsonData['Response'];
        if (responseValue != null && responseValue.toLowerCase() == 'false') {
          _showNoResultsFound();
        }

        for (Movie movie in searchResult.getSearch()!) {
          print(movie.toString());
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
    } else {
      _showNoResultsFound();
    }
  }

  void _showNoResultsFound() {
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
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
            child: TextField(
              minLines: 1,
              maxLines: 3,
              maxLength: 350,
              autofocus: true,
              textInputAction: TextInputAction.go,
              textCapitalization: TextCapitalization.sentences,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: ctrlSearch,
              onChanged: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
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
                        : ListView.builder(
                            itemCount: _moviesList.length,
                            itemBuilder: (context, index) {
                              final movie = _moviesList[index];

                              return SearchResultTile(
                                key: UniqueKey(),
                                movie: movie,
                                refreshHome: widget.refreshHome,
                              );
                            },
                          ),
                  ),
                )
        ],
      ),
    );
  }
}
