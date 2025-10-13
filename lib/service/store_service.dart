import '../entity/movie.dart';
import '../main.dart';
import '../redux/actions.dart';

abstract class StoreService {
  Future<void> loadWatchList() async {
    await store.dispatch(LoadWatchListAction());
  }

  Future<void> loadWatchedList() async {
    await store.dispatch(LoadWatchedListAction());
  }

  Future<void> loadAllLists() async {
    store.dispatchAndWaitAll([LoadWatchListAction(), LoadWatchedListAction()]);
  }

  Future<void> removeMovieFromWatchListAction(Movie movie) async {
    await store.dispatch(RemoveMovieFromWatchListAction(movie));
  }

  Future<void> removeMovieFromWatchedListAction(Movie movie) async {
    await store.dispatch(RemoveMovieFromWatchedListAction(movie));
  }
}
