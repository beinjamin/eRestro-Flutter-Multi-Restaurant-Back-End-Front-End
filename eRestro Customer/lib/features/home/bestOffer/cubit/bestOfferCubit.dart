import 'package:erestro/features/home/bestOffer/bestOfferModel.dart';
import 'package:erestro/features/home/bestOffer/bestOfferRepository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class BestOfferState {}

class BestOfferInitial extends BestOfferState {}

class BestOfferProgress extends BestOfferState {}

class BestOfferSuccess extends BestOfferState {
  final List<BestOfferModel> bestOfferList;

  BestOfferSuccess(this.bestOfferList);
}

class BestOfferFailure extends BestOfferState {
  final String errorCode;

  BestOfferFailure(this.errorCode);
}

class BestOfferCubit extends Cubit<BestOfferState> {
  final BestOfferRepository _bestOfferRepository;

  BestOfferCubit(this._bestOfferRepository) : super(BestOfferInitial());

  void fetchBestOffer() {
    /*if(state is BestOfferSuccess) {
      return;
    }*/
    emit(BestOfferProgress());
    _bestOfferRepository.getBestOffer().then((value) => emit(BestOfferSuccess(value))).catchError((e) {
      emit(BestOfferFailure(e.toString()));
    });
  }
}