import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:hive/hive.dart';

//AuthLocalDataSource will communicate with local database (hive)
class AuthLocalDataSource {
  bool? checkIsAuth() {
    return Hive.box(authBox).get(isLoginKey, defaultValue: false);
  }

  /*String? getJwt() {
    return Hive.box(authBox).get(jwtTokenKey, defaultValue: "");
  }

  String? getAuthType() {
    return Hive.box(authBox).get(authTypeKey, defaultValue: "");
  }

  String? getUserFirebaseId() {
    return Hive.box(authBox).get(firebaseIdBoxKey, defaultValue: "");
  }

  bool? getIsNewUser() {
    return Hive.box(authBox).get(isNewUserKey, defaultValue: false);
  }*/

  String? getId() {
    return Hive.box(authBox).get(idKey, defaultValue: "");
  }

  String? getName() {
    return Hive.box(authBox).get(nameKey, defaultValue: "");
  }

  String? getIpAddress() {
    return Hive.box(authBox).get(ipAddressKey, defaultValue: "");
  }

  String? getEmail() {
    return Hive.box(authBox).get(emailKey, defaultValue: "");
  }

  String? getMobile() {
    return Hive.box(authBox).get(mobileKey, defaultValue: "");
  }

  String? getImage() {
    return Hive.box(authBox).get(imageKey, defaultValue: "");
  }

  String? getBalance() {
    return Hive.box(authBox).get(balanceKey, defaultValue: "");
  }

  String? getRating() {
    return Hive.box(authBox).get(ratingKey, defaultValue: "");
  }

  String? getNoOfRatings() {
    return Hive.box(authBox).get(noOfRatingsKey, defaultValue: "");
  }

  String? getActivationSelector() {
    return Hive.box(authBox).get(activationSelectorKey, defaultValue: "");
  }

  String? getActivationCode() {
    return Hive.box(authBox).get(activationCodeKey, defaultValue: "");
  }

  String? getForgottenPasswordSelector() {
    return Hive.box(authBox).get(forgottenPasswordSelectorKey, defaultValue: "");
  }

  String? getForgottenPasswordCode() {
    return Hive.box(authBox).get(forgottenPasswordCodeKey, defaultValue: "");
  }

  String? getForgottenPasswordTime() {
    return Hive.box(authBox).get(forgottenPasswordTimeKey, defaultValue: "");
  }

  String? getRememberSelector() {
    return Hive.box(authBox).get(rememberSelectorKey, defaultValue: "");
  }

  String? getRememberCode() {
    return Hive.box(authBox).get(rememberCodeKey, defaultValue: "");
  }

  String? getCreatedOn() {
    return Hive.box(authBox).get(createdOnKey, defaultValue: "");
  }

  String? getLastLogin() {
    return Hive.box(authBox).get(lastLoginKey, defaultValue: "");
  }

  String? getActive() {
    return Hive.box(authBox).get(activeKey, defaultValue: "");
  }

  String? getCompany() {
    return Hive.box(authBox).get(companyKey, defaultValue: "");
  }

  String? getAddress() {
    return Hive.box(authBox).get(addressKey, defaultValue: "");
  }

  String? getBonus() {
    return Hive.box(authBox).get(bonusKey, defaultValue: "");
  }

  String? getDob() {
    return Hive.box(authBox).get(dobKey, defaultValue: "");
  }

  String? getCountryCode() {
    return Hive.box(authBox).get(countryCodeKey, defaultValue: "");
  }

  String? getCity() {
    return Hive.box(authBox).get(cityKey, defaultValue: "");
  }

  String? getArea() {
    return Hive.box(authBox).get(areaKey, defaultValue: "");
  }

  String? getStreet() {
    return Hive.box(authBox).get(streetKey, defaultValue: "");
  }

  String? getPinCode() {
    return Hive.box(authBox).get(pinCodeKey, defaultValue: "");
  }

  String? getServiceableCity() {
    return Hive.box(authBox).get(serviceableCityKey, defaultValue: "");
  }

  String? getApikey() {
    return Hive.box(authBox).get(apikeyKey, defaultValue: "");
  }

  String? getReferralCode() {
    return Hive.box(authBox).get(referralCodeKey, defaultValue: "");
  }

  String? getFriendsCode() {
    return Hive.box(authBox).get(friendsCodeKey, defaultValue: "");
  }

  String? getFcmId() {
    return Hive.box(authBox).get(fcmIdKey, defaultValue: "");
  }

  String? getLatitude() {
    return Hive.box(authBox).get(latitudeKey, defaultValue: "");
  }

  String? getLongitude() {
    return Hive.box(authBox).get(longitudeKey, defaultValue: "");
  }

  String? getCreatedAt() {
    return Hive.box(authBox).get(createdAtKey, defaultValue: "");
  }

  bool? showIntroSlider() {
    return Hive.box(authBox).get(showIntroSliderKey, defaultValue: true);
  }

  Future<void> setShowIntroSlider(bool value) async {
    Hive.box(authBox).put(showIntroSliderKey, value);
  }


  Future<void> changeAuthStatus(bool? authStatus) async {
    Hive.box(authBox).put(isLoginKey, authStatus);
  }

  Future<void> setId(String? id) async {
    Hive.box(authBox).put(idKey, id);
  }

  Future<void> setName(String?  name) async {
    Hive.box(authBox).put(nameKey, name);
  }

  Future<void> setIpAddress(String?  ipAddress) async {
    Hive.box(authBox).put(ipAddressKey, ipAddress);
  }

  Future<void> setEmail(String? email) async {
    Hive.box(authBox).put(emailKey, email);
  }

  Future<void> setMobile(String? mobile) async {
    Hive.box(authBox).put(mobileKey, mobile);
  }

  Future<void> setImage(String? image) async {
    Hive.box(authBox).put(imageKey, image);
  }

  Future<void> setBalance(String? balance) async {
    Hive.box(authBox).put(balanceKey, balance);
  }

  String? setRating(String? rating) {
    Hive.box(authBox).put(ratingKey, rating);
  }

  String? setNoOfRatings(String? noOfRatings) {
    Hive.box(authBox).put(noOfRatingsKey, noOfRatings);
  }

  Future<void> setActivationSelector(String? activationSelector) async {
    Hive.box(authBox).put(activationSelectorKey, activationSelector);
  }

  Future<void> setActivationCode(String? activationCode) async {
    Hive.box(authBox).put(activationCodeKey, activationCode);
  }

  Future<void> setForgottenPasswordSelector(String? forgottenPasswordSelector) async {
    Hive.box(authBox).put(forgottenPasswordSelectorKey, forgottenPasswordSelector);
  }

  Future<void> setForgottenPasswordCode(String? forgottenPasswordCode) async {
    Hive.box(authBox).put(forgottenPasswordCodeKey, forgottenPasswordCode);
  }

  Future<void> setForgottenPasswordTime(String? forgottenPasswordTime) async {
    Hive.box(authBox).put(forgottenPasswordTimeKey, forgottenPasswordTime);
  }

  Future<void> setRememberSelector(String? rememberSelector) async {
    Hive.box(authBox).put(rememberSelectorKey, rememberSelector);
  }

  Future<void> setRememberCode(String? rememberCode) async {
    Hive.box(authBox).put(rememberCodeKey, rememberCode);
  }

  Future<void> setCreatedOn(String? createdOn) async {
    Hive.box(authBox).put(createdOnKey, createdOn);
  }

  Future<void> setLastLogin(String? lastLogin) async {
    Hive.box(authBox).put(lastLoginKey, lastLogin);
  }

  Future<void> setActive(String? active) async {
    Hive.box(authBox).put(authTypeKey, active);
  }

  Future<void> setCompany(String? company) async {
    Hive.box(authBox).put(companyKey, company);
  }

  Future<void> setAddress(String? address) async {
    Hive.box(authBox).put(addressKey, address);
  }

  Future<void> setBonus(String? bonus) async {
    Hive.box(authBox).put(bonusKey, bonus);
  }

  Future<void> setDob(String? dob) async {
    Hive.box(authBox).put(dobKey, dob);
  }

  Future<void> setCountryCode(String? countryCode) async {
    Hive.box(authBox).put(countryCodeKey, countryCode);
  }

  Future<void> setCity(String? city) async {
    Hive.box(authBox).put(cityKey, city);
  }

  Future<void> setArea(String? area) async {
    Hive.box(authBox).put(areaKey, area);
  }

  Future<void> setStreet(String? street) async {
    Hive.box(authBox).put(streetKey, street);
  }

  Future<void> setPinCode(String? pinCode) async {
    Hive.box(authBox).put(pinCodeKey, pinCode);
  }

  Future<void> setServiceableCity(String? serviceableCity) async {
    Hive.box(authBox).put(serviceableCityKey, serviceableCity);
  }

  Future<void> setApikey(String? apikey) async {
    Hive.box(authBox).put(apikeyKey, apikey);
  }

  Future<void> setReferralCode(String? referralCode) async {
    Hive.box(authBox).put(referralCodeKey, referralCode);
  }

  Future<void> setFriendsCode(String? friendsCode) async {
    Hive.box(authBox).put(friendsCodeKey, friendsCode);
  }

  Future<void> setFcmId(String? fcmId) async {
    Hive.box(authBox).put(fcmIdKey, fcmId);
  }

  Future<void> setLatitude(String? latitude) async {
    Hive.box(authBox).put(latitudeKey, latitude);
  }

  Future<void> setLongitude(String? longitude) async {
    Hive.box(authBox).put(longitudeKey, longitude);
  }

  Future<void> setCreatedAt(String? createdAt) async {
    Hive.box(authBox).put(createdAtKey, createdAt);
  }
}
