import 'package:erestro/ui/address/change_location_Screen.dart';
import 'package:erestro/ui/auth/change_password_screen.dart';
import 'package:erestro/ui/home/cuisine/cuisine_detail_Screen.dart';
import 'package:erestro/ui/home/cuisine/cuisine_screen.dart';
import 'package:erestro/ui/address/delivery_address_screen.dart';
import 'package:erestro/ui/search/filter_detail_Screen.dart';
import 'package:erestro/ui/order/order_tracking_screen.dart';
import 'package:erestro/ui/payment/payment_screen.dart';
import 'package:erestro/ui/rating/product_rating_screen.dart';
import 'package:erestro/ui/rating/rider_rating_screen.dart';
import 'package:erestro/ui/faq/faq_Screen.dart';
import 'package:erestro/ui/ticket/add_ticket_screen.dart';
import 'package:erestro/ui/ticket/edit_ticket_screen.dart';
import 'package:erestro/ui/order/my_order_screen.dart';
import 'package:erestro/ui/order/order_deliverd_screen.dart';
import 'package:erestro/ui/order/order_detail_screen.dart';
import 'package:erestro/ui/auth/reset_password_screen.dart';
import 'package:erestro/ui/search/search_screen.dart';
import 'package:erestro/ui/address/select_delivery_location_screen.dart';
import 'package:erestro/ui/ticket/ticket_screen.dart';
import 'package:erestro/ui/main/introduction_slider_screen.dart';
import 'package:erestro/ui/auth/login_screen.dart';
import 'package:erestro/ui/main/main_screen.dart';
import 'package:erestro/ui/notification/notification_screen.dart';
import 'package:erestro/ui/settings/profile_screen.dart';
import 'package:erestro/ui/auth/registration_screen.dart';
import 'package:erestro/ui/home/restaurants/restaurants_nearby_Screen.dart';
import 'package:erestro/ui/address/add_address_screen.dart';
import 'package:erestro/ui/settings/service_screen.dart';
import 'package:erestro/ui/main/splash_screen.dart';
import 'package:erestro/ui/transaction/transaction_screen.dart';
import 'package:erestro/ui/address/update_address_screen.dart';
import 'package:erestro/ui/transaction/wallet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Routes {
  static const home = "/";
  static const restaurantNearBy = "/restaurantNearBy";
  static const login = "login";
  static const splash = 'splash';
  static const signUp = "/signUp";
  static const resetPassword = "/resetPassword";
  static const introSlider = "/introSlider";
  static const cuisine = "/cuisine";
  static const faqs = "/faqs";
  static const addTicket = "/addTicket";
  static const ticket = "/ticket";
  static const editTicket = "/editTicket";
  static const profile = "/profile";
  static const addAddress = "/addAddress";
  static const updateAddress = "/updateAddress";
  static const deliveryAddress = "/deliveryAddress";
  static const selectAddress = "/selectAddress";
  static const changePassword = "/changePassword";
  static const notification = "/notification";
  static const appSettings = "/appSettings";
  static const settings = "/settings";
  static const cuisineDetail = "/cuisineDetail";
  static const order = "/order";
  static const orderDetail = "/orderDetail";
  static const orderDeliverd = "/orderDeliverd";
  static const riderRating = "/riderRating";
  static const search = "/search";
  static const place = "/place";
  static const filter = "/filter";
  static const payment = "/payment";
  static const transaction = "/transaction";
  static const wallet = "/wallet";
  static const orderTracking = "/orderTracking";
  static const changeAddress = "/changeAddress";
  static const productRating = "/productRating";
  static String currentRoute = splash;

  static Route<dynamic> onGenerateRouted(RouteSettings routeSettings) {
    //to track current route
    //this will only track pushed route on top of previous route
    currentRoute = routeSettings.name ?? "";
    print("Current route is : $currentRoute");
    switch (routeSettings.name) {
      case splash:
        return CupertinoPageRoute(builder: (context) => const SplashScreen());
      case home:
        return CupertinoPageRoute(builder: (context) => const MainScreen());
      case introSlider:
        return CupertinoPageRoute(builder: (context) => const IntroductionSliderScreen());
      case login:
        return CupertinoPageRoute(builder: (context) => const LoginScreen());
      case signUp:
        return RegistrationScreen.route(routeSettings);
      case notification:
        return NotificationScreen.route(routeSettings);
      case appSettings:
        return ServiceScreen.route(routeSettings);
      case restaurantNearBy:
        return RestaurantsNearbyScreen.route(routeSettings);
      case cuisine:
        return CuisineScreen.route(routeSettings);
      case faqs:
        return FaqsScreen.route(routeSettings);
      case addTicket:
        return AddTicketScreen.route(routeSettings);
      case ticket:
        return TicketScreen.route(routeSettings);
      case editTicket:
        return EditTicketScreen.route(routeSettings);
      case profile:
        return ProfileScreen.route(routeSettings);
      case addAddress:
        return AddAddressScreen.route(routeSettings);
      case updateAddress:
        return UpdateAddressScreen.route(routeSettings);
      case deliveryAddress:
        return DeliveryAddressScreen.route(routeSettings);
      case selectAddress:
        return SelectDeliveryLocationScreen.route(routeSettings);
      case changePassword:
        return ChangePasswordScreen.route(routeSettings);
      case resetPassword:
        return ResetPasswordScreen.route(routeSettings);
      case cuisineDetail:
        return CuisineDetailScreen.route(routeSettings);
      case order:
        return MyOrderScreen.route(routeSettings);
      case orderDetail:
        return OrderDetailScreen.route(routeSettings);
      case orderDeliverd:
        return OrderDeliveredScreen.route(routeSettings);
      case riderRating:
        return RiderRatingScreen.route(routeSettings);
      case search:
        return SearchScreen.route(routeSettings);
      case filter:
        return FilterDetailScreen.route(routeSettings);
      case payment:
        return PaymentScreen.route(routeSettings);
      case transaction:
        return TransactionScreen.route(routeSettings);
      case wallet:
        return WalletScreen.route(routeSettings);
      case orderTracking:
        return OrderTrackingScreen.route(routeSettings);
      case changeAddress:
        return ChangeLocationScreen.route(routeSettings);
      case productRating:
        return ProductRatingScreen.route(routeSettings);

      default:
        return CupertinoPageRoute(builder: (context) => const Scaffold());
    }
  }
}
