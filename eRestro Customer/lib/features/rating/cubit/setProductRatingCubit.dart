import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/rating/ratingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class SetProductRatingState {}

class SetProductRatingInitial extends SetProductRatingState {}

class SetProductRatingProgress extends SetProductRatingState {}

class SetProductRatingSuccess extends SetProductRatingState {
  final AddressModel addressModel;

  SetProductRatingSuccess(this.addressModel);
}

class SetProductRatingFailure extends SetProductRatingState {
  final String errorCode;

  SetProductRatingFailure(this.errorCode);
}

class SetProductRatingCubit extends Cubit<SetProductRatingState> {
  final RatingRepository _ratingRepository;

  SetProductRatingCubit(this._ratingRepository) : super(SetProductRatingInitial());

  void setProductRating(String? userId, String? productId, String? rating, String? comment/*, String? images*/) {
    emit(SetProductRatingProgress());
    _ratingRepository.setProductRating(userId, productId, rating, comment/*, images*/).then((value) => emit(SetProductRatingSuccess(AddressModel(/*userId: userId, productId: productId, rating: rating, comment: comment, images: images*/)))).catchError((e) {
      emit(SetProductRatingFailure(e.toString()));
    });
  }
}