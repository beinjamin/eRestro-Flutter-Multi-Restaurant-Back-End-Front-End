class SettingModel {
  List<String>? logo;
  List<String>? privacyPolicy;
  List<String>? termsConditions;
  List<String>? fcmServerKey;
  List<String>? contactUs;
  List<String>? aboutUs;
  List<String>? currency;
  List<UserData>? userData;
  List<SystemSettings>? systemSettings;
  List<String>? tags;

  SettingModel(
      {this.logo,
        this.privacyPolicy,
        this.termsConditions,
        this.fcmServerKey,
        this.contactUs,
        this.aboutUs,
        this.currency,
        this.userData,
        this.systemSettings,
        this.tags});

  SettingModel.fromJson(Map<String, dynamic> json) {
    logo = json['logo'] == null ? List<String>.from([]) : (json['logo'] as List).map((e) => e.toString()).toList() ;
    privacyPolicy = json['privacy_policy'] == null ? List<String>.from([]) : (json['privacy_policy'] as List).map((e) => e.toString()).toList() ;
    termsConditions = json['terms_conditions'] == null ? List<String>.from([]) : (json['terms_conditions'] as List).map((e) => e.toString()).toList() ;
    fcmServerKey = json['fcm_server_key'] == null ? List<String>.from([]) : (json['fcm_server_key'] as List).map((e) => e.toString()).toList() ;
    contactUs = json['contact_us'] == null ? List<String>.from([]) : (json['contact_us'] as List).map((e) => e.toString()).toList() ;
    aboutUs = json['about_us'] == null ? List<String>.from([]) : (json['about_us'] as List).map((e) => e.toString()).toList() ;
    currency = json['currency'] == null ? List<String>.from([]) : (json['currency'] as List).map((e) => e.toString()).toList() ;

    if (json['user_data'] != null) {
      userData = <UserData>[];
      json['user_data'].forEach((v) {
        if (v.toString().isNotEmpty){
          userData!.add(UserData.fromJson(v));
      }
      });
    }
    if (json['system_settings'] != null) {
      systemSettings = <SystemSettings>[];
      json['system_settings'].forEach((v) {
        systemSettings!.add(SystemSettings.fromJson(v));
      });
    }
    tags = json['tags'] == null ? List<String>.from([]) : (json['tags'] as List).map((e) => e.toString()).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logo'] = this.logo;
    data['privacy_policy'] = this.privacyPolicy;
    data['terms_conditions'] = this.termsConditions;
    data['fcm_server_key'] = this.fcmServerKey;
    data['contact_us'] = this.contactUs;
    data['about_us'] = this.aboutUs;
    data['currency'] = this.currency;
    if (this.userData != null) {
      data['user_data'] = this.userData!.map((v) => v.toJson()).toList();
    }
    if (this.systemSettings != null) {
      data['system_settings'] =
          this.systemSettings!.map((v) => v.toJson()).toList();
    }
    data['tags'] = this.tags;
    return data;
  }
}

class UserData {
  String? id;
  String? username;
  String? email;
  String? mobile;
  String? balance;
  String? dob;
  String? referralCode;
  String? friendsCode;
  String? cityName;
  String? area;
  String? landmark;
  String? pincode;
  String? cartTotalItems;

  UserData(
      {this.id,
        this.username,
        this.email,
        this.mobile,
        this.balance,
        this.dob,
        this.referralCode,
        this.friendsCode,
        this.cityName,
        this.area,
        this.landmark,
        this.pincode,
        this.cartTotalItems});

  UserData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    username = json['username'];
    email = json['email'];
    mobile = json['mobile'];
    balance = json['balance'];
    dob = json['dob'];
    referralCode = json['referral_code'];
    friendsCode = json['friends_code'];
    cityName = json['city_name'];
    area = json['area'];
    landmark = json['landmark'];
    pincode = json['pincode'];
    cartTotalItems = json['cart_total_items'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['username'] = this.username;
    data['email'] = this.email;
    data['mobile'] = this.mobile;
    data['balance'] = this.balance;
    data['dob'] = this.dob;
    data['referral_code'] = this.referralCode;
    data['friends_code'] = this.friendsCode;
    data['city_name'] = this.cityName;
    data['area'] = this.area;
    data['landmark'] = this.landmark;
    data['pincode'] = this.pincode;
    data['cart_total_items'] = this.cartTotalItems;
    return data;
  }
}

class SystemSettings {
  String? systemConfigurations;
  String? systemTimezoneGmt;
  String? systemConfigurationsId;
  String? appName;
  String? supportNumber;
  String? supportEmail;
  String? currentVersion;
  String? currentVersionIos;
  String? isVersionSystemOn;
  String? currency;
  String? systemTimezone;
  String? isReferEarnOn;
  String? isEmailSettingOn;
  String? minReferEarnOrderAmount;
  String? referEarnBonus;
  String? referEarnMethod;
  String? maxReferEarnAmount;
  String? referEarnBonusTimes;
  String? minimumCartAmt;
  String? lowStockLimit;
  String? maxItemsCart;
  String? isRiderOtpSettingOn;
  String? cartBtnOnList;
  String? expandProductImages;
  String? isAppMaintenanceModeOn;

  SystemSettings(
      {this.systemConfigurations,
        this.systemTimezoneGmt,
        this.systemConfigurationsId,
        this.appName,
        this.supportNumber,
        this.supportEmail,
        this.currentVersion,
        this.currentVersionIos,
        this.isVersionSystemOn,
        this.currency,
        this.systemTimezone,
        this.isReferEarnOn,
        this.isEmailSettingOn,
        this.minReferEarnOrderAmount,
        this.referEarnBonus,
        this.referEarnMethod,
        this.maxReferEarnAmount,
        this.referEarnBonusTimes,
        this.minimumCartAmt,
        this.lowStockLimit,
        this.maxItemsCart,
        this.isRiderOtpSettingOn,
        this.cartBtnOnList,
        this.expandProductImages,
        this.isAppMaintenanceModeOn});

  SystemSettings.fromJson(Map<String, dynamic> json) {
    systemConfigurations = json['system_configurations'];
    systemTimezoneGmt = json['system_timezone_gmt'];
    systemConfigurationsId = json['system_configurations_id'];
    appName = json['app_name'];
    supportNumber = json['support_number'];
    supportEmail = json['support_email'];
    currentVersion = json['current_version'];
    currentVersionIos = json['current_version_ios'];
    isVersionSystemOn = json['is_version_system_on'];
    currency = json['currency'];
    systemTimezone = json['system_timezone'];
    isReferEarnOn = json['is_refer_earn_on'];
    isEmailSettingOn = json['is_email_setting_on'];
    minReferEarnOrderAmount = json['min_refer_earn_order_amount'];
    referEarnBonus = json['refer_earn_bonus'];
    referEarnMethod = json['refer_earn_method'];
    maxReferEarnAmount = json['max_refer_earn_amount'];
    referEarnBonusTimes = json['refer_earn_bonus_times'];
    minimumCartAmt = json['minimum_cart_amt'];
    lowStockLimit = json['low_stock_limit'];
    maxItemsCart = json['max_items_cart'];
    isRiderOtpSettingOn = json['is_rider_otp_setting_on'];
    cartBtnOnList = json['cart_btn_on_list'];
    expandProductImages = json['expand_product_images'];
    isAppMaintenanceModeOn = json['is_app_maintenance_mode_on'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['system_configurations'] = this.systemConfigurations;
    data['system_timezone_gmt'] = this.systemTimezoneGmt;
    data['system_configurations_id'] = this.systemConfigurationsId;
    data['app_name'] = this.appName;
    data['support_number'] = this.supportNumber;
    data['support_email'] = this.supportEmail;
    data['current_version'] = this.currentVersion;
    data['current_version_ios'] = this.currentVersionIos;
    data['is_version_system_on'] = this.isVersionSystemOn;
    data['currency'] = this.currency;
    data['system_timezone'] = this.systemTimezone;
    data['is_refer_earn_on'] = this.isReferEarnOn;
    data['is_email_setting_on'] = this.isEmailSettingOn;
    data['min_refer_earn_order_amount'] = this.minReferEarnOrderAmount;
    data['refer_earn_bonus'] = this.referEarnBonus;
    data['refer_earn_method'] = this.referEarnMethod;
    data['max_refer_earn_amount'] = this.maxReferEarnAmount;
    data['refer_earn_bonus_times'] = this.referEarnBonusTimes;
    data['minimum_cart_amt'] = this.minimumCartAmt;
    data['low_stock_limit'] = this.lowStockLimit;
    data['max_items_cart'] = this.maxItemsCart;
    data['is_rider_otp_setting_on'] = this.isRiderOtpSettingOn;
    data['cart_btn_on_list'] = this.cartBtnOnList;
    data['expand_product_images'] = this.expandProductImages;
    data['is_app_maintenance_mode_on'] = this.isAppMaintenanceModeOn;
    return data;
  }
}