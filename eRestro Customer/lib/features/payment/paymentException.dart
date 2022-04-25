class PaymentException implements Exception {
  final String errorMessageCode;

  PaymentException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
