class SliderException implements Exception {
  final String errorMessageCode;

  SliderException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
