import 'package:erestro/features/order/orderLiveTrackingModel.dart';
import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/features/order/orderRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


//State
@immutable
abstract class OrderLiveTrackingState {}

class OrderLiveTrackingInitial extends OrderLiveTrackingState {}
class OrderLiveTracking extends OrderLiveTrackingState {
  final OrderLiveTrackingModel orderLiveTrackingList;

  OrderLiveTracking({required this.orderLiveTrackingList});
}
class OrderLiveTrackingProgress extends OrderLiveTrackingState {
  OrderLiveTrackingProgress();
}

class OrderLiveTrackingSuccess extends OrderLiveTrackingState {
  final OrderLiveTrackingModel orderLiveTracking;
  OrderLiveTrackingSuccess(this.orderLiveTracking);
}

class OrderLiveTrackingFailure extends OrderLiveTrackingState {
  final String errorMessage;
  OrderLiveTrackingFailure(this.errorMessage);
}

class OrderLiveTrackingCubit extends Cubit<OrderLiveTrackingState> {
  final OrderRepository _orderRepository;
  OrderLiveTrackingCubit(this._orderRepository) : super(OrderLiveTrackingInitial());

  //to getOrder user
  void getOrderLiveTracking({
    String? orderId,
  }) {
    if(state is! OrderLiveTrackingSuccess){
      //emitting GetOrderProgress state
      emit(OrderLiveTrackingProgress());
    }
    //GetOrder user with given provider and also add user detials in api
    _orderRepository
        .getOrderLiveTrackingData(orderId).then((value) => emit(OrderLiveTrackingSuccess(value))).catchError((e) {
      emit(OrderLiveTrackingFailure(e.toString()));
    });
  }

}
