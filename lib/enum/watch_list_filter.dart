import '../entity/movie.dart';

enum WatchListFilter {
  all('All'),
  under1h00m('Under 1h 00m'),
  under1h30m('Under 1h 30m'),
  under1h45m('Under 1h 45m'),
  under2h00m('Under 2h 00m'),
  between1h00mAnd2h00m('Betw. 1h and 2h'),
  under2h30m('Under 2h 30m'),
  over2h30m('Over 2h 30m'),
  favorites('Favorites');

  final String label;

  const WatchListFilter(this.label);

  static const List<WatchListFilter> runtimeFilters = [
    WatchListFilter.between1h00mAnd2h00m,
    WatchListFilter.over2h30m,
    WatchListFilter.under1h00m,
    WatchListFilter.under1h30m,
    WatchListFilter.under1h45m,
    WatchListFilter.under2h00m,
    WatchListFilter.under2h30m,
  ];

  bool get isRuntimeFilter => runtimeFilters.contains(this);

  bool matches(Movie movie) {
    final runtime = movie.getRuntime() ?? 0;

    switch (this) {
      case WatchListFilter.under1h00m:
        return runtime > 0 && runtime <= 60;
      case WatchListFilter.under1h30m:
        return runtime > 0 && runtime <= 90;
      case WatchListFilter.under1h45m:
        return runtime > 0 && runtime <= 105;
      case WatchListFilter.under2h00m:
        return runtime > 0 && runtime <= 120;
      case WatchListFilter.between1h00mAnd2h00m:
        return runtime >= 60 && runtime <= 120;
      case WatchListFilter.under2h30m:
        return runtime > 0 && runtime <= 150;
      case WatchListFilter.over2h30m:
        return runtime > 150;
      case WatchListFilter.favorites:
        return movie.isFavorite();
      case WatchListFilter.all:
        return true;
    }
  }
}
