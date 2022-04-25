import 'package:erestro/utils/constants.dart';
import 'package:hive/hive.dart';

class SettingsLocalDataSource {
  bool? showIntroSlider() {
    return Hive.box(settingsBox).get(showIntroSliderKey, defaultValue: true);
  }

  Future<void> setShowIntroSlider(bool value) async {
    Hive.box(settingsBox).put(showIntroSliderKey, value);
  }

  bool? notification() {
    return Hive.box(settingsBox).get(soundKey, defaultValue: true);
  }

  Future<void> setNotification(bool value) async {
    Hive.box(settingsBox).put(soundKey, value);
  }
}
