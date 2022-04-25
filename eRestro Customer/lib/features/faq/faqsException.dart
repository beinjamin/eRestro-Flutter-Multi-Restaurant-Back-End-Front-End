class FaqsException implements Exception {
  final String errorMessageCode;

  FaqsException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
