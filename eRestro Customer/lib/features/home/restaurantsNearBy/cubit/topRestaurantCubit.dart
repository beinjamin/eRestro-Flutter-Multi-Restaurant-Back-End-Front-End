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
abstract class TopRestaurantState {}

class TopRestaurantInitial extends TopRestaurantState {}

class TopRestaurantProgress extends TopRestaurantState {}

class TopRestaurantSuccess extends TopRestaurantState {
  final List<RestaurantModel> topRestaurantList;
  final int totalData;
  final bool hasMore;
  TopRestaurantSuccess(this.topRestaurantList, this.totalData, this.hasMore);
}

class TopRestaurantFailure extends TopRestaurantState {
  final String errorMessageCode;
  TopRestaurantFailure(this.errorMessageCode);
}
String? totalHasMore;
class TopRestaurantCubit extends Cubit<TopRestaurantState> {
  TopRestaurantCubit() : super(TopRestaurantInitial());
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

/*  getTopRestaurant(String limit) async {
    emit(TopRestaurantProgress());
    _notificationCubit.getTopRestaurant(limit).then((val) => emit(TopRestaurantSuccess(val,)),).catchError((e) {
      emit(TopRestaurantFailure(e.toString()));
    });
  }*/
  void fetchTopRestaurant(String limit, String? topRatedPartner, String? cityId, String? latitude,
      String? longitude, String? userId, String? id) {

    /*if(state is TopRestaurantSuccess) {
      return;
    }*/

    emit(TopRestaurantProgress());
    _fetchData(limit: limit, topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId, id: id).then((value) {
      final List<RestaurantModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(TopRestaurantSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(TopRestaurantFailure(e.toString()));
    });
  }

  void fetchMoreTopRestaurantData(String limit, String? topRatedPartner, String? cityId, String? latitude,
  String? longitude, String? userId, String? id) {
    _fetchData(limit: limit, offset: (state as TopRestaurantSuccess).topRestaurantList.length.toString(), topRatedPartner: topRatedPartner, cityId: cityId, latitude: latitude, longitude: longitude, userId: userId).then((value) {
      //
      final oldState = (state as TopRestaurantSuccess);
      final List<RestaurantModel> usersDetails = value;
      final List<RestaurantModel> updatedUserDetails = List.from(oldState.topRestaurantList);
      updatedUserDetails.addAll(usersDetails);
      emit(TopRestaurantSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(TopRestaurantFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TopRestaurantSuccess) {
      return (state as TopRestaurantSuccess).hasMore;
    } else {
      return false;
    }
  }
  topRestaurantList() {
    if (state is TopRestaurantSuccess) {
      return (state as TopRestaurantSuccess).topRestaurantList;
    }
    return [];
  }
}
