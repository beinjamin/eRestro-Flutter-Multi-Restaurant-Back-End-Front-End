import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/payment/paymentException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class PaymentRemoteDataSource {
  Future<dynamic> getPayment(String? userId, String? orderId, String? amount) async {
    try {
      final body = {
        userIdKey: userId,
        orderIdKey: orderId,
        amountKey: amount};
      final response = await http.post(Uri.parse(getPaypalLinkUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print("response...................$responseJson");

      if (responseJson['error']) {
        throw PaymentException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw PaymentException(errorMessageCode: StringsRes.noInternet);
    } on PaymentException catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }

  Future<List> getStripeWebhook() async {
    try {
      final body = {};

      final response = await http.post(Uri.parse(stripeWebhookUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw PaymentException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw PaymentException(errorMessageCode: StringsRes.noInternet);
    } on PaymentException catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }

  Future<String> addTransaction(String transactionType, String userId, String orderId, String type, String paymentMethod, String txnId, String amount, String status, String message) async {
    try {
      final body = {
      transactionTypeKey: transactionType,
      userIdKey: userId,
      orderIdKey:  orderId,
      typeKey : type,
      paymentMethodKey: paymentMethod,
      txnIdKey : txnId,
      amountKey : amount,
      statusKey : status,
      messageKey : message,
    };
      final response = await http.post(Uri.parse(addTransactionUrl), body: body, headers: ApiUtils.getHeaders());
      final Map<String, dynamic>responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw PaymentException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'][type][0].toString();
    } on SocketException catch (_) {
      throw PaymentException(errorMessageCode: StringsRes.noInternet);
    } on PaymentException catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }

  Future<String> placeOrder(String userId, String mobile, String productVariantId, String quantity, String total, String deliveryCharge,
      String taxAmount, String taxPercentage, String finalTotal, String latitude, String longitude, String promoCode, String paymentMethod, String addressId,
      String isWalletUsed, String walletBalanceUsed, String activeStatus, String orderNote, String deliveryTip) async {
    try {
      final body = {
        userIdKey: userId,
        mobileKey: mobile,
        productVariantIdKey: productVariantId,
        quantityKey: quantity,
        totalKey: total,
        deliveryChargeKey: deliveryCharge,
        taxAmountKey: taxAmount,
        taxPercentageKey: taxPercentage,
        finalTotalKey: finalTotal,
        latitudeKey: latitude,
        longitudeKey: longitude,
        promoCodeKey: promoCode,
        paymentMethodKey: paymentMethod,
        addressIdKey: addressId,
        isWalletUsedKey: isWalletUsed,
        walletBalanceUsedKey: walletBalanceUsed,
        activeStatusKey: activeStatus,
        orderNoteKey: orderNote,
        deliveryTipKey: deliveryTip,   //{optional}
      };
      final response = await http.post(Uri.parse(placeOrderUrl), body: body, headers: ApiUtils.getHeaders());
      final Map<String, dynamic>responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw PaymentException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'];
    } on SocketException catch (_) {
      throw PaymentException(errorMessageCode: StringsRes.noInternet);
    } on PaymentException catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }
}
