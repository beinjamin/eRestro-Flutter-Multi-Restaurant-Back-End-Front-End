import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/address/addressException.dart';
import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
import 'package:http/http.dart' as http;

class AddressRemoteDataSource {
  Future<List<AddressModel>> getAddress(String? userId) async {
    try {
      final body = {userIdKey: userId};
      final response = await http.post(Uri.parse(getAddressUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => AddressModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future addAddress(String? userId, String? mobile, String? address, String? city, String? latitude, String? longitude,
      String? area, String? type, String? name, String? countryCode, String? alternateMobile, String? landmark, String? pincode, String? state, String? country, String? isDefault) async {
    try {
      final body = {userIdKey: userId, mobileKey: mobile, addressKey: address, cityKey: city, latitudeKey: latitude, longitudeKey: longitude,
        areaKey: area ?? "", typeKey: type, nameKey: name, countryCodeKey: countryCode, alternateMobileKey: alternateMobile, landmarkKey: landmark, pinCodeKey: pincode, stateKey: state, countryKey: country, isDefaultKey: isDefault};
      print("body:"+body.toString());
      final response = await http.post(Uri.parse(addAddressUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      print(responseJson);

      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).first;
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future updateAddress(String? id, String? userId, String? mobile, String? address, String? city, String? latitude, String? longitude,
      String? area, String? type, String? name, String? countryCode, String? alternateMobile, String? landmark, String? pincode, String? state, String? country, String? isDefault) async {
    try {
      final body = {idKey: id, userIdKey: userId, mobileKey: mobile, addressKey: address, cityKey: city ?? "", latitudeKey: latitude, longitudeKey: longitude,
        areaKey: area ?? "", typeKey: type ?? "", nameKey: name, countryCodeKey: countryCode, alternateMobileKey: alternateMobile, landmarkKey: landmark ?? "", pinCodeKey: pincode, stateKey: state, countryKey: country, isDefaultKey: isDefault};
      //print("body:"+body.toString());
      final response = await http.post(Uri.parse(updateAddressUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      print(responseJson);
      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).first;
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future deleteAddress(String? id) async {
    try {
      final body = {idKey: id};
      final response = await http.post(Uri.parse(deleteAddressUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future checkCityDeliverable(String? name) async {
    try {
      final body = {nameKey: name};
      final response = await http.post(Uri.parse(isCityDeliverableUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print(responseJson.toString() +" "+ responseJson['city_id']);
      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }

      return responseJson;
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

  Future checkDeliveryChargeCubit(String? userId, String? addressId) async {
    try {
      final body = {userIdKey: userId, addressIdKey: addressId};
      final response = await http.post(Uri.parse(getDeliveryChargesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print(responseJson);
      if (responseJson['error']) {
        throw AddressException(errorMessageCode: responseJson['message']);
      }

      return responseJson;
    } on SocketException catch (_) {
      throw AddressException(errorMessageCode: StringsRes.noInternet);
    } on AddressException catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    } catch (e) {
      throw AddressException(errorMessageCode: e.toString());
    }
  }

}
