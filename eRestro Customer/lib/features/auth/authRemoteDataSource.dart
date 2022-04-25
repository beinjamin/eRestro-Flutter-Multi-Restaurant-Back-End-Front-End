import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:erestro/helper/string.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;
import 'package:erestro/features/auth/auhtException.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';
import 'package:http/http.dart' as http;

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String? referCode;
  int count = 1;

//to addUser
  Future<dynamic> addUser(
      {String? name,
      String? email,
      String? mobile,
      String? countryCode,
      String? password,
      String? fcmId,
      String? friendCode /*, String? latitude, String? longitude*/}) async {
    try {
      referEarn();
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {
        nameKey: name,
        emailKey: email,
        mobileKey: mobile,
        countryCodeKey: countryCode ?? "",
        referralCodeKey: referCode ?? "",
        passwordKey: password,
        fcmIdKey: fcmToken,
        friendCodeKey: friendCode ?? "" /*, latitudeKey: latitude ?? "", longitudeKey: longitude ?? ""*/
      };
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(registerUserUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  final chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));

  //to referEarn
  Future<void> referEarn() async {
    try {
      String refer = getRandomString(8);
      //body of post request
      final body = {referralCodeKey: refer};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(validateReferCodeUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      // print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }
      if (!responseJson['error']) {
        referCode = refer;
      } else {
        if (count < 5) referEarn();
        count++;
      }

      return responseJson;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to loginUser
  Future<dynamic> signInUser({String? mobile, String? password}) async {
    try {
      String fcmToken = await getFCMToken();
      //body of post request
      final body = {mobileKey: mobile, passwordKey: password, fcmIdKey: fcmToken};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(loginUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to check user's exist
  Future<bool> isUserExist(String mobile) async {
    try {
      final body = {
        mobileKey: mobile,
      };
      final response = await http.post(Uri.parse(verifyUserUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        //if user does not exist means
        if (responseJson['message'] == "102") {
          return false;
        }
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return true;
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to reset password of user's
  Future<List<dynamic>> resetPassword({String? mobile, String? password}) async {
    try {
      //body of post request
      final body = {mobileNoKey: mobile, newKey: password};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(resetPasswordUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to change password of user's
  Future<dynamic> changePassword({String? userId, String? oldPassword, String? newPassword}) async {
    try {
      //body of post request
      final body = {userIdKey: userId, oldKey: oldPassword, newKey: newPassword};
      print("call here" + body.toString());
      final response = await http.post(Uri.parse(updateUserUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  //to update fcmId of user's
  Future<dynamic> updateFcmId({String? userId, String? fcmId}) async {
    try {
      //body of post request
      final body = {userIdKey: userId, fcmIdKey: fcmId};
      //print("call here"+body.toString());
      final response = await http.post(Uri.parse(resetPasswordUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      // print(responseJson);

      if (responseJson['error']) {
        throw AuthException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw AuthException(errorMessageCode: StringsRes.noInternet);
    } on AuthException catch (e) {
      throw AuthException(errorMessageCode: e.toString());
    } catch (e) {
      //print(e.toString());
      throw AuthException(errorMessageCode: e.toString());
    }
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }
}
