import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/cart/cartException.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
import 'package:http/http.dart' as http;

class CartRemoteDataSource {
//to manageCart
  Future<dynamic> manageCart(
      {String? userId, String? productVariantId, String? isSavedForLater, String? qty, String? addOnId, String? addOnQty}) async {
    try {
      //body of post request
      final body = {
        userIdKey: userId,
        productVariantIdKey: productVariantId,
        isSavedForLaterKey: isSavedForLater,
        qtyKey: qty,
        addOnIdKey: addOnId ?? "",
        addOnQtyKey: addOnQty ?? ""
      };
      print("call here" + body.toString());
      final response = await http.post(Uri.parse(manageCartUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);

      if (responseJson['error']) {
        throw CartException(errorMessageCode: responseJson['message']);
      }

      return responseJson;
    } on SocketException catch (_) {
      throw CartException(errorMessageCode: StringsRes.noInternet);
    } on CartException catch (e) {
      throw CartException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw CartException(errorMessageCode: e.toString());
    }
  }

  //to placeOrder
  Future<dynamic> placeOrder(
      {String? userId,
      String? mobile,
      String? productVariantId,
      String? quantity,
      String? total,
      String? deliveryCharge,
      String? taxAmount,
      String? taxPercentage,
      String? finalTotal,
      String? latitude,
      String? longitude,
      String? promoCode,
      String? paymentMethod,
      String? addressId,
      String? isWalletUsed,
      String? walletBalanceUsed,
      String? activeStatus,
      String? orderNote,
      String? deliveryTip}) async {
    try {
      //body of post request
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
        deliveryTipKey: deliveryTip
      };
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(placeOrderUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw CartException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw CartException(errorMessageCode: StringsRes.noInternet);
    } on CartException catch (e) {
      throw CartException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw CartException(errorMessageCode: e.toString());
    }
  }

  //to removeCart
  Future<dynamic> removeCart({String? userId, String? productVariantId}) async {
    try {
      //body of post request
      final body = {userIdKey: userId, productVariantIdKey: productVariantId};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(removeFromCartUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw CartException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw CartException(errorMessageCode: StringsRes.noInternet);
    } on CartException catch (e) {
      throw CartException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw CartException(errorMessageCode: e.toString());
    }
  }

  //to getUserCart
  Future<CartModel> getCart({String? userId /*, String? isSavedForLater, String? restaurantId*/}) async {
    try {
      //body of post request
      final body = {userIdKey: userId /*, isSavedForLaterKey: isSavedForLater, restaurantIdKey: restaurantId*/};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(getUserCartUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw CartException(errorMessageCode: responseJson['message']);
      }

      return CartModel.fromJson(responseJson);
    } on SocketException catch (_) {
      throw CartException(errorMessageCode: StringsRes.noInternet);
    } on CartException catch (e) {
      throw CartException(errorMessageCode: e.toString());
    } catch (e) {
      throw CartException(errorMessageCode: e.toString());
    }
  }
}
