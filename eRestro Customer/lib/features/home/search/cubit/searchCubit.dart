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
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchProgress extends SearchState {}

class SearchSuccess extends SearchState {
  final List<ProductDetails> searchList;
  final int totalData;
  final bool hasMore;
  SearchSuccess(this.searchList, this.totalData, this.hasMore);
}

class SearchFailure extends SearchState {
  final String errorMessageCode;
  SearchFailure(this.errorMessageCode);
}

String? totalHasMore;

class SearchCubit extends Cubit<SearchState> {
  SearchCubit() : super(SearchInitial());
  Future<List<ProductDetails>> _fetchData({
    required String limit,
    String? offset,
    String? search,
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
        searchKey: search ?? "",
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

/*  getSearch(String limit) async {
    emit(SearchProgress());
    _SearchCubit.getSearch(limit).then((val) => emit(SearchSuccess(val,)),).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }*/
  void fetchSearch(String limit, String search, String? latitude, String? longitude, String? userId, String? cityId) {
    emit(SearchProgress());
    _fetchData(limit: limit, search: search, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      final List<ProductDetails> usersDetails = value;
      final total = /*value.length*/ int.parse(totalHasMore!);
      emit(SearchSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }

  void fetchMoreSearchData(String limit, String search, String? latitude, String? longitude, String? userId, String? cityId) {
    _fetchData(
            limit: limit,
            offset: (state as SearchSuccess).searchList.length.toString(),
            search: search,
            latitude: latitude,
            longitude: longitude,
            userId: userId,
            cityId: cityId)
        .then((value) {
      //
      final oldState = (state as SearchSuccess);
      final List<ProductDetails> usersDetails = value;
      final List<ProductDetails> updatedUserDetails = List.from(oldState.searchList);
      updatedUserDetails.addAll(usersDetails);
      emit(SearchSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(SearchFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SearchSuccess) {
      return (state as SearchSuccess).hasMore;
    } else {
      return false;
    }
  }

  searchList() {
    if (state is SearchSuccess) {
      return (state as SearchSuccess).searchList;
    }
    return [];
  }
}
