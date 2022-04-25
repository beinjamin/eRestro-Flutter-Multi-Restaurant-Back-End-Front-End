import 'package:erestro/features/home/minMaxPriceModel.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/variantsModel.dart';

class BestOfferModel {
  String? id;
  String? type;
  String? typeId;
  String? image;
  String? dateAdded;
  List<Data>? data;

  BestOfferModel(
      {this.id, this.type, this.typeId, this.image, this.dateAdded, this.data});

  BestOfferModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    typeId = json['type_id'];
    image = json['image'];
    dateAdded = json['date_added'];

    data = json['data'] == null
        ? []
        : (json['data'] as List).map((e) => Data.fromJson(e ?? {})).toList();
    // if (json['data'] != null) {
    //   data = List<Data>.from([]);
    //   json['data'].forEach((v) {
    //     data!.add( Data.fromJson(v));
    //   });
    // }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['type_id'] = this.typeId;
    data['image'] = this.image;
    data['date_added'] = this.dateAdded;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? name;
  String? parentId;
  String? slug;
  String? image;
  String? banner;
  String? rowOrder;
  String? status;
  String? clicks;

  // List<Null>? children;
  String? text;
  State? state; //State
  String? icon;
  String? level;
  String? total;
  String? sales;
  String? stockType;
  String? isPricesInclusiveTax;
  String? type;
  String? attrValueIds;
  String? partnerRating;
  String? partnerSlug;
  String? partnerNoOfRatings;
  String? partnerProfile;
  String? partnerName;
  String? partnerDescription;
  String? partnerId;
  String? ownerName;
  String? stock;
  String? categoryId;
  String? shortDescription;
  String? totalAllowedQuantity;
  String? minimumOrderQuantity;
  String? quantityStepSize;
  String? codAllowed;
  String? rating;
  String? noOfRatings;
  String? isCancelable;
  String? cancelableTill;
  String? indicator;
  List<String>? highlights;
  String? availability;
  String? categoryName;
  String? taxPercentage;

  // List<Null>? reviewImages;
  // List<Null>? attributes;
  List<VariantsModel>? variants;
  MinMaxPriceModel? minMaxPrice;
  bool? isPurchased;
  String? isFavorite;
  String? imageMd;
  String? imageSm;
  List<RestaurantModel>? partnerDetails;

  // List<Null>? variantAttributes;

  Data({
    this.id,
    this.name,
    this.parentId,
    this.slug,
    this.image,
    this.banner,
    this.rowOrder,
    this.status,
    this.clicks,
    //  this.children,
    this.text,
    this.state,
    this.icon,
    this.level,
    this.total,
    this.sales,
    this.stockType,
    this.isPricesInclusiveTax,
    this.type,
    this.attrValueIds,
    this.partnerRating,
    this.partnerSlug,
    this.partnerNoOfRatings,
    this.partnerProfile,
    this.partnerName,
    this.partnerDescription,
    this.partnerId,
    this.ownerName,
    this.stock,
    this.categoryId,
    this.shortDescription,
    this.totalAllowedQuantity,
    this.minimumOrderQuantity,
    this.quantityStepSize,
    this.codAllowed,
    this.rating,
    this.noOfRatings,
    this.isCancelable,
    this.cancelableTill,
    this.indicator,
    this.highlights,
    this.availability,
    this.categoryName,
    this.taxPercentage,
    //  this.reviewImages,
    //  this.attributes,
    this.variants,
    this.minMaxPrice,
    this.isPurchased,
    this.isFavorite,
    this.imageMd,
    this.imageSm,
    //  this.variantAttributes
    this.partnerDetails});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? "";
    name = json['name'] ?? "";
    parentId = json['parent_id'] ?? "";
    slug = json['slug'] ?? "";
    image = json['image'] ?? "";
    banner = json['banner'] ?? "";
    rowOrder = json['row_order'] ?? "";
    status = json['status'] ?? "";
    clicks = json['clicks'] ?? "";
    /*   if (json['children'] != null) {
      children = <Null>[];
      json['children'].forEach((v) {
        children!.add(new Null.fromJson(v));
      });
    }*/
    text = json['text'] ?? "";
    state = State.fromJson(json['state'] ?? {});
    icon = json['icon'] ?? "";
    level = json['level'] == null ? "" : json['level'].toString();
    total = json['total'] == null ? "" : json['total'].toString();
    sales = json['sales'] ?? "";
    stockType = json['stock_type'] ?? "";
    isPricesInclusiveTax = json['is_prices_inclusive_tax'] ?? "";
    type = json['type'] ?? "";
    attrValueIds = json['attr_value_ids'] ?? "";
    partnerRating = json['partner_rating'] ?? "";
    partnerSlug = json['partner_slug'] ?? "";
    partnerNoOfRatings = json['partner_no_of_ratings'] ?? "";
    partnerProfile = json['partner_profile'] ?? "";
    partnerName = json['partner_name'] ?? "";
    partnerDescription = json['partner_description'] ?? "";
    partnerId = json['partner_id'] ?? "";
    ownerName = json['owner_name'] ?? "";
    stock = json['stock'] ?? "";
    categoryId = json['category_id'] ?? "";
    shortDescription = json['short_description'] ?? "";
    totalAllowedQuantity = json['total_allowed_quantity'] ?? "";
    minimumOrderQuantity = json['minimum_order_quantity'] ?? "";
    quantityStepSize = json['quantity_step_size'] ?? "";
    codAllowed = json['cod_allowed'] ?? "";
    rating = json['rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    isCancelable = json['is_cancelable'] ?? "";
    cancelableTill = json['cancelable_till'] ?? "";
    indicator = json['indicator'] ?? "";
    highlights = json['highlights'] == null
        ? List<String>.from([])
        : (json['highlights'] as List).map((e) => e.toString()).toList();
    availability = json['availability'].toString();
    categoryName = json['category_name'] ?? "";
    taxPercentage = json['tax_percentage'] ?? "";
    /*  if (json['review_images'] != null) {
      reviewImages = <Null>[];
      json['review_images'].forEach((v) {
        reviewImages!.add(new Null.fromJson(v));
      });
    }*/
    /*  if (json['attributes'] != null) {
      attributes = <Null>[];
      json['attributes'].forEach((v) {
        attributes!.add(new Null.fromJson(v));
      });
    }*/
    if (json['variants'] != null) {
      variants = <VariantsModel>[];
      json['variants'].forEach((v) {
        variants!.add(VariantsModel.fromJson(v));
      });
    } else {
      variants = [];
    }
    minMaxPrice = json['min_max_price'] != null
        ? MinMaxPriceModel.fromJson(json['min_max_price'])
        : null;
    isPurchased = json['is_purchased'] ?? false;
    isFavorite = json['is_favorite'] ?? "";
    imageMd = json['image_md'] ?? "";
    imageSm = json['image_sm'] ?? "";
    /*  if (json['variant_attributes'] != null) {
      variantAttributes = <Null>[];
      json['variant_attributes'].forEach((v) {
        variantAttributes!.add(new Null.fromJson(v));
      });
    }*/
    if (json['partner_details'] != null) {
      partnerDetails = <RestaurantModel>[];
      json['partner_details'].forEach((v) {
        partnerDetails!.add(RestaurantModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['parent_id'] = this.parentId;
    data['slug'] = this.slug;
    data['image'] = this.image;
    data['banner'] = this.banner;
    data['row_order'] = this.rowOrder;
    data['status'] = this.status;
    data['clicks'] = this.clicks;
    /*  if (this.children != null) {
      data['children'] = this.children!.map((v) => v.toJson()).toList();
    }*/
    data['text'] = this.text;
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    data['icon'] = this.icon;
    data['level'] = this.level;
    data['total'] = this.total;
    data['sales'] = this.sales;
    data['stock_type'] = this.stockType;
    data['is_prices_inclusive_tax'] = this.isPricesInclusiveTax;
    data['type'] = this.type;
    data['attr_value_ids'] = this.attrValueIds;
    data['partner_rating'] = this.partnerRating;
    data['partner_slug'] = this.partnerSlug;
    data['partner_no_of_ratings'] = this.partnerNoOfRatings;
    data['partner_profile'] = this.partnerProfile;
    data['partner_name'] = this.partnerName;
    data['partner_description'] = this.partnerDescription;
    data['partner_id'] = this.partnerId;
    data['owner_name'] = this.ownerName;
    data['stock'] = this.stock;
    data['category_id'] = this.categoryId;
    data['short_description'] = this.shortDescription;
    data['total_allowed_quantity'] = this.totalAllowedQuantity;
    data['minimum_order_quantity'] = this.minimumOrderQuantity;
    data['quantity_step_size'] = this.quantityStepSize;
    data['cod_allowed'] = this.codAllowed;
    data['rating'] = this.rating;
    data['no_of_ratings'] = this.noOfRatings;
    data['is_cancelable'] = this.isCancelable;
    data['cancelable_till'] = this.cancelableTill;
    data['indicator'] = this.indicator;
    data['highlights'] = this.highlights;
    data['availability'] = this.availability;
    data['category_name'] = this.categoryName;
    data['tax_percentage'] = this.taxPercentage;
    /*  if (this.reviewImages != null) {
      data['review_images'] =
          this.reviewImages!.map((v) => v.toJson()).toList();
    }*/
    /*  if (this.attributes != null) {
      data['attributes'] = this.attributes!.map((v) => v.toJson()).toList();
    }*/
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    if (this.minMaxPrice != null) {
      data['min_max_price'] = this.minMaxPrice!.toJson();
    }
    data['is_purchased'] = this.isPurchased;
    data['is_favorite'] = this.isFavorite;
    data['image_md'] = this.imageMd;
    data['image_sm'] = this.imageSm;
    /*  if (this.variantAttributes != null) {
      data['variant_attributes'] =
          this.variantAttributes!.map((v) => v.toJson()).toList();
    }*/
    if (this.partnerDetails != null) {
      data['partner_details'] =
          this.partnerDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class State {
  bool? opened;

  State({this.opened});

  State.fromJson(Map<String, dynamic> json) {
    opened = json['opened'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['opened'] = this.opened;
    return data;
  }
}
