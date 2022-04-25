import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/faq/faqsException.dart';
import 'package:erestro/features/faq/faqsModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class FaqsRemoteDataSource {
  Future<List<FaqsModel>> getFaqs() async {
    try {
      final body = {};
      final response = await http.post(Uri.parse(getFaqsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw FaqsException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => FaqsModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw FaqsException(errorMessageCode: StringsRes.noInternet);
    } on FaqsException catch (e) {
      throw FaqsException(errorMessageCode: e.toString());
    } catch (e) {
      throw FaqsException(errorMessageCode: e.toString());
    }
  }
}
