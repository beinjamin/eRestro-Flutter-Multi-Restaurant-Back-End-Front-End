import 'package:erestro/features/promoCode/promoCodeRepository.dart';
import 'package:erestro/features/promoCode/promoCodeValidateModel.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


abstract class ValidatePromoCodeState {}

class ValidatePromoCodeIntial extends ValidatePromoCodeState {}

class ValidatePromoCodeFetchInProgress extends ValidatePromoCodeState {}

class ValidatePromoCodeFetchSuccess extends ValidatePromoCodeState {
  final PromoCodeValidateModel? promoCodeValidateModel;

  ValidatePromoCodeFetchSuccess( {this.promoCodeValidateModel});
}

class ValidatePromoCodeFetchFailure extends ValidatePromoCodeState {
  final String errorCode;

  ValidatePromoCodeFetchFailure(this.errorCode);
}

class ValidatePromoCodeCubit extends Cubit<ValidatePromoCodeState> {
  final PromoCodeRepository _validatePromoCodeRepository;
  ValidatePromoCodeCubit(this._validatePromoCodeRepository) : super(ValidatePromoCodeIntial());

  //to getCart user
  void getValidatePromoCode(
      String? promoCode,
      String? userId,
      String? finalTotal
      ) {
    //emitting GetCartProgress state
    emit(ValidatePromoCodeFetchInProgress());
    //GetCart user with given provider and also add user detials in api
    _validatePromoCodeRepository.validatePromoCodeData(promoCode: promoCode, userId: userId, finalTotal: finalTotal).then((value) => emit(ValidatePromoCodeFetchSuccess(promoCodeValidateModel: value))).catchError((e) {
      emit(ValidatePromoCodeFetchFailure(e.toString()));
    });
  }

}
