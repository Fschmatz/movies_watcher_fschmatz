class AppDetails {
  static final String appVersion = "1.6.3";
  static final String appName = "Movies Watcher Fschmatz";
  static final String appNameHomePage = "Watchlist";
  static final String backupFileName = "movies_watcher_backup";
  static final String repositoryLink = "https://github.com/Fschmatz/movies_watcher_fschmatz";

  static String changelogCurrent = '''
$appVersion
- Async Redux
- Bug fixes
- UI changes
''';

  static String changelogsOld = '''
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
