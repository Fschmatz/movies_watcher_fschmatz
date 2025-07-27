import '../main.dart';
import '../redux/actions.dart';

abstract class StoreService {
  Future<void> loadWatchListMovies() async {
    await store.dispatch(LoadWatchListAction());
  }

  Future<void> loadWatchedListMovies() async {
    await store.dispatch(LoadWatchedListAction());
  }
}
