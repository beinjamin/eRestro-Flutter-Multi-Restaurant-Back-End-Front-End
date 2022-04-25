class SearchException implements Exception {
  final String errorMessageCode;

  SearchException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
