class TicketException implements Exception {
  final String errorMessageCode;

  TicketException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
