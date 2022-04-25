import 'package:erestro/features/favourite/favouriteRepository.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusInitial extends UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusInProgress extends UpdateProductFavoriteStatusState {}

class UpdateProductFavoriteStatusSuccess extends UpdateProductFavoriteStatusState {
  final ProductDetails product;
  final bool wasFavoriteProductProcess; //to check that process is to favorite the product or not
  UpdateProductFavoriteStatusSuccess(this.product, this.wasFavoriteProductProcess);
}

class UpdateProductFavoriteStatusFailure extends UpdateProductFavoriteStatusState {
  final String errorMessage;

  UpdateProductFavoriteStatusFailure(this.errorMessage);
}

class UpdateProductFavoriteStatusCubit extends Cubit<UpdateProductFavoriteStatusState> {
  late FavouriteRepository favoriteRepository;
  UpdateProductFavoriteStatusCubit() : super(UpdateProductFavoriteStatusInitial()) {
    favoriteRepository = FavouriteRepository();
  }

  void favoriteProduct({required String userId, required String type, required ProductDetails product}) {
    //
    emit(UpdateProductFavoriteStatusInProgress());
    favoriteRepository.favoriteProduct(userId: userId, type: type, productId: product.id!).then((value) {
      emit(UpdateProductFavoriteStatusSuccess(product, true));
    }).catchError((e) {
      emit(UpdateProductFavoriteStatusFailure(e.toString()));
    });
  }

  //can pass only Product id here
  void unFavoriteProduct({required String userId, required String type, required ProductDetails product}) {
    emit(UpdateProductFavoriteStatusInProgress());
    favoriteRepository.unFavoriteProduct(userId: userId, type: type, productId: product.id!).then((value) {
      emit(UpdateProductFavoriteStatusSuccess(product, false));
    }).catchError((e) {
      emit(UpdateProductFavoriteStatusFailure(e.toString()));
    });
  }
}
