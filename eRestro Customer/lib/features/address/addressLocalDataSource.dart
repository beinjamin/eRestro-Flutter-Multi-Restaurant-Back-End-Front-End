import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:hive/hive.dart';

class AddressLocalDataSource {
  String getId() {
    return Hive.box(addressBox).get(idBoxKey, defaultValue: "");
  }

  String getUserId() {
    return Hive.box(addressBox).get(userIdBoxKey, defaultValue: "");
  }

  String getName() {
    return Hive.box(addressBox).get(nameBoxKey, defaultValue: "");
  }

  String getType() {
    return Hive.box(addressBox).get(typeBoxKey, defaultValue: "");
  }

  String getMobile() {
    return Hive.box(addressBox).get(mobileNumberBoxKey, defaultValue: "");
  }

  String getAlternateMobile() {
    return Hive.box(addressBox).get(alternateMobileBoxKey, defaultValue: "");
  }

  String getAddress() {
    return Hive.box(addressBox).get(addressBoxKey, defaultValue: "");
  }

  String getLandmark() {
    return Hive.box(addressBox).get(landmarkBoxKey, defaultValue: "");
  }

  String getArea() {
    return Hive.box(addressBox).get(areaBoxKey, defaultValue: "");
  }

  String getCityId() {
    return Hive.box(addressBox).get(cityIdBoxKey, defaultValue: "");
  }

  String getPincode() {
    return Hive.box(addressBox).get(pincodeBoxKey, defaultValue: "1");
  }

  String getCountryCode() {
    return Hive.box(addressBox).get(countryCodeBoxKey, defaultValue: "");
  }

  String getState() {
    return Hive.box(addressBox).get(stateBoxKey, defaultValue: "");
  }

  String getCountry() {
    return Hive.box(addressBox).get(countryBoxKey, defaultValue: "");
  }

  String getIsDeliverable() {
    return Hive.box(addressBox).get(isDeliverableBoxKey, defaultValue: "");
  }

  String getLatitude() {
    return Hive.box(addressBox).get(latitudeBoxKey, defaultValue: "");
  }

  String getLongitude() {
    return Hive.box(addressBox).get(longitudeBoxKey, defaultValue: "");
  }

  String getIsDefault() {
    return Hive.box(addressBox).get(isDefaultBoxKey, defaultValue: "");
  }

  String getCity() {
    return Hive.box(addressBox).get(cityKey, defaultValue: "");
  }

  String getCityLatitude() {
    return Hive.box(addressBox).get(cityLatitudeBoxKey, defaultValue: "");
  }

  String getCityLongitude() {
    return Hive.box(addressBox).get(cityLongitudeBoxKey, defaultValue: "");
  }

  String getMinimumFreeDeliveryOrderAmount() {
    return Hive.box(addressBox).get(minimumFreeDeliveryOrderAmountBoxKey, defaultValue: "");
  }

  String getDeliveryCharges() {
    return Hive.box(addressBox).get(deliveryChargesBoxKey, defaultValue: "");
  }

  String getGeolocationType() {
    return Hive.box(addressBox).get(geolocationTypeBoxKey, defaultValue: "");
  }

  String getRadius() {
    return Hive.box(addressBox).get(radiusBoxKey, defaultValue: "");
  }
  //


  Future<void> setId(String id) async {
    Hive.box(addressBox).put(idKey, id);
  }

  Future<void> setUserId(String userId) async {
    return Hive.box(addressBox).put(userIdBoxKey, userId);
  }

  Future<void> setName(String name) async {
    return Hive.box(addressBox).put(nameBoxKey, name);
  }

  Future<void> setType(String type) async {
    return Hive.box(addressBox).put(typeBoxKey, type);
  }

  Future<void> setMobile(String mobileNumber) async {
    return Hive.box(addressBox).put(mobileNumberBoxKey, mobileNumber);
  }

  Future<void> setAlternateMobile(String alternateMobile) async {
    return Hive.box(addressBox).put(alternateMobileBoxKey, alternateMobile);
  }

  Future<void> setAddress(String address) async {
    return Hive.box(addressBox).put(addressBoxKey, address);
  }

  Future<void> setLandmark(String landmark) async {
    return Hive.box(addressBox).put(landmarkBoxKey, landmark);
  }

  Future<void> setArea(String area) async {
    return Hive.box(addressBox).put(areaBoxKey, area);
  }

  Future<void> setCityId(String cityId) async {
    return Hive.box(addressBox).put(cityIdBoxKey, cityId);
  }

  Future<void> setPincode(String pincode) async {
    return Hive.box(addressBox).put(pincodeBoxKey, pincode);
  }

  Future<void> setCountryCode(String countryCode) async {
    return Hive.box(addressBox).put(countryCodeBoxKey, countryCode);
  }

  Future<void> setState(String state) async {
    return Hive.box(addressBox).put(stateBoxKey, state);
  }

  Future<void> setCountry(String country) async {
    return Hive.box(addressBox).put(countryBoxKey, country);
  }

  Future<void> setIsDeliverable(String isDeliverable) async {
    return Hive.box(addressBox).put(isDeliverableBoxKey, isDeliverable);
  }

  Future<void> setLatitude(String latitude) async {
    print(latitude);
    return Hive.box(addressBox).put(latitudeBoxKey, latitude);
  }

  Future<void> setLongitude(String longitude) async {
    print(longitude);
    return Hive.box(addressBox).put(longitudeBoxKey, longitude);
  }

  Future<void> setIsDefault(String isDefault) async {
    return Hive.box(addressBox).put(isDefaultBoxKey, isDefault);
  }

  Future<void> setCity(String city) async {
    print(city);
    return Hive.box(addressBox).put(cityKey, city);
  }

  Future<void> setCityLatitude(String cityLatitude) async {
    return Hive.box(addressBox).put(cityLatitudeBoxKey, cityLatitude);
  }

  Future<void> setCityLongitude(String cityLongitude) async {
    return Hive.box(addressBox).put(cityLongitudeBoxKey, cityLongitude);
  }

  Future<void> setMinimumFreeDeliveryOrderAmount(String minimumFreeDeliveryOrderAmount) async {
    return Hive.box(addressBox).put(minimumFreeDeliveryOrderAmountBoxKey, minimumFreeDeliveryOrderAmount);
  }

  Future<void> setDeliveryCharges(String deliveryCharges) async {
    return Hive.box(addressBox).put(deliveryChargesBoxKey, deliveryCharges);
  }

  Future<void> setGeolocationType(String geolocationType) async {
    return Hive.box(addressBox).put(geolocationTypeBoxKey, geolocationType);
  }

  Future<void> setRadius(String radius) async {
    return Hive.box(addressBox).put(radiusBoxKey, radius);
  }
}
