class TransactionException implements Exception {
  final String errorMessageCode;

  TransactionException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
