class PromoCodeException implements Exception {
  final String errorMessageCode;

  PromoCodeException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
