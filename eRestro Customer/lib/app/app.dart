import 'dart:io';
import 'package:erestro/features/address/addressLocalDataSource.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/address/cubit/addAddressCubit.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/cityDeliverableCubit.dart';
import 'package:erestro/features/address/cubit/deliveryChargeCubit.dart';
import 'package:erestro/features/address/cubit/updateAddressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/auth/cubits/signInCubit.dart';
import 'package:erestro/features/auth/cubits/signUpCubit.dart';
import 'package:erestro/features/auth/cubits/verifyUserCubit.dart';
import 'package:erestro/features/bottomNavigationBar/navicationBarCubit.dart';
import 'package:erestro/features/cart/cartRepository.dart';
import 'package:erestro/features/cart/cubits/getCartCubit.dart';
import 'package:erestro/features/cart/cubits/manageCartCubit.dart';
import 'package:erestro/features/cart/cubits/placeOrder.dart';
import 'package:erestro/features/cart/cubits/removeFromCartCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteProductsCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteRestaurantCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteRestaurant.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteProduct.dart';
import 'package:erestro/features/home/bestOffer/bestOfferRepository.dart';
import 'package:erestro/features/home/bestOffer/cubit/bestOfferCubit.dart';
import 'package:erestro/features/home/cuisine/cubit/cuisineCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/restaurantCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/topRestaurantCubit.dart';
import 'package:erestro/features/home/search/cubit/searchCubit.dart';
import 'package:erestro/features/home/sections/cubit/sectionsCubit.dart';
import 'package:erestro/features/home/slider/cubit/sliderOfferCubit.dart';
import 'package:erestro/features/home/slider/sliderRepository.dart';
import 'package:erestro/features/order/cubit/orderCubit.dart';
import 'package:erestro/features/order/cubit/orderDetailCubit.dart';
import 'package:erestro/features/order/cubit/orderLiveTrackingCubit.dart';
import 'package:erestro/features/order/orderRepository.dart';
import 'package:erestro/features/product/cubit/productCubit.dart';
import 'package:erestro/features/product/productRepository.dart';
import 'package:erestro/features/promoCode/cubit/promoCodeCubit.dart';
import 'package:erestro/features/rating/cubit/setRiderRatingCubit.dart';
import 'package:erestro/features/rating/ratingRepository.dart';
import 'package:erestro/features/settings/settingsCubit.dart';
import 'package:erestro/features/settings/settingsRepository.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/features/systemConfig/systemConfigRepository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:hive_flutter/hive_flutter.dart';

Future<Widget> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, statusBarBrightness: Brightness.dark, statusBarIconBrightness: Brightness.dark));
    initializedDownload();
    await Firebase.initializeApp();

    if (defaultTargetPlatform == TargetPlatform.android) {}
  }

  await Hive.initFlutter();
  await Hive.openBox(authBox); //auth box for storing all authentication related details
  await Hive.openBox(settingsBox); //settings box for storing all settings details
  await Hive.openBox(userdetailsBox); //userDetails box for storing all userDetails details
  await Hive.openBox(addressBox); //address box for storing all address details

  return MyApp();
}

Future<void> initializedDownload() async {
  await FlutterDownloader.initialize(debug: false);
}

class GlobalScrollBehavior extends ScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      //providing global providers
      providers: [
        //Creating cubit/bloc that will be use in whole app or
        //will be use in multiple screens
        BlocProvider<NavigationBarCubit>(create: (_) => NavigationBarCubit()),
        BlocProvider<AuthCubit>(create: (_) => AuthCubit(AuthRepository())),
        BlocProvider<SignUpCubit>(create: (_) => SignUpCubit(AuthRepository())),
        BlocProvider<SignInCubit>(create: (_) => SignInCubit(AuthRepository())),
        BlocProvider<VerifyUserCubit>(create: (_) => VerifyUserCubit(AuthRepository())),
        BlocProvider<RestaurantCubit>(create: (_) => RestaurantCubit()),
        BlocProvider<TopRestaurantCubit>(create: (_) => TopRestaurantCubit()),
        BlocProvider<CuisineCubit>(create: (_) => CuisineCubit()),
        BlocProvider<BestOfferCubit>(create: (_) => BestOfferCubit(BestOfferRepository())),
        BlocProvider<SliderCubit>(create: (_) => SliderCubit(SliderRepository())),
        BlocProvider<SectionsCubit>(create: (_) => SectionsCubit()),
        BlocProvider<AddressCubit>(create: (_) => AddressCubit(AddressRepository())),
        BlocProvider<AddAddressCubit>(create: (_) => AddAddressCubit(AddressRepository())),
        BlocProvider<CityDeliverableCubit>(create: (_) => CityDeliverableCubit(AddressRepository(), AddressLocalDataSource())),
        BlocProvider<PromoCodeCubit>(create: (_) => PromoCodeCubit()),
        BlocProvider<GetCartCubit>(create: (_) => GetCartCubit(CartRepository())),
        BlocProvider<ProductCubit>(create: (_) => ProductCubit(ProductRepository())),
        BlocProvider<ManageCartCubit>(create: (_) => ManageCartCubit(CartRepository())),
        BlocProvider<RemoveFromCartCubit>(create: (_) => RemoveFromCartCubit(CartRepository())),
        BlocProvider<OrderCubit>(create: (_) => OrderCubit()),
        BlocProvider<PlaceOrderCubit>(create: (_) => PlaceOrderCubit(CartRepository())),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit()),
        BlocProvider<SystemConfigCubit>(create: (_) => SystemConfigCubit(SystemConfigRepository())),
        BlocProvider<OrderDetailCubit>(create: (_) => OrderDetailCubit(OrderRepository())),
        BlocProvider<OrderLiveTrackingCubit>(create: (_) => OrderLiveTrackingCubit(OrderRepository())),
        BlocProvider<UpdateAddressCubit>(create: (_) => UpdateAddressCubit(AddressRepository())),
        BlocProvider<DeliveryChargeCubit>(create: (_) => DeliveryChargeCubit(AddressRepository())),
        BlocProvider<SettingsCubit>(create: (_) => SettingsCubit(SettingsRepository())),
        BlocProvider<SetRiderRatingCubit>(create: (_) => SetRiderRatingCubit(RatingRepository())),
        BlocProvider<FavoriteRestaurantsCubit>(create: (_) => FavoriteRestaurantsCubit()),
        BlocProvider<UpdateRestaurantFavoriteStatusCubit>(create: (_) => UpdateRestaurantFavoriteStatusCubit()),
        BlocProvider<FavoriteProductsCubit>(create: (_) => FavoriteProductsCubit()),
        BlocProvider<UpdateProductFavoriteStatusCubit>(create: (_) => UpdateProductFavoriteStatusCubit()),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            builder: (context, widget) {
              return ScrollConfiguration(behavior: GlobalScrollBehavior(), child: widget!);
            },
            debugShowCheckedModeBanner: false,
            initialRoute: Routes.splash,
            onGenerateRoute: Routes.onGenerateRouted,
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
