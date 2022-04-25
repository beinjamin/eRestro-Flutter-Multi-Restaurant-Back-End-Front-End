import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/helpAndSupport/helpAndSupportException.dart';
import 'package:erestro/features/helpAndSupport/helpAndSupportModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

class HelpAndSupportRemoteDataSource {
  Future<List<HelpAndSupportModel>> getHelpAndSupport() async {
    try {
      final body = {};
      final response = await http.post(Uri.parse(getTicketTypesUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw HelpAndSupportException(errorMessageCode: responseJson['message']);
      }

      return (responseJson['data'] as List).map((e) => HelpAndSupportModel.fromJson(Map.from(e))).toList();
    } on SocketException catch (_) {
      throw HelpAndSupportException(errorMessageCode: StringsRes.noInternet);
    } on HelpAndSupportException catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

  Future getAddTicket(String? ticketTypeId, String? subject, String? email, String? description, String? userId) async {
    try {
      final body = {ticketTypeIdKey: ticketTypeId, subjectKey: subject, emailKey: email, descriptionKey: description, userIdKey: userId};
      final response = await http.post(Uri.parse(addTicketUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw HelpAndSupportException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw HelpAndSupportException(errorMessageCode: StringsRes.noInternet);
    } on HelpAndSupportException catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

  Future getEditTicket(String? ticketId, String? ticketTypeId, String? subject, String? email, String? description, String? userId, String? status) async {
    try {
      final body = {ticketIdKey: ticketId, ticketTypeIdKey: ticketTypeId, subjectKey: subject, emailKey: email, descriptionKey: description, userIdKey: userId, statusKey: status};
      final response = await http.post(Uri.parse(editTicketUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));
      if (responseJson['error']) {
        throw HelpAndSupportException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw HelpAndSupportException(errorMessageCode: StringsRes.noInternet);
    } on HelpAndSupportException catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }
  /*user_type:user
  user_id:1
  ticket_id:1
  message:test
  attachments[]:files  {optional} {type allowed -> image,video,document,spreadsheet,archive}*/

  Future setMessage(String? userType, String? userId, String? ticketId, String? message, List<File>? attachments) async {
    try {
      final body = {userTypeKey: userType, userIdKey: userId, ticketIdKey: ticketId, messageKey: message, userIdKey: userId};
      final response = await http.post(Uri.parse(sendMessageUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = Map.from(jsonDecode(response.body));

      if (responseJson['error']) {
        throw HelpAndSupportException(errorMessageCode: responseJson['message']);
      }

      return responseJson['data'];
    } on SocketException catch (_) {
      throw HelpAndSupportException(errorMessageCode: StringsRes.noInternet);
    } on HelpAndSupportException catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    } catch (e) {
      throw HelpAndSupportException(errorMessageCode: e.toString());
    }
  }

}
