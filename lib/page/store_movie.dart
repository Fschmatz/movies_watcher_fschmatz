import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:movies_watcher_fschmatz/enum/no_yes.dart';

import '../entity/movie.dart';
import '../service/api_service.dart';
import '../service/movie_service.dart';
import '../util/toast_utils.dart';

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
  final double _posterHeight = 220;
  final double _posterWidth = 150;
  final bool _validFieldWithoutRequired = true;
  bool _validTitle = true;
  bool _validRuntime = true;
  bool _validYear = true;
  final TextEditingController _ctrlTitle = TextEditingController();
  final TextEditingController _ctrlYear = TextEditingController();
  final TextEditingController _ctrlReleased = TextEditingController();
  final TextEditingController _ctrlRuntime = TextEditingController();
  final TextEditingController _ctrlDirector = TextEditingController();
  final TextEditingController _ctrlPlot = TextEditingController();
  final TextEditingController _ctrlCountry = TextEditingController();
  final TextEditingController _ctrlPoster = TextEditingController();
  final TextEditingController _ctrlRating = TextEditingController();
  bool _isUpdate = false;
  bool _isLoading = false;
  bool _isSaving = false;
  final BorderRadius _posterBorder = BorderRadius.circular(20);
  bool _isFromTmdb = false;

  @override
  void initState() {
    super.initState();

    if (widget.isFromSearch) {
      _movie = widget.movie;
      _isLoading = true;
      _loadMovieData();
    }

    if (widget.isUpdate) {
      _isUpdate = true;
      _movie = widget.movie;
      _isLoading = true;
      _isFromTmdb = _movie.getTmdbID() != null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          loadTextFields();
          _isLoading = false;
        });
      });
    }
  }

  void _loadMovieData() async {
    if (_movie.getTmdbID() != null) {
      Movie? fetchedMovie = await ApiService().getMovieDetails(_movie.getTmdbID()!);

      if (fetchedMovie != null) {
        setState(() {
          if (_isUpdate) {
            fetchedMovie.setId(_movie.getId()!);
            if (_movie.getWatched() != null) fetchedMovie.setWatched(_movie.getWatched()!);
            if (_movie.getDateAdded() != null) fetchedMovie.setDateAdded(_movie.getDateAdded()!);
            if (_movie.getDateWatched() != null) fetchedMovie.setDateWatched(_movie.getDateWatched()!);
          }

          _movie = fetchedMovie;
          _posterUrl = fetchedMovie.getPoster();
          loadTextFields();
          _isLoading = false;

          if (_isUpdate) {
            ToastUtils.show("Data refreshed from API");
          }
        });
      } else {
        setState(() => _isLoading = false);
      }
    } else {
      _showNoResultsFound();
    }
  }

  void _showNoResultsFound() {
    ToastUtils.show(
      "No Results Found!",
    );
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
    _ctrlRating.text = _movie.getRating() ?? '';
    _movieWatchedState = _movie.getWatched()!;
  }

  void _beforeStoreMovie() async {
    setState(() => _isSaving = true);

    if (!_isUpdate) {
      final int? tmdbID = _movie.getTmdbID();
      bool exists = tmdbID != null && await MovieService().existsByTmdbId(tmdbID);

      if (exists) {
        setState(() => _isSaving = false);
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
        setState(() => _isSaving = true);
      }
    }

    _storeMovie().then((_) {
      ToastUtils.show(_isUpdate ? "Movie updated!" : "Movie saved!");

      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    });
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
    _movie.setRating(_ctrlRating.text);
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
    _movie.setRating(_ctrlRating.text);
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
    if (_posterUrl != null && _posterUrl!.trim() != "N/A") {
      http.Response response = await http.get(Uri.parse(_posterUrl!));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Uint8List compressedPoster = await compressCoverImage(response.bodyBytes);
        _movie.setPoster(base64Encode(compressedPoster));
      } else {
        if (!_isUpdate) _movie.setPoster("");
      }
    } else {
      if (!_isUpdate) _movie.setPoster("");
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
              errorText: (fieldValidator) ? null : "$label is empty or invalid")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isUpdate ? const Text('Edit') : const Text(''),
        actions: [
          if (_isUpdate && _isFromTmdb)
            IconButton(
              tooltip: "Refresh from API",
              icon: const Icon(Icons.sync_outlined),
              onPressed: _loadMovieData,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _isLoading
            ? const Center(
                key: ValueKey('loading'),
                child: CircularProgressIndicator(),
              )
            : ListView(key: const ValueKey('content'), children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: _isUpdate && !(_movie.getPoster()?.startsWith('http') ?? false) && _movie.getPoster() != "N/A"
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
                //buildTextField("TMDB ID", _ctrlImdbId, false, 1, 200, _validFieldWithoutRequired),
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
                buildTextField("Plot", _ctrlPlot, false, 5, 800, _validFieldWithoutRequired),
                buildTextField("Country", _ctrlCountry, false, 2, 200, _validFieldWithoutRequired),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: buildTextField("Released", _ctrlReleased, false, 1, 30, _validFieldWithoutRequired),
                    ),
                    Expanded(
                      child: buildTextField("Rating", _ctrlRating, false, 1, 4, _validFieldWithoutRequired),
                    ),
                  ],
                ),
                if (!_isUpdate) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownMenu<NoYes>(
                      initialSelection: _movieWatchedState,
                      expandedInsets: EdgeInsets.zero,
                      label: const Text('Status'),
                      onSelected: (NoYes? value) {
                        if (value != null) {
                          setState(() {
                            _movieWatchedState = value;
                          });
                        }
                      },
                      dropdownMenuEntries: const [
                        DropdownMenuEntry<NoYes>(
                          value: NoYes.no,
                          label: 'Not Watched',
                          leadingIcon: Icon(Icons.visibility_off_outlined),
                        ),
                        DropdownMenuEntry<NoYes>(
                          value: NoYes.yes,
                          label: 'Watched',
                          leadingIcon: Icon(Icons.visibility_outlined),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(
                  height: 100,
                )
              ]),
      ),
      floatingActionButton: _isLoading
          ? null
          : _isSaving
              ? FloatingActionButton.extended(
                  onPressed: null,
                  icon: const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                    ),
                  ),
                  label: const Text(
                    "Saving...",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              : FloatingActionButton.extended(
                  onPressed: () {
                    if (validateTextFields()) {
                      _beforeStoreMovie();
                    } else {
                      setState(() {
                        _validTitle;
                        _validRuntime;
                        _validYear;
                      });
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text(
                    "Save",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
    );
  }
}
