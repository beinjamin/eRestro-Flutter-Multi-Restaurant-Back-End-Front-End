import 'dart:convert';
import 'dart:io';

import 'package:erestro/features/home/slider/sliderException.dart';
import 'package:erestro/features/home/slider/sliderModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class SliderRemoteDataSource {
  Future<List<SliderModel>> getSlider() async {
    try {
      final body = {};
      final response = await http.post(Uri.parse(getSliderImagesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      //print("response:"+responseJson.toString());

      if (responseJson['error']) {
        throw SliderException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => SliderModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw SliderException(errorMessageCode: StringsRes.noInternet);
    } on SliderException catch (e) {
      throw SliderException(errorMessageCode: e.toString());
    } catch (e) {
      throw SliderException(errorMessageCode: e.toString());
    }
  }
}
