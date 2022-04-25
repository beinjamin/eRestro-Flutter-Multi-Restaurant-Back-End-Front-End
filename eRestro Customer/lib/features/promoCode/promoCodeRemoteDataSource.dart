import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/promoCode/promoCodeException.dart';
import 'package:erestro/features/promoCode/promoCodeValidateModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class PromoCodeRemoteDataSource {

//to promoCode
  Future<PromoCodeValidateModel> validatePromoCode({String? promoCode, String? userId, String? finalTotal}) async {
    try {
      //body of post request
      final body = {promoCodeKey: promoCode, userIdKey: userId, finalTotalKey: finalTotal};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(validatePromoCodeUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson['data'][0]['promo_code']);

      if (responseJson['error']) {
        throw PromoCodeException(errorMessageCode: responseJson['message']);
      }

      return PromoCodeValidateModel.fromJson(responseJson['data'][0]);
    } on SocketException catch (_) {
      throw PromoCodeException(errorMessageCode: StringsRes.noInternet);
    } on PromoCodeException catch (e) {
      throw PromoCodeException(errorMessageCode: e.toString());
    } catch (e) {
      print(e.toString());
      throw PromoCodeException(errorMessageCode: e.toString());
    }
  }

}
