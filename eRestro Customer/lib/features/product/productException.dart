class ProductException implements Exception {
  final String errorMessageCode;

  ProductException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
