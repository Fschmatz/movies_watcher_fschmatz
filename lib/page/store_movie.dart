import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../api_key.dart';
import '../entity/movie.dart';
import '../entity/no_yes.dart';

class StoreMovie extends StatefulWidget {
  const StoreMovie({super.key});

  @override
  State<StoreMovie> createState() => _StoreMovieState();
}

class _StoreMovieState extends State<StoreMovie> {
  Movie movie = Movie();
  TextEditingController ctrlImdbId = TextEditingController();
  TextEditingController ctrlName = TextEditingController();

  void loadMovieData() async {
    final String apiKey = ApiKey.key;
    final String movieId = ctrlImdbId.text;
    final String apiUrl = 'http://www.omdbapi.com/?i=$movieId&apikey=$apiKey';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonData = json.decode(response.body);

      setState(() {
        movie = Movie.fromJson(jsonData);
      });

    } else {
      Fluttertoast.showToast(
        msg: "API Error",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Opa!'),
        ),
        body: ListView(
            children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
             child: TextField(
              // autofocus: true,
              minLines: 1,
              maxLines: 3,
              maxLength: 200,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.name,
              controller: ctrlImdbId,
               decoration: const InputDecoration(
                   helperText: "* Required",
                   labelText: "IMDB ID"

               ),
             ),
            ),



          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title: ${movie.getTitle()}'),
                Text('Year: ${movie.getYear()}'),
                Text('Released: ${movie.getReleased()}'),
                Text('Runtime: ${movie.getRuntime()}'),
                Text('Director: ${movie.getDirector()}'),
                Text('Plot: ${movie.getPlot()}'),
                Text('Country: ${movie.getCountry()}'),
                //Text('Poster: ${movie.poster}'),
                Text('IMDb Rating: ${movie.getImdbRating()}'),
                Text('IMDb ID: ${movie.getImdbID()}'),
                Text('Watched: ${movie.getWatched()} '),
              /*  Text('Date Added: ${movie.dateAdded}'),
                Text('Date Watched: ${movie.dateWatched}'),*/
              ],
            ),
          ),

          Center(
            child: movie.getPoster() != null
                ? Image.network(
                    movie.getPoster()!,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return SizedBox.shrink();
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        Text('Failed to load image'),
                  )
                : Text('No poster available'),
          ),
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
                  Icons.save_outlined,
                ),
                label: const Text(
                  'LOAD',
                )),
          ),
        ]));
  }
}
