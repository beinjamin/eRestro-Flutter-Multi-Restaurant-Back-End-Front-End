import 'package:erestro/features/payment/paymentException.dart';
import 'package:erestro/features/payment/paymentRemoteDataSource.dart';

class PaymentRepository {
  static final PaymentRepository _paymentRepository = PaymentRepository._internal();
  late PaymentRemoteDataSource _paymentRemoteDataSource;

  factory PaymentRepository() {
    _paymentRepository._paymentRemoteDataSource = PaymentRemoteDataSource();
    return _paymentRepository;
  }

  PaymentRepository._internal();

  Future<String> getPayment(String? userId, String? orderId, String? amount) async {
    try {
      final result = await _paymentRemoteDataSource.getPayment(userId, orderId, amount);
      return result;
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }

  Future<String> getAppSettings(String? userId, String? orderId, String? amount) async {
    try {
      final result = await _paymentRemoteDataSource.getPayment(userId, orderId, amount);
      return result;
    } catch (e) {
      throw PaymentException(errorMessageCode: e.toString());
    }
  }

}
