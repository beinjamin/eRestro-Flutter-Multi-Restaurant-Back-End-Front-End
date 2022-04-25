import 'package:erestro/features/home/restaurantWorkingTimeModel.dart';

class RestaurantModel {
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
  List<RestaurantWorkingTimeModel>? partnerWorkingTime;

  RestaurantModel copyWith(
      {String? isFavourite}){
    return RestaurantModel(
      partnerId: this.partnerId,
      isFavorite: isFavourite ?? this.isFavorite,
      isRestroOpen: this.isRestroOpen,
      partnerCookTime: this.partnerCookTime,
      distance: this.distance,
      ownerName: this.ownerName,
      email: this.email,
      tags: this.tags,
      mobile: this.mobile,
      partnerAddress: this.partnerAddress,
      cityId: this.cityId,
      cityName: this.cityName,
      fcmId: this.fcmId,
      latitude: this.latitude,
      longitude: this.longitude,
      balance: this.balance,
      slug: this.slug,
      partnerName: this.partnerName,
      description: this.description,
      partnerIndicator: this.partnerIndicator,
      gallery: this.gallery,
      partnerRating: this.partnerRating,
      noOfRatings: this.noOfRatings,
      accountNumber: this.accountNumber,
      accountName: this.accountName,
      bankCode: this.bankCode,
      bankName: this.bankName,
      cookingTime: this.cookingTime,
      status: this.status,
      commission: this.commission,
      partnerProfile: this.partnerProfile,
      nationalIdentityCard: this.nationalIdentityCard,
      addressProof: this.addressProof,
      taxNumber: this.taxNumber,
      dateAdded: this.dateAdded,
      partnerWorkingTime: this.partnerWorkingTime,
    );
  }


  RestaurantModel(
      {this.partnerId,
        this.isFavorite,
        this.isRestroOpen,
        this.partnerCookTime,
        this.distance,
        this.ownerName,
        this.email,
        this.tags,
        this.mobile,
        this.partnerAddress,
        this.cityId,
        this.cityName,
        this.fcmId,
        this.latitude,
        this.longitude,
        this.balance,
        this.slug,
        this.partnerName,
        this.description,
        this.partnerIndicator,
        this.gallery,
        this.partnerRating,
        this.noOfRatings,
        this.accountNumber,
        this.accountName,
        this.bankCode,
        this.bankName,
        this.cookingTime,
        this.status,
        this.commission,
        this.partnerProfile,
        this.nationalIdentityCard,
        this.addressProof,
        this.taxNumber,
        this.dateAdded,
        this.partnerWorkingTime});

  RestaurantModel.fromJson(Map<String, dynamic> json) {
    partnerId = json['partner_id'] ?? "";
    isFavorite = json['is_favorite'] ?? "";
    isRestroOpen = json['is_restro_open'] ?? "";
    partnerCookTime = json['partner_cook_time'] ?? "";
    distance = json['distance'] ?? "";
    ownerName = json['owner_name'] ?? "";
    email = json['email'] ?? "";
    tags =  json['tags'] == null ? List<String>.from([]) : (json['tags'] as List).map((e) => e.toString()).toList() ;
    mobile = json['mobile'] ?? "";
    partnerAddress = json['partner_address'] ?? "";
    cityId = json['city_id'] ?? "";
    cityName = json['city_name'] ?? "";
    fcmId = json['fcm_id'] ?? "";
    latitude = json['latitude'] ?? "";
    longitude = json['longitude'] ?? "";
    balance = json['balance'] ?? "";
    slug = json['slug'] ?? "";
    partnerName = json['partner_name'] ?? "";
    description = json['description'] ?? "";
    partnerIndicator = json['partner_indicator'] ?? "";
    gallery = json['gallery'] == null ? List<String>.from([]) : (json['gallery'] as List).map((e) => e.toString()).toList() ;
    partnerRating = json['partner_rating'] ?? "";
    noOfRatings = json['no_of_ratings'] ?? "";
    accountNumber = json['account_number'] ?? "";
    accountName = json['account_name'] ?? "";
    bankCode = json['bank_code'] ?? "";
    bankName = json['bank_name'] ?? "";
    cookingTime = json['cooking_time'] ?? "";
    status = json['status'] ?? "";
    commission = json['commission'] ?? "";
    partnerProfile = json['partner_profile'] ?? "";
    nationalIdentityCard = json['national_identity_card'] ?? "";
    addressProof = json['address_proof'] ?? "";
    taxNumber = json['tax_number'] ?? "";
    dateAdded = json['date_added'] ?? "";
    if (json['partner_working_time'] != null) {
      partnerWorkingTime = <RestaurantWorkingTimeModel>[];
      json['partner_working_time'].forEach((v) {
        partnerWorkingTime!.add(RestaurantWorkingTimeModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
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
    if (this.partnerWorkingTime != null) {
      data['partner_working_time'] =
          this.partnerWorkingTime!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
