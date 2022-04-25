import 'package:erestro/features/auth/authModel.dart';
import 'package:erestro/features/cart/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';

import '../cartModel.dart';


//State
@immutable
abstract class ManageCartState {}

class ManageCartInitial extends ManageCartState {}
class ManageCart extends ManageCartState {
  //to manageCart
  String? userId, productVariantId;

  ManageCart({this.userId, this.productVariantId});
}
class ManageCartProgress extends ManageCartState {
  ManageCartProgress();
}

class ManageCartSuccess extends ManageCartState {
  final List<Data> data;
  final String? totalQuantity, subTotal, taxPercentage, taxAmount;
  final double? overallAmount;
  ManageCartSuccess(this.data,this.totalQuantity, this.subTotal, this.taxPercentage, this.taxAmount, this.overallAmount);
}

class ManageCartFailure extends ManageCartState {
  final String errorMessage;
  ManageCartFailure(this.errorMessage);
}

class ManageCartCubit extends Cubit<ManageCartState> {
  final CartRepository _cartRepository;
  ManageCartCubit(this._cartRepository) : super(ManageCartInitial());

  //to manageCart user
  void manageCartUser({
    String? userId, String? productVariantId, String? isSavedForLater, String? qty, String? addOnId, String? addOnQty
      }) {
    //emitting manageCartProgress state
    emit(ManageCartProgress());
    //manageCart
    _cartRepository
        .manageCartData(
        userId: userId,
        productVariantId: productVariantId,
        isSavedForLater: isSavedForLater,
        qty: qty,
        addOnId: addOnId,
        addOnQty: addOnQty,
    )
        .then((result) {
      //success
      emit(ManageCartSuccess((result['cart'] as List).map((e) => Data.fromJson(e)).toList()  , result['data']['total_quantity'], result['data']['sub_total'], result['data']['tax_percentage'], result['data']['tax_amount'], double.parse(result['data']['overall_amount']),));
    }).catchError((e) {
      //failure
      emit(ManageCartFailure(e.toString()));
    });
  }

}
