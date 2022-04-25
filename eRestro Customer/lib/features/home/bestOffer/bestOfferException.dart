class BestOfferException implements Exception {
  final String errorMessageCode;

  BestOfferException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
