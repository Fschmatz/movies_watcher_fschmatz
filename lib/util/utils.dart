import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_details.dart';

class Utils {

  openGithubRepository() {
    launchBrowser(AppDetails.repositoryLink);
  }

  openApiPage() {
    launchBrowser("https://www.omdbapi.com/");
  }

  launchBrowser(String url) {
    launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }



  String getThemeStringFormatted(ThemeMode? currentTheme) {
    String theme = currentTheme.toString().replaceAll('ThemeMode.', '');
    if (theme == 'system') {
      theme = 'system default';
    }
    return theme.replaceFirst(theme[0], theme[0].toUpperCase());
  }

}