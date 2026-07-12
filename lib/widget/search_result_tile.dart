import 'package:flutter/material.dart';

import '../entity/movie.dart';
import '../page/store_movie.dart';

class SearchResultTile extends StatefulWidget {
  final Movie movie;

  const SearchResultTile({
    super.key,
    required this.movie,
  });

  @override
  State<SearchResultTile> createState() => _SearchResultTileState();
}

class _SearchResultTileState extends State<SearchResultTile> {
  Movie movie = Movie();
  double posterHeight = 110;
  double posterWidth = 70;
  BorderRadius posterBorder = BorderRadius.circular(20);

  @override
  void initState() {
    super.initState();

    movie = widget.movie;
  }

  void _openStoreMoviePage() {    
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StoreMovie(
            key: UniqueKey(),
            movie: movie,
            isUpdate: false,
            isFromSearch: true,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    Image? posterImage = Image.network(
      movie.getPoster()!,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
        return const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 30.0,
          ),
        );
      },
    );

    return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: _openStoreMoviePage,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 85,
                  constraints: const BoxConstraints(minHeight: 135),
                  child: posterImage,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.getTitle()!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (movie.getReleased() != null && movie.getReleased()!.isNotEmpty) ? movie.getReleased()! : movie.getYear() ?? '',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                        if (movie.getRating() != null && movie.getRating()!.isNotEmpty && movie.getRating() != '0.0') ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                movie.getRating()!,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
