class RatingException implements Exception {
  final String errorMessageCode;

  RatingException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
