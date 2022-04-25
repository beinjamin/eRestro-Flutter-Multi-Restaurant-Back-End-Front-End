import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/cuisine/cuisineException.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class CuisineDetailState {}

class CuisineDetailInitial extends CuisineDetailState {}

class CuisineDetailProgress extends CuisineDetailState {}

class CuisineDetailSuccess extends CuisineDetailState {
  final List<ProductDetails> cuisineDetailList;
  final int totalData;
  final bool hasMore;
  CuisineDetailSuccess(this.cuisineDetailList, this.totalData, this.hasMore);
}

class CuisineDetailFailure extends CuisineDetailState {
  final String errorMessageCode;
  CuisineDetailFailure(this.errorMessageCode);
}
String? totalHasMore;
class CuisineDetailCubit extends Cubit<CuisineDetailState> {
  CuisineDetailCubit() : super(CuisineDetailInitial());
  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    required String? categoryId,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        categoryIdKey: categoryId,
        filterByKey: "sd.user_id",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        cityIdKey: cityId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      //print(body);
      final response = await http.post(Uri.parse(getProductsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw CuisineException(errorMessageCode: responseJson['message']);
      }


        return (responseJson['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();

    } on SocketException catch (_) {
      throw CuisineException(errorMessageCode: StringsRes.noInternet);
    } on CuisineException catch (e) {
      throw CuisineException(errorMessageCode: e.toString());
    } catch (e) {
      throw CuisineException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getCuisineDetail(String limit) async {
    emit(CuisineDetailProgress());
    _cuisineDetailCubit.getCuisineDetail(limit).then((val) => emit(CuisineDetailSuccess(val,)),).catchError((e) {
      emit(CuisineDetailFailure(e.toString()));
    });
  }*/
  void fetchCuisineDetail(String limit, String categoryId, String? latitude,
      String? longitude, String? userId, String? cityId) {
    emit(CuisineDetailProgress());
    _fetchData(limit: limit, categoryId: categoryId, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(CuisineDetailSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(CuisineDetailFailure(e.toString()));
    });
  }

  void fetchMoreCuisineDetailData(String limit, String categoryId, String? latitude,
      String? longitude, String userId, String? cityId) {
    _fetchData(limit: limit, offset: (state as CuisineDetailSuccess).cuisineDetailList.length.toString(), categoryId: categoryId, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      //
      final oldState = (state as CuisineDetailSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.cuisineDetailList);
      updatedUserDetails.addAll(usersDetails);
      emit(CuisineDetailSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(CuisineDetailFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is CuisineDetailSuccess) {
      return (state as CuisineDetailSuccess).hasMore;
    } else {
      return false;
    }
  }
  cuisineDetailList() {
    if (state is CuisineDetailSuccess) {
      return (state as CuisineDetailSuccess).cuisineDetailList;
    }
    return [];
  }
}
