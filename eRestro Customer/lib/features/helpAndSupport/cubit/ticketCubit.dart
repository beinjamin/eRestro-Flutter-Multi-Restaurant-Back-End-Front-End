import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/helpAndSupport/ticketException.dart';
import 'package:erestro/features/helpAndSupport/ticketModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class TicketState {}

class TicketInitial extends TicketState {}

class TicketProgress extends TicketState {}

class TicketSuccess extends TicketState {
  final List<TicketModel> ticketList;
  final int totalData;
  final bool hasMore;
  TicketSuccess(this.ticketList, this.totalData, this.hasMore);
}

class TicketFailure extends TicketState {
  final String errorMessageCode;
  TicketFailure(this.errorMessageCode);
}
String? totalHasMore;
class TicketCubit extends Cubit<TicketState> {
  TicketCubit() : super(TicketInitial());
  Future<List<TicketModel>> getTicket({
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
      final response = await http.post(Uri.parse(getTicketsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      // print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw TicketException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => TicketModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw TicketException(errorMessageCode: StringsRes.noInternet);
    } on TicketException catch (e) {
      throw TicketException(errorMessageCode: e.toString());
    } catch (e) {
      throw TicketException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getTicket(String limit) async {
    emit(TicketProgress());
    _ticketCubit.getTicket(limit).then((val) => emit(TicketSuccess(val,)),).catchError((e) {
      emit(TicketFailure(e.toString()));
    });
  }*/
  void fetchTicket(String limit) {
    emit(TicketProgress());
    getTicket(limit: limit).then((value) {
      final List<TicketModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(TicketSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(TicketFailure(e.toString()));
    });
  }

  void fetchMoreTicketData(String limit) {
    getTicket(limit: limit, offset: (state as TicketSuccess).ticketList.length.toString()).then((value) {
      //
      final oldState = (state as TicketSuccess);
      final List<TicketModel> usersDetails = value;
      final List<TicketModel> updatedUserDetails = List.from(oldState.ticketList);
      updatedUserDetails.addAll(usersDetails);
      emit(TicketSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(TicketFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TicketSuccess) {
      return (state as TicketSuccess).hasMore;
    } else {
      return false;
    }
  }
  ticketList() {
    if (state is TicketSuccess) {
      return (state as TicketSuccess).ticketList;
    }
    return [];
  }

  void deleteTicket(String? id)
  {
    if(state is TicketSuccess) {
      //
      List<TicketModel> currentTicket = (state as TicketSuccess).ticketList;
      bool hasMore = (state as TicketSuccess).hasMore;
      int totalData = (state as TicketSuccess).totalData;
      //TicketModel addressModel= (state as TicketSuccess).addressModel;
      currentTicket.removeWhere((element) => element.id == id);
      emit(TicketSuccess( List<TicketModel>.from(currentTicket), totalData, hasMore));
    }
  }

  void addTicket(TicketModel addressModel)
  {
    if(state is TicketSuccess) {
      //
      List<TicketModel> currentTicket = (state as TicketSuccess).ticketList;
      bool hasMore = (state as TicketSuccess).hasMore;
      int totalData = (state as TicketSuccess).totalData;
      currentTicket.insert(0, addressModel);
      emit(TicketSuccess( List<TicketModel>.from(currentTicket), totalData, hasMore));
    }
  }
}
