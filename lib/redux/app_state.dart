import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';

class AppState {
  List<Movie> watchList;
  SortOption selectedHomeSortOption;
  List<Movie> watchedList;
  String selectedYearWatchedList;

  AppState({required this.watchList, required this.selectedHomeSortOption, required this.watchedList, required this.selectedYearWatchedList});

  static AppState initialState() =>
      AppState(watchList: [], selectedHomeSortOption: SortOption.titleAsc, watchedList: [], selectedYearWatchedList: DateTime.now().year.toString());

  AppState copyWith({List<Movie>? watchList, SortOption? selectedHomeSortOption, List<Movie>? watchedList, String? selectedYearWatchedList}) {
    return AppState(
        watchList: watchList ?? this.watchList,
        selectedHomeSortOption: selectedHomeSortOption ?? this.selectedHomeSortOption,
        watchedList: watchedList ?? this.watchedList,
        selectedYearWatchedList: selectedYearWatchedList ?? this.selectedYearWatchedList);
  }
}
