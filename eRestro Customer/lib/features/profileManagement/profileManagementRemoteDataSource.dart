import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/profileManagement/profileManagementException.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
class ProfileManagementRemoteDataSource {

  Future addProfileImage(File? images, String? userId) async {
    try {
      Map<String, String?> body = {userIdKey: userId};
      Map<String, File?> fileList = {
        imageKey: images,
      };
      var response = await postApiFile(Uri.parse(updateUserUrl), fileList, body, userId);
      final res = json.decode(response);
      if (res['error']) {
        throw ProfileManagementException(errorMessageCode: res['message']);
      }
      return res['data'];
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: StringsRes.noInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future postApiFile(Uri url, Map<String, File?> fileList, Map<String, String?> body, String? userId) async {
    print("Uri is##############" + url.toString());
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll(ApiUtils.getHeaders());
      body.forEach((key, value) {
        request.fields[key] = value!;
      });
    //  request.fields[accessValueKey] = accessValue;
      body[userIdKey] = userId;
      print(body[userIdKey].toString());

      fileList.forEach((key, value) async {
        final mimeType = lookupMimeType(value!.path);

        var extension = mimeType!.split("/");
        var pic = await http.MultipartFile.fromPath(key, value.path,contentType: new MediaType('image', '${extension[1]}'));
        request.files.add(pic);
      });
      var res = await request.send();
      var responseData = await res.stream.toBytes();
      var response = String.fromCharCodes(responseData);
      if (res.statusCode == 200) {
        print("response ********" + response);
        return response;
      } else {
        return null;
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: StringsRes.noInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }

  Future<void> updateProfile({String? userId, String? email, String? name, String? mobile, String? referralCode}) async {
    try {
      //body of post request
      Map<String, String> body = {userIdKey: userId!, emailKey: email!, nameKey: name!, mobileKey: mobile!,  referralCodeKey: referralCode!};
      //print("body:"+body.toString());
      final response = await http.post(Uri.parse(updateUserUrl), body: body, headers: ApiUtils.getHeaders());

      final responseJson = jsonDecode(response.body);
      //print("Response:"+responseJson.toString());
      if (responseJson['error']) {
        throw ProfileManagementException(errorMessageCode: responseJson['message']);
      }
    } on SocketException catch (_) {
      throw ProfileManagementException(errorMessageCode: StringsRes.noInternet);
    } on ProfileManagementException catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProfileManagementException(errorMessageCode: e.toString());
    }
  }
}
