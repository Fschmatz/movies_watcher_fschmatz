import 'package:easy_dynamic_theme/easy_dynamic_theme.dart';
import 'package:flutter/material.dart';

import '../redux/app_state.dart';
import '../redux/build_context_extension.dart';
import '../redux/selectors.dart';
import '../util/app_constants.dart';
import '../util/theme_extension.dart';
import '../util/utils_functions.dart';
import '../util/widget/app_parameter_value.dart';
import '../util/widget/dialog_backup.dart';
import '../util/widget/dialog_select_theme.dart';
import '../util/widget/section_segmented_widget_list.dart';
import '../widget/dialog_select_grid_size.dart';
import '../widget/settings_switch.dart';
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
    String lastBackupDate = context.select((AppState state) => selectParameterValueByKey(state, AppConstants.lastBackupDateAppParameter)) ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 75),
        children: <Widget>[
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: context.colors.primaryContainer,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.colors.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: context.colors.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          SectionSegmentedWidgetList(
            title: "General",
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
              const SettingsSwitch(
                title: "Show name",
                parameterKey: AppConstants.showMovieNameOnCardAppParameter,
                subtitle: 'Show the movie name on the card',
              ),
              const SettingsSwitch(
                title: "Show runtime",
                parameterKey: AppConstants.showRuntimeChipOnCardAppParameter,
                subtitle: 'Show the movie runtime on the card',
              ),
              const SettingsSwitch(
                title: "Format runtime",
                parameterKey: AppConstants.formatRuntimeAppParameter,
                subtitle: 'Format runtime to hours and minutes',
                defaultValue: false,
              ),
              ListTile(
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DialogSelectGridSize(
                      parameterKey: AppConstants.gridSizeAppParameter,
                      defaultValue: 3,
                    );
                  },
                ),
                title: const Text("Movies per row in grid"),
                subtitle: const Row(
                  children: [
                    AppParameterValue(
                      parameterKey: AppConstants.gridSizeAppParameter,
                      defaultValue: '3',
                    ),
                    Text(" movies"),
                  ],
                ),
              ),
            ],
          ),
          SectionSegmentedWidgetList(
            title: "Backup",
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
                subtitle: Text("Last backup: $lastBackupDate"),
                trailing: UtilsFunctions.isLastBackupDateMoreThan30Days(lastBackupDate)
                    ? Icon(
                        Icons.error_outline_outlined,
                        color: context.colors.error,
                      )
                    : null,
              ),
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
          SectionSegmentedWidgetList(
            title: "About",
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
        ],
      ),
    );
  }
}
