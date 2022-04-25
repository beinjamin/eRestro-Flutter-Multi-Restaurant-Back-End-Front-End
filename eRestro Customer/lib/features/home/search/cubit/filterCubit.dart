import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';

import 'package:http/http.dart' as http;

import '../searchException.dart';

@immutable
abstract class FilterState {}

class FilterInitial extends FilterState {}

class FilterProgress extends FilterState {}

class FilterSuccess extends FilterState {
  final List<ProductDetails> filterList;
  final int totalData;
  final bool hasMore;
  FilterSuccess(this.filterList, this.totalData, this.hasMore);
}

class FilterFailure extends FilterState {
  final String errorMessageCode;
  FilterFailure(this.errorMessageCode);
}

String? totalHasMore;

class FilterCubit extends Cubit<FilterState> {
  FilterCubit() : super(FilterInitial());
  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    String? categoryId,
    String? vegetarian,
    String? order,
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
        filterByKey: "sd.user_id",
        categoryIdKey: categoryId ?? "",
        vegetarianKey: vegetarian ?? "",
        sortKey: "pv.price",
        orderKey: order,
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId ?? "",
        cityIdKey: cityId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      print(body);
      final response = await http.post(Uri.parse(getProductsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw SearchException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => ProductDetails.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw SearchException(errorMessageCode: StringsRes.noInternet);
    } on SearchException catch (e) {
      throw SearchException(errorMessageCode: e.toString());
    } catch (e) {
      throw SearchException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getFilter(String limit) async {
    emit(FilterProgress());
    _FilterCubit.getFilter(limit).then((val) => emit(FilterSuccess(val,)),).catchError((e) {
      emit(FilterFailure(e.toString()));
    });
  }*/
  void fetchFilter(
      String limit, String categoryId, String vegetarian, String order, String? latitude, String? longitude, String? userId, String? cityId) {
    emit(FilterProgress());
    _fetchData(
            limit: limit,
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId)
        .then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = /*value.length*/ int.parse(totalHasMore!);
      emit(FilterSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(FilterFailure(e.toString()));
    });
  }

  void fetchMoreFilterData(
      String limit, String categoryId, String vegetarian, String order, String? latitude, String? longitude, String? userId, String? cityId) {
    _fetchData(
            limit: limit,
            offset: (state as FilterSuccess).filterList.length.toString(),
            categoryId: categoryId,
            vegetarian: vegetarian,
            order: order,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId)
        .then((value) {
      //
      final oldState = (state as FilterSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.filterList);
      updatedUserDetails.addAll(usersDetails);
      emit(FilterSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(FilterFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is FilterSuccess) {
      return (state as FilterSuccess).hasMore;
    } else {
      return false;
    }
  }

  filterList() {
    if (state is FilterSuccess) {
      return (state as FilterSuccess).filterList;
    }
    return [];
  }
}
