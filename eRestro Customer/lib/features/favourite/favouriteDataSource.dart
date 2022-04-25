import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/favourite/favouriteException.dart';
import 'package:erestro/features/favourite/favouriteModel.dart';
import 'package:erestro/features/helpAndSupport/cubit/ticketCubit.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportException.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportModel.dart';
import 'package:erestro/features/helpAndSupport/ticketModel.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class FavouriteRemoteDataSource {
  Future<List<RestaurantModel>> getFavouriteRestaurants({String? userId, String? type}) async {
    try {
      final body = {
        userIdKey: userId,
        typeKey: type,
      };
      final response = await http.post(Uri.parse(getFavoritesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw FavouriteException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => RestaurantModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw FavouriteException(errorMessageCode: StringsRes.noInternet);
    } on FavouriteException catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future<List<ProductDetails>> getFavouriteProducts({String? userId, String? type}) async {
    try {
      final body = {
        userIdKey: userId,
        typeKey: type,
      };
      final response = await http.post(Uri.parse(getFavoritesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print(responseJson);
      if (responseJson['error']) {
        throw FavouriteException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'][0] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw FavouriteException(errorMessageCode: StringsRes.noInternet);
    } on FavouriteException catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future favouriteAdd(String? userId, String? type, String? typeId) async {
    try {
      final body = {userIdKey: userId, typeKey: type, typeIdKey: typeId};
      //print("body${body}");
      final response = await http.post(Uri.parse(addToFavoritesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print("response${responseJson}");
      if (responseJson['error']) {
        throw FavouriteException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw FavouriteException(errorMessageCode: StringsRes.noInternet);
    } on FavouriteException catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future favouriteRemove(String? userId, String? type, String? typeId) async {
    try {
      final body = {userIdKey: userId, typeKey: type, typeIdKey: typeId};
      //print("body${body}");
      final response = await http.post(Uri.parse(removeFromFavoritesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print("favourite${responseJson}");
      if (responseJson['error']) {
        throw FavouriteException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw FavouriteException(errorMessageCode: StringsRes.noInternet);
    } on FavouriteException catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }
}
