import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:movies_watcher_fschmatz/service/app_parameter_service.dart';
import 'package:movies_watcher_fschmatz/service/movie_service.dart';
import 'package:movies_watcher_fschmatz/util/toast_utils.dart';
import 'package:movies_watcher_fschmatz/util/utils_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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

  Future<void> backupData() async {
    await AppParameterService().saveLastBackupDate();

    List<Map<String, dynamic>> moviesList = await _loadAllMovies();
    List<Map<String, dynamic>> parametersList = await _loadAllParameters();

    if (moviesList.isNotEmpty) {
      Map<String, dynamic> combinedData = {
        'movies': moviesList,
        'parameters': parametersList,
      };

      await _saveDataAsJsonAndShare(combinedData);

      ToastUtils.show(
        "Backup completed!",
      );
    } else {
      ToastUtils.showErrorMessage(
        "No data found!",
      );
    }
  }

  Future<void> _saveDataAsJsonAndShare(Map<String, dynamic> data) async {
    try {
      final directory = await getTemporaryDirectory();
      final newFileName = UtilsFunctions.getBackupFilename();

      final file = File('${directory.path}/$newFileName');

      await file.writeAsString(json.encode(data));

      await Share.shareXFiles([XFile(file.path)], text: 'Backup $newFileName');
    } catch (e) {
      ToastUtils.showErrorMessage(
        "Error!",
      );
    }
  }

  Future<void> restoreBackupData() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final dynamic decodedJson = json.decode(jsonString);

        if (decodedJson.containsKey('movies')) {
          await _deleteAllMovies();
          await _insertMovies(decodedJson['movies']);
        }

        if (decodedJson.containsKey('parameters')) {
          await _deleteAllParameters();
          await _insertParameters(decodedJson['parameters']);
        }

        ToastUtils.show(
          "Success!",
        );
      }
    } catch (e) {
      ToastUtils.showErrorMessage(
        "Error!",
      );
    }
  }
}
