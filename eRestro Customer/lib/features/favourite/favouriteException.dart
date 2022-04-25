class FavouriteException implements Exception {
  final String errorMessageCode;

  FavouriteException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
