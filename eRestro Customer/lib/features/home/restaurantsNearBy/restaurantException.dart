class RestaurantException implements Exception {
  final String errorMessageCode;

  RestaurantException({required this.errorMessageCode, errorMessageKey});

  @override
  String toString() => errorMessageCode;
}
