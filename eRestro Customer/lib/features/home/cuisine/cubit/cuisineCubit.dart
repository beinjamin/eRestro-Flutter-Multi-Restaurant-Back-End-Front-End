import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/cuisine/cuisineException.dart';
import 'package:erestro/features/home/cuisine/cuisineModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/widgets/cuicineSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class CuisineState {}

class CuisineInitial extends CuisineState {}

class CuisineProgress extends CuisineState {}

class CuisineSuccess extends CuisineState {
  final List<CuisineModel> cuisineList;
  final int totalData;
  final bool hasMore;
  CuisineSuccess(this.cuisineList, this.totalData, this.hasMore);
}

class CuisineFailure extends CuisineState {
  final String errorMessageCode;
  CuisineFailure(this.errorMessageCode);
}

class CuisineCubit extends Cubit<CuisineState> {
  CuisineCubit() : super(CuisineInitial());
  Future<List<CuisineModel>> _fetchData({
    required String limit,
    String? offset,
    required String? type,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getCategoriesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
     // print(responseJson);

      if (responseJson['error']) {
        throw CuisineException(errorMessageCode: responseJson['message']);
      }

      if(type==popularCategoriesKey) {
        return (responseJson['popular_categories']  as List).map((e) => CuisineModel.fromJson(e)).toList();
      } else {
        return (responseJson['data'] as List).map((e) => CuisineModel.fromJson(e)).toList();
      }
    } on SocketException catch (_) {
      throw CuisineException(errorMessageCode: StringsRes.noInternet);
    } on CuisineException catch (e) {
      throw CuisineException(errorMessageCode: e.toString());
    } catch (e) {
      throw CuisineException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getCuisine(String limit) async {
    emit(CuisineProgress());
    _cuisineCubit.getCuisine(limit).then((val) => emit(CuisineSuccess(val,)),).catchError((e) {
      emit(CuisineFailure(e.toString()));
    });
  }*/
  void fetchCuisine(String limit, String type) {
    /*if(state is CuisineSuccess) {
      return;
    }*/
    emit(CuisineProgress());
    _fetchData(limit: limit, type: type).then((value) {
      final List<CuisineModel> usersDetails = value;
      final total = value.length;
      emit(CuisineSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(CuisineFailure(e.toString()));
    });
  }

  void fetchMoreCuisineData(String limit, String type) {
    _fetchData(limit: limit, offset: (state as CuisineSuccess).cuisineList.length.toString(), type: type).then((value) {
      //
      final oldState = (state as CuisineSuccess);
      final List<CuisineModel> usersDetails = value;
      final List<CuisineModel> updatedUserDetails = List.from(oldState.cuisineList);
      updatedUserDetails.addAll(usersDetails);
      emit(CuisineSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(CuisineFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is CuisineSuccess) {
      return (state as CuisineSuccess).hasMore;
    } else {
      return false;
    }
  }
  cuisineList() {
    if (state is CuisineSuccess) {
      return (state as CuisineSuccess).cuisineList;
    }
    return [];
  }
}
