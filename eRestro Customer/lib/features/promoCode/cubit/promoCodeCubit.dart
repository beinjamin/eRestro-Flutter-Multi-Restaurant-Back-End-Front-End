import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/promoCode/promoCodeException.dart';
import 'package:erestro/features/promoCode/promoCodesModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class PromoCodeState {}

class PromoCodeInitial extends PromoCodeState {}

class PromoCodeProgress extends PromoCodeState {}

class PromoCodeSuccess extends PromoCodeState {
  final List<PromoCodesModel> promoCodeList;
  final int totalData;
  final bool hasMore;
  PromoCodeSuccess(this.promoCodeList, this.totalData, this.hasMore);
}

class PromoCodeFailure extends PromoCodeState {
  final String errorMessageCode;
  PromoCodeFailure(this.errorMessageCode);
}
String? totalHasMore;
class PromoCodeCubit extends Cubit<PromoCodeState> {
  PromoCodeCubit() : super(PromoCodeInitial());
  Future<List<PromoCodesModel>> _fetchData({
    required String limit,
    String? offset,
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
      final response = await http.post(Uri.parse(getPromoCodesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw PromoCodeException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => PromoCodesModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw PromoCodeException(errorMessageCode: StringsRes.noInternet);
    } on PromoCodeException catch (e) {
      throw PromoCodeException(errorMessageCode: e.toString());
    } catch (e) {
      throw PromoCodeException(errorMessageKey: e.toString(), errorMessageCode: e.toString());
    }
  }

/*  getPromoCode(String limit) async {
    emit(PromoCodeProgress());
    _notificationCubit.getPromoCode(limit).then((val) => emit(PromoCodeSuccess(val,)),).catchError((e) {
      emit(PromoCodeFailure(e.toString()));
    });
  }*/
  void fetchPromoCode(String limit) {
    emit(PromoCodeProgress());
    _fetchData(limit: limit).then((value) {
      final List<PromoCodesModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(PromoCodeSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(PromoCodeFailure(e.toString()));
    });
  }

  void fetchMorePromoCodeData(String limit) {
    _fetchData(limit: limit, offset: (state as PromoCodeSuccess).promoCodeList.length.toString()).then((value) {
      //
      final oldState = (state as PromoCodeSuccess);
      final List<PromoCodesModel> usersDetails = value;
      final List<PromoCodesModel> updatedUserDetails = List.from(oldState.promoCodeList);
      updatedUserDetails.addAll(usersDetails);
      emit(PromoCodeSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(PromoCodeFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is PromoCodeSuccess) {
      return (state as PromoCodeSuccess).hasMore;
    } else {
      return false;
    }
  }
  promoCodeList() {
    if (state is PromoCodeSuccess) {
      return (state as PromoCodeSuccess).promoCodeList;
    }
    return [];
  }
}
