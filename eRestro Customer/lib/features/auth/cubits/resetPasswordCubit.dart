import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';


//State
@immutable
abstract class ResetPasswordState {}

class ResetPasswordInitial extends ResetPasswordState {}
class ResetPassword extends ResetPasswordState {
  //to reset password
  String? mobile, password;

  ResetPassword({this.mobile, this.password});
}
class ResetPasswordProgress extends ResetPasswordState {
  ResetPasswordProgress();
}

class ResetPasswordSuccess extends ResetPasswordState {
  String? mobile, password;
  ResetPasswordSuccess(this.mobile, this.password);
}

class ResetPasswordFailure extends ResetPasswordState {
  final String errorMessage;
  ResetPasswordFailure(this.errorMessage);
}

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  final AuthRepository _authRepository;
  ResetPasswordCubit(this._authRepository) : super(ResetPasswordInitial());

  //to resetPassword user
  void resetPassword({
      String? mobile,
      String? password,}) {
    //emitting resetPasswordProgress state
    emit(ResetPasswordProgress());
    //resetPassword user with given provider and also reset password user in api
    _authRepository
        .resetPassword(
        mobile: mobile,
        password: password,
    )
        .then((result) {
      //success
      emit(ResetPasswordSuccess(mobile, password));
    }).catchError((e) {
      //failure
      print(e.toString());
      emit(ResetPasswordFailure(e.toString()));
    });
  }

}
