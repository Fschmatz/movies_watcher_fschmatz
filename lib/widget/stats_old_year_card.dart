import 'package:flutter/material.dart';

import '../entity/movie.dart';

class StatsOldYearCard extends StatelessWidget {
  final String year;
  final List<Movie> movies;

  const StatsOldYearCard({
    super.key,
    required this.year,
    required this.movies,
  });

  @override
  Widget build(BuildContext context) {
    final int totalMovies = movies.length;
    final int totalRuntime = movies.fold(0, (sum, movie) => sum + (movie.getRuntime() ?? 0));

    return Card(
      child: ListTile(
        title: Expanded(
          child: Text(
            year,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        trailing: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalMovies films',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$totalRuntime min',
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
