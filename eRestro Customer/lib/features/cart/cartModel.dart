import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/features/promoCode/promoCodesModel.dart';

class CartModel {
  bool? error;
  String? message;
  String? totalQuantity;
  String? subTotal;
  String? taxPercentage;
  String? taxAmount;
  double? overallAmount;
  int? totalArr;
  List<String>? variantId;
  List<Data>? data;

  CartModel(
      {this.error,
        this.message,
        this.totalQuantity,
        this.subTotal,
        this.taxPercentage,
        this.taxAmount,
        this.overallAmount,
        this.totalArr,
        this.variantId,
        this.data,
      });


    CartModel updateCart(List<Data> data,String? totalQuantity, String? subTotal, String? taxPercentage, String? taxAmount, double? overallAmount){
    return CartModel(
      data: data,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      subTotal: subTotal ?? subTotal,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      taxAmount: taxAmount ?? taxAmount,
      overallAmount: overallAmount ?? this.overallAmount,
    );
  }

  CartModel.fromJson(Map<String, dynamic> json) {
    error = json['error'];
    message = json['message'];
    totalQuantity = json['total_quantity'];
    subTotal = json['sub_total'];
    taxPercentage = json['tax_percentage'];
    taxAmount = json['tax_amount'];
    overallAmount = json['overall_amount']==null?0:double.parse(json['overall_amount'].toString());
    totalArr = json['total_arr'];
    variantId = json['variant_id'] == null ? List<String>.from([]) : (json['variant_id'] as List).map((e) => e.toString()).toList();
    data = [];
    if (json['data'] != null) {
      json['data'].forEach((v) {
        data!.add( Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['error'] = this.error;
    data['message'] = this.message;
    data['total_quantity'] = this.totalQuantity;
    data['sub_total'] = this.subTotal;
    data['tax_percentage'] = this.taxPercentage;
    data['tax_amount'] = this.taxAmount;
    data['overall_amount'] = this.overallAmount;
    data['total_arr'] = this.totalArr;
    data['variant_id'] = this.variantId;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? userId;
  String? productVariantId;
  String? qty;
  String? isSavedForLater;
  String? dateCreated;
  String? isPricesInclusiveTax;
  String? name;
  String? image;
  String? shortDescription;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? totalAllowedQuantity;
  String? price;
  String? specialPrice;
  String? taxPercentage;
  List<ProductVariants>? productVariants;
  List<ProductDetails>? productDetails;

  Data(
      {this.id,
        this.userId,
        this.productVariantId,
        this.qty,
        this.isSavedForLater,
        this.dateCreated,
        this.isPricesInclusiveTax,
        this.name,
        this.image,
        this.shortDescription,
        this.minimumOrderQuantity,
        this.quantityStepSize,
        this.totalAllowedQuantity,
        this.price,
        this.specialPrice,
        this.taxPercentage,
        this.productVariants,
        this.productDetails});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    userId = json['user_id'] ?? "";
    productVariantId = json['product_variant_id'] ?? "";
    qty = json['qty'] ?? "";
    isSavedForLater = json['is_saved_for_later'] ?? "";
    dateCreated = json['date_created'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    name = json['name'] ?? "";
    image = json['image'] ?? "";
    shortDescription = json['short_description'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    price = json['price'].toString();
    specialPrice =json['special_price'].toString();
    taxPercentage = json['tax_percentage'] ?? "";
    if (json['product_variants'] != null) {
      productVariants = <ProductVariants>[];
      json['product_variants'].forEach((v) {
        productVariants!.add(new ProductVariants.fromJson(v));
      });
    }
    if (json['product_details'] != null) {
      productDetails = <ProductDetails>[];
      json['product_details'].forEach((v) {
        productDetails!.add(new ProductDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_variant_id'] = this.productVariantId;
    data['qty'] = this.qty;
    data['is_saved_for_later'] = this.isSavedForLater;
    data['date_created'] = this.dateCreated;
    data['is_prices_inclusive_tax'] = this.isPricesInclusiveTax;
    data['name'] = this.name;
    data['image'] = this.image;
    data['short_description'] = this.shortDescription;
    data['minimum_order_quantity'] = this.minimumOrderQuantity;
    data['quantity_step_size'] = this.quantityStepSize;
    data['total_allowed_quantity'] = this.totalAllowedQuantity;
    data['price'] = this.price;
    data['special_price'] = this.specialPrice;
    data['tax_percentage'] = this.taxPercentage;
    if (this.productVariants != null) {
      data['product_variants'] =
          this.productVariants!.map((v) => v.toJson()).toList();
    }
    if (this.productDetails != null) {
      data['product_details'] =
          this.productDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductVariants {
  String? id;
  String? productId;
  String? attributeValueIds;
  String? attributeSet;
  String? price;
  String? specialPrice;
  String? sku;
  String? stock;
  String? images;
  String? availability;
  String? status;
  String? dateAdded;
  String? varaintIds;
  String? attrName;
  String? variantValues;


  ProductVariants(
      {this.id,
        this.productId,
        this.attributeValueIds,
        this.attributeSet,
        this.price,
        this.specialPrice,
        this.sku,
        this.stock,
        this.images,
        this.availability,
        this.status,
        this.dateAdded,
        this.varaintIds,
        this.attrName,
        this.variantValues});

  ProductVariants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    attributeValueIds = json['attribute_value_ids'];
    attributeSet = json['attribute_set'];
    price = json['price'];
    specialPrice = json['special_price'];
    sku = json['sku'];
    stock = json['stock'];
    images = json['images'];
    availability = json['availability'].toString();
    status = json['status'];
    dateAdded = json['date_added'];
    varaintIds = json['varaint_ids'];
    attrName = json['attr_name'];
    variantValues = json['variant_values'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['attribute_value_ids'] = this.attributeValueIds;
    data['attribute_set'] = this.attributeSet;
    data['price'] = this.price;
    data['special_price'] = this.specialPrice;
    data['sku'] = this.sku;
    data['stock'] = this.stock;
    data['images'] = this.images;
    data['availability'] = this.availability;
    data['status'] = this.status;
    data['date_added'] = this.dateAdded;
    data['varaint_ids'] = this.varaintIds;
    data['attr_name'] = this.attrName;
    data['variant_values'] = this.variantValues;
    return data;
  }
}


class Variants {
  String? id;
  String? productId;
  String? attributeValueIds;
  String? attributeSet;
  String? price;
  String? specialPrice;
  String? sku;
  String? stock;
  //List<Null>? images;
  String? availability;
  String? status;
  String? dateAdded;
  String? variantIds;
  String? attrName;
  String? variantValues;
  String? swatcheType;
  String? swatcheValue;
  //List<Null>? imagesMd;
  //List<Null>? imagesSm;
  String? cartCount;
  int? isPurchased;

  Variants(
      {this.id,
        this.productId,
        this.attributeValueIds,
        this.attributeSet,
        this.price,
        this.specialPrice,
        this.sku,
        this.stock,
       // this.images,
        this.availability,
        this.status,
        this.dateAdded,
        this.variantIds,
        this.attrName,
        this.variantValues,
        this.swatcheType,
        this.swatcheValue,
       // this.imagesMd,
       // this.imagesSm,
        this.cartCount,
        this.isPurchased});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    attributeValueIds = json['attribute_value_ids'];
    attributeSet = json['attribute_set'];
    price = json['price'];
    specialPrice = json['special_price'];
    sku = json['sku'];
    stock = json['stock'];
    /*if (json['images'] != null) {
      images = <Null>[];
      json['images'].forEach((v) {
        images!.add(new Null.fromJson(v));
      });
    }*/
    availability = json['availability'].toString();
    status = json['status'];
    dateAdded = json['date_added'];
    variantIds = json['variant_ids'];
    attrName = json['attr_name'];
    variantValues = json['variant_values'];
    swatcheType = json['swatche_type'];
    swatcheValue = json['swatche_value'];
    /*if (json['images_md'] != null) {
      imagesMd = <Null>[];
      json['images_md'].forEach((v) {
        imagesMd!.add(new Null.fromJson(v));
      });
    }*/
    /*if (json['images_sm'] != null) {
      imagesSm = <Null>[];
      json['images_sm'].forEach((v) {
        imagesSm!.add(new Null.fromJson(v));
      });
    }*/
    cartCount = json['cart_count'];
    isPurchased = json['is_purchased'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['attribute_value_ids'] = this.attributeValueIds;
    data['attribute_set'] = this.attributeSet;
    data['price'] = this.price;
    data['special_price'] = this.specialPrice;
    data['sku'] = this.sku;
    data['stock'] = this.stock;
    /*if (this.images != null) {
      data['images'] = this.images!.map((v) => v.toJson()).toList();
    }*/
    data['availability'] = this.availability;
    data['status'] = this.status;
    data['date_added'] = this.dateAdded;
    data['variant_ids'] = this.variantIds;
    data['attr_name'] = this.attrName;
    data['variant_values'] = this.variantValues;
    data['swatche_type'] = this.swatcheType;
    data['swatche_value'] = this.swatcheValue;
    /*if (this.imagesMd != null) {
      data['images_md'] = this.imagesMd!.map((v) => v.toJson()).toList();
    }*/
    /*if (this.imagesSm != null) {
      data['images_sm'] = this.imagesSm!.map((v) => v.toJson()).toList();
    }*/
    data['cart_count'] = this.cartCount;
    data['is_purchased'] = this.isPurchased;
    return data;
  }

}