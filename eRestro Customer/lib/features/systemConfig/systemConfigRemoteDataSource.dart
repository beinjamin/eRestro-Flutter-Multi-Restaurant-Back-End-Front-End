import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/systemConfig/settingModel.dart';
import 'package:erestro/features/systemConfig/systemCongifException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class SystemConfigRemoteDataSource {
  Future<SettingModel> getSystemConfing(String? userId) async {
    try {
      final body = {};
      if(userId!="")
      {
        body[userIdKey]= userId;
      }
      final response = await http.post(Uri.parse(getSettingsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print("response...................${responseJson['data']}");
      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      //print("response...................${responseJson}");
      return SettingModel.fromJson(responseJson['data']);
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: StringsRes.noInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }

  Future<String> getAppSettings(String type) async {
    try {
      final body = {};
      final response = await http.post(Uri.parse(getSettingsUrl), body: body, headers: ApiUtils.getHeaders());
      final Map<String, dynamic>responseJson = jsonDecode(response.body);
      if (responseJson['error']) {
        throw SystemConfigException(errorMessageCode: responseJson['message']);
      }
      return responseJson['data'][type][0].toString();
    } on SocketException catch (_) {
      throw SystemConfigException(errorMessageCode: StringsRes.noInternet);
    } on SystemConfigException catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    } catch (e) {
      throw SystemConfigException(errorMessageCode: e.toString());
    }
  }
}
