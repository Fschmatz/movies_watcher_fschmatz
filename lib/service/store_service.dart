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
}
