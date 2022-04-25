import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/rating/deliveryBoyRatingModel.dart';
import 'package:erestro/features/rating/ratingRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../deliveryBoyRatingModel.dart';

abstract class SetRiderRatingState {}

class SetRiderRatingInitial extends SetRiderRatingState {}

class SetRiderRatingProgress extends SetRiderRatingState {}

class SetRiderRatingSuccess extends SetRiderRatingState {
  final RiderRatingModel riderRatingModel;

  SetRiderRatingSuccess(this.riderRatingModel);
}

class SetRiderRatingFailure extends SetRiderRatingState {
  final String errorCode;

  SetRiderRatingFailure(this.errorCode);
}

class SetRiderRatingCubit extends Cubit<SetRiderRatingState> {
  final RatingRepository _ratingRepository;

  SetRiderRatingCubit(this._ratingRepository) : super(SetRiderRatingInitial());

  void setRiderRating(String? userId, String? riderId, String? rating, String? comment) {
    emit(SetRiderRatingProgress());
    _ratingRepository.setRiderRating(userId,  riderId,  rating,  comment).then((value) => emit(SetRiderRatingSuccess(RiderRatingModel(/*data: userId,  RiderId: RiderId,  rating: rating,  comment: comment*/)))).catchError((e) {
      emit(SetRiderRatingFailure(e.toString()));
    });
  }
}