class OrderException implements Exception {
  final String errorMessageCode;

  OrderException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
