import 'package:movies_watcher_fschmatz/entity/movie.dart';
import 'package:movies_watcher_fschmatz/redux/selectors.dart';

import '../enum/no_yes.dart';
import '../enum/sort_watch_list_option.dart';
import '../service/movie_service.dart';
import 'app_action.dart';
import 'app_state.dart';

class LoadWatchListAction extends AppAction {
  @override
  Future<AppState> reduce() async {
    List<Movie> movies = await MovieService().queryAllByWatchedNoYesAndOrderByAndConvertToList(NoYes.no, state.selectedHomeSortOption.sqlOrderBy);

    return state.copyWith(watchList: movies);
  }
}

class LoadWatchedListAction extends AppAction {
  @override
  Future<AppState> reduce() async {
    String selectedYearWatchedList = selectSelectedYearWatchedList();

    List<Movie> movies = await MovieService().findWatchedByYear(selectedYearWatchedList);

    return state.copyWith(watchedList: movies);
  }
}

class ChangeWatchListSortAction extends AppAction {
  final SortOption sortOption;

  ChangeWatchListSortAction(this.sortOption);

  @override
  Future<AppState> reduce() async {
    return state.copyWith(selectedHomeSortOption: sortOption);
  }
}

class ChangeWatchedListSelectedYearAction extends AppAction {
  final String selectedYear;

  ChangeWatchedListSelectedYearAction(this.selectedYear);

  @override
  Future<AppState> reduce() async {
    return state.copyWith(selectedYearWatchedList: selectedYear);
  }
}
