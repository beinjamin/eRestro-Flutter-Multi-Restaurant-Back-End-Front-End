import 'package:erestro/features/cart/cartException.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/cart/cartRemoteDataSource.dart';

class CartRepository {
  static final CartRepository _cartRepository = CartRepository._internal();
  late CartRemoteDataSource _cartRemoteDataSource;

  factory CartRepository() {
    _cartRepository._cartRemoteDataSource = CartRemoteDataSource();
    return _cartRepository;
  }
  CartRepository._internal();


  //to manageCart
  Future<Map<String, dynamic>> manageCartData({String? userId, String? productVariantId, String? isSavedForLater, String? qty, String? addOnId, String? addOnQty}) async {

      final result = await _cartRemoteDataSource.manageCart(userId: userId, productVariantId: productVariantId, isSavedForLater: isSavedForLater, qty: qty, addOnId: addOnId, addOnQty: addOnQty);
      return Map.from(result); //

  }

  //to placeOrder
  Future<Map<String, dynamic>> placeOrderData({String? userId, String? mobile, String? productVariantId, String? quantity, String? total, String? deliveryCharge, String? taxAmount, String? taxPercentage, String? finalTotal, String? latitude, String? longitude, String? promoCode, String? paymentMethod, String? addressId, String? isWalletUsed, String? walletBalanceUsed, String? activeStatus, String? orderNote, String? deliveryTip}) async {

      final result = await _cartRemoteDataSource.placeOrder( userId: userId,
          mobile: mobile,
          productVariantId: productVariantId,
          quantity: quantity,
          total: total,
          deliveryCharge: deliveryCharge,
          taxAmount: taxAmount,
          taxPercentage: taxPercentage,
          finalTotal: finalTotal,
          latitude: latitude,
          longitude: longitude,
          promoCode: promoCode,
          paymentMethod: paymentMethod,
          addressId: addressId,
          isWalletUsed: isWalletUsed,
          walletBalanceUsed: walletBalanceUsed,
          activeStatus: activeStatus,
          orderNote: orderNote,
          deliveryTip: deliveryTip);
      return Map.from(result); //

  }

  //to removeFromCart
  Future<Map<String, dynamic>> removeFromCart({String? userId, String? productVariantId}) async {
      final result = await _cartRemoteDataSource.removeCart(userId: userId, productVariantId: productVariantId);
      return Map.from(result); //

  }

  //to getCart
  Future <CartModel> getCartData(String? userId) async {
    try {
      CartModel result = await _cartRemoteDataSource.getCart(userId: userId);
      return result;
    } catch (e) {
      throw CartException(errorMessageCode: e.toString());
    }
  }


}
