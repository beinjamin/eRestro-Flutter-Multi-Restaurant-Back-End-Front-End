import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/rating/RatingException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class RatingRemoteDataSource {
  Future<List<AddressModel>> getProductRating(String? userId) async {
    try {
      final body = {userIdKey: userId};
      final response = await http.post(Uri.parse(getProductRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => AddressModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  /*Future<List<CityModel>> getRiderRating(String? riderId) async {
    try {
      final body = {riderIdKey: riderId};
      final response = await http.post(Uri.parse(getRiderRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => CityModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }*/

  Future setProductRating(String? userId, String? productId, String? rating, String? comment /*, String? images*/) async {
    try {
      final body = {userIdKey: userId, productIdKey: productId, ratingKey: rating, commentKey: comment /*, imagesKey: images*/};
      //print("body:"+body.toString());
      final response = await http.post(Uri.parse(setProductRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print(responseJson);

      if (responseJson['error']) {
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future setRiderRating(String? userId, String? riderId, String? rating, String? comment) async {
    try {
      final body = {userIdKey: userId, riderIdKey: riderId, ratingKey: rating, commentKey: comment};
      //print("body:"+body.toString());
      final response = await http.post(Uri.parse(setRiderRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print(responseJson);
      if (responseJson['error']) {
        //print("error:"+responseJson['error']);
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future deleteProductRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final response = await http.post(Uri.parse(deleteProductRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      if (responseJson['error']) {
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future deleteRiderRating(String? ratingId) async {
    try {
      final body = {ratingIdKey: ratingId};
      final response = await http.post(Uri.parse(deleteRiderRatingUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      if (responseJson['error']) {
        throw RatingException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw RatingException(errorMessageCode: StringsRes.noInternet);
    } on RatingException catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }
}
