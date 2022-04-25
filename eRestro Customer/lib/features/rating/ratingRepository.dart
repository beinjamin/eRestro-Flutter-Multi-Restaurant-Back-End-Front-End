import 'package:erestro/features/rating/RatingException.dart';
import 'package:erestro/features/rating/ratingRemoteDataSource.dart';

class RatingRepository {
  static final RatingRepository _ratingRepository = RatingRepository._internal();
  late RatingRemoteDataSource _ratingRemoteDataSource;

  factory RatingRepository() {
    _ratingRepository._ratingRemoteDataSource = RatingRemoteDataSource();
    return _ratingRepository;
  }

  RatingRepository._internal();

  Future setProductRating(String? userId, String? productId, String? rating, String? comment /*, String? images*/) async {
    try {
      final result = await _ratingRemoteDataSource.setProductRating(userId, productId, rating, comment /*,  images*/);
      return result;
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future setRiderRating(String? userId, String? riderId, String? rating, String? comment) async {
    try {
      final result = await _ratingRemoteDataSource.setRiderRating(userId, riderId, rating, comment);
      return result;
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future deleteProductRating(String? ratingId) async {
    try {
      final result = await _ratingRemoteDataSource.deleteProductRating(ratingId);
      return result;
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }

  Future deleteRiderRating(String? ratingId) async {
    try {
      final result = await _ratingRemoteDataSource.deleteRiderRating(ratingId);
      return result;
    } catch (e) {
      throw RatingException(errorMessageCode: e.toString());
    }
  }
}
