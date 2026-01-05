import 'package:flutter/material.dart';
import 'package:movies_watcher_fschmatz/util/utils_string.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_details.dart';

class UtilsFunctions {
  static void openGithubRepository() {
    launchBrowser(AppDetails.repositoryLink);
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
}
