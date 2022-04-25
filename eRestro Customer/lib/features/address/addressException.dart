class AddressException implements Exception {
  final String errorMessageCode;

  AddressException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
