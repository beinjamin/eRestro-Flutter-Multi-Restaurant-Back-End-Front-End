import 'package:erestro/features/home/addOnsDataModel.dart';

class OrderModel {
  String? id;
  String? userId;
  String? riderId;
  String? addressId;
  String? mobile;
  String? total;
  String? deliveryCharge;
  String? isDeliveryChargeReturnable;
  String? walletBalance;
  String? totalPayable;
  String? promoCode;
  String? promoDiscount;
  String? discount;
  String? finalTotal;
  String? paymentMethod;
  String? latitude;
  String? longitude;
  String? address;
  String? deliveryTime;
  String? deliveryDate;
  List<List>? status;
  String? activeStatus;
  String? dateAdded;
  String? otp;
  String? notes;
  String? deliveryTip;
  String? username;
  String? countryCode;
  String? name;
  String? riderMobile;
  String? riderName;
  String? riderImage;
  String? riderRating;
  String? riderNoOfRatings;
  String? totalTaxPercent;
  String? totalTaxAmount;
  String? invoiceHtml;
  List<OrderItems>? orderItems;

  OrderModel({this.id, this.userId, this.riderId, this.addressId, this.mobile, this.total, this.deliveryCharge, this.isDeliveryChargeReturnable, this.walletBalance, this.totalPayable, this.promoCode, this.promoDiscount, this.discount, this.finalTotal, this.paymentMethod, this.latitude, this.longitude, this.address, this.deliveryTime, this.deliveryDate, this.status, this.activeStatus, this.dateAdded, this.otp, this.notes, this.deliveryTip, this.username, this.countryCode, this.name, this.riderMobile, this.riderName, this.riderImage, this.riderRating, this.riderNoOfRatings, this.totalTaxPercent, this.totalTaxAmount, this.invoiceHtml, this.orderItems});

  OrderModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    riderId = json['rider_id'];
    addressId = json['address_id'];
    mobile = json['mobile'];
    total = json['total'];
    deliveryCharge = json['delivery_charge'];
    isDeliveryChargeReturnable = json['is_delivery_charge_returnable'];
    walletBalance = json['wallet_balance'];
    totalPayable = json['total_payable'];
    promoCode = json['promo_code'];
    promoDiscount = json['promo_discount'];
    discount = json['discount'];
    finalTotal = json['final_total'];
    paymentMethod = json['payment_method'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    address = json['address'];
    deliveryTime = json['delivery_time'];
    deliveryDate = json['delivery_date'];
    if (json['status'] != null) {
      status = <List>[];
      json['status'].forEach((v) { status!.add((v)); });
    }
    activeStatus = json['active_status'];
    dateAdded = json['date_added'];
    otp = json['otp'];
    notes = json['notes'];
    deliveryTip = json['delivery_tip'];
    username = json['username'];
    countryCode = json['country_code'];
    name = json['name'];
    riderMobile = json['rider_mobile'];
    riderName = json['rider_name'];
    riderImage = json['rider_image'];
    riderRating = json['rider_rating'];
    riderNoOfRatings = json['rider_no_of_ratings'];
    totalTaxPercent = json['total_tax_percent'];
    totalTaxAmount = json['total_tax_amount'];
    invoiceHtml = json['invoice_html'];
    if (json['order_items'] != null) {
      orderItems = <OrderItems>[];
      json['order_items'].forEach((v) { orderItems!.add(new OrderItems.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['rider_id'] = this.riderId;
    data['address_id'] = this.addressId;
    data['mobile'] = this.mobile;
    data['total'] = this.total;
    data['delivery_charge'] = this.deliveryCharge;
    data['is_delivery_charge_returnable'] = this.isDeliveryChargeReturnable;
    data['wallet_balance'] = this.walletBalance;
    data['total_payable'] = this.totalPayable;
    data['promo_code'] = this.promoCode;
    data['promo_discount'] = this.promoDiscount;
    data['discount'] = this.discount;
    data['final_total'] = this.finalTotal;
    data['payment_method'] = this.paymentMethod;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['address'] = this.address;
    data['delivery_time'] = this.deliveryTime;
    data['delivery_date'] = this.deliveryDate;
    if (this.status != null) {
      data['status'] = this.status!.map((v) => v).toList();
    }

    data['active_status'] = this.activeStatus;
    data['date_added'] = this.dateAdded;
    data['otp'] = this.otp;
    data['notes'] = this.notes;
    data['delivery_tip'] = this.deliveryTip;
    data['username'] = this.username;
    data['country_code'] = this.countryCode;
    data['name'] = this.name;
    data['rider_mobile'] = this.riderMobile;
    data['rider_name'] = this.riderName;
    data['rider_image'] = this.riderImage;
    data['rider_rating'] = this.riderRating;
    data['rider_no_of_ratings'] = this.riderNoOfRatings;
    data['total_tax_percent'] = this.totalTaxPercent;
    data['total_tax_amount'] = this.totalTaxAmount;
    data['invoice_html'] = this.invoiceHtml;
    if (this.orderItems != null) {
      data['order_items'] = this.orderItems!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

/*class Status {


  Status({});

  Status.fromJson(Map<String, dynamic> json) {
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return data;
  }
}*/

class OrderItems {
  String? id;
  String? userId;
  String? orderId;
  String? partnerId;
  String? isCredited;
  String? productName;
  String? variantName;
  List<AddOnsDataModel>? addOns;
  String? productVariantId;
  String? quantity;
  String? price;
  String? discountedPrice;
  String? taxPercent;
  String? taxAmount;
  String? discount;
  String? subTotal;
  String? dateAdded;
  String? productId;
  String? isCancelable;
  String? isReturnable;
  String? image;
  String? name;
  String? type;
  String? orderCounter;
  List<RestaurantDetails>? partnerDetails;
  String? varaintIds;
  String? variantValues;
  String? attrName;
  String? imageSm;
  String? imageMd;

  OrderItems({this.id, this.userId, this.orderId, this.partnerId, this.isCredited, this.productName, this.variantName, this.productVariantId, this.quantity, this.price, this.discountedPrice, this.taxPercent, this.taxAmount, this.discount, this.subTotal, this.dateAdded, this.productId, this.isCancelable, this.isReturnable, this.image, this.name, this.type, this.orderCounter, this.partnerDetails, this.varaintIds, this.variantValues, this.attrName, this.imageSm, this.imageMd});

  OrderItems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    partnerId = json['partner_id'];
    isCredited = json['is_credited'];
    productName = json['product_name'];
    variantName = json['variant_name'];
    if (json['add_ons'] != null) {
      addOns = <AddOnsDataModel>[];
      json['add_ons'].forEach((v) { addOns!.add(AddOnsDataModel.fromJson(v)); });
    }
    productVariantId = json['product_variant_id'];
    quantity = json['quantity'];
    price = json['price'];
    discountedPrice = json['discounted_price'];
    taxPercent = json['tax_percent'];
    taxAmount = json['tax_amount'];
    discount = json['discount'];
    subTotal = json['sub_total'];
    dateAdded = json['date_added'];
    productId = json['product_id'];
    isCancelable = json['is_cancelable'];
    isReturnable = json['is_returnable'];
    image = json['image'];
    name = json['name'];
    type = json['type'];
    orderCounter = json['order_counter'];
    if (json['partner_details'] != null) {
      partnerDetails = <RestaurantDetails>[];
      json['partner_details'].forEach((v) { partnerDetails!.add(RestaurantDetails.fromJson(v)); });
    }
    varaintIds = json['varaint_ids'];
    variantValues = json['variant_values'];
    attrName = json['attr_name'];
    imageSm = json['image_sm'];
    imageMd = json['image_md'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['order_id'] = this.orderId;
    data['partner_id'] = this.partnerId;
    data['is_credited'] = this.isCredited;
    data['product_name'] = this.productName;
    data['variant_name'] = this.variantName;
    if (this.addOns != null) {
      data['add_ons'] = this.addOns!.map((v) => v.toJson()).toList();
    }
    data['product_variant_id'] = this.productVariantId;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['discounted_price'] = this.discountedPrice;
    data['tax_percent'] = this.taxPercent;
    data['tax_amount'] = this.taxAmount;
    data['discount'] = this.discount;
    data['sub_total'] = this.subTotal;
    data['date_added'] = this.dateAdded;
    data['product_id'] = this.productId;
    data['is_cancelable'] = this.isCancelable;
    data['is_returnable'] = this.isReturnable;
    data['image'] = this.image;
    data['name'] = this.name;
    data['type'] = this.type;
    data['order_counter'] = this.orderCounter;
    if (this.partnerDetails != null) {
      data['partner_details'] = this.partnerDetails!.map((v) => v.toJson()).toList();
    }
    data['varaint_ids'] = this.varaintIds;
    data['variant_values'] = this.variantValues;
    data['attr_name'] = this.attrName;
    data['image_sm'] = this.imageSm;
    data['image_md'] = this.imageMd;
    return data;
  }
}

class RestaurantDetails {
  String? partnerId;
  String? isFavorite;
  String? isRestroOpen;
  String? partnerCookTime;
  String? distance;
  String? ownerName;
  String? email;
  List<String>? tags;
  String? mobile;
  String? partnerAddress;
  String? cityId;
  String? cityName;
  String? fcmId;
  String? latitude;
  String? longitude;
  String? balance;
  String? slug;
  String? partnerName;
  String? description;
  String? partnerIndicator;
  List<String>? gallery;
  String? partnerRating;
  String? noOfRatings;
  String? accountNumber;
  String? accountName;
  String? bankCode;
  String? bankName;
  String? cookingTime;
  String? status;
  String? commission;
  String? partnerProfile;
  String? nationalIdentityCard;
  String? addressProof;
  String? taxNumber;
  String? dateAdded;

  RestaurantDetails({this.partnerId, this.isFavorite, this.isRestroOpen, this.partnerCookTime, this.distance, this.ownerName, this.email, this.tags, this.mobile, this.partnerAddress, this.cityId, this.cityName, this.fcmId, this.latitude, this.longitude, this.balance, this.slug, this.partnerName, this.description, this.partnerIndicator, this.gallery, this.partnerRating, this.noOfRatings, this.accountNumber, this.accountName, this.bankCode, this.bankName, this.cookingTime, this.status, this.commission, this.partnerProfile, this.nationalIdentityCard, this.addressProof, this.taxNumber, this.dateAdded});

  RestaurantDetails.fromJson(Map<String, dynamic> json) {
    partnerId = json['partner_id'];
    isFavorite = json['is_favorite'];
    isRestroOpen = json['is_restro_open'];
    partnerCookTime = json['partner_cook_time'];
    distance = json['distance'];
    ownerName = json['owner_name'];
    email = json['email'];
    tags = json['tags'].cast<String>();
    mobile = json['mobile'];
    partnerAddress = json['partner_address'];
    cityId = json['city_id'];
    cityName = json['city_name'];
    fcmId = json['fcm_id'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    balance = json['balance'];
    slug = json['slug'];
    partnerName = json['partner_name'];
    description = json['description'];
    partnerIndicator = json['partner_indicator'];
    gallery = json['gallery'].cast<String>();
    partnerRating = json['partner_rating'];
    noOfRatings = json['no_of_ratings'];
    accountNumber = json['account_number'];
    accountName = json['account_name'];
    bankCode = json['bank_code'];
    bankName = json['bank_name'];
    cookingTime = json['cooking_time'];
    status = json['status'];
    commission = json['commission'];
    partnerProfile = json['partner_profile'];
    nationalIdentityCard = json['national_identity_card'];
    addressProof = json['address_proof'];
    taxNumber = json['tax_number'];
    dateAdded = json['date_added'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['partner_id'] = this.partnerId;
    data['is_favorite'] = this.isFavorite;
    data['is_restro_open'] = this.isRestroOpen;
    data['partner_cook_time'] = this.partnerCookTime;
    data['distance'] = this.distance;
    data['owner_name'] = this.ownerName;
    data['email'] = this.email;
    data['tags'] = this.tags;
    data['mobile'] = this.mobile;
    data['partner_address'] = this.partnerAddress;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['fcm_id'] = this.fcmId;
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    data['balance'] = this.balance;
    data['slug'] = this.slug;
    data['partner_name'] = this.partnerName;
    data['description'] = this.description;
    data['partner_indicator'] = this.partnerIndicator;
    data['gallery'] = this.gallery;
    data['partner_rating'] = this.partnerRating;
    data['no_of_ratings'] = this.noOfRatings;
    data['account_number'] = this.accountNumber;
    data['account_name'] = this.accountName;
    data['bank_code'] = this.bankCode;
    data['bank_name'] = this.bankName;
    data['cooking_time'] = this.cookingTime;
    data['status'] = this.status;
    data['commission'] = this.commission;
    data['partner_profile'] = this.partnerProfile;
    data['national_identity_card'] = this.nationalIdentityCard;
    data['address_proof'] = this.addressProof;
    data['tax_number'] = this.taxNumber;
    data['date_added'] = this.dateAdded;
    return data;
  }
}