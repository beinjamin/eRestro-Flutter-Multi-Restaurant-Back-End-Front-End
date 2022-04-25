class PromoCodeValidateModel {
  String? id;
  String? promoCode;
  String? message;
  String? startDate;
  String? endDate;
  String? noOfUsers;
  String? minimumOrderAmount;
  String? discount;
  String? discountType;
  String? maxDiscountAmount;
  String? repeatUsage;
  String? noOfRepeatUsage;
  String? image;
  String? status;
  String? dateCreated;
  String? promoUsedCounter;
  String? userPromoUsageCounter;
  String? finalTotal;
  String? finalDiscount;

  PromoCodeValidateModel(
      {this.id,
        this.promoCode,
        this.message,
        this.startDate,
        this.endDate,
        this.noOfUsers,
        this.minimumOrderAmount,
        this.discount,
        this.discountType,
        this.maxDiscountAmount,
        this.repeatUsage,
        this.noOfRepeatUsage,
        this.image,
        this.status,
        this.dateCreated,
        this.promoUsedCounter,
        this.userPromoUsageCounter,
        this.finalTotal,
        this.finalDiscount});

  PromoCodeValidateModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    promoCode = json['promo_code'];
    message = json['message'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    noOfUsers = json['no_of_users'];
    minimumOrderAmount = json['minimum_order_amount'];
    discount = json['discount'];
    discountType = json['discount_type'];
    maxDiscountAmount = json['max_discount_amount'];
    repeatUsage = json['repeat_usage'];
    noOfRepeatUsage = json['no_of_repeat_usage'];
    image = json['image'];
    status = json['status'];
    dateCreated = json['date_created'];
    promoUsedCounter = json['promo_used_counter'];
    userPromoUsageCounter = json['user_promo_usage_counter'];
    finalTotal = json['final_total'];
    finalDiscount = json['final_discount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['promo_code'] = this.promoCode;
    data['message'] = this.message;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['no_of_users'] = this.noOfUsers;
    data['minimum_order_amount'] = this.minimumOrderAmount;
    data['discount'] = this.discount;
    data['discount_type'] = this.discountType;
    data['max_discount_amount'] = this.maxDiscountAmount;
    data['repeat_usage'] = this.repeatUsage;
    data['no_of_repeat_usage'] = this.noOfRepeatUsage;
    data['image'] = this.image;
    data['status'] = this.status;
    data['date_created'] = this.dateCreated;
    data['promo_used_counter'] = this.promoUsedCounter;
    data['user_promo_usage_counter'] = this.userPromoUsageCounter;
    data['final_total'] = this.finalTotal;
    data['final_discount'] = this.finalDiscount;
    return data;
  }
}