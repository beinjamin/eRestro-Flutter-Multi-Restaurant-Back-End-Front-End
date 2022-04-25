//State
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/settings/settingsModel.dart';
import 'package:erestro/features/settings/settingsRepository.dart';

class SettingsState {
  final SettingsModel? settingsModel;
  SettingsState({this.settingsModel});
}

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _settingsRepository;
  SettingsCubit(this._settingsRepository) : super(SettingsState()) {
    _getCurrentSettings();
  }

  void _getCurrentSettings() {
    emit(SettingsState(settingsModel: SettingsModel.fromJson(_settingsRepository.getCurrentSettings())));
  }

  SettingsModel getSettings() {
    return state.settingsModel!;
  }

  void changeShowIntroSlider() {
    _settingsRepository.changeIntroSlider(false);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(showIntroSlider: false)));
  }

  void changeNotification(bool value) {
    _settingsRepository.changeNotification(value);
    emit(SettingsState(settingsModel: state.settingsModel!.copyWith(notification: value)));
  }
}
