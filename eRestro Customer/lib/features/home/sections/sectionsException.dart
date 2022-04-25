class SectionsException implements Exception {
  final String errorMessageCode;

  SectionsException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
