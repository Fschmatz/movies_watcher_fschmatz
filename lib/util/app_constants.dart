class AppConstants {
  // WIDGETS
  static const Duration movieListAnimationDuration = Duration(milliseconds: 1000);

  // APP PARAMETERS
  static const String showRuntimeChipOnCardAppParameter = "showRuntimeChipOnCard";
  static const String showMovieNameOnCardAppParameter = "showMovieNameOnCard";
  static const String lastBackupDateAppParameter = "lastBackupDate";

  // STRINGS
  static const String backupFileName = "movies_watcher_backup";
  static const String appVersion = "1.9.0";
  static const String appName = "Movies Watcher Fschmatz";
  static const String appNameHomePage = "Watchlist";
  static const String repositoryLink = "https://github.com/Fschmatz/movies_watcher_fschmatz";
  static const String apiHomePage = "https://www.omdbapi.com/";
  static const String apiUrl = "http://www.omdbapi.com/?type=movie";

  static String changelogCurrent = '''
$appVersion
- Bug fixes
- UI changes
''';

  static String changelogsOld = '''
1.8.1
- Add app parameters
- Show/hide movie name 
- Bug fixes
- Logic changes
- UI changes

1.7.4
- Bug fixes
- UI changes
- Update Flutter 3.38

1.6.5  
- Async Redux
- Bug fixes
- UI changes  
  
1.5.0  
- UI changes
- Update Flutter 3.32
- Themed icon
- Bug fixes

1.4.4
- New cards for home
- Year total on stats page
- UI changes on stats page
- Logic changes
- Bug fixes

1.3.13
- Added menus with checkmark
- Filter by year for watched
- Stats page changes
- Use color from poster on the dialog
- Select custom poster
- Page dropdown for search
- UI changes
- Added alert when adding duplicates
- Bug fixes
  
1.2.2
- UI changes
- Added sort options
- Bug fixes
- Logic changes

1.1.3
- UI changes
- Bug fixes
- Flutter 3.19

1.0.1
- Technically usable
- Movie info dialog
- Create backup
- Restore from backup
- Bug fixes

0.9.1
- Edit page
- UI changes
- Bug fixes

0.8.0
- Add movie by IMDb ID
- UI changes
- Print movies list
- Statistics page prototype
- Bug fixes

0.7.0
- Search page
- Bug fixes

0.6.0
- Load home for watched and not watched
- Initial statistics page
- Delete movie
- Bottom menu
- Share movie
- Bug fixes

0.5.0
- Save movie
- Load home

0.4.0
- Load data from API
- Created new page  
- Code changes
  
0.3.0
- DB
- Added API
- Various logic changes

0.2.0
- Home

0.1.0
- Project start
''';
}
