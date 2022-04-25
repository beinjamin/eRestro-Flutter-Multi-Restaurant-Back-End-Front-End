import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';


//State
@immutable
abstract class UpdateFcmIdState {}

class UpdateFcmIdInitial extends UpdateFcmIdState {}
class UpdateFcmId extends UpdateFcmIdState {
  //to update fcmId
  String? userId, fcmId;

  UpdateFcmId({this.userId, this.fcmId});
}
class UpdateFcmIdProgress extends UpdateFcmIdState {
  UpdateFcmIdProgress();
}

class UpdateFcmIdSuccess extends UpdateFcmIdState {
  UpdateFcmIdSuccess();
}

class UpdateFcmIdFailure extends UpdateFcmIdState {
  final String errorMessage;
  UpdateFcmIdFailure(this.errorMessage);
}

class UpdateFcmIdCubit extends Cubit<UpdateFcmIdState> {
  final AuthRepository _authRepository;
  UpdateFcmIdCubit(this._authRepository) : super(UpdateFcmIdInitial());

  //to update fcmId
  void updateFcmId({
    String? userId,
    String? fcmId,}) {
    //emitting updateFcmIdProgress state
    emit(UpdateFcmIdProgress());
    //update fcmId of user with given provider and also update user fcmId in api
    _authRepository
        .updateFcmId(
      userId: userId,
      fcmId: fcmId,
    )
        .then((result) {
      //success
      emit(UpdateFcmIdSuccess());
    }).catchError((e) {
      //failure
      emit(UpdateFcmIdFailure(e.toString()));
    });
  }

}
