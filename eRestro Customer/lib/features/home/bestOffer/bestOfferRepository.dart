import 'package:erestro/features/home/bestOffer/bestOfferModel.dart';
import 'package:erestro/features/home/bestOffer/bestOfferRemoteDataSource.dart';
import 'package:erestro/features/home/bestOffer/bestOfferException.dart';

class BestOfferRepository {
  static final BestOfferRepository _bestOfferRepository = BestOfferRepository._internal();
  late BestOfferRemoteDataSource _bestOfferRemoteDataSource;

  factory BestOfferRepository() {
    _bestOfferRepository._bestOfferRemoteDataSource = BestOfferRemoteDataSource();
    return _bestOfferRepository;
  }

  BestOfferRepository._internal();

  Future<List<BestOfferModel>> getBestOffer() async {
    try {
      List<BestOfferModel> result = await _bestOfferRemoteDataSource.getBestOffer();
      return result/*.map((e) => BestOfferModel.fromJson(Map.from(e))).toList()*/;
    } catch (e) {
      throw BestOfferException(errorMessageCode: e.toString());
    }
  }

}
