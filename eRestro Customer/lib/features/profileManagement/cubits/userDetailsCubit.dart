import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/profileManagement/models/userProfile.dart';
import 'package:erestro/features/profileManagement/profileManagementRepository.dart';

@immutable
abstract class UserDetailsState {}

class UserDetailsInitial extends UserDetailsState {}

class UserDetailsFetchInProgress extends UserDetailsState {}

class UserDetailsFetchSuccess extends UserDetailsState {
  final UserProfile userProfile;
  UserDetailsFetchSuccess(this.userProfile);
}

class UserDetailsFetchFailure extends UserDetailsState {
  final String errorMessage;
  UserDetailsFetchFailure(this.errorMessage);
}

class UserDetailsCubit extends Cubit<UserDetailsState> {
  final ProfileManagementRepository _profileManagementRepository;
  UserDetailsCubit(this._profileManagementRepository) : super(UserDetailsInitial());

/*  //to fetch user details form remote
  void fetchUserDetails(String firebaseId) async {
    emit(UserDetailsFetchInProgress());

    try {
      UserProfile userProfile = await _profileManagementRepository.getUserDetailsById(firebaseId);
      await _profileManagementRepository.setUserDetailsLocally(userProfile);
      emit(UserDetailsFetchSuccess(userProfile));
    } catch (e) {
      emit(UserDetailsFetchFailure(e.toString()));
    }
  }*/

  //load userdetials from hive box
  Future<void> loadUserDetailsLocally() async {
    try {
      UserProfile userProfile = await _profileManagementRepository.getUserDetails();

      emit(UserDetailsFetchSuccess(userProfile));
    } catch (e) {
      emit(UserDetailsFetchFailure(e.toString()));
    }
  }

  String? getUserName() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile.name;
    }
    return "";
  }

  String getUserId() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile.userId!;
    }
    return "";
  }

  String? getUserMobile() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile.mobileNumber;
    }
    return "";
  }

  String? getUserEmail() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile.email;
    }
    return "";
  }

  void updateUserProfileUrl(String profileUrl) {
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;
      _profileManagementRepository.profileManagementLocalDataSource.serProfilrUrl(profileUrl);

      emit((UserDetailsFetchSuccess(oldUserDetails.copyWith(profileUrl: profileUrl))));
    }
  }

  void updateUserProfile({String? profileUrl, String? name, String? allTimeRank, String? allTimeScore, String? coins, String? status, String? mobile, String? email}) {
    //
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;
      final userDetails = oldUserDetails.copyWith(
        email: email,
        mobile: mobile,
        coins: coins,
        allTimeRank: allTimeRank,
        allTimeScore: allTimeScore,
        name: name,
        profileUrl: profileUrl,
        status: status,
      );
      _profileManagementRepository.setUserDetailsLocally(userDetails);

      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  //update only coins (this will be call only when updating coins after using lifeline )
  void updateCoins({int? coins, bool? addCoin}) {
    //
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;

      final currentCoins = int.parse(oldUserDetails.coins!);
      print("Coins : $currentCoins");
      final updatedCoins = addCoin! ? (currentCoins + coins!) : (currentCoins - coins!);
      print("Coins update ......" + updatedCoins.toString());
      final userDetails = oldUserDetails.copyWith(
        coins: updatedCoins.toString(),
      );
      _profileManagementRepository.profileManagementLocalDataSource.setCoins(userDetails.coins!);
      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  //update score
  void updateScore(int? score) {
    //
    if (state is UserDetailsFetchSuccess) {
      final oldUserDetails = (state as UserDetailsFetchSuccess).userProfile;
      final currentScore = int.parse(oldUserDetails.allTimeScore!);
      final userDetails = oldUserDetails.copyWith(
        allTimeScore: (currentScore + score!).toString(),
      );
      _profileManagementRepository.profileManagementLocalDataSource.setScore(userDetails.allTimeScore!);
      emit((UserDetailsFetchSuccess(userDetails)));
    }
  }

  String? getCoins() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile.coins;
    }
    return "";
  }

  UserProfile getUserProfile() {
    if (state is UserDetailsFetchSuccess) {
      return (state as UserDetailsFetchSuccess).userProfile;
    }
    return UserProfile();
  }
}
