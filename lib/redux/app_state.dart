import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';

class AppState {
  List<Movie> watchList;
  SortOption selectedHomeSortOption;
  bool isLoadingWatchList;
  List<Movie> watchedList;
  String selectedYearWatchedList;
  bool isLoadingWatchedList;

  AppState(
      {required this.watchList,
      required this.selectedHomeSortOption,
      required this.watchedList,
      required this.selectedYearWatchedList,
      required this.isLoadingWatchList,
      required this.isLoadingWatchedList});

  static AppState initialState() => AppState(
      watchList: [],
      selectedHomeSortOption: SortOption.titleAsc,
      watchedList: [],
      selectedYearWatchedList: DateTime.now().year.toString(),
      isLoadingWatchList: false,
      isLoadingWatchedList: false);

  AppState copyWith(
      {List<Movie>? watchList,
      SortOption? selectedHomeSortOption,
      List<Movie>? watchedList,
      String? selectedYearWatchedList,
      bool? isLoadingWatchList,
      bool? isLoadingWatchedList}) {
    return AppState(
        watchList: watchList ?? this.watchList,
        selectedHomeSortOption: selectedHomeSortOption ?? this.selectedHomeSortOption,
        watchedList: watchedList ?? this.watchedList,
        selectedYearWatchedList: selectedYearWatchedList ?? this.selectedYearWatchedList,
        isLoadingWatchList: isLoadingWatchList ?? this.isLoadingWatchList,
        isLoadingWatchedList: isLoadingWatchedList ?? this.isLoadingWatchedList);
  }
}
