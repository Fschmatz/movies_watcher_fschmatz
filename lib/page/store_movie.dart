//import 'dart:html';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import '../api_key.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';
import '../service/movie_service.dart';

class StoreMovie extends StatefulWidget {
  const StoreMovie({super.key});

  @override
  State<StoreMovie> createState() => _StoreMovieState();
}

class _StoreMovieState extends State<StoreMovie> {
  Movie movie = Movie();
  MovieService movieService = MovieService();
  String? posterUrl;
  File? poster;
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

  @override
  void initState() {
    super.initState();

    ctrlImdbId.text = "tt1560653";
  }

  void loadMovieData() async {
    final String apiKey = ApiKey.key;
    final String movieId = ctrlImdbId.text;
    final String apiUrl = 'http://www.omdbapi.com/?i=$movieId&apikey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() {
        movie = Movie.fromJson(jsonData);
        posterUrl = movie.getPoster();
        loadTextFields();
      });
    } else {
      Fluttertoast.showToast(
        msg: "API Error",
      );
    }
  }

  void loadTextFields() {
    ctrlTitle.text = movie.getTitle() ?? '';
    ctrlYear.text = movie.getYear() ?? '';
    ctrlReleased.text = movie.getReleased() ?? '';
    ctrlRuntime.text = movie.getRuntime() ?? '';
    ctrlDirector.text = movie.getDirector() ?? '';
    ctrlPlot.text = movie.getPlot() ?? '';
    ctrlCountry.text = movie.getCountry() ?? '';
    ctrlPoster.text = movie.getPoster() ?? '';
    ctrlImdbRating.text = movie.getImdbRating() ?? '';
    ctrlImdbId.text = movie.getImdbID() ?? '';
  }

  void saveMovie() {
    if (poster != null) {
      _downloadPoster();

      Uint8List? posterBytes;
      posterBytes = poster!.readAsBytesSync();
      movie.setPoster(base64Encode(posterBytes));
    }

    movie.setTitle(ctrlTitle.text);
    movie.setYear(ctrlYear.text);
    movie.setReleased(ctrlReleased.text);
    movie.setRuntime(ctrlRuntime.text);
    movie.setDirector(ctrlDirector.text);
    movie.setPlot(ctrlPlot.text);
    movie.setCountry(ctrlCountry.text);
    movie.setImdbRating(ctrlImdbRating.text);
    movie.setImdbID(ctrlImdbId.text);

    // movieService.insertMovie(movie);
    setState(() {
      poster;
    });
  }

  Future<void> _downloadPoster() async {
    final url = posterUrl;
    final response = await http.get(Uri.parse(url!));
    final documentDirectory = await getApplicationDocumentsDirectory();
    poster = File('${documentDirectory.path}/image.jpg');
    await poster?.writeAsBytes(response.bodyBytes);

    File? compressedFile = await FlutterNativeImage.compressImage(poster!.path,
        quality: 85, targetWidth: 325, targetHeight: 475);

    poster = compressedFile;
  }

  Widget buildTextField(String label, TextEditingController controller,
      bool required, int maxLines, int maxLength) {
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
            border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('New movie'),
        ),
        body: ListView(children: [
          buildTextField("IMDB ID", ctrlImdbId, true, 1, 200),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  loadMovieData();
                  /* if (validarTextFields()) {
                    _salvarLivro();
                    widget.refreshHome();
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      nomeValido;
                    });
                  }*/
                },
                icon: const Icon(
                  Icons.download_outlined,
                ),
                label: const Text(
                  'Load',
                )),
          ),
          Center(
            child: posterUrl != null
                ? Image.network(
                    posterUrl!,
                    width: 150,
                    height: 250,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox.shrink();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Failed to load image'),
                  )
                : const Text('No poster available'),
          ),
          buildTextField("Title", ctrlTitle, true, 2, 200),
          buildTextField("Year", ctrlYear, true, 1, 4),
          buildTextField("Released", ctrlReleased, false, 1, 30),
          buildTextField("Runtime", ctrlRuntime, true, 1, 30),
          buildTextField("Director", ctrlDirector, false, 2, 200),
          buildTextField("Plot", ctrlPlot, false, 5, 500),
          buildTextField("Country", ctrlCountry, false, 2, 200),
          buildTextField("IMDB Rating", ctrlImdbRating, false, 1, 4),
       /*   Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            elevation: 0,
            child: poster == null
                ? Container(
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(5)),
                    width: 70,
                    height: 105,
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.file(
                      poster!,
                      width: 70,
                      height: 105,
                      fit: BoxFit.fill,
                    ),
                  ),
          ),*/
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: FilledButton.tonalIcon(
                onPressed: () {
                  saveMovie();

                  /* if (validarTextFields()) {
                    _salvarLivro();
                    widget.refreshHome();
                    Navigator.of(context).pop();
                  } else {
                    setState(() {
                      nomeValido;
                    });
                  }*/
                },
                icon: const Icon(
                  Icons.save_outlined,
                ),
                label: const Text(
                  'Save',
                )),
          ),
        ]));
  }
}
