import 'package:erestro/features/home/addOnsDataModel.dart';

class VariantsModel {
  String? id;
  String? productId;
  String? attributeValueIds;
  String? attributeSet;
  String? price;
  String? specialPrice;
  String? sku;
  String? stock;
  // List<Null>? images;
  String? availability;
  String? status;
  String? dateAdded;
  String? variantIds;
  String? attrName;
  String? variantValues;
  String? swatcheType;
  String? swatcheValue;
  // List<Null>? imagesMd;
  // List<Null>? imagesSm;
  String? cartCount;
  List<AddOnsDataModel>? addOnsData;
  int? isPurchased;

  VariantsModel(
      {this.id,
        this.productId,
        this.attributeValueIds,
        this.attributeSet,
        this.price,
        this.specialPrice,
        this.sku,
        this.stock,
        //  this.images,
        this.availability,
        this.status,
        this.dateAdded,
        this.variantIds,
        this.attrName,
        this.variantValues,
        //  this.swatcheType,
        this.swatcheValue,
        //  this.imagesMd,
        //  this.imagesSm,
        this.cartCount,
        this.addOnsData,
        this.isPurchased});

  VariantsModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    productId = json['product_id'] ?? "";
    attributeValueIds = json['attribute_value_ids']?? "";
    attributeSet = json['attribute_set']?? "";
    price = json['price']?? "";
    specialPrice = json['special_price']?? "";
    sku = json['sku']?? "";
    stock = json['stock']?? "";
    /*  if (json['images'] != null) {
      images = <Null>[];
      json['images'].forEach((v) {
        images!.add(new Null.fromJson(v));
      });
    }*/
    availability = json['availability'].toString();
    status = json['status'] ?? "";
    dateAdded = json['date_added'] ?? "";
    variantIds = json['variant_ids'] ?? "";
    attrName = json['attr_name'] ?? "";
    variantValues = json['variant_values'] ?? "";
    swatcheType = json['swatche_type'] ?? "";
    swatcheValue = json['swatche_value'] ?? "";
    /*  if (json['images_md'] != null) {
      imagesMd = <Null>[];
      json['images_md'].forEach((v) {
        imagesMd!.add(new Null.fromJson(v));
      });
    }*/
    /*   if (json['images_sm'] != null) {
      imagesSm = <Null>[];
      json['images_sm'].forEach((v) {
        imagesSm!.add(new Null.fromJson(v));
      });
    }*/
    cartCount = json['cart_count'] ?? "";
    if (json['add_ons_data'] != null) {
      addOnsData = <AddOnsDataModel>[];
      json['add_ons_data'].forEach((v) {
        addOnsData!.add(AddOnsDataModel.fromJson(v));
      });
    }
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
    /*  if (this.images != null) {
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
    /*  if (this.imagesMd != null) {
      data['images_md'] = this.imagesMd!.map((v) => v.toJson()).toList();
    }*/
    /*  if (this.imagesSm != null) {
      data['images_sm'] = this.imagesSm!.map((v) => v.toJson()).toList();
    }*/
    data['cart_count'] = this.cartCount;
    if (this.addOnsData != null) {
      data['add_ons_data'] = this.addOnsData!.map((v) => v.toJson()).toList();
    }
    data['is_purchased'] = this.isPurchased;
    return data;
  }
}