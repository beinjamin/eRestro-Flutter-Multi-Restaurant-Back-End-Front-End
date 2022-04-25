import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/features/order/orderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


//State
@immutable
abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}
class OrderDetail extends OrderDetailState {
  final List<OrderModel> orderDetailList;

  OrderDetail({required this.orderDetailList});
}
class OrderDetailProgress extends OrderDetailState {
  OrderDetailProgress();
}

class OrderDetailSuccess extends OrderDetailState {
  final String? status, orderId;
  OrderDetailSuccess(this.status, this.orderId);
}

class OrderDetailFailure extends OrderDetailState {
  final String errorMessage;
  OrderDetailFailure(this.errorMessage);
}

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderRepository _orderRepository;
  OrderDetailCubit(this._orderRepository) : super(OrderDetailInitial());

  //to getOrder user
  void getOrderDetail({
    String? status,
    String? orderId,
  }) {
    //emitting GetOrderProgress state
    emit(OrderDetailProgress());
    //GetOrder user with given provider and also add user detials in api
    _orderRepository
        .getOrderData(status, orderId).then((value) => emit(OrderDetailSuccess(status, orderId))).catchError((e) {
      emit(OrderDetailFailure(e.toString()));
    });
  }

}
