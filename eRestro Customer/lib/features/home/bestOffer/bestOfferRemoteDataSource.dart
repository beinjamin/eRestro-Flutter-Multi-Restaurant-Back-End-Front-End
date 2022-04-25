import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/bestOffer/bestOfferException.dart';
import 'package:erestro/features/home/bestOffer/bestOfferModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class BestOfferRemoteDataSource {
  Future<List<BestOfferModel>> getBestOffer() async {
    try {
      final body = {};
      final response = await http.post(Uri.parse(getOfferImagesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw BestOfferException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => BestOfferModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw BestOfferException(errorMessageCode: StringsRes.noInternet);
    } on BestOfferException catch (e) {
      throw BestOfferException(errorMessageCode: e.toString());
    } catch (e) {
      throw BestOfferException(errorMessageCode: e.toString());
    }
  }
}
