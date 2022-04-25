import 'package:erestro/features/product/productModel.dart';
import 'package:erestro/features/product/productRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;


//State
@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}
class Product extends ProductState {
  final List<ProductModel> productList;

  Product({required this.productList});
}
class ProductProgress extends ProductState {
  ProductProgress();
}

class ProductSuccess extends ProductState {
  final ProductModel productModel;
  ProductSuccess(this.productModel);
}

class ProductFailure extends ProductState {
  final String errorMessage;
  ProductFailure(this.errorMessage);
}

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _productRepository;
  ProductCubit(this._productRepository) : super(ProductInitial());

  //to getCart user
  void getProduct({
    String? partnerId,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
  }) {
    //emitting GetCartProgress state
    emit(ProductProgress());
    //GetCart user with given provider and also add user detials in api
    _productRepository
        .getProductData(partnerId, latitude, longitude, userId, cityId).then((value) => emit(ProductSuccess(value))).catchError((e) {
      emit(ProductFailure(e.toString()));
    });
  }

}


/*@immutable
abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductProgress extends ProductState {}

class ProductSuccess extends ProductState {
  final List<ProductModel> productList;
  final int totalData;
  final bool hasMore;
  ProductSuccess(this.productList, this.totalData, this.hasMore);
}

class ProductFailure extends ProductState {
  final String errorMessageCode;
  ProductFailure(this.errorMessageCode);
}
String? totalHasMore;
class ProductCubit extends Cubit<ProductState> {
  ProductCubit() : super(ProductInitial());

  Future<List<ProductModel>> _fetchData({
    required String limit,
    String? offset,
    String? partnerId,
    String? latitude,
    String? longitude,
    String? userId,
    String? cityId,
  }) async {
    try {
      //
      //body of post request
      final body = {
        limitKey: limit,
        offsetKey: offset ?? "",
        partnerIdKey: partnerId,
        filterByKey: "p.id",
        latitudeKey: latitude ?? "",
        longitudeKey: longitude ?? "",
        userIdKey: userId,
        cityIdKey: cityId ?? ""
      };
      if (offset == null) {
        body.remove(offset);
      }
      final response = await http.post(Uri.parse(getProductsUrl), body: body,
          headers: ApiUtils.getHeaders());
      final responseJson = jsonDecode(response.body);
      //print(responseJson);
      totalHasMore = responseJson['total'];


      if (responseJson['error']) {
        throw ProductException(errorMessageCode: responseJson['message']);
      }
      return (responseJson['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } on SocketException catch (_) {
      throw ProductException(errorMessageCode: StringsRes.noInternet);
    } on ProductException catch (e) {
      throw ProductException(errorMessageCode: e.toString());
    } catch (e) {
      throw ProductException(errorMessageKey: e.toString(), errorMessageCode: '');
    }
  }

  void fetchProduct(String limit,
      String? partnerId,
      String? latitude,
      String? longitude,
      String? userId,
      String? cityId) {

    emit(ProductProgress());
    _fetchData(limit: limit, partnerId: partnerId, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      final List<ProductModel> usersDetails = value;
      final total = int.parse(totalHasMore!);
      emit(ProductSuccess(
        usersDetails,
        total,
        total > usersDetails.length,
      ));
    }).catchError((e) {
      emit(ProductFailure(e.toString()));
    });
  }

  void fetchMoreProductData(String limit,
      String? partnerId,
      String? latitude,
      String? longitude,
      String? userId,
      String? cityId) {
    _fetchData(limit: limit, offset: (state as ProductSuccess).productList.length.toString(), partnerId: partnerId, latitude: latitude, longitude: longitude, userId: userId, cityId: cityId).then((value) {
      //
      final oldState = (state as ProductSuccess);
      final List<ProductModel> usersDetails = value;
      final List<ProductModel> updatedUserDetails = List.from(oldState.productList);
      updatedUserDetails.addAll(usersDetails);
      emit(ProductSuccess(updatedUserDetails, oldState.totalData, oldState.totalData > updatedUserDetails.length));
    }).catchError((e) {
      emit(ProductFailure(e.toString()));
    });
  }

  bool hasMoreData() {
    if (state is ProductSuccess) {
      return (state as ProductSuccess).hasMore;
    } else {
      return false;
    }
  }
  productList() {
    if (state is ProductSuccess) {
      return (state as ProductSuccess).productList;
    }
    return [];
  }
}*/
