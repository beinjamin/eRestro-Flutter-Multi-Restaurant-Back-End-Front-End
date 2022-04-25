import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/notificatiion/NotificationModel.dart';
import 'package:erestro/features/notificatiion/notificationException.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationProgress extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotificationModel> notificationList;
  final int totalData;
  final bool hasMore;
  NotificationSuccess(this.notificationList, this.totalData, this.hasMore);
}

class NotificationFailure extends NotificationState {
  final String errorMessageCode;
  NotificationFailure(this.errorMessageCode);
}
String? totalHasMore;
class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());
  Future<List<NotificationModel>> _fetchData({
    required String limit,
    String? offset,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getNotificationsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
     // print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw NotificationException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw NotificationException(errorMessageCode: StringsRes.noInternet);
    } on NotificationException catch (e) {
      throw NotificationException(errorMessageCode: e.toString());
    } catch (e) {
      throw NotificationException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getNotification(String limit) async {
    emit(NotificationProgress());
    _notificationCubit.getNotification(limit).then((val) => emit(NotificationSuccess(val,)),).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }*/
  void fetchNotification(String limit) {
    emit(NotificationProgress());
    _fetchData(limit: limit).then((value) {
      final List<NotificationModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(NotificationSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }

  void fetchMoreNotificationData(String limit) {
    _fetchData(limit: limit, offset: (state as NotificationSuccess).notificationList.length.toString()).then((value) {
      //
      final oldState = (state as NotificationSuccess);
      final List<NotificationModel> usersDetails = value;
      final List<NotificationModel> updatedUserDetails = List.from(oldState.notificationList);
      updatedUserDetails.addAll(usersDetails);
      emit(NotificationSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(NotificationFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is NotificationSuccess) {
      return (state as NotificationSuccess).hasMore;
    } else {
      return false;
    }
  }
  notificationList() {
    if (state is NotificationSuccess) {
      return (state as NotificationSuccess).notificationList;
    }
    return [];
  }
}
