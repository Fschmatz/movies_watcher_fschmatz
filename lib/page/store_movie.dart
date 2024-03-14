import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:movies_watcher_fschmatz/entity/no_yes.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../api_key.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class StoreMovie extends StatefulWidget {
  @override
  State<StoreMovie> createState() => _StoreMovieState();

  Movie movie;
  bool isUpdate;
  bool isFromSearchPage;
  Function() refreshHome;

  StoreMovie({Key? key, required this.movie, required this.isUpdate, required this.isFromSearchPage, required this.refreshHome}) : super(key: key);
}

class _StoreMovieState extends State<StoreMovie> {
  Movie movie = Movie();
  MovieService movieService = MovieService();
  NoYes movieWatchedState = NoYes.NO;
  String? posterUrl;
  File? poster;
  double posterHeight = 225;
  double posterWidth = 140;
  final bool _validFieldWithoutRequired = true;
  bool _validImdbId = true;
  bool _validTitle = true;
  bool _validRuntime = true;
  bool _validYear = true;
  final TextEditingController ctrlImdbId = TextEditingController();
  final TextEditingController ctrlTitle = TextEditingController();
  final TextEditingController ctrlYear = TextEditingController();
  final TextEditingController ctrlReleased = TextEditingController();
  final TextEditingController ctrlRuntime = TextEditingController();
  final TextEditingController ctrlDirector = TextEditingController();
  final TextEditingController ctrlPlot = TextEditingController();
  final TextEditingController ctrlCountry = TextEditingController();
  final TextEditingController ctrlPoster = TextEditingController();
  final TextEditingController ctrlImdbRating = TextEditingController();
  bool isUpdate = false;

  @override
  void initState() {
    super.initState();

    if (widget.isFromSearchPage) {
      ctrlImdbId.text = widget.movie.getImdbID()!;
      _loadMovieData();
    }

    if (widget.isUpdate) {
      isUpdate = true;
      movie = widget.movie;
      _validImdbId = true;
      loadTextFields();
    }
  }

  void _loadMovieData() async {
    if (ctrlImdbId.text.isNotEmpty) {
      final String apiKey = ApiKey.key;
      final String movieId = ctrlImdbId.text.trim();
      final String apiUrl = 'http://www.omdbapi.com/?i=$movieId&apikey=$apiKey';

      try {
        final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonData = json.decode(response.body);

          String? responseValue = jsonData['Response'];
          if (responseValue != null && responseValue.toLowerCase() == 'false') {
            _showNoResultsFound();
          }

          setState(() {
            movie = Movie.fromJson(jsonData);
            posterUrl = movie.getPoster();
            _validImdbId = true;
            loadTextFields();
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
    Fluttertoast.showToast(
      msg: "No Results Found!",
    );
    setState(() {
      _validImdbId = false;
    });
  }

  void loadTextFields() {
    ctrlTitle.text = movie.getTitle() ?? '';
    ctrlYear.text = movie.getYear() ?? '';
    ctrlReleased.text = movie.getReleased() ?? '';
    ctrlRuntime.text = movie.getRuntime().toString();
    ctrlDirector.text = movie.getDirector() ?? '';
    ctrlPlot.text = movie.getPlot() ?? '';
    ctrlCountry.text = movie.getCountry() ?? '';
    ctrlPoster.text = movie.getPoster() ?? '';
    ctrlImdbRating.text = movie.getImdbRating() ?? '';
    ctrlImdbId.text = movie.getImdbID() ?? '';
    movieWatchedState = movie.getWatched()!;
  }

  Future<void> storeMovie() async {
    if(isUpdate){
      await updateMovie();
    } else {
      await saveMovie();
    }
  }

  Future<void> saveMovie() async {
    if (posterUrl != null) {
      Uint8List? base64ImageBytes;
      Uint8List? compressedPoster;
      http.Response response = await http.get(Uri.parse(posterUrl!));
      base64ImageBytes = response.bodyBytes;
      compressedPoster = await compressCoverImage(base64ImageBytes);
      movie.setPoster(base64Encode(compressedPoster));
    }

    int runtimeInt = _parseRuntime();

    movie.setTitle(ctrlTitle.text);
    movie.setYear(ctrlYear.text);
    movie.setReleased(ctrlReleased.text);
    movie.setRuntime(runtimeInt);
    movie.setDirector(ctrlDirector.text);
    movie.setPlot(ctrlPlot.text);
    movie.setCountry(ctrlCountry.text);
    movie.setImdbRating(ctrlImdbRating.text);
    movie.setImdbID(ctrlImdbId.text);
    movie.setWatched(movieWatchedState);

    await movieService.insertMovie(movie);
  }

  Future<void> updateMovie() async {
    int runtimeInt = _parseRuntime();

    movie.setTitle(ctrlTitle.text);
    movie.setYear(ctrlYear.text);
    movie.setReleased(ctrlReleased.text);
    movie.setRuntime(runtimeInt);
    movie.setDirector(ctrlDirector.text);
    movie.setPlot(ctrlPlot.text);
    movie.setCountry(ctrlCountry.text);
    movie.setImdbRating(ctrlImdbRating.text);
    movie.setWatched(movieWatchedState);

    await movieService.updateMovie(movie);
  }

  int _parseRuntime(){
    int runtimeInt = 0;

    if (ctrlRuntime.text.isNotEmpty) {
      String text = ctrlRuntime.text;
      try {
        runtimeInt = int.parse(text);
      } catch (e) {
        runtimeInt = 0;
      }
    }
    return runtimeInt;
  }

  Future<Uint8List> compressCoverImage(Uint8List list) async {
    var result = await FlutterImageCompress.compressWithList(
      list,
      minHeight: 250,
      minWidth: 220,
      quality: 90,
    );

    return result;
  }

  bool validateTextFields() {
    bool ok = true;
    if (ctrlImdbId.text.isEmpty) {
      ok = false;
      _validImdbId = false;
    }
    if (ctrlTitle.text.isEmpty) {
      ok = false;
      _validTitle = false;
    }
    if (ctrlRuntime.text.isEmpty) {
      ok = false;
      _validRuntime = false;
    }
    if (ctrlYear.text.isEmpty) {
      ok = false;
      _validYear = false;
    }
    return ok;
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    bool required,
    int maxLines,
    int maxLength,
    bool fieldValidator,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
          minLines: 1,
          maxLines: maxLines,
          maxLength: maxLength,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: TextInputType.text,
          controller: controller,
          decoration: InputDecoration(
              helperText: required ? "* Required" : "",
              labelText: label,
              border: const OutlineInputBorder(),
              errorText: (fieldValidator) ? null : "ID is empty or invalid")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).colorScheme.background,
          title: isUpdate ? const Text('Edit movie') : const Text('New movie'),
          actions: [
            Visibility(
              visible: !isUpdate,
              child: IconButton(
                  icon: const Icon(
                    Icons.refresh_outlined,
                  ),
                  onPressed: () {
                    if (ctrlImdbId.text.isNotEmpty) {
                      _loadMovieData();
                    }
                  }),
            ),
          ],
        ),
        body: ListView(children: [
          Visibility(
            visible: !isUpdate,
            child: Center(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Image.network(
                  posterUrl ?? '',
                  width: posterWidth,
                  height: posterHeight,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.medium,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return Card(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child));
                    }
                    return Card(
                      child: SizedBox(
                        width: posterWidth,
                        height: posterHeight,
                        child: const Icon(Icons.error),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Card(
                    child: SizedBox(
                      width: posterWidth,
                      height: posterHeight,
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: !isUpdate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                  minLines: 1,
                  maxLines: 1,
                  maxLength: 200,
                  onSubmitted: (e) => _loadMovieData(),
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  keyboardType: TextInputType.text,
                  controller: ctrlImdbId,
                  decoration: InputDecoration(
                      helperText: true ? "* Required" : "",
                      labelText: "IMDB ID",
                      border: const OutlineInputBorder(),
                      errorText: (_validImdbId) ? null : "Link is empty")),
            ),
          ),
          buildTextField("Title", ctrlTitle, true, 2, 200, _validTitle),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildTextField("Runtime - Min", ctrlRuntime, true, 1, 30, _validRuntime),
              ),
              Expanded(
                child: buildTextField("Year", ctrlYear, true, 1, 4, _validYear),
              ),
            ],
          ),
          buildTextField("Director", ctrlDirector, false, 2, 200, _validFieldWithoutRequired),
          buildTextField("Plot", ctrlPlot, false, 5, 500, _validFieldWithoutRequired),
          buildTextField("Country", ctrlCountry, false, 2, 200, _validFieldWithoutRequired),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: buildTextField("Released", ctrlReleased, false, 1, 30, _validFieldWithoutRequired),
              ),
              Expanded(
                child: buildTextField("IMDB Rating", ctrlImdbRating, false, 1, 4, _validFieldWithoutRequired),
              ),
            ],
          ),
          Visibility(
            visible: !isUpdate,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
              child: SegmentedButton<NoYes>(
                showSelectedIcon: false,
                segments: const <ButtonSegment<NoYes>>[
                  ButtonSegment<NoYes>(value: NoYes.NO, label: Text('Not Watched'), icon: Icon(Icons.visibility_off_outlined)),
                  ButtonSegment<NoYes>(value: NoYes.YES, label: Text('Watched'), icon: Icon(Icons.visibility_outlined)),
                ],
                selected: <NoYes>{movieWatchedState},
                onSelectionChanged: (Set<NoYes> newSelection) {
                  setState(() {
                    movieWatchedState = newSelection.first;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  if (validateTextFields()) {
                    storeMovie().then((_) => {
                      widget.refreshHome(),
                      Navigator.of(context).pop()
                    });
                  } else {
                    setState(() {
                      _validImdbId;
                      _validTitle;
                      _validRuntime;
                      _validYear;
                    });
                  }
                },
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save',
                )),
          ),
          const SizedBox(
            height: 50,
          )
        ]));
  }
}
