import 'package:flutter/material.dart';

import '../entity/movie.dart';

class StatsMonthTile extends StatelessWidget {
  final String monthYear;
  final List<Movie> movies;
  final VoidCallback onTap;

  const StatsMonthTile({
    super.key,
    required this.monthYear,
    required this.movies,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: const Icon(Icons.analytics_outlined),
      title: Text(
        monthYear,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${movies.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.navigate_next_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
