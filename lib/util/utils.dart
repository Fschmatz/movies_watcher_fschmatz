import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_details.dart';

class Utils {
  void openGithubRepository() {
    launchBrowser(AppDetails.repositoryLink);
  }

  void openApiPage() {
    launchBrowser("https://www.omdbapi.com/");
  }

  void launchBrowser(String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  Color lightenColor(Color c, [int percent = 10]) {
    assert(1 <= percent && percent <= 100);
    var p = percent / 100;
    return Color.fromARGB(
        c.alpha, c.red + ((255 - c.red) * p).round(), c.green + ((255 - c.green) * p).round(), c.blue + ((255 - c.blue) * p).round());
  }

  String getThemeStringFormatted(ThemeMode? currentTheme) {
    String theme = currentTheme.toString().replaceAll('ThemeMode.', '');
    if (theme == 'system') {
      theme = 'system default';
    }
    return theme.replaceFirst(theme[0], theme[0].toUpperCase());
  }
}
