import 'dart:convert';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:movies_watcher_fschmatz/service/app_parameter_service.dart';
import 'package:movies_watcher_fschmatz/service/movie_service.dart';
import 'package:permission_handler/permission_handler.dart';

class BackupUtils {
  /* PER APP SPECIFIC FUNCTIONS */

  Future<List<Map<String, dynamic>>> _loadAllMovies() async {
    return MovieService().loadAllMovies();
  }

  Future<void> _deleteAllMovies() async {
    await MovieService().deleteAllMovies();
  }

  Future<void> _insertMovies(List<dynamic> jsonData) async {
    await MovieService().insertMoviesFromRestoreBackup(jsonData);
  }

  Future<List<Map<String, dynamic>>> _loadAllParameters() async {
    return AppParameterService().loadAllParameters();
  }

  Future<void> _deleteAllParameters() async {
    await AppParameterService().deleteAllParameters();
  }

  Future<void> _insertParameters(List<dynamic> jsonData) async {
    await AppParameterService().insertParametersFromRestoreBackup(jsonData);
  }

  /* END PER APP SPECIFIC FUNCTIONS */

  Future<void> _loadStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;

    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  // Always using Android Download folder
  Future<String> _loadDirectory() async {
    bool dirDownloadExists = true;
    String directory = "/storage/emulated/0/Download/";

    dirDownloadExists = await Directory(directory).exists();
    if (dirDownloadExists) {
      directory = "/storage/emulated/0/Download/";
    } else {
      directory = "/storage/emulated/0/Downloads/";
    }

    return directory;
  }

  Future<void> backupData(String fileName) async {
    await _loadStoragePermission();
    await AppParameterService().saveLastBackupDate();

    List<Map<String, dynamic>> moviesList = await _loadAllMovies();
    List<Map<String, dynamic>> parametersList = await _loadAllParameters();

    if (moviesList.isNotEmpty) {
      Map<String, dynamic> combinedData = {
        'movies': moviesList,
        'parameters': parametersList,
      };

      await _saveDataAsJson(combinedData, fileName);

      Fluttertoast.showToast(
        msg: "Backup completed!",
      );
    } else {
      Fluttertoast.showToast(
        msg: "No data found!",
      );
    }
  }

  Future<void> _saveDataAsJson(Map<String, dynamic> data, String fileName) async {
    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');

      await file.writeAsString(json.encode(data));
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error!",
      );
    }
  }

  Future<void> restoreBackupData(String fileName) async {
    await _loadStoragePermission();

    try {
      String directory = await _loadDirectory();

      final file = File('$directory/$fileName.json');
      final jsonString = await file.readAsString();
      final dynamic decodedJson = json.decode(jsonString);

      if (decodedJson is List) {
        // Backup Antigo
        await _deleteAllMovies();
        await _insertMovies(decodedJson);
      } else if (decodedJson is Map<String, dynamic>) {
        // Backup Novo
        if (decodedJson.containsKey('movies')) {
          await _deleteAllMovies();
          await _insertMovies(decodedJson['movies']);
        }

        if (decodedJson.containsKey('parameters')) {
          await _deleteAllParameters();
          await _insertParameters(decodedJson['parameters']);
        }
      }

      Fluttertoast.showToast(
        msg: "Success!",
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error!",
      );
    }
  }
}
