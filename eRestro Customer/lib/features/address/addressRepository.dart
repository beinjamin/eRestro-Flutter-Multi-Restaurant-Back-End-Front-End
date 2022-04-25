import 'package:erestro/features/address/addressException.dart';
import 'package:erestro/features/address/addressLocalDataSource.dart';
import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/address/addressRemoteDataSource.dart';

class AddressRepository {
  static final AddressRepository _addressRepository = AddressRepository._internal();
  late AddressRemoteDataSource _addressRemoteDataSource;
  late AddressLocalDataSource _addressLocalDataSource;

  factory AddressRepository() {
    _addressRepository._addressRemoteDataSource = AddressRemoteDataSource();
    _addressRepository._addressLocalDataSource = AddressLocalDataSource();
    return _addressRepository;
  }

  AddressRepository._internal();
  AddressLocalDataSource get addressLocalDataSource => _addressLocalDataSource;

  Future<List<AddressModel>> getAddress(String? userId) async {
    try {
      List<AddressModel> result = await _addressRemoteDataSource.getAddress(userId);
      return result;
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future getAddAddress(
      String? userId,
      String? mobile,
      String? address,
      String? cityId,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final result = await _addressRemoteDataSource.addAddress(userId, mobile, address, cityId, latitude, longitude, area, type, name, countryCode,
          alternateMobile, landmark, pincode, state, country, isDefault);
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      _addressLocalDataSource.getCity();
      print("city:" + result['latitude'] + "" + result['longitude'] + _addressLocalDataSource.getCity());
      return result;
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future getUpdateAddress(
      String? id,
      String? userId,
      String? mobile,
      String? address,
      String? city,
      String? latitude,
      String? longitude,
      String? area,
      String? type,
      String? name,
      String? countryCode,
      String? alternateMobile,
      String? landmark,
      String? pincode,
      String? state,
      String? country,
      String? isDefault) async {
    try {
      final result = await _addressRemoteDataSource.updateAddress(id ?? "", userId, mobile, address, city, latitude, longitude, area ?? "", type,
          name, countryCode, alternateMobile ?? "", landmark ?? "", pincode ?? "", state ?? "", country ?? "", isDefault ?? "");
      _addressLocalDataSource.setCity(result['city']);
      _addressLocalDataSource.setLatitude(result['latitude']);
      _addressLocalDataSource.setLongitude(result['longitude']);
      return result;
    } catch (e) {
      print("Update Address:$e");
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future getDeleteAddress(String? id) async {
    try {
      final result = await _addressRemoteDataSource.deleteAddress(id);
      return result;
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future getCityDeliverable(String? name) async {
    try {
      final result = await _addressRemoteDataSource.checkCityDeliverable(name);
      //print("hellow"+result['city_id'].toString());
      await _addressLocalDataSource.setCityId(result['city_id']);
      //await _addressLocalDataSource.getCityId();

      return result['city_id'];
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future<String> getDeliveryCharge(String? userId, String? addressId) async {
    try {
      final result = await _addressRemoteDataSource.checkDeliveryChargeCubit(userId, addressId);
      //await _addressLocalDataSource.setCityId(result);
      //await _addressLocalDataSource.getCityId();
      print("result is:" + Map.from(result)['delivery_charge'].toString());

      return Map.from(result)['delivery_charge'].toString();
    } catch (e) {
      print("error" + e.toString());
      throw AddressException(errorMessageCode: e.toString());
    }
  }
}
