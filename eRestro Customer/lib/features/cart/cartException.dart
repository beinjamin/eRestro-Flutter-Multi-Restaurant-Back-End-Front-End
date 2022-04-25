class CartException implements Exception {
  final String errorMessageCode;

  CartException({required this.errorMessageCode});
  @override
  String toString() => errorMessageCode;
}
