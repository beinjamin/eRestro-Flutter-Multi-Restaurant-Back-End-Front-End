import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/cart/cartRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


//State
@immutable
abstract class GetCartState {}

class GetCartInitial extends GetCartState {}
class GetCart extends GetCartState {
  //to store authDetials
  final List<CartModel> cartList;

  GetCart({required this.cartList});
}
class GetCartProgress extends GetCartState {
  GetCartProgress();
}

class GetCartSuccess extends GetCartState {
  final CartModel cartModel;
  GetCartSuccess(this.cartModel);
}

class GetCartFailure extends GetCartState {
  final String errorMessage;
  GetCartFailure(this.errorMessage);
}

class GetCartCubit extends Cubit<GetCartState> {
  final CartRepository _cartRepository;
  GetCartCubit(this._cartRepository) : super(GetCartInitial());

  //to getCart user
  getCartUser({
    String? userId
  }) {
    //emitting GetCartProgress state
    /*if(state is GetCartSuccess) {
      return;
    }*/
    emit(GetCartProgress());
    //GetCart user with given provider and also add user detials in api
    _cartRepository
        .getCartData(userId).then((value) => emit(GetCartSuccess(value))).catchError((e) {
          //print("hellow: $e");
      emit(GetCartFailure(e.toString()));
    });
  }

  CartModel getCartModel(){
    if(state is GetCartSuccess){
      return (state as GetCartSuccess).cartModel;
    }
    return CartModel();
  }

  void updateCartList(CartModel cartModel){
      emit(GetCartSuccess(cartModel));
  }

}
