import 'package:erestro/features/order/orderException.dart';
import 'package:erestro/features/order/orderLiveTrackingModel.dart';
import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/features/order/orderRemoteDataSource.dart';


class OrderRepository {
  static final OrderRepository _orderRepository = OrderRepository._internal();
  late OrderRemoteDataSource _orderRemoteDataSource;

  factory OrderRepository() {
    _orderRepository._orderRemoteDataSource = OrderRemoteDataSource();
    return _orderRepository;
  }
  OrderRepository._internal();


  //to getOrder
  Future <OrderModel> getOrderData(String? status, String? orderId) async {
    try {
      OrderModel result = await _orderRemoteDataSource.getOrder(status: status, orderId: orderId);
      return result;
    } catch (e) {
      throw OrderException(errorMessageCode: e.toString());
    }
  }

  //to getOrderLiveTracking
  Future <OrderLiveTrackingModel> getOrderLiveTrackingData(String? orderId) async {
    try {
      OrderLiveTrackingModel result = await _orderRemoteDataSource.getOrderLiveTracing(orderId: orderId);
      return result;
    } catch (e) {
      throw OrderException(errorMessageCode: e.toString());
    }
  }

}
