import 'package:erestro/features/cart/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/features/auth/authRepository.dart';


//State
@immutable
abstract class RemoveFromCartState {}

class RemoveFromCartInitial extends RemoveFromCartState {}
class RemoveFromCart extends RemoveFromCartState {
  //to removeFromCart
  String? userId, productVariantId;

  RemoveFromCart({this.userId, this.productVariantId});
}
class RemoveFromCartProgress extends RemoveFromCartState {
  RemoveFromCartProgress();
}

class RemoveFromCartSuccess extends RemoveFromCartState {
  RemoveFromCartSuccess();
}

class RemoveFromCartFailure extends RemoveFromCartState {
  final String errorMessage;
  RemoveFromCartFailure(this.errorMessage);
}

class RemoveFromCartCubit extends Cubit<RemoveFromCartState> {
  final CartRepository _cartRepository;
  RemoveFromCartCubit(this._cartRepository) : super(RemoveFromCartInitial());

  //to RemoveFromCart user
  void removeFromCart({
      String? userId,
      String? productVariantId,}) {
    //emitting removeFromCartProgress state
    emit(RemoveFromCartProgress());
    //removeFromCart user in api
    _cartRepository
        .removeFromCart(
        userId: userId,
        productVariantId: productVariantId,
    )
        .then((result) {
      //success
      emit(RemoveFromCartSuccess());
    }).catchError((e) {
      //failure
      emit(RemoveFromCartFailure(e.toString()));
    });
  }

}
