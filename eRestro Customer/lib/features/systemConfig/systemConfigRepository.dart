import 'package:erestro/features/systemConfig/settingModel.dart';
import 'package:erestro/features/systemConfig/systemConfigRemoteDataSource.dart';
import 'package:erestro/features/systemConfig/systemCongifException.dart';

class SystemConfigRepository {
  static final SystemConfigRepository _systemConfigRepository = SystemConfigRepository._internal();
  late SystemConfigRemoteDataSource _systemConfigRemoteDataSource;

  factory SystemConfigRepository() {
    _systemConfigRepository._systemConfigRemoteDataSource = SystemConfigRemoteDataSource();
    return _systemConfigRepository;
  }

  SystemConfigRepository._internal();

  Future<SettingModel> getSystemConfig(String? userId) async {
    try {
      SettingModel result = await _systemConfigRemoteDataSource.getSystemConfing(userId);
      //print(result);
      return result;
    } catch (e) {
      print(e.toString());
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final result = await _systemConfigRemoteDataSource.getAppSettings(type);
      return result;
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

}
