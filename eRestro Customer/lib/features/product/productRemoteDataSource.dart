import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/cart/cartException.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/product/productModel.dart';
import 'package:erestro/features/product/productException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class ProductRemoteDataSource {

  //to getUserProduct
  Future<ProductModel> getProduct({String? partnerId, String? latitude,
    String? longitude, String? userId, String? cityId}) async {
    try {
      //body of post request
      final body = {partnerIdKey: partnerId, filterByKey:"p.id", latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "", userIdKey: userId, cityIdKey: cityId ?? ""};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(getProductsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw ProductException(errorMessageCode: responseJson['message']);
      }

      return  ProductModel.fromJson(responseJson);
    } on SocketException catch (_) {
      throw ProductException(errorMessageCode: StringsRes.noInternet);
    } on ProductException catch (e) {
      throw ProductException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw ProductException(errorMessageCode: e.toString());
    }
  }

}
