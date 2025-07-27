import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:movies_watcher_fschmatz/enum/no_yes.dart';

import '../api_key.dart';
import '../entity/movie.dart';
import '../service/movie_service.dart';

class StoreMovie extends StatefulWidget {
  final Movie movie;
  final bool isUpdate;
  final bool isFromSearch;
  final bool? isFromWatched;

  const StoreMovie({super.key, required this.movie, required this.isUpdate, required this.isFromSearch, this.isFromWatched});

  @override
  State<StoreMovie> createState() => _StoreMovieState();
}

class _StoreMovieState extends State<StoreMovie> {
  Movie _movie = Movie();
  NoYes _movieWatchedState = NoYes.no;
  String? _posterUrl;
  File? _poster;
  final double _posterHeight = 220;
  final double _posterWidth = 150;
  final bool _validFieldWithoutRequired = true;
  bool _validImdbId = true;
  bool _validTitle = true;
  bool _validRuntime = true;
  bool _validYear = true;
  final TextEditingController _ctrlImdbId = TextEditingController();
  final TextEditingController _ctrlTitle = TextEditingController();
  final TextEditingController _ctrlYear = TextEditingController();
  final TextEditingController _ctrlReleased = TextEditingController();
  final TextEditingController _ctrlRuntime = TextEditingController();
  final TextEditingController _ctrlDirector = TextEditingController();
  final TextEditingController _ctrlPlot = TextEditingController();
  final TextEditingController _ctrlCountry = TextEditingController();
  final TextEditingController _ctrlPoster = TextEditingController();
  final TextEditingController _ctrlImdbRating = TextEditingController();
  bool _isUpdate = false;
  bool _customPosterSelected = false;
  final BorderRadius _posterBorder = BorderRadius.circular(12);

  @override
  void initState() {
    super.initState();

    if (widget.isFromSearch) {
      _ctrlImdbId.text = widget.movie.getImdbID()!;
      _loadMovieData();
    }

    if (widget.isUpdate) {
      _isUpdate = true;
      _movie = widget.movie;
      _validImdbId = true;
      loadTextFields();
    }
  }

  void _loadMovieData() async {
    if (_ctrlImdbId.text.isNotEmpty) {
      final String apiKey = ApiKey.key;
      final String movieId = _ctrlImdbId.text.trim();
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
            _movie = Movie.fromJson(jsonData);
            _posterUrl = _movie.getPoster();
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
    _ctrlTitle.text = _movie.getTitle() ?? '';
    _ctrlYear.text = _movie.getYear() ?? '';
    _ctrlReleased.text = _movie.getReleased() ?? '';
    _ctrlRuntime.text = _movie.getRuntime().toString();
    _ctrlDirector.text = _movie.getDirector() ?? '';
    _ctrlPlot.text = _movie.getPlot() ?? '';
    _ctrlCountry.text = _movie.getCountry() ?? '';
    _ctrlPoster.text = _movie.getPoster() ?? '';
    _ctrlImdbRating.text = _movie.getImdbRating() ?? '';
    _ctrlImdbId.text = _movie.getImdbID() ?? '';
    _movieWatchedState = _movie.getWatched()!;
  }

  void _beforeStoreMovie() async {
    if (!_isUpdate) {
      bool exists = await MovieService().existsByImdbId(_ctrlImdbId.text);

      if (exists) {
        bool? confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Duplicate Entry"),
            content: const Text("This movie already exists on the collection. Do you want to save it anyway?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Save"),
              ),
            ],
          ),
        );

        if (confirm != true) {
          return;
        }
      }
    }

    _storeMovie().then((_) => Navigator.of(context).pop());
  }

  Future<void> _storeMovie() async {
    if (_isUpdate) {
      await _updateMovie();
    } else {
      await _insertMovie();
    }
  }

  Future<void> _insertMovie() async {
    await _loadAndParsePoster();
    int runtimeInt = _parseRuntime();

    _movie.setTitle(_ctrlTitle.text);
    _movie.setYear(_ctrlYear.text);
    _movie.setReleased(_ctrlReleased.text);
    _movie.setRuntime(runtimeInt);
    _movie.setDirector(_ctrlDirector.text);
    _movie.setPlot(_ctrlPlot.text);
    _movie.setCountry(_ctrlCountry.text);
    _movie.setImdbRating(_ctrlImdbRating.text);
    _movie.setImdbID(_ctrlImdbId.text);
    _movie.setWatched(_movieWatchedState);

    await MovieService().insertMovie(_movie);
  }

  Future<void> _updateMovie() async {
    await _loadAndParsePoster();
    int runtimeInt = _parseRuntime();

    _movie.setTitle(_ctrlTitle.text);
    _movie.setYear(_ctrlYear.text);
    _movie.setReleased(_ctrlReleased.text);
    _movie.setRuntime(runtimeInt);
    _movie.setDirector(_ctrlDirector.text);
    _movie.setPlot(_ctrlPlot.text);
    _movie.setCountry(_ctrlCountry.text);
    _movie.setImdbRating(_ctrlImdbRating.text);
    _movie.setWatched(_movieWatchedState);

    await MovieService().updateMovie(_movie);
  }

  int _parseRuntime() {
    int runtimeInt = 0;

    if (_ctrlRuntime.text.isNotEmpty) {
      String text = _ctrlRuntime.text;
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
    if (_ctrlImdbId.text.isEmpty) {
      ok = false;
      _validImdbId = false;
    }
    if (_ctrlTitle.text.isEmpty) {
      ok = false;
      _validTitle = false;
    }
    if (_ctrlRuntime.text.isEmpty) {
      ok = false;
      _validRuntime = false;
    }
    if (_ctrlYear.text.isEmpty) {
      ok = false;
      _validYear = false;
    }
    return ok;
  }

  Future<void> _loadAndParsePoster() async {
    Uint8List? base64ImageBytes;
    Uint8List? compressedPoster;

    if (_customPosterSelected && _poster != null) {
      compressedPoster = await compressCoverImage(_poster!.readAsBytesSync());
      _movie.setPoster(base64Encode(compressedPoster));
    } else if (!_customPosterSelected && _posterUrl != null) {
      http.Response response = await http.get(Uri.parse(_posterUrl!));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        base64ImageBytes = response.bodyBytes;
        compressedPoster = await compressCoverImage(base64ImageBytes);
        _movie.setPoster(base64Encode(compressedPoster));
      } else {
        _movie.setPoster("");
      }
    }
  }

  Future<void> pickImageFromGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File? file = File(pickedFile.path);

      setState(() {
        _poster = file;
        _customPosterSelected = true;
      });
    }
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
        title: _isUpdate ? const Text('Edit') : const Text('New'),
        actions: [
          IconButton(
            tooltip: "Change Poster",
            icon: const Icon(
              Icons.photo_library_outlined,
            ),
            onPressed: pickImageFromGallery,
          ),
        ],
      ),
      body: ListView(children: [
        Center(
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: _customPosterSelected
                ? Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: _posterBorder,
                    ),
                    elevation: 0,
                    child: ClipRRect(
                      borderRadius: _posterBorder,
                      child: Image.file(
                        _poster!,
                        width: _posterWidth,
                        height: _posterHeight,
                        fit: BoxFit.fill,
                      ),
                    ),
                  )
                : _isUpdate
                    ? (_movie.getPoster() == null || _movie.getPoster()!.isEmpty)
                        ? SizedBox(
                            height: _posterHeight,
                            width: _posterWidth,
                            child: Icon(
                              Icons.movie_outlined,
                              size: 30,
                              color: Theme.of(context).hintColor,
                            ),
                          )
                        : SizedBox(
                            height: _posterHeight,
                            width: _posterWidth,
                            child: ClipRRect(
                              borderRadius: _posterBorder,
                              child: Image.memory(
                                base64Decode(_movie.getPoster()!),
                                fit: BoxFit.fill,
                                gaplessPlayback: true,
                              ),
                            ),
                          )
                    : Image.network(
                        _posterUrl ?? '',
                        width: _posterWidth,
                        height: _posterHeight,
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.medium,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return Card(child: ClipRRect(borderRadius: _posterBorder, child: child));
                          }
                          return Card(
                            child: SizedBox(
                              width: _posterWidth,
                              height: _posterHeight,
                              child: const Icon(Icons.error),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Card(
                          child: SizedBox(
                            width: _posterWidth,
                            height: _posterHeight,
                            child: const Icon(Icons.image_outlined),
                          ),
                        ),
                      ),
          ),
        ),
        Visibility(
          visible: !_isUpdate,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
                minLines: 1,
                maxLines: 1,
                maxLength: 200,
                onSubmitted: (e) => _loadMovieData(),
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                keyboardType: TextInputType.text,
                controller: _ctrlImdbId,
                decoration: InputDecoration(
                    helperText: "* Required",
                    labelText: "IMDB ID",
                    border: const OutlineInputBorder(),
                    errorText: (_validImdbId) ? null : "Link is empty")),
          ),
        ),
        buildTextField("Title", _ctrlTitle, true, 2, 200, _validTitle),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildTextField("Runtime - Min", _ctrlRuntime, true, 1, 5, _validRuntime),
            ),
            Expanded(
              child: buildTextField("Year", _ctrlYear, true, 1, 4, _validYear),
            ),
          ],
        ),
        buildTextField("Director", _ctrlDirector, false, 2, 200, _validFieldWithoutRequired),
        buildTextField("Plot", _ctrlPlot, false, 5, 500, _validFieldWithoutRequired),
        buildTextField("Country", _ctrlCountry, false, 2, 200, _validFieldWithoutRequired),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: buildTextField("Released", _ctrlReleased, false, 1, 30, _validFieldWithoutRequired),
            ),
            Expanded(
              child: buildTextField("IMDB Rating", _ctrlImdbRating, false, 1, 4, _validFieldWithoutRequired),
            ),
          ],
        ),
        Visibility(
          visible: !_isUpdate,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
            child: SegmentedButton<NoYes>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<NoYes>>[
                ButtonSegment<NoYes>(value: NoYes.no, label: Text('Not Watched'), icon: Icon(Icons.visibility_off_outlined)),
                ButtonSegment<NoYes>(value: NoYes.yes, label: Text('Watched'), icon: Icon(Icons.visibility_outlined)),
              ],
              selected: <NoYes>{_movieWatchedState},
              onSelectionChanged: (Set<NoYes> newSelection) {
                setState(() {
                  _movieWatchedState = newSelection.first;
                });
              },
            ),
          ),
        ),
        /* Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: FilledButton.tonalIcon(
              onPressed: () {
                if (validateTextFields()) {
                  _beforeStoreMovie();
                  //_storeMovie().then((_) => _reloadMoviesList()).then((_) => Navigator.of(context).pop());
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
        ),*/
        const SizedBox(
          height: 100,
        )
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (validateTextFields()) {
            _beforeStoreMovie();
          } else {
            setState(() {
              _validImdbId;
              _validTitle;
              _validRuntime;
              _validYear;
            });
          }
        },
        child: const Icon(Icons.save_outlined),
      ),
    );
  }
}
