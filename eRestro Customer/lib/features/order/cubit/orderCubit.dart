import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/order/orderException.dart';
import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderProgress extends OrderState {}

class OrderSuccess extends OrderState {
  final List<OrderModel> orderList;
  final int totalData;
  final bool hasMore;
  OrderSuccess(this.orderList, this.totalData, this.hasMore);
}

class OrderFailure extends OrderState {
  final String errorMessageCode;
  OrderFailure(this.errorMessageCode);
}
String? totalHasMore;
class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(OrderInitial());
  Future<List<OrderModel>> _fetchData({
    required String limit,
    String? offset,
    required String? userId,
    String? id,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId,
        idKey: id ?? "",
      };

      if (offset == null) {
        body.remove(offset);
      }
      //print(body);
      final response = await http.post(Uri.parse(getOrdersUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw OrderException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => OrderModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw OrderException(errorMessageCode: StringsRes.noInternet);
    } on OrderException catch (e) {
      throw OrderException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw OrderException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getOrder(String limit) async {
    emit(OrderProgress());
    _notificationCubit.getOrder(limit).then((val) => emit(OrderSuccess(val,)),).catchError((e) {
      emit(OrderFailure(e.toString()));
    });
  }*/
  void fetchOrder(String limit, String userId, String id) {
    emit(OrderProgress());
    _fetchData(limit: limit, userId: userId, id: id).then((value) {
      final List<OrderModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(OrderSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(OrderFailure(e.toString()));
    });
  }

  void fetchMoreOrderData(String limit, String? userId, String? id) {
    _fetchData(limit: limit, offset: (state as OrderSuccess).orderList.length.toString(), userId: userId, id: id).then((value) {
      //
      final oldState = (state as OrderSuccess);
      final List<OrderModel> usersDetails = value;
      final List<OrderModel> updatedUserDetails = List.from(oldState.orderList);
      updatedUserDetails.addAll(usersDetails);
      emit(OrderSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(OrderFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is OrderSuccess) {
      return (state as OrderSuccess).hasMore;
    } else {
      return false;
    }
  }
  orderList() {
    if (state is OrderSuccess) {
      return (state as OrderSuccess).orderList;
    }
    return [];
  }
}
