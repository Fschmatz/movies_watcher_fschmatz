import 'package:jiffy/jiffy.dart';
import 'package:movies_watcher_fschmatz/redux/actions.dart';
import '../dao/app_parameter_dao.dart';
import '../entity/app_parameter.dart';
import '../main.dart';
import 'store_service.dart';

class AppParameterService extends StoreService {
  final dbParams = AppParameterDAO.instance;

  Future<void> saveParameter(AppParameter parameter) async {
    await dbParams.insertOrUpdate(parameter.toMap());
    await loadAppParameters();
  }

  Future<void> deleteParameter(String key) async {
    await dbParams.delete(key);
    await loadAppParameters();
  }

  Future<List<AppParameter>> getAll() async {
    var resp = await dbParams.queryAllRows();
    
    return resp.isNotEmpty
        ? resp.map((map) => AppParameter.fromMap(map)).toList()
        : [];
  }

  Future<void> saveLastBackupDate() async {
    await saveParameter(AppParameter(
      key: 'lastBackupDate',
      value: Jiffy.now().format(pattern: 'dd/MM/yyyy HH:mm'),
    ));
  }

  Future<String?> getLastBackupDate() async {
    var resp = await dbParams.queryByKey('lastBackupDate');
    return resp != null ? AppParameter.fromMap(resp).getValue() : null;
  }

  Future<List<Map<String, dynamic>>> loadAllParameters() {
    return dbParams.queryAllRows();
  }

  Future<void> deleteAllParameters() async {
    await dbParams.deleteAll();
  }

  Future<void> insertParametersFromRestoreBackup(List<dynamic> jsonData) async {
    for (var item in jsonData) {
      await dbParams.insertOrUpdate(item as Map<String, dynamic>);
    }
    await loadAppParameters();
  }
}
