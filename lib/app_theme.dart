import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:movies_watcher_fschmatz/page/watch_list.dart';

class AppTheme extends StatefulWidget {
  const AppTheme({super.key});

  @override
  State<AppTheme> createState() => _AppThemeState();
}

class _AppThemeState extends State<AppTheme> {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightScheme = lightDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue);
        final darkScheme = darkDynamic ?? ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: lightScheme,
            useMaterial3: true,
            cardTheme: CardThemeData(color: lightScheme.surfaceContainerHigh, elevation: 0, surfaceTintColor: Colors.transparent),
          ),
          darkTheme: ThemeData(
            colorScheme: darkScheme.copyWith(surface: darkScheme.surfaceContainerLow),
            useMaterial3: true,
            cardTheme: CardThemeData(color: darkScheme.surfaceContainerHigh, elevation: 0, surfaceTintColor: Colors.transparent),
          ),
          themeMode: EasyDynamicTheme.of(context).themeMode,
          home: const WatchList(),
        );
      },
    );
  }
}
