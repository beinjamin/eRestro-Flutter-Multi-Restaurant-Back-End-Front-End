import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/cart/cartException.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/order/orderException.dart';
import 'package:erestro/features/order/orderLiveTrackingModel.dart';
import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/features/product/productModel.dart';
import 'package:erestro/features/product/productException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class OrderRemoteDataSource {

  //to getUserOrder
  Future<OrderModel> getOrder({
    String? status,
    String? orderId}) async {
    try {
      //body of post request
      final body = {
        statusKey: status,
        orderIdKey: orderId};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(updateOrderStatusUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw OrderException(errorMessageCode: responseJson['message']);
      }

      return  OrderModel.fromJson(responseJson);
    } on SocketException catch (_) {
      throw OrderException(errorMessageCode: StringsRes.noInternet);
    } on OrderException catch (e) {
      throw OrderException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw OrderException(errorMessageCode: e.toString());
    }
  }

  //to getUserOrderLiveTracking
  Future<OrderLiveTrackingModel> getOrderLiveTracing({
    String? orderId}) async {
    try {
      //body of post request
      final body = {
        orderIdKey: orderId};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(getLiveTrackingDetailsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw OrderException(errorMessageCode: responseJson['message']);
      }

      return  OrderLiveTrackingModel.fromJson(responseJson['data'][0]);
    } on SocketException catch (_) {
      throw OrderException(errorMessageCode: StringsRes.noInternet);
    } on OrderException catch (e) {
      throw OrderException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw OrderException(errorMessageCode: e.toString());
    }
  }

}
