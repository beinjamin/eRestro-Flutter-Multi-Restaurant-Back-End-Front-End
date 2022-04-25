import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/restaurantsNearBy/restaurantException.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class RestaurantState {}

class RestaurantInitial extends RestaurantState {}

class RestaurantProgress extends RestaurantState {}

class RestaurantSuccess extends RestaurantState {
  final List<RestaurantModel> restaurantList;
  final int totalData;
  final bool hasMore;
  RestaurantSuccess(this.restaurantList, this.totalData, this.hasMore);
}

class RestaurantFailure extends RestaurantState {
  final String errorMessageCode;
  RestaurantFailure(this.errorMessageCode);
}
String? totalHasMore;
class RestaurantCubit extends Cubit<RestaurantState> {
  RestaurantCubit() : super(RestaurantInitial());
  Future<List<RestaurantModel>> _fetchData({
    required String limit,
    String? offset,
    String? topRatedPartner,
    String? cityId,
    String? latitude,
    String? longitude,
    String? userId,
    String? id,
  }) async {


    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        topRatedPartnerKey: topRatedPartner ?? "",
        cityIdKey: cityId ?? "",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        idKey: id ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getPartnersUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];


      if (responseJson['error']) {
        throw RestaurantException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => RestaurantModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw RestaurantException(errorMessageCode: StringsRes.noInternet);
    } on RestaurantException catch (e) {
      throw RestaurantException(errorMessageCode: e.toString());
    } catch (e) {
      throw RestaurantException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getRestaurant(String limit) async {
    emit(RestaurantProgress());
    _notificationCubit.getRestaurant(limit).then((val) => emit(RestaurantSuccess(val,)),).catchError((e) {
      emit(RestaurantFailure(e.toString()));
    });
  }*/
  void fetchRestaurant(String limit, String? topRatedPartner, String? cityId, String? latitude,
      String? longitude, String? userId, String? id) {

    /*if(state is RestaurantSuccess) {
      return;
    }*/

    emit(RestaurantProgress());
    _fetchData(limit: limit, topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId, id: id).then((value) {
      final List<RestaurantModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(RestaurantSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(RestaurantFailure(e.toString()));
    });
  }

  void fetchMoreRestaurantData(String limit, String? topRatedPartner, String? cityId, String? latitude,
  String? longitude, String? userId, String? id) {
    _fetchData(limit: limit, offset: (state as RestaurantSuccess).restaurantList.length.toString(), topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId).then((value) {
      //
      final oldState = (state as RestaurantSuccess);
      final List<RestaurantModel> usersDetails = value;
      final List<RestaurantModel> updatedUserDetails = List.from(oldState.restaurantList);
      updatedUserDetails.addAll(usersDetails);
      emit(RestaurantSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(RestaurantFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is RestaurantSuccess) {
      return (state as RestaurantSuccess).hasMore;
    } else {
      return false;
    }
  }
  restaurantList() {
    if (state is RestaurantSuccess) {
      return (state as RestaurantSuccess).restaurantList;
    }
    return [];
  }
}
