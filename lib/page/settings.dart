import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/util/utils_functions.dart';
import 'package:movies_watcher_fschmatz/widget/app_parameter_value.dart';
import 'package:movies_watcher_fschmatz/widget/settings_switch.dart';

import '../util/app_constants.dart';
import '../util/dialog_backup.dart';
import '../util/dialog_select_theme.dart';
import 'app_info.dart';
import 'changelog.dart';

class Settings extends StatefulWidget {
  final Function()? loadNotWatchedMovies;

  const Settings({super.key, this.loadNotWatchedMovies});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "General",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const DialogSelectTheme();
                          },
                        ),
                        leading: const Icon(Icons.brightness_6_outlined),
                        title: const Text("App theme"),
                        subtitle: Text(
                          UtilsFunctions.getThemeStringFormatted(EasyDynamicTheme.of(context).themeMode),
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 1),
                      const SettingsSwitch(
                        title: "Show name",
                        parameterKey: AppConstants.showMovieNameOnCardAppParameter,
                        subtitle: 'Show the movie name on the card',
                      ),
                      Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 1),
                      const SettingsSwitch(
                        title: "Show runtime",
                        parameterKey: AppConstants.showRuntimeChipOnCardAppParameter,
                        subtitle: 'Show the movie runtime on the card',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "Backup",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogBackup(
                              isCreateBackup: true,
                              reloadHomeFunction: widget.loadNotWatchedMovies,
                            );
                          },
                        ),
                        leading: const Icon(Icons.save_outlined),
                        title: const Text("Backup now"),
                        subtitle: Row(
                          children: [
                            const Text("Last backup: ", style: TextStyle(fontSize: 12)),
                            AppParameterValue(parameterKey: AppConstants.lastBackupDateAppParameter),
                          ],
                        ),
                      ),
                      Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 1),
                      ListTile(
                        onTap: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return DialogBackup(
                              isCreateBackup: false,
                              reloadHomeFunction: widget.loadNotWatchedMovies,
                            );
                          },
                        ),
                        leading: const Icon(Icons.settings_backup_restore_outlined),
                        title: const Text("Restore from backup"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                  child: Text(
                    "About",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info_outline),
                        title: const Text("App info"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const AppInfo(),
                            ),
                          );
                        },
                      ),
                      Divider(color: Theme.of(context).colorScheme.surfaceContainerLow, height: 1),
                      ListTile(
                        leading: const Icon(Icons.article_outlined),
                        title: const Text("Changelog"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => const Changelog(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
