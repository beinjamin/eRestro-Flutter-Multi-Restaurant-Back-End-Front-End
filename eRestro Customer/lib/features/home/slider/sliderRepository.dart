import 'package:erestro/features/home/slider/sliderException.dart';
import 'package:erestro/features/home/slider/sliderModel.dart';
import 'package:erestro/features/home/slider/sliderRemoteDataSource.dart';

class SliderRepository {
  static final SliderRepository _sliderRepository = SliderRepository._internal();
  late SliderRemoteDataSource _sliderRemoteDataSource;

  factory SliderRepository() {
    _sliderRepository._sliderRemoteDataSource = SliderRemoteDataSource();
    return _sliderRepository;
  }

  SliderRepository._internal();

  Future<List<SliderModel>> getSlider() async {
    try {
      List<SliderModel> result = await _sliderRemoteDataSource.getSlider();
      return result/*.map((e) => SliderModel.fromJson(Map.from(e))).toList()*/;
    } catch (e) {
      throw SliderException(errorMessageCode: e.toString());
    }
  }

}
