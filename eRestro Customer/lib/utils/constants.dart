final String appName = "eRestro";
final String packageName = "PLACE_YOUR_PACKAGE_NAME";
final String androidLink = 'https://play.google.com/store/apps/details?id=';

final String iosPackage = 'PLACE_YOUR_PACKAGE_NAME';
final String iosLink = 'your ios link here';

//Hive all boxes name
final String authBox = "auth";
final String settingsBox = "settings";
final String userdetailsBox = "userdetails";
final String addressBox = "address";

//authBox keys
final String isLoginKey = "isLogin";
final String jwtTokenKey = "jwtToken";
final String firebaseIdBoxKey = "firebaseId";
final String authTypeKey = "authType";
final String isNewUserKey = "isNewUser";
final String lastLoginKey = "lastLogin";
final String ipAddressKey = "IpAddressKey";
final String balanceKey = "balanceKey";
final String noOfRatingsKey = "noOfRatingsKey";
final String activationSelectorKey = "activationSelectorKey";
final String activationCodeKey = "activationCodeKey";
final String forgottenPasswordSelectorKey = "forgottenPasswordSelectorKey";
final String forgottenPasswordCodeKey = "forgottenPasswordCodeKey";
final String forgottenPasswordTimeKey = "forgottenPasswordTimeKey";
final String rememberSelectorKey = "rememberSelectorKey";
final String rememberCodeKey = "rememberCodeKey";
final String createdOnKey = "createdOnKey";
final String activeKey = "activeKey";
final String companyKey = "companyKey";
final String bonusKey = "bonusKey";
final String dobKey = "dobKey";
final String cityKey = "city";
final String streetKey = "streetKey";
final String serviceableCityKey = "serviceableCityKey";
final String apikeyKey = "apikeyKey";
final String createdAtKey = "createdAtKey";

//userBox keys
final String nameBoxKey = "name";
final String userUIdBoxKey = "userUID";
final String emailBoxKey = "email";
final String mobileNumberBoxKey = "mobile";
final String rankBoxKey = "rank";
final String coinsBoxKey = "coins";
final String scoreBoxKey = "score";
final String profileUrlBoxKey = "profileUrl";
final String statusBoxKey = "status";
final String referCodeBoxKey = "referCode";

//settings box keys
final String showIntroSliderKey = "showIntroSlider";
final String vibrationKey = "vibration";
final String backgroundMusicKey = "backgroundMusic";
final String soundKey = "sound";
final String languageCodeKey = "language";
final String fontSizeKey = "fontSize";
final String rewardEarnedKey = "rewardEarned";
final String fcmTokenBoxKey = "fcmToken";
final String settingsThemeKey = "theme";

//address box keys
final String idBoxKey = "id";
final String userIdBoxKey = "userId";
final String typeBoxKey = "type";
final String mobileBoxKey = "mobile";
final String alternateMobileBoxKey = "alternateMobile";
final String addressBoxKey = "address";
final String landmarkBoxKey = "landmark";
final String areaBoxKey = "area";
final String cityIdBoxKey = "cityId";
final String pincodeBoxKey = "pincode";
final String countryCodeBoxKey = "countryCode";
final String stateBoxKey = "";
final String countryBoxKey = "country";
final String isDeliverableBoxKey = "isDeliverable";
final String latitudeBoxKey = "latitude";
final String longitudeBoxKey = "longitude";
final String isDefaultBoxKey = "isDefault";
final String cityLatitudeBoxKey = "cityLatitude";
final String cityLongitudeBoxKey = "cityLongitude";
final String minimumFreeDeliveryOrderAmountBoxKey = "minimumFreeDeliveryOrderAmount";
final String deliveryChargesBoxKey = "deliveryCharges";
final String geolocationTypeBoxKey = "geolocationType";
final String radiusBoxKey = "radius";

//Database related constants

//Add your database url
//make sure do not add '/' at the end of url

final String databaseUrl = 'PLACE_YOUR_BASE_URL';
final String baseUrl = databaseUrl + '/api/';
final String perPage = "10";
//
final String jwtKey = 'PLACE_YOUR_JWT_KEY';
final String googleAPiKeyAndroid = "PLACE_YOUR_MAP_KEY_ANDROID";
final String googleAPiKeyIos = "PLACE_YOUR_MAP_KEY_IOS";

//api end points

final String loginUrl = "${baseUrl}login";
final String updateFcmUrl = "${baseUrl}update_fcm";
final String resetPasswordUrl = "${baseUrl}reset_password";
final String getLoginIdentityUrl = "${baseUrl}get_login_identity";
final String verifyUserUrl = "${baseUrl}verify_user";
final String registerUserUrl = "${baseUrl}register_user";
final String updateUserUrl = "${baseUrl}update_user";
final String isCityDeliverableUrl = "${baseUrl}is_city_deliverable";
final String getSliderImagesUrl = "${baseUrl}get_slider_images";
final String getOfferImagesUrl = "${baseUrl}get_offer_images";
final String getCategoriesUrl = "${baseUrl}get_categories";
final String getCitiesUrl = "${baseUrl}get_cities";
final String getProductsUrl = "${baseUrl}get_products";
final String validatePromoCodeUrl = "${baseUrl}validate_promo_code";
final String getPartnersUrl = "${baseUrl}get_partners";
final String addAddressUrl = "${baseUrl}add_address";
final String updateAddressUrl = "${baseUrl}update_address";
final String getAddressUrl = "${baseUrl}get_address";
final String deleteAddressUrl = "${baseUrl}delete_address";
final String getSettingsUrl = "${baseUrl}get_settings";
final String placeOrderUrl = "${baseUrl}place_order";
final String getOrdersUrl = "${baseUrl}get_orders";
final String setProductRatingUrl = "${baseUrl}set_product_rating";
final String deleteProductRatingUrl = "${baseUrl}delete_product_rating";
final String getProductRatingUrl = "${baseUrl}get_product_rating";
final String manageCartUrl = "${baseUrl}manage_cart";
final String getUserCartUrl = "${baseUrl}get_user_cart";
final String addToFavoritesUrl = "${baseUrl}add_to_favorites";
final String removeFromFavoritesUrl = "${baseUrl}remove_from_favorites";
final String getFavoritesUrl = "${baseUrl}get_favorites";
final String getNotificationsUrl = "${baseUrl}get_notifications";
final String updateOrderStatusUrl = "${baseUrl}update_order_status";
final String addTransactionUrl = "${baseUrl}add_transaction";
final String getSectionsUrl = "${baseUrl}get_sections";
final String transactionsUrl = "${baseUrl}transactions";
final String deleteOrderUrl = "${baseUrl}delete_order";
final String getTicketTypesUrl = "${baseUrl}get_ticket_types";
final String addTicketUrl = "${baseUrl}add_ticket";
final String editTicketUrl = "${baseUrl}edit_ticket";
final String sendMessageUrl = "${baseUrl}send_message";
final String getTicketsUrl = "${baseUrl}get_tickets";
final String getMessagesUrl = "${baseUrl}get_messages";
final String setRiderRatingUrl = "${baseUrl}set_rider_rating";
final String getRiderRatingUrl = "${baseUrl}get_rider_rating";
final String deleteRiderRatingUrl = "${baseUrl}delete_rider_rating";
final String getFaqsUrl = "${baseUrl}get_faqs";
final String getPromoCodesUrl = "${baseUrl}get_promo_codes";
final String removeFromCartUrl = "${baseUrl}remove_from_cart";
final String makePaymentsUrl = "${baseUrl}make_payments";
final String getPaypalLinkUrl = "${baseUrl}get_paypal_link";
final String paypalTransactionWebviewUrl = "${baseUrl}paypal_transaction_webview";
final String appPaymentStatusUrl = "${baseUrl}app_payment_status";
final String ipnUrl = "${baseUrl}ipn";
final String stripeWebhookUrl = "${baseUrl}stripe_webhook";
final String generatePaytmChecksumUrl = "${baseUrl}generate_paytm_checksum";
final String generatePaytmTxnTokenUrl = "${baseUrl}generate_paytm_txn_token";
final String validatePaytmChecksumUrl = "${baseUrl}validate_paytm_checksum";
final String validateReferCodeUrl = "${baseUrl}validate_refer_code";
final String flutterwaveWebviewUrl = "${baseUrl}flutterwave_webview";
final String flutterwavePaymentResponseUrl = "${baseUrl}flutterwave-payment-response";
final String searchPlacesUrl = "${baseUrl}search_places";
final String getDeliveryChargesUrl = "${baseUrl}get_delivery_charges";
final String getLiveTrackingDetailsUrl = "${baseUrl}get_live_tracking_details";
