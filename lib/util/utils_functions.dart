import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:movies_watcher_fschmatz/util/app_constants.dart';
import 'package:movies_watcher_fschmatz/util/utils_string.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilsFunctions {
  static void openGithubRepository() {
    launchBrowser(AppConstants.repositoryLink);
  }

  static void launchBrowser(String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  static String getThemeStringFormatted(ThemeMode? currentTheme) {
    String theme = currentTheme.toString().replaceAll('ThemeMode.', '');

    if (theme == 'system') {
      theme = 'system default';
    }

    return UtilsString.capitalizeFirstLetterString(theme);
  }

  static String getBackupFilename() {
    String name = AppConstants.backupFileName;
    String dateTimeStr = Jiffy.now().format(pattern: 'dd_MM_yyyy_HHmmss');

    return '${name}_$dateTimeStr.json';
  }

  static String formatRuntime(int runtime, bool format) {
    if (!format) {
      return "${runtime}m";
    }

    final int hours = runtime ~/ 60;
    final int minutes = runtime % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
    }

    return '${minutes}m';
  }
}
