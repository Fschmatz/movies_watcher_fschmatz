import 'package:async_redux/async_redux.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/redux/app_state.dart';

import 'app_theme.dart';

final Store<AppState> store = Store<AppState>(
  initialState: AppState.initialState(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    StoreProvider<AppState>(
      store: store,
      child: EasyDynamicThemeWidget(
        child: const AppTheme(),
      ),
    ),
  );
}
