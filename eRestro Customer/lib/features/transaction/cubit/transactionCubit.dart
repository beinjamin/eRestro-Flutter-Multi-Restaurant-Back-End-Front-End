import 'dart:convert';
import 'dart:io';
import 'package:erestro/features/home/restaurantsNearBy/restaurantException.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/transaction/restaurantException.dart';
import 'package:erestro/features/transaction/transactionModel.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/apiUtils.dart';
import 'package:erestro/utils/constants.dart';

import 'package:http/http.dart' as http;

@immutable
abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionProgress extends TransactionState {}

class TransactionSuccess extends TransactionState {
  final List<TransactionModel> transactionList;
  final int totalData;
  final bool hasMore;
  TransactionSuccess(this.transactionList, this.totalData, this.hasMore);
}

class TransactionFailure extends TransactionState {
  final String errorMessageCode;
  TransactionFailure(this.errorMessageCode);
}
String? totalHasMore;
class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit() : super(TransactionInitial());
  Future<List<TransactionModel>> _fetchData({
    required String limit,
    String? offset,
    String? userId,
    String? transactionType
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        userIdKey: userId ?? "",
        transactionTypeKey: transactionType ?? ""
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(transactionsUrl), body: body, headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];

      if (responseJson['error']) {
        throw TransactionException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List).map((e) => TransactionModel.fromJson(e)).toList();
    } on SocketException catch (_) {
      throw TransactionException(errorMessageCode: StringsRes.noInternet);
    } on TransactionException catch (e) {
      throw TransactionException(errorMessageCode: e.toString());
    } catch (e) {
      throw TransactionException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

/*  getTransaction(String limit) async {
    emit(TransactionProgress());
    _notificationCubit.getTransaction(limit).then((val) => emit(TransactionSuccess(val,)),).catchError((e) {
      emit(TransactionFailure(e.toString()));
    });
  }*/
  void fetchTransaction(String limit, String? userId, String? transactionType) {
    emit(TransactionProgress());
    _fetchData(limit: limit, userId: userId, transactionType: transactionType).then((value) {
      final List<TransactionModel> usersDetails = value;
      final total = /*value.length*/int.parse(totalHasMore!);
      emit(TransactionSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(TransactionFailure(e.toString()));
    });
  }

  void fetchMoreTransactionData(String limit, String? userId, String? transactionType) {
    _fetchData(limit: limit, offset: (state as TransactionSuccess).transactionList.length.toString(), userId: userId, transactionType: transactionType).then((value) {
      //
      final oldState = (state as TransactionSuccess);
      final List<TransactionModel> usersDetails = value;
      final List<TransactionModel> updatedUserDetails = List.from(oldState.transactionList);
      updatedUserDetails.addAll(usersDetails);
      emit(TransactionSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(TransactionFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is TransactionSuccess) {
      return (state as TransactionSuccess).hasMore;
    } else {
      return false;
    }
  }
  transactionList() {
    if (state is TransactionSuccess) {
      return (state as TransactionSuccess).transactionList;
    }
    return [];
  }

  void addTransaction(TransactionModel transactionModel)
  {
    if(state is TransactionSuccess) {
      //
      List<TransactionModel> currentTransaction = (state as TransactionSuccess).transactionList;
      int offset = (state as TransactionSuccess).totalData;
      bool limit = (state as TransactionSuccess).hasMore;
      currentTransaction.insert(0, transactionModel);
      emit(TransactionSuccess( List<TransactionModel>.from(currentTransaction), offset, limit));
    }
  }


}
