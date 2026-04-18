import '../entity/app_parameter.dart';
import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';
import '../main.dart';

List<Movie> selectWatchListMovies() => store.state.watchList;

SortOption selectSelectedHomeSortOption() => store.state.selectedHomeSortOption;

List<Movie> selectWatchedListMovies() => store.state.watchedList;

String selectSelectedYearWatchedList() => store.state.selectedYearWatchedList;

List<AppParameter> selectAppParameters() => store.state.appParameters;

String? selectParameterValueByKey(String key) {
  try {
    return store.state.appParameters
        .firstWhere((element) => element.getKey() == key)
        .getValue();
  } catch (e) {
    return null;
  }
}
