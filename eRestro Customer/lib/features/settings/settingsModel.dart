class SettingsModel {
  final bool showIntroSlider;
  final bool notification;

  SettingsModel({required this.notification, required this.showIntroSlider});

  static SettingsModel fromJson(var settingsJson) {
    //to see the json response go to getCurrentSettings() function in settingsRepository
    return SettingsModel(
        notification: settingsJson['notification'],
        showIntroSlider: settingsJson['showIntroSlider'],);
  }

  SettingsModel copyWith({bool? showIntroSlider, bool? notification}) {
    return SettingsModel(
        notification: notification ?? this.notification,
        showIntroSlider: showIntroSlider ?? this.showIntroSlider,);
  }
}
