import '../entity/app_parameter.dart';
import '../entity/movie.dart';
import '../enum/sort_watch_list_option.dart';
import 'app_state.dart';

List<Movie> selectWatchListMovies(AppState state) => state.watchList;

SortOption selectSelectedHomeSortOption(AppState state) =>
    state.selectedHomeSortOption;

List<Movie> selectWatchedListMovies(AppState state) => state.watchedList;

String selectSelectedYearWatchedList(AppState state) =>
    state.selectedYearWatchedList;

List<AppParameter> selectAppParameters(AppState state) => state.appParameters;

String? selectParameterValueByKey(AppState state, String key) {
  try {
    return state.appParameters
        .firstWhere((element) => element.getKey() == key)
        .getValue();
  } catch (e) {
    return null;
  }
}

bool selectParameterValueByKeyAsBoolean(AppState state, String key,
    {bool defaultValue = true}) {
  String? value = selectParameterValueByKey(state, key);

  if (value == null) {
    return defaultValue;
  }

  return value == "true";
}
