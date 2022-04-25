import 'package:erestro/features/settings/settingsLocalDataSource.dart';

class SettingsRepository {
  static final SettingsRepository _settingsRepository = SettingsRepository._internal();
  late SettingsLocalDataSource _settingsLocalDataSource;

  factory SettingsRepository() {
    _settingsRepository._settingsLocalDataSource = SettingsLocalDataSource();
    return _settingsRepository;
  }

  SettingsRepository._internal();

  Map<String, dynamic> getCurrentSettings() {
    return {
      "showIntroSlider": _settingsLocalDataSource.showIntroSlider(),
      "notification": _settingsLocalDataSource.notification(),
    };
  }

  void changeIntroSlider(bool value) => _settingsLocalDataSource.setShowIntroSlider(value);

  void changeNotification(bool value) => _settingsLocalDataSource.setNotification(value);

}
