import 'package:erestro/features/product/productModel.dart';
import 'package:erestro/features/product/productRemoteDataSource.dart';
import 'package:erestro/features/product/productException.dart';

class ProductRepository {
  static final ProductRepository _productRepository = ProductRepository._internal();
  late ProductRemoteDataSource _productRemoteDataSource;

  factory ProductRepository() {
    _productRepository._productRemoteDataSource = ProductRemoteDataSource();
    return _productRepository;
  }
  ProductRepository._internal();


  //to getProduct
  Future <ProductModel> getProductData(String? partnerId, String? latitude,
      String? longitude, String? userId, String? cityId) async {
    try {
      ProductModel result = await _productRemoteDataSource.getProduct(partnerId: partnerId,latitude: latitude ?? "",
        longitude: longitude ?? "", userId: userId, cityId: cityId);
      return result;
    } catch (e) {
      throw ProductException(errorMessageCode: e.toString());
    }
  }

}
