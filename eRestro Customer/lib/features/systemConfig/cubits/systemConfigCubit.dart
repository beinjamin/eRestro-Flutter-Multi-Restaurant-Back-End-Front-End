//State
import 'package:erestro/features/systemConfig/settingModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/systemConfig/systemConfigRepository.dart';

abstract class SystemConfigState {}

class SystemConfigIntial extends SystemConfigState {}

class SystemConfigFetchInProgress extends SystemConfigState {}

class SystemConfigFetchSuccess extends SystemConfigState {
  final SettingModel systemConfigModel;

  SystemConfigFetchSuccess({required this.systemConfigModel});
}

class SystemConfigFetchFailure extends SystemConfigState {
  final String errorCode;

  SystemConfigFetchFailure(this.errorCode);
}

class SystemConfigCubit extends Cubit<SystemConfigState> {
  final SystemConfigRepository _systemConfigRepository;
  SystemConfigCubit(this._systemConfigRepository) : super(SystemConfigIntial());

/*  void getSystemConfig() async {
    emit(SystemConfigFetchInProgress());
    try {
      final systemConfig = await _systemConfigRepository.getSystemConfig();
      print(systemConfig)
      emit(SystemConfigFetchSuccess(
        systemConfigModel: systemConfig,
      ));
      print(systemConfig.toString());
    } catch (e) {
      print("Hello Error"+e.toString());
      emit(SystemConfigFetchFailure(e.toString()));
    }
  }*/

  //to getCart user
  void getSystemConfig(
    String? userId
  ) {
    //emitting GetCartProgress state
    emit(SystemConfigFetchInProgress());
    //GetCart user with given provider and also add user detials in api
    _systemConfigRepository
        .getSystemConfig(userId).then((value) => emit(SystemConfigFetchSuccess(systemConfigModel: value))).catchError((e) {
      emit(SystemConfigFetchFailure(e.toString()));
    });
  }

  String getCurrency() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.currency![0];
    }
    return "";
  }

  String getMobile() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.userData![0].mobile!;
    }
    return "";
  }

  String getEmail() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.userData![0].email!;
    }
    return "";
  }

  String getName() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.userData![0].username!;
    }
    return "";
  }

  String getWallet() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.userData![0].balance!;
    }
    return "";
  }

  String getReferCode() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.userData![0].referralCode!;
    }
    return "";
  }

  String getIsReferEarnOn() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isReferEarnOn!;
    }
    return "";
  }

  String getCurrentVersionAndroid() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].currentVersion!;
    }
    return "";
  }

  String getCurrentVersionIos() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].currentVersionIos!;
    }
    return "";
  }

  String getReferEarnOn() {
    //print("Status:"+(state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isReferEarnOn!.toString());
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isReferEarnOn!;
    }
    return "";
  }

  String isForceUpdateEnable() {
    if (state is SystemConfigFetchSuccess) {
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isVersionSystemOn!;
    }
    return "";
  }

  String isAppMaintenance() {
    if (state is SystemConfigFetchSuccess) {
      //print("Main:"+(state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isAppMaintenanceModeOn!);
      return (state as SystemConfigFetchSuccess).systemConfigModel.systemSettings![0].isAppMaintenanceModeOn!;
    }
    return "";
  }
}
