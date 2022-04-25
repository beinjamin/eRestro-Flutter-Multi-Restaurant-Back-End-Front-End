import 'package:erestro/features/profileManagement/profileManagementException.dart';
import 'package:erestro/features/profileManagement/profileManagementLocalDataSource.dart';
import 'package:erestro/features/profileManagement/profileManagementRemoteDataSource.dart';
import 'dart:io';

import 'models/userProfile.dart';

class ProfileManagementRepository {
  static final ProfileManagementRepository _profileManagementRepository = ProfileManagementRepository._internal();
  late ProfileManagementLocalDataSource _profileManagementLocalDataSource;
  late ProfileManagementRemoteDataSource _profileManagementRemoteDataSource;

  factory ProfileManagementRepository() {
    _profileManagementRepository._profileManagementLocalDataSource = ProfileManagementLocalDataSource();
    _profileManagementRepository._profileManagementRemoteDataSource = ProfileManagementRemoteDataSource();

    return _profileManagementRepository;
  }

  ProfileManagementRepository._internal();

  ProfileManagementLocalDataSource get profileManagementLocalDataSource => _profileManagementLocalDataSource;

  Future<void> setUserDetailsLocally(UserProfile userProfile) async {
    await profileManagementLocalDataSource.setUserUId(userProfile.userId!);
    await profileManagementLocalDataSource.setCoins(userProfile.coins!);
    await profileManagementLocalDataSource.serProfilrUrl(userProfile.profileUrl!);
    await profileManagementLocalDataSource.setEmail(userProfile.email!);
    await profileManagementLocalDataSource.setFirebaseId(userProfile.firebaseId!);
    await profileManagementLocalDataSource.setName(userProfile.name!);
    await profileManagementLocalDataSource.setRank(userProfile.allTimeRank!);
    await profileManagementLocalDataSource.setScore(userProfile.allTimeScore!);
    await profileManagementLocalDataSource.setMobileNumber(userProfile.mobileNumber!);
    await profileManagementLocalDataSource.setFCMToken(userProfile.fcmToken!);
    await profileManagementLocalDataSource.setReferCode(userProfile.referCode!);
  }

  Future<UserProfile> getUserDetails() async {
    try {
      return UserProfile(
        fcmToken: _profileManagementLocalDataSource.getFCMToken(),
        referCode: _profileManagementLocalDataSource.getReferCode(),
        allTimeRank: _profileManagementLocalDataSource.getRank(),
        allTimeScore: _profileManagementLocalDataSource.getScore(),
        coins: _profileManagementLocalDataSource.getCoins(),
        email: _profileManagementLocalDataSource.getEmail(),
        firebaseId: _profileManagementLocalDataSource.getFirebaseId(),
        mobileNumber: _profileManagementLocalDataSource.getMobileNumber(),
        name: _profileManagementLocalDataSource.getName(),
        profileUrl: _profileManagementLocalDataSource.getProfileUrl(),
        registeredDate: "",
        status: _profileManagementLocalDataSource.getStatus(),
        userId: _profileManagementLocalDataSource.getUserUID(),
      );
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

/*  Future<UserProfile> getUserDetailsById(String firebaseId) async {
    try {
      final result = await _profileManagementRemoteDataSource.getUserDetailsById(firebaseId);

      return UserProfile.fromJson(result);
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }*/

  Future<String> uploadProfilePicture(File? file, String? userId) async {
    try {
      final result = await _profileManagementRemoteDataSource.addProfileImage(file, userId);
      return result['image'].toString();
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  //update profile method in remote data source
  Future<void> updateProfile({String? userId, String? email, String? name, String? mobile, String? referralCode}) async {
    try {
      await _profileManagementRemoteDataSource.updateProfile(userId: userId, email: email, name: name, mobile: mobile, referralCode: referralCode);
    } catch (e) {
      print(e.toString());
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }
}
