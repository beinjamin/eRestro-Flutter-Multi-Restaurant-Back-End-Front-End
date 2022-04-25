class HelpAndSupportException implements Exception {
  final String errorMessageCode;

  HelpAndSupportException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
