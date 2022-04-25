import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';


//State
@immutable
abstract class ChangePasswordState {}

class ChangePasswordInitial extends ChangePasswordState {}
class ChangePassword extends ChangePasswordState {
  //to reset password
  String? userId, oldPassword, newPassword;

  ChangePassword({this.userId, this.oldPassword, this.newPassword});
}
class ChangePasswordProgress extends ChangePasswordState {
  ChangePasswordProgress();
}

class ChangePasswordSuccess extends ChangePasswordState {
  String? userId, oldPassword, newPassword;
  ChangePasswordSuccess(this.userId, this.oldPassword, this.newPassword);
}

class ChangePasswordFailure extends ChangePasswordState {
  final String errorMessage;
  ChangePasswordFailure(this.errorMessage);
}

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final AuthRepository _authRepository;
  ChangePasswordCubit(this._authRepository) : super(ChangePasswordInitial());

  //to changePassword user
  void changePassword({
      String? userId,
      String? oldPassword,
      String? newPassword,}) {
    //emitting changePasswordProgress state
    emit(ChangePasswordProgress());
    //changePassword user with given provider and also change password user in api
    _authRepository
        .changePassword(
        userId: userId,
        oldPassword: oldPassword,
        newPassword: newPassword,
    )
        .then((result) {
      //success
      emit(ChangePasswordSuccess(userId, oldPassword, newPassword));
    }).catchError((e) {
      //failure
      emit(ChangePasswordFailure(e.toString()));
    });
  }

}
