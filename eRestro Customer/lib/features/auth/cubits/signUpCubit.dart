import 'package:erestro/features/auth/authModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';


//State
@immutable
abstract class SignUpState {}

class SignUpInitial extends SignUpState {}
class SignUp extends SignUpState {
  //to store authDetials
  final AuthModel authModel;

  SignUp({required this.authModel});
}
class SignUpProgress extends SignUpState {
  SignUpProgress();
}

class SignUpSuccess extends SignUpState {
  final AuthModel authModel;

  SignUpSuccess({required this.authModel});
}

class SignUpFailure extends SignUpState {
  final String errorMessage;
  SignUpFailure(this.errorMessage);
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;
  SignUpCubit(this._authRepository) : super(SignUpInitial());

  //to signIn user
  void signUpUser({
      String? name,
      String? email,
      String? mobile,
      String? countryCode,
      String? password,
      String? fcmId,
      String? friendCode,
      //String? latitude,
      //String? longitude
  }) {
    //emitting signInProgress state
  //  emit(SignInProgress(authProvider));
    //signIn user with given provider and also add user detials in api
    _authRepository
        .addUserData(
        name: name,
        email: email,
        mobile: mobile,
        countryCode: countryCode ?? "",
        password: password,
        fcmId: fcmId ?? "",
        friendCode: friendCode ?? "",
        //latitude: latitude ?? "",
        //longitude: longitude ?? ""
    )
        .then((result) {
      //success
      emit(SignUpSuccess(authModel: AuthModel.fromJson(result)));
    }).catchError((e) {
      //failure
      emit(SignUpFailure(e.toString()));
    });
  }

}
