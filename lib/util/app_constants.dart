class AppConstants {
  // WIDGETS
  static const Duration movieListAnimationDuration = Duration(milliseconds: 1000);

  // APP PARAMETERS
  static const String showRuntimeChipOnCardAppParameter = "showRuntimeChipOnCard";
  static const String showMovieNameOnCardAppParameter = "showMovieNameOnCard";
  static const String formatRuntimeAppParameter = "formatRuntime";
  static const String lastBackupDateAppParameter = "lastBackupDate";
  static const String gridSizeAppParameter = "gridSize";

  // VARIOUS
  static const double posterBorderRadius = 20;
  static const List<int> gridSizeOptions = [2, 3, 4, 5];
  static const Map<int, double> mapRuntimeChipBottomWithoutName = {
    2: 8,
    3: 4,
    4: 6,
    5: 8,
  };
  static const Map<int, double> mapRuntimeChipRightWithoutName = {
    2: 8,
    3: 8,
    4: 6,
    5: 4,
  };
  static const Map<int, double> mapFavoriteChipIconSize = {
    2: 24,
    3: 20,
    4: 16,
    5: 14,
  };

  // BACKUP
  static const String backupFileName = "movies_watcher_backup";
  static const String backupDataFormat = "dd/MM/yyyy HH:mm";

  // STRINGS
  static const String appVersion = "2.2.1";
  static const String appName = "Movies Watcher Fschmatz";
  static const String appNameHomePage = "Watchlist";
  static const String repositoryLink = "https://github.com/Fschmatz/movies_watcher_fschmatz";

  static String changelogCurrent = '''
$appVersion
- Grid options
- Favorites for watchlist page
- Bug fixes
- UI changes
''';

  static String changelogsOld = '''
2.1.3
- Bug fixes
- Format runtime option
- UI changes 

2.0.7
- Use TMDB Api
- Show trending, now playing and upcoming
- Bug fixes
- New backup logic
- Database changes

1.9.3
- Bug fixes
- Sync movie on edit page
- UI changes
- Flutter 3.44

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
