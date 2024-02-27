import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies_watcher_fschmatz/page/home.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color topOverlayColor = theme.colorScheme.background;
    final Brightness iconBrightness = theme.brightness == Brightness.light
                                      ? Brightness.dark
                                      : Brightness.light;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          statusBarColor: topOverlayColor,
          systemStatusBarContrastEnforced: false,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
        child: const Home());
  }
}
