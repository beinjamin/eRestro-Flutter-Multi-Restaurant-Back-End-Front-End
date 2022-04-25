import 'package:erestro/features/promoCode/promoCodeException.dart';
import 'package:erestro/features/promoCode/promoCodeRemoteDataSource.dart';
import 'package:erestro/features/promoCode/promoCodeValidateModel.dart';

class PromoCodeRepository {
  static final PromoCodeRepository _promoCodeRepository = PromoCodeRepository._internal();
  late PromoCodeRemoteDataSource _promoCodeRemoteDataSource;

  factory PromoCodeRepository() {
    _promoCodeRepository._promoCodeRemoteDataSource = PromoCodeRemoteDataSource();
    return _promoCodeRepository;
  }
  PromoCodeRepository._internal();



  //to add user's data to database. This will be in use when authenticating using phoneNumber
  Future<PromoCodeValidateModel> validatePromoCodeData({String? promoCode, String? userId, String? finalTotal}) async {
      try {
        final result = await _promoCodeRemoteDataSource.validatePromoCode(promoCode: promoCode, userId: userId, finalTotal: finalTotal);
        //print("Type:" + result.toString());
        return result; //
      }catch (e) {
        throw PromoCodeException(errorMessageCode: e.toString());
      }
  }

}
