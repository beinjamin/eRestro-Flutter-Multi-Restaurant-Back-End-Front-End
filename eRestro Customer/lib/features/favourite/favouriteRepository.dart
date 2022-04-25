import 'package:erestro/features/favourite/favouriteDataSource.dart';
import 'package:erestro/features/favourite/favouriteException.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';

class FavouriteRepository {
  static final FavouriteRepository _favouriteRepository = FavouriteRepository._internal();
  late FavouriteRemoteDataSource _favouriteRemoteDataSource;

  factory FavouriteRepository() {
    _favouriteRepository._favouriteRemoteDataSource = FavouriteRemoteDataSource();
    return _favouriteRepository;
  }

  FavouriteRepository._internal();

  Future<List<RestaurantModel>> getFavourite(String? userId, String? type) async {
    try {
      List<RestaurantModel> result = await _favouriteRemoteDataSource.getFavouriteRestaurants(userId: userId, type: type);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future getFavouriteAdd(String? userId, String? type, String? typeId) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, typeId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future getFavouriteRemove(String? userId, String? type, String? typeId) async {
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, typeId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future<List<RestaurantModel>> getFavoriteRestaurants(String? userId, String? type) async {
    /*await Future.delayed(const Duration(seconds: 2));
    return [];*/
    try {
      List<RestaurantModel> result = await _favouriteRemoteDataSource.getFavouriteRestaurants(userId: userId, type: type);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future favoriteRestaurant({required String userId, required String type, required String restaurantId}) async {
    /*await Future.delayed(const Duration(milliseconds: 500));
    return true;*/
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, restaurantId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future unFavoriteRestaurant({required String userId, required String type, required String restaurantId}) async {
    /*await Future.delayed(const Duration(milliseconds: 500));
    return true;*/
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, restaurantId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future<List<ProductDetails>> getFavoriteProducts(String? userId, String? type) async {
    /*await Future.delayed(const Duration(seconds: 2));
    return [];*/
    try {
      List<ProductDetails> result = await _favouriteRemoteDataSource.getFavouriteProducts(userId: userId, type: type);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future favoriteProduct({required String userId, required String type, required String productId}) async {
    /*await Future.delayed(const Duration(milliseconds: 500));
    return true;*/
    try {
      final result = await _favouriteRemoteDataSource.favouriteAdd(userId, type, productId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }

  Future unFavoriteProduct({required String userId, required String type, required String productId}) async {
    /*await Future.delayed(const Duration(milliseconds: 500));
    return true;*/
    try {
      final result = await _favouriteRemoteDataSource.favouriteRemove(userId, type, productId);
      return result;
    } catch (e) {
      throw FavouriteException(errorMessageCode: e.toString());
    }
  }
}
