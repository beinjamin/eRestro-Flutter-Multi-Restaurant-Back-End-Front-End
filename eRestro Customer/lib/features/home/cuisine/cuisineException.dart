class CuisineException implements Exception {
  final String errorMessageCode;

  CuisineException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
