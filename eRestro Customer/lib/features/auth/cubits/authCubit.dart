import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authModel.dart';
import 'package:erestro/features/auth/authRepository.dart';

//authentication provider
//enum AuthProvider { gmail, fb, email, mobile, apple }

//State
@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class Authenticated extends AuthState {
  //to store authDetials
  final AuthModel authModel;

  Authenticated({required this.authModel});
}

class Unauthenticated extends AuthState {}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  AuthCubit(this._authRepository) : super(AuthInitial()) {
    checkAuthStatus();
  }

  AuthRepository get authRepository => _authRepository;
  void checkAuthStatus() {
    //authDetails is map. keys are isLogin,userId,authProvider,jwtToken
    final authDetails = _authRepository.getLocalAuthDetails();

    if (authDetails['isLogin']) {
      emit(Authenticated(authModel: AuthModel.fromJson(authDetails)));
    } else {
      emit(Unauthenticated());
    }
  }

  void statusUpdateAuth(AuthModel authModel){
    emit(Authenticated(authModel: authModel));
  }

  bool logInStatus(){
    if(state is Authenticated) {
      return true;
    } else {
      return false;
    }
  }

  String getId() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.id!;
    }
    return "";
  }

  String getName() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.username!;
    }
    return "";
  }

  String getEmail() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.email!;
    }
    return "";
  }

  String getProfile() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.image!;
    }
    return "";
  }

  String getMobile() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.mobile!;
    }
    return "";
  }

  String getCountryCode() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.countryCode!;
    }
    return "";
  }

  String getAddress() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.address!;
    }
    return "";
  }

  String getLatitude() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.latitude!;
    }
    return "";
  }

  String getLongitude() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.longitude!;
    }
    return "";
  }

  String getReferralCode() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.referralCode!;
    }
    return "";
  }

  String getActive() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.active!;
    }
    return "";
  }

  void updateUserProfileUrl(String profileUrl) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setImage(profileUrl);

      emit((Authenticated(authModel: oldUserDetails.copyWith(image: profileUrl))));
  }

  void updateDetails({required AuthModel authModel}) {
    emit(Authenticated(authModel: authModel));
  }

  void updateUserId(String id) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setId(id);
      emit((Authenticated(authModel: oldUserDetails.copyWith(id: id))));
  }

  void updateUserName(String name) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setName(name);

      emit((Authenticated(authModel: oldUserDetails.copyWith(name: name))));
  }

  void updateUserEmail(String email) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setEmail(email);

      emit((Authenticated(authModel: oldUserDetails.copyWith(email: email))));
  }

  void updateUserAddress(String address) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setAddress(address);

      emit((Authenticated(authModel: oldUserDetails.copyWith(address: address))));
  }

  void updateUserLatitude(String latitude) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setLatitude(latitude);

      emit((Authenticated(authModel: oldUserDetails.copyWith(latitude: latitude))));
  }

  void updateUserLongitude(String longitude) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setLongitude(longitude);

      emit((Authenticated(authModel: oldUserDetails.copyWith(latitude: longitude))));
  }

  void updateUserReferralCode(String referralCode) {
      final oldUserDetails = (state as Authenticated).authModel;
      _authRepository.authLocalDataSource.setReferralCode(referralCode);

      emit((Authenticated(authModel: oldUserDetails.copyWith(referralCode: referralCode))));
  }

/*  bool getIsNewUser() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.isNewUser;
    }
    return false;
  }

  AuthProvider getAuthProvider() {
    if (state is Authenticated) {
      return (state as Authenticated).authModel.authProvider;
    }
    return AuthProvider.email;
  }*/

  //to update auth status
  void updateAuthDetails({String? id, String? ipAddress, String? name, String? email,
    String? mobile, String? image, String? balance, String? rating, String? noOfRatings, String? activationSelector, String? activationCode,
    String? forgottenPasswordSelector, String? forgottenPasswordCode, String? forgottenPasswordTime, String? rememberSelector,
    String? rememberCode, String? createdOn, String? lastLogin, String? active, String? company, String? address,
    String? bonus, String? dob, String? countryCode, String? city, String? area, String? street,
    String? pincode, String? serviceableCity, String? apikey, String? referralCode, String? friendsCode, String? fcmId,
    String? latitude, String? longitude, String? createdAt,}) {
    //updating authDetails locally
    _authRepository.setLocalAuthDetails(
      id : id,
      ipAddress : ipAddress,
      name : name,
      email : email,
      mobile : mobile,
      image : image,
      balance : balance,
      rating : rating,
      noOfRatings : noOfRatings,
      activationSelector : activationSelector,
      activationCode : activationCode,
      forgottenPasswordSelector : forgottenPasswordSelector,
      forgottenPasswordCode : forgottenPasswordCode,
      forgottenPasswordTime : forgottenPasswordTime,
      rememberSelector : rememberSelector,
      rememberCode : rememberCode,
      createdOn : createdOn,
      lastLogin : lastLogin,
      active : active,
      company : company,
      address : address,
      bonus : bonus,
      dob : dob,
      countryCode : countryCode,
      city : city,
      area : area,
      street : street,
      pincode : pincode,
      serviceableCity : serviceableCity,
      apikey : apikey,
      referralCode : referralCode,
      friendsCode : friendsCode,
      fcmId : fcmId,
      latitude : latitude,
      longitude : longitude,
      createdAt : createdAt,
    );

    //emitting new state in cubit
    emit(
      Authenticated(
        authModel: AuthModel(
        id : id ?? "",
        ipAddress : ipAddress ?? "",
        username : name ?? "",
        email : email ?? "",
        mobile : mobile ?? "",
        image : image ?? "",
        balance : balance ?? "",
        rating : rating ?? "",
        noOfRatings : noOfRatings ?? "",
        activationSelector : activationSelector ?? "",
        activationCode : activationCode ?? "",
        forgottenPasswordSelector : forgottenPasswordSelector ?? "",
        forgottenPasswordCode : forgottenPasswordCode ?? "",
        forgottenPasswordTime : forgottenPasswordTime ?? "",
        rememberSelector : rememberSelector ?? "",
        rememberCode : rememberCode ?? "",
        createdOn : createdOn ?? "",
        lastLogin : lastLogin ?? "",
        active : active ?? "",
        company : company ?? "",
        address : address ?? "",
        bonus : bonus ?? "",
        dob : dob ?? "",
        countryCode : countryCode ?? "",
        city : city ?? "",
        area : area ?? "",
        street : street ?? "",
        pincode : pincode ?? "",
        serviceableCity : serviceableCity ?? "",
        apikey : apikey ?? "",
        referralCode : referralCode ?? "",
        friendsCode : friendsCode ?? "",
        fcmId : fcmId ?? "",
        latitude : latitude ?? "",
        longitude : longitude ?? "",
        createdAt : createdAt ?? "",
          )),
    );
  }

  //to signout
  void signOut() {
    if (state is Authenticated) {
      _authRepository.signOut();
      emit(Unauthenticated());
      //print("signoutSucessfull");
    }
  }
}
