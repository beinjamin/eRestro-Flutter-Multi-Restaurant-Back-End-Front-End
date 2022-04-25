import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/sections/sectionsException.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class SectionsState {}

class SectionsInitial extends SectionsState {}

class SectionsProgress extends SectionsState {}

class SectionsSuccess extends SectionsState {
  final List<SectionsModel> sectionsList;
  final int totalData;
  final bool hasMore;
  SectionsSuccess(this.sectionsList, this.totalData, this.hasMore);
}

class SectionsFailure extends SectionsState {
  final String errorMessageCode;
  SectionsFailure(this.errorMessageCode);
}

class SectionsCubit extends Cubit<SectionsState> {
  SectionsCubit() : super(SectionsInitial());
  Future<List<SectionsModel>> _fetchData({
    required String limit,
    String? offset,
    String? userId,
    String? latitude,
    String? longitude,
    String? cityId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        pLimitKey: limit,
        pOffsetKey: offset ?? "",
        userIdKey: userId ?? "",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        cityIdKey: cityId ?? "",
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getSectionsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);

      if (responseJson['error']) {
        throw SectionsException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => SectionsModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw SectionsException(errorMessageCode: StringsRes.noInternet);
    } on SectionsException catch (e) {
      throw SectionsException(errorMessageCode: e.toString());
    } catch (e) {
      throw SectionsException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getSections(String limit) async {
    emit(SectionsProgress());
    _sectionsCubit.getSections(limit).then((val) => emit(SectionsSuccess(val,)),).catchError((e) {
      emit(SectionsFailure(e.toString()));
    });
  }*/
  void fetchSections(String limit, String? userId, String? latitude,
      String? longitude,String? cityId) {
    /*if(state is SectionsSuccess) {
      return;
    }*/
    emit(SectionsProgress());
    _fetchData(limit: limit, userId: userId, latitude: latitude, longitude: longitude, cityId: cityId).then((value) {
      final List<SectionsModel> usersDetails = value;
      final total = value.length;
      emit(SectionsSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(SectionsFailure(e.toString()));
    });
  }

  void fetchMoreSectionsData(String limit, String? userId, String? latitude,
      String? longitude, String? cityId) {
    _fetchData(limit: limit, offset: (state as SectionsSuccess).sectionsList.length.toString(), userId: userId, latitude: latitude, longitude: longitude, cityId: cityId).then((value) {
      //
      final oldState = (state as SectionsSuccess);
      final List<SectionsModel> usersDetails = value;
      final List<SectionsModel> updatedUserDetails = List.from(oldState.sectionsList);
      updatedUserDetails.addAll(usersDetails);
      emit(SectionsSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(SectionsFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is SectionsSuccess) {
      return (state as SectionsSuccess).hasMore;
    } else {
      return false;
    }
  }
  sectionsList() {
    if (state is SectionsSuccess) {
      return (state as SectionsSuccess).sectionsList;
    }
    return [];
  }
}
