import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/address/addressModel.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/cityDeliverableCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/bottomNavigationBar/navicationBarCubit.dart';
import 'package:erestro/features/cart/cubits/getCartCubit.dart';
import 'package:erestro/features/cart/cubits/manageCartCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteProductsCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteProduct.dart';
import 'package:erestro/features/home/bestOffer/cubit/bestOfferCubit.dart';
import 'package:erestro/features/home/cuisine/cubit/cuisineCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/restaurantCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/topRestaurantCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/sections/cubit/sectionsCubit.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/features/home/slider/cubit/sliderOfferCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/auth/login_screen.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/home/restaurants/restaurant_detail_screen.dart';
import 'package:erestro/ui/home/topBrand/top_brand_screen.dart';
import 'package:erestro/ui/settings/maintenance_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/ticket/chat_screen.dart';
import 'package:erestro/ui/widgets/bottomCartSimmer.dart';
import 'package:erestro/ui/widgets/cuicineSimmer.dart';
import 'package:erestro/ui/widgets/headerAddressSimmer.dart';
import 'package:erestro/ui/widgets/homeSimmer.dart';
import 'package:erestro/ui/widgets/productContainer.dart';
import 'package:erestro/ui/widgets/restaurantContainer.dart';
import 'package:erestro/ui/widgets/restaurantNearBySimmer.dart';
import 'package:erestro/ui/widgets/sectionSimmer.dart';
import 'package:erestro/ui/widgets/sliderSimmer.dart';
import 'package:erestro/ui/widgets/topBrandSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:new_version/new_version.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/home/productAddOnsModel.dart';
import '../../features/home/variantsModel.dart';
import '../../utils/internetConnectivity.dart';

class HomeScreen extends StatefulWidget {
  final AnimationController animationController;
  const HomeScreen({Key? key, required this.animationController}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  int _currentPage = 0;
  ScrollController restaurantController = ScrollController();
  ScrollController topRestaurantController = ScrollController();
  ScrollController cuisineController = ScrollController();
  final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  bool _show = true;
  double bottomBarHeight = 75; // set bottom bar height
  final Geolocator geolocator = Geolocator();
  Position? _currentPosition;
  String? _currentAddress;
  String showMessage = "";
  List<String> variance = [];
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? status = "", appVersion, forceUpdate, currentVersion = "";
  late NewVersion newVersion;
  List<RestaurantModel> restaurantList = [];
  List<ProductDetails> productList = [];
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    restaurantController.addListener(restaurantScrollListener);
    topRestaurantController.addListener(topRestaurantScrollListener);
    cuisineController.addListener(cuisineScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
      if (context.read<SystemConfigCubit>().state is! SystemConfigFetchSuccess) {
        context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
      }
    });
    context.read<SliderCubit>().fetchSlider();
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    context.read<CuisineCubit>().fetchCuisine(perPage, categoryKey);
    context.read<BestOfferCubit>().fetchBestOffer();
    _initLocalNotification();
    getUserLocation();
    setupInteractedMessage();
    myScroll();
    //Check for Force Update
    newVersion = NewVersion(
      iOSId: 'https://apps.apple.com/in/app/safari/id1146562112',
      androidId: 'com.wrteam.erestro',
    );
    advancedStatusCheck(newVersion);
    if (Platform.isIOS) {
      appVersion = context.read<SystemConfigCubit>().getCurrentVersionIos();
    } else {
      appVersion = context.read<SystemConfigCubit>().getCurrentVersionAndroid();
    }
    if (context.read<SystemConfigCubit>().isForceUpdateEnable() == "1") {
      forceUpdateDialog(newVersion);
    } else {}

    //Check if Currently in Maintenance or Not
    isMaintenance();

    //Check User Active Deactive Status
    userStatus();
    super.initState();
  }

  isMaintenance() {
    if (context.read<SystemConfigCubit>().isAppMaintenance() == "1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MaintenanceScreen(),
        ),
      );
    } else {}
  }

  userStatus() {
    if (context.read<AuthCubit>().getActive() == "0") {
      Future.delayed(Duration.zero, () {
        userActiveStatus(context);
      });
    } else {}
  }

  basicStatusCheck(NewVersion newVersion) {
    newVersion.showAlertIfNecessary(context: context);
  }

  advancedStatusCheck(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    if (status != null) {
      currentVersion = status.localVersion.toString();
      debugPrint(status.releaseNotes);
      debugPrint(status.appStoreLink);
      debugPrint(status.localVersion);
      debugPrint(status.storeVersion);
      debugPrint(status.canUpdate.toString());
    }
  }

  forceUpdateDialog(NewVersion newVersion) async {
    final status = await newVersion.getVersionStatus();
    debugPrint(status!.releaseNotes);
    debugPrint(status.appStoreLink);
    debugPrint(status.localVersion);
    debugPrint(status.storeVersion);
    debugPrint(status.canUpdate.toString());
    newVersion.showUpdateDialog(
      allowDismissal: currentVersion != appVersion ? false : true,
      dismissButtonText: "",
      context: context,
      versionStatus: status,
      dialogTitle: "UpdateDialogTitle",
      dialogText: "UpdateDialogSubTitle",
    );
  }

  Future restaurantClose(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(StringsRes.restaurantClose,
              textAlign: TextAlign.start,
              maxLines: 2,
              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(StringsRes.ok, style: const TextStyle(color: ColorsRes.red, fontSize: 12, fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
            )
          ],
        );
      },
    );
  }

  Future userActiveStatus(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(StringsRes.userNotActive,
              textAlign: TextAlign.start,
              maxLines: 2,
              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(StringsRes.ok, style: const TextStyle(color: ColorsRes.red, fontSize: 12, fontWeight: FontWeight.w500)),
              onPressed: () {
                context.read<AuthCubit>().signOut();
                Navigator.of(context)
                    .pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
              },
            )
          ],
        );
      },
    );
  }

  getUserLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();

      getUserLocation();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        await Geolocator.openLocationSettings();

        getUserLocation();
      } else {
        getUserLocation();
      }
    } else {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("heading---${position.heading}");

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "en");
      // print(placemarks[0]);

      String? address =
          "${placemarks[0].name},${placemarks[0].thoroughfare},${placemarks[0].locality},${placemarks[0].postalCode},${placemarks[0].country}";
      setState(() {
        _currentAddress = "${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].postalCode}";
        print(context.read<AddressCubit>().gerCurrentAddress().city);
        if (context.read<AddressCubit>().gerCurrentAddress().city != "") {
          context.read<CityDeliverableCubit>().fetchCityDeliverable(context.read<AddressCubit>().gerCurrentAddress().city);
        } else {
          context.read<CityDeliverableCubit>().fetchCityDeliverable(placemarks[0].locality);
        }
      });
      print("curadd-$address");
    }
  }

  void _initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
      //print("data:select" + payload.toString());
      if (payload != null) {
        List<String> pay = payload.split(",");
        //
        if (pay[0] == "products") {
          //getProduct(id, 0, 0, true);
        } else if (pay[0] == "categories") {
          Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {'categoryId': pay[1], 'name': StringsRes.deliciousCuisine});
        } else if (pay[0] == "wallet") {
          Navigator.of(context).pushNamed(Routes.wallet);
        } else if (pay[0] == 'order') {
          Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
            'id': pay[1],
            'riderId': "",
            'riderName': "",
            'riderRating': "",
            'riderImage': "",
            'riderMobile': "",
            'riderNoOfRating': ""
          });
          //Navigator.of(context).pushNamed(Routes.order, arguments: false);
        } else if (pay[0] == "ticket_message") {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ChatScreen(
                      id: pay[1],
                      status: "",
                    )),
          );
          // Navigator.of(context).pushNamed(Routes.ticket);
        } else if (pay[0] == "ticket_status") {
          Navigator.of(context).pushNamed(Routes.ticket);
        } else {
          Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
        }
      }
    });
    _requestPermissionsForIos();
  }

  Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    }
  }

  Future<void> onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {}

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    //print("initialMessage"+initialMessage.toString());
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // handle background notification

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("data:onMessage");
      print("data notification*********************************${message.data}");
      if (message.data != null) {
        var data = message.data;
        print("data notification*********************************$data");
        var title = data['title'].toString();
        var body = data['body'].toString();
        var type = data['type'].toString();
        var image = data['image'].toString();
        var id = data['type_id'] ?? '';

        if (image != null && image != 'null' && image != '') {
          generateImageNotification(title, body, image, type, id);
        } else {
          generateSimpleNotification(title, body, type, id);
        }
      }
    });
  }

// notification type is move to screen
  Future<void> _handleMessage(RemoteMessage message) async {
    if (message.data['type'] == 'category') {
      Navigator.of(context).pushNamed(Routes.cuisine, arguments: false);
    }
    if (message.data['type'] == "products") {
      //getProduct(id, 0, 0, true);
    } else if (message.data['type'] == "categories") {
      Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {'categoryId': message.data['type_id'], 'name': StringsRes.deliciousCuisine});
    } else if (message.data['type'] == "wallet") {
      Navigator.of(context).pushNamed(Routes.wallet);
    } else if (message.data['type'] == 'order') {
      Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
        'id': message.data['type_id'],
        'riderId': "",
        'riderName': "",
        'riderRating': "",
        'riderImage': "",
        'riderMobile': "",
        'riderNoOfRating': ""
      });
      //Navigator.of(context).pushNamed(Routes.order, arguments: false);
    } else if (message.data['type'] == "ticket_message") {
      Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatScreen(
                  id: message.data['type_id'],
                  status: "",
                )),
      );
      // Navigator.of(context).pushNamed(Routes.ticket);
    } else if (message.data['type'] == "ticket_status") {
      Navigator.of(context).pushNamed(Routes.ticket);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
    }
  }

  Future<void> generateImageNotification(String title, String msg, String image, String type, String? id) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.erestro', //channel id
      'erestro', //channel name
      'erestro', //channel description
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation, icon: "@mipmap/ic_launcher",
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type + "," + id!);
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(String title, String msg, String type, String? id) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'com.wrteam.erestro', //channel id
        'erestro', //channel name
        'erestro', //channel description
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        icon: "@mipmap/ic_launcher");
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: type + "," + id!);
  }

  restaurantScrollListener() {
    if (restaurantController.position.maxScrollExtent == restaurantController.offset) {
      if (context.read<RestaurantCubit>().hasMoreData()) {
        context.read<RestaurantCubit>().fetchMoreRestaurantData(
            perPage,
            "0",
            context.read<CityDeliverableCubit>().getCityId(),
            context.read<AddressCubit>().gerCurrentAddress().latitude,
            context.read<AddressCubit>().gerCurrentAddress().longitude,
            context.read<AuthCubit>().getId(),
            "");
      }
    }
  }

  topRestaurantScrollListener() {
    if (topRestaurantController.position.maxScrollExtent == topRestaurantController.offset) {
      if (context.read<TopRestaurantCubit>().hasMoreData()) {
        context.read<TopRestaurantCubit>().fetchMoreTopRestaurantData(
            perPage,
            "1",
            context.read<CityDeliverableCubit>().getCityId(),
            context.read<AddressCubit>().gerCurrentAddress().latitude,
            context.read<AddressCubit>().gerCurrentAddress().longitude,
            context.read<AuthCubit>().getId(),
            "");
      }
    }
  }

  cuisineScrollListener() {
    if (cuisineController.position.maxScrollExtent == cuisineController.offset) {
      if (context.read<CuisineCubit>().hasMoreData()) {
        context.read<CuisineCubit>().fetchMoreCuisineData(perPage, categoryKey);
      }
    }
  }

  void myScroll() async {
    _scrollBottomBarController.addListener(() {
      if (_scrollBottomBarController.position.userScrollDirection == ScrollDirection.reverse) {
        if (!context.read<NavigationBarCubit>().animationController.isAnimating) {
          context.read<NavigationBarCubit>().animationController.forward();
          setState(() {
            _show = false;
          });
        }
      }
      if (_scrollBottomBarController.position.userScrollDirection == ScrollDirection.forward) {
        if (!context.read<NavigationBarCubit>().animationController.isAnimating) {
          context.read<NavigationBarCubit>().animationController.reverse();
          setState(() {
            _show = true;
          });
        }
      }
    });
  }

  Widget deliveryLocation() {
    return BlocConsumer<AddressCubit, AddressState>(
        bloc: context.read<AddressCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is AddressProgress || state is AddressInitial) {
            return HeaderAddressSimmer(width: width!, height: height!);
          }
          if (state is AddressFailure) {
            return Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final addressList = (state as AddressSuccess).addressList;

          List<AddressModel> addressModel = addressList.where((element) => element.isDefault == '1').toList();
          AddressModel addressModelData = addressModel.first;
          return SizedBox(
            height: height! / 20.0,
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(
                  addressModelData.type == StringsRes.home
                      ? StringsRes.home
                      : addressModelData.type == StringsRes.office
                          ? StringsRes.office
                          : StringsRes.other,
                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: height! / 99.0),
              Expanded(
                child: SizedBox(
                  width: width! / 1.5,
                  child: Text(
                    addressModelData.address! +
                        "," +
                        addressModelData.area! +
                        "," +
                        addressModelData.city.toString() +
                        "," +
                        addressModelData.state! +
                        ",",
                    style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, overflow: TextOverflow.ellipsis),
                    maxLines: 1,
                  ),
                ),
              )
            ]),
          );
        });
  }

  bottomModelSheetShow(List<ProductDetails> productList, int index) {
    ProductDetails productDetailsModel = productList[index];
    Map<String, int> qtyData = {};
    int _currentIndex = 0, qty = 0;
    List<bool> _isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    for (int i = 0; i < productDetailsModel.variants![_currentIndex].addOnsData!.length; i++) {
      productAddOnIds.add(productDetailsModel.variants![_currentIndex].addOnsData![i].id!);
    }
    if (productDetailsModel.variants![_currentIndex].cartCount != "0") {
      qty = int.parse(productDetailsModel.variants![_currentIndex].cartCount!);
    } else {
      qty = int.parse(productDetailsModel.minimumOrderQuantity!);
    }
    qtyData[productVariantId!] = qty;

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
            double priceCurrent = double.parse(productDetailsModel.variants![_currentIndex].specialPrice!);
            if (priceCurrent == 0) {
              priceCurrent = double.parse(productDetailsModel.variants![_currentIndex].price!);
            }

            double offCurrent = 0;
            if (productDetailsModel.variants![_currentIndex].specialPrice! != "0") {
              offCurrent = (double.parse(productDetailsModel.variants![_currentIndex].price!) -
                      double.parse(productDetailsModel.variants![_currentIndex].specialPrice!))
                  .toDouble();
              offCurrent = offCurrent * 100 / double.parse(productDetailsModel.variants![_currentIndex].price!).toDouble();
            }
            productVariantId = productDetailsModel.variants![_currentIndex].id;
            return BlocProvider<UpdateProductFavoriteStatusCubit>(
              create: (context) => UpdateProductFavoriteStatusCubit(),
              child: Builder(builder: (context) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                        width: width!,
                        height: (MediaQuery.of(context).size.height / 1.14),
                        padding: EdgeInsets.only(top: height! / 15.0),
                        child: Container(
                          decoration: DesignConfig.boxDecorationContainerRoundHalf(ColorsRes.white, 25, 0, 25, 0),
                          child: Container(
                            padding: const EdgeInsets.only(left: /*width!/25.*/ 0, right: /* width!/25.*/ 0, top: /*height!/25.*/ 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                                child: /*Image.network(productDetailsModel.image!, width: width!/5.0, height: height!/10.2, fit: BoxFit.cover)*/
                                                    ColorFiltered(
                                                  colorFilter: productDetailsModel.partnerDetails![0].isRestroOpen == "1"
                                                      ? const ColorFilter.mode(
                                                          Colors.transparent,
                                                          BlendMode.multiply,
                                                        )
                                                      : const ColorFilter.mode(
                                                          Colors.grey,
                                                          BlendMode.saturation,
                                                        ),
                                                  child: FadeInImage(
                                                    placeholder: AssetImage(
                                                      DesignConfig.setPngPath('placeholder_square'),
                                                    ),
                                                    image: NetworkImage(
                                                      productDetailsModel.image!,
                                                    ),
                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(
                                                        DesignConfig.setPngPath('placeholder_square'),
                                                      );
                                                    },
                                                    width: width!,
                                                    height: height! / 5.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )),
                                            BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
                                                bloc: context.read<FavoriteProductsCubit>(),
                                                builder: (context, favoriteProductState) {
                                                  if (favoriteProductState is FavoriteProductsFetchSuccess) {
                                                    //check if restaurant is favorite or not
                                                    bool isProductFavorite =
                                                        context.read<FavoriteProductsCubit>().isProductFavorite(productDetailsModel.id!);
                                                    return BlocConsumer<UpdateProductFavoriteStatusCubit, UpdateProductFavoriteStatusState>(
                                                      bloc: context.read<UpdateProductFavoriteStatusCubit>(),
                                                      listener: ((context, state) {
                                                        //
                                                        if (state is UpdateProductFavoriteStatusSuccess) {
                                                          //
                                                          if (state.wasFavoriteProductProcess) {
                                                            context.read<FavoriteProductsCubit>().addFavoriteProduct(state.product);
                                                          } else {
                                                            //
                                                            context.read<FavoriteProductsCubit>().removeFavoriteProduct(state.product);
                                                          }
                                                        }
                                                      }),
                                                      builder: (context, state) {
                                                        if (state is UpdateProductFavoriteStatusInProgress) {
                                                          return Container(
                                                              margin: const EdgeInsets.only(right: 10.0),
                                                              height: height! / 27,
                                                              width: width! / 14,
                                                              padding: const EdgeInsets.all(8.0),
                                                              decoration: DesignConfig.boxDecorationContainerRoundHalf(
                                                                  ColorsRes.lightFont, 15.0, 0.0, 0.0, 5.0),
                                                              child: const CircularProgressIndicator(color: ColorsRes.red));
                                                        }
                                                        return InkWell(
                                                            onTap: () {
                                                              //
                                                              if (state is UpdateProductFavoriteStatusInProgress) {
                                                                return;
                                                              }
                                                              if (isProductFavorite) {
                                                                context.read<UpdateProductFavoriteStatusCubit>().unFavoriteProduct(
                                                                    userId: context.read<AuthCubit>().getId(),
                                                                    type: productsKey,
                                                                    product: productDetailsModel);
                                                              } else {
                                                                //
                                                                context.read<UpdateProductFavoriteStatusCubit>().favoriteProduct(
                                                                    userId: context.read<AuthCubit>().getId(),
                                                                    type: productsKey,
                                                                    product: productDetailsModel);
                                                              }
                                                            },
                                                            child: Container(
                                                                height: height! / 27,
                                                                width: width! / 14,
                                                                alignment: Alignment.center,
                                                                decoration: DesignConfig.boxDecorationContainerRoundHalf(
                                                                    ColorsRes.lightFont, 15.0, 0.0, 0.0, 5.0),
                                                                child: isProductFavorite
                                                                    ? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                                    : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)));
                                                      },
                                                    );
                                                  }
                                                  //if some how failed to fetch favorite products or still fetching the products
                                                  return const SizedBox();
                                                }),
                                          ],
                                        ),
                                        SizedBox(height: height! / 99.0),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: Text(productDetailsModel.name!,
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark, fontSize: 18, fontWeight: FontWeight.w500))),
                                                    SizedBox(width: width! / 50.0),
                                                    productDetailsModel.indicator == "1"
                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                        : productDetailsModel.indicator == "2"
                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                            : const SizedBox(),
                                                  ],
                                                ),
                                                const SizedBox(height: 2.5),
                                                Text(productDetailsModel.shortDescription!,
                                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                                const SizedBox(height: 5),
                                                Text(context.read<SystemConfigCubit>().getCurrency() + priceCurrent.toString(),
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: ColorsRes.red, fontSize: 14, fontWeight: FontWeight.w700)),
                                                const SizedBox(height: 2.5),
                                                offCurrent.toStringAsFixed(2) == "0.00"
                                                    ? const SizedBox()
                                                    : Row(children: [
                                                        Text(
                                                          context.read<SystemConfigCubit>().getCurrency() +
                                                              productDetailsModel.variants![_currentIndex].price!,
                                                          style: const TextStyle(
                                                              decoration: TextDecoration.lineThrough,
                                                              letterSpacing: 0,
                                                              color: ColorsRes.lightFont,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              overflow: TextOverflow.ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                        Text(
                                                          "  " + offCurrent.toStringAsFixed(2) + StringsRes.percentSymbol + " " + StringsRes.off,
                                                          style: const TextStyle(
                                                              color: ColorsRes.red,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              overflow: TextOverflow.ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ]),
                                                const SizedBox(height: 2.0),
                                              ]),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: height! / 40.0,
                                            top: height! / 40.0,
                                            left: width! / 25.0,
                                            right: width! / 25.0,
                                          ),
                                          child: Divider(
                                            color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                            height: 0.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(StringsRes.quantity,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                              Row(children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: InkWell(
                                                      onTap: qty > 1
                                                          ? () {
                                                              setState(() {
                                                                if (qty <= int.parse(productDetailsModel.minimumOrderQuantity!)) {
                                                                  qty = int.parse(productDetailsModel.quantityStepSize!);
                                                                } else {
                                                                  qty = qty - int.parse(productDetailsModel.quantityStepSize!);
                                                                }
                                                                qtyData[productVariantId!] = qty;
                                                              });
                                                            }
                                                          : null,
                                                      child: const Icon(Icons.remove_circle, color: ColorsRes.lightFont)),
                                                ),
                                                SizedBox(width: width! / 50.0),
                                                Text(qtyData[productVariantId!].toString(),
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w700)),
                                                //Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w700)),
                                                SizedBox(width: width! / 50.0),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (qty >= int.parse(productDetailsModel.totalAllowedQuantity!)) {
                                                            qty = int.parse(productDetailsModel.totalAllowedQuantity!);
                                                          } else {
                                                            qty = (qty + int.parse(productDetailsModel.quantityStepSize!));
                                                          }
                                                          qtyData[productVariantId!] = qty;
                                                          //productDetailsModel.variants![0].cartCount = (int.parse(productDetailsModel.variants![0].cartCount!) + 1).toString();
                                                        });
                                                      },
                                                      child: const Icon(Icons.add_circle, color: ColorsRes.red)),
                                                ),
                                              ]),
                                            ],
                                          ),
                                        ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: height! / 40.0,
                                                  top: height! / 40.0,
                                                  left: width! / 25.0,
                                                  right: width! / 25.0,
                                                ),
                                                child: Divider(
                                                  color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                                  height: 0.0,
                                                ),
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Row(
                                                  children: [
                                                    Text(StringsRes.size,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                                    //Text(StringsRes.chose, textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  //bottom: height! / 40.0,
                                                  top: height! / 60.0,
                                                  left: width! / 25.0,
                                                  right: width! / 25.0,
                                                ),
                                                /*child: Divider(
                                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                              height: 0.0,
                                            ),*/
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: List.generate(productDetailsModel.variants!.length, (index) {
                                                      VariantsModel data = productDetailsModel.variants![index];
                                                      double price = double.parse(data.specialPrice!);
                                                      if (price == 0) {
                                                        price = double.parse(data.price!);
                                                      }

                                                      double off = 0;
                                                      if (data.specialPrice! != "0") {
                                                        off = (double.parse(data.price!) - double.parse(data.specialPrice!)).toDouble();
                                                        off = off * 100 / double.parse(data.price!).toDouble();
                                                      }
                                                      return InkWell(
                                                          onTap: () {},
                                                          child: RadioListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            dense: true,
                                                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                            activeColor: ColorsRes.red,
                                                            controlAffinity: ListTileControlAffinity.trailing,
                                                            value: index,
                                                            groupValue: _currentIndex,
                                                            title: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(data.variantValues!,
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                                                const Spacer(),
                                                                Row(
                                                                  children: [
                                                                    Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(
                                                                          color: ColorsRes.red,
                                                                          fontSize: 13,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            onChanged: (int? value) {
                                                              _currentIndex = value!;
                                                              productVariantId = productDetailsModel.variants![value].id!;

                                                              if (qtyData.containsKey(productVariantId)) {
                                                                qty = qtyData[productVariantId] ?? 1;
                                                              } else {
                                                                int newQty = 0;
                                                                if (productDetailsModel.variants![value].cartCount != "0") {
                                                                  newQty = int.parse(productDetailsModel.variants![value].cartCount!);
                                                                } else {
                                                                  newQty = int.parse(productDetailsModel.minimumOrderQuantity!);
                                                                }
                                                                qtyData[productVariantId!] = newQty;
                                                                qty = newQty;
                                                              }
                                                              setState(() {});
                                                            },
                                                          ));
                                                    })),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: height! / 40.0, top: height! / 40.0, left: width! / 25.0, right: width! / 25.0),
                                                child: Divider(
                                                  color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                                  height: 0.0,
                                                ),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Row(
                                                  children: [
                                                    Text(StringsRes.extraAddOn,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                                    //Text(StringsRes.chose2, textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    /*bottom: height! / 40.0,*/ top: height! / 60.0, left: width! / 25.0, right: width! / 25.0),
                                                /*child: Divider(
                                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                              height: 0.0,
                                            ),*/
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(productDetailsModel.productAddOns!.length, (index) {
                                                  ProductAddOnsModel data = productDetailsModel.productAddOns![index];
                                                  if (productAddOnIds.contains(data.id)) {
                                                    _isChecked[index] = true;
                                                    if (!addOnIds.contains(data.id!)) {
                                                      addOnIds.add(data.id!);
                                                      addOnQty.add("1");
                                                      addOnPrice.add(double.parse(data.price!));
                                                    }
                                                  } else {
                                                    _isChecked[index] = false;
                                                  }
                                                  return InkWell(
                                                      onTap: () {},
                                                      child: Container(
                                                          margin: EdgeInsets.only(
                                                            left: width! / 25.0,
                                                            right: width! / 25.0,
                                                            //bottom: height! / 99.0,
                                                            //top: height! / 99.0,
                                                          ), //padding: EdgeInsets.only(left: width!/25.0, right: width!/25.0),
                                                          //decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                                          child: CheckboxListTile(
                                                              contentPadding: EdgeInsets.zero,
                                                              dense: true,
                                                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                              activeColor: ColorsRes.red,
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                      width: width! / 2.0,
                                                                      child: Text(
                                                                        data.title!,
                                                                        textAlign: TextAlign.start,
                                                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12),
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )),
                                                                  const Spacer(),
                                                                  Text(context.read<SystemConfigCubit>().getCurrency() + data.price!,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                        color: ColorsRes.red,
                                                                        fontSize: 13,
                                                                      )),
                                                                ],
                                                              ),
                                                              value: _isChecked[index],
                                                              onChanged: (val) {
                                                                setState(
                                                                  () {
                                                                    _isChecked[index] = val!;
                                                                    if (_isChecked[index] == false) {
                                                                      addOnIds.removeAt(index);
                                                                      productAddOnIds.remove(data.id);
                                                                      addOnQty.removeAt(index);
                                                                      addOnPrice.removeAt(index);
                                                                    } else {
                                                                      productAddOnIds.add(data.id!);
                                                                      if (!addOnIds.contains(data.id!)) {
                                                                        addOnIds.add(data.id!);
                                                                        addOnQty.add("1");
                                                                        addOnPrice.add(double.parse(data.price!));
                                                                      }
                                                                    }
                                                                  },
                                                                );
                                                              })));
                                                }),
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                  return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                                      ? Container(
                                          height: 0.0,
                                        )
                                      : Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                            Expanded(
                                              child: BlocConsumer<GetCartCubit, GetCartState>(
                                                  bloc: context.read<GetCartCubit>(),
                                                  listener: (context, state) {},
                                                  builder: (context, state) {
                                                    if (state is GetCartProgress || state is GetCartInitial) {
                                                      return BottomCartSimmer(show: false, width: width!, height: height!);
                                                    }
                                                    if (state is GetCartFailure) {
                                                      return const Text(/*state.errorMessage.toString()*/ "", textAlign: TextAlign.center);
                                                    }
                                                    final cartList = (state as GetCartSuccess).cartModel;
                                                    var sum = 0.0;
                                                    for (var i = 0; i < addOnPrice.length; i++) {
                                                      sum += addOnPrice[i];
                                                    }
                                                    double overAllTotal = ((priceCurrent * qtyData[productVariantId!]!) + sum);
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text("${qtyData[productVariantId!].toString()} ${StringsRes.itemTag}" + " | ",
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                                        Text(context.read<SystemConfigCubit>().getCurrency() + overAllTotal.toStringAsFixed(2),
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                            style: const TextStyle(color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                            Expanded(
                                                child: productDetailsModel.variants![_currentIndex].availability == "1" ||
                                                        productDetailsModel.variants![_currentIndex].availability == ""
                                                    ? BlocConsumer<ManageCartCubit, ManageCartState>(
                                                        bloc: context.read<ManageCartCubit>(),
                                                        listener: (context, state) {
                                                          if (state is ManageCartSuccess) {
                                                            final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                                            context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                                                state.data,
                                                                state.totalQuantity,
                                                                state.subTotal,
                                                                state.taxPercentage,
                                                                state.taxAmount,
                                                                state.overallAmount));
                                                            Navigator.pop(context);
                                                            UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false);
                                                            // Navigator.pop(context);
                                                          } else if (state is ManageCartFailure) {
                                                            Navigator.pop(context);
                                                            //showMessage = state.errorMessage.toString();
                                                            UiUtils.setSnackBar(StringsRes.addToCart, state.errorMessage, context, false);
                                                          }
                                                        },
                                                        builder: (context, state) {
                                                          return TextButton(
                                                              style: TextButton.styleFrom(
                                                                splashFactory: NoSplash.splashFactory,
                                                              ),
                                                              onPressed: () {
                                                                if (qty == 0) {
                                                                  Navigator.pop(context);
                                                                  UiUtils.setSnackBar(
                                                                      StringsRes.quantity, StringsRes.quantityMessage, context, false);
                                                                } else {
                                                                  context.read<ManageCartCubit>().manageCartUser(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      productVariantId: productVariantId,
                                                                      isSavedForLater: "0",
                                                                      qty: qtyData[productVariantId!].toString(),
                                                                      addOnId: addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                      addOnQty: addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "");
                                                                }
                                                              },
                                                              child: Container(
                                                                  width: width,
                                                                  padding: EdgeInsets.only(
                                                                      top: height! / 55.0,
                                                                      bottom: height! / 55.0,
                                                                      left: width! / 20.0,
                                                                      right: width! / 20.0),
                                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                                                  child: Text(StringsRes.addToCart,
                                                                      textAlign: TextAlign.center,
                                                                      maxLines: 1,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                                        })
                                                    : Container())
                                          ]),
                                          // showMessage==""?Container():Text(showMessage, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.darkFontColor, fontSize: 16, fontWeight: FontWeight.w500))
                                        );
                                }),
                              ],
                            ),
                          ),
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
                  ],
                );
              }),
            );
          });
        });
  }

  Widget homeList() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          slider(),
          Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Padding(
              padding: EdgeInsets.only(left: width! / 20.0, top: height! / 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(StringsRes.deliciousCuisine,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
                  Text(StringsRes.discoverAndGetBestFood,
                      textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                ],
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.cuisine);
              },
              child: Padding(
                padding: EdgeInsets.only(right: width! / 20.0, top: height! / 40.0),
                child: Text(StringsRes.showAll, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
              ),
            ),
          ]),
          topCuisine(),
          Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Padding(
              padding: EdgeInsets.only(left: width! / 20.0),
              child: Text(StringsRes.topBrandsNearYou,
                  textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const TopBrandScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(right: width! / 20.0, top: height! / 40.0),
                child: Text(StringsRes.showAll, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
              ),
            ),
          ]),
          topBrand(),
          Padding(
            padding: EdgeInsets.only(left: width! / 20.0),
            child: Text(StringsRes.bestOfferForYou,
                textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          bestOffer(),
          Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Padding(
              padding: EdgeInsets.only(left: width! / 20.0),
              child: Text(StringsRes.restaurantsNearby,
                  textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.restaurantNearBy);
              },
              child: Padding(
                padding: EdgeInsets.only(right: width! / 20.0),
                child: Text(StringsRes.showAll, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
              ),
            ),
          ]),
          restaurantsNearby(),
          SizedBox(height: height! / 50.0),
          topDeal(),
          SizedBox(height: height! / 99.0),
        ]);
  }

  Widget searchBar() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.search);
      },
      child: Container(
          decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 15.0),
          padding: EdgeInsets.only(left: width! / 20.0), // margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0),
          child: TextField(
            controller: searchController,
            cursorColor: ColorsRes.lightFont,
            textAlignVertical: TextAlignVertical.center,
            enabled: false,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixIcon: const Icon(Icons.search, color: ColorsRes.lightFont),
              hintText: StringsRes.searchTitle,
              labelStyle: const TextStyle(
                color: ColorsRes.lightFont,
                fontSize: 14.0,
              ),
              hintStyle: const TextStyle(
                color: ColorsRes.lightFont,
                fontSize: 14.0,
              ),
            ),
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
            ),
          )),
    );
  }

  Widget topCuisine() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return CuisineSimmer(length: 6, height: height!, width: width!);
          }
          if (state is CuisineFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final cuisineList = (state as CuisineSuccess).cuisineList;
          final hasMore = state.hasMore;
          return Container(
            height: height! / 2.8,
            margin: EdgeInsets.only(left: width! / 20.0),
            child: GridView.count(
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.98,
              children: List.generate(cuisineList.length > 6 ? 6 : cuisineList.length, (index) {
                return hasMore && index == (cuisineList.length - 1)
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': cuisineList[index].id!, 'name': cuisineList[index].text!});
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: height! / 88.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: width! / 3.0,
                                height: height! / 9.0,
                                decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 15.0),
                                padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                                margin: EdgeInsets.only(top: height! / 20.0, right: width! / 20.0),
                                child: Padding(
                                  padding: EdgeInsets.only(top: height! / 30.0),
                                  child: Text(cuisineList[index].name!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: width! / 20.0),
                                  alignment: Alignment.topCenter,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: ColorsRes.white,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ClipOval(
                                          child: FadeInImage(
                                        placeholder: AssetImage(
                                          DesignConfig.setPngPath('placeholder_square'),
                                        ),
                                        image: NetworkImage(
                                          cuisineList[index].image!,
                                        ),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            DesignConfig.setPngPath('placeholder_square'),
                                          );
                                        },
                                        width: 55.0,
                                        height: 55.0,
                                        fit: BoxFit.cover,
                                      )),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      );
              }),
            ),
          );
        });
  }

  Widget topDeal() {
    return BlocConsumer<SectionsCubit, SectionsState>(
        bloc: context.read<SectionsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SectionsProgress || state is SectionsInitial) {
            return SectionSimmer(length: 5, width: width!, height: height!);
          }
          if (state is SectionsFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final sectionsList = (state as SectionsSuccess).sectionsList;
          final hasMore = state.hasMore;
          return ListView.builder(
              shrinkWrap: true,
              //padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: sectionsList.length,
              itemBuilder: (BuildContext buildContext, index) {
                productList = sectionsList[index].productDetails!;
                return hasMore && index == (sectionsList.length - 1)
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionsList[index].productDetails!.isEmpty
                              ? Container()
                              : Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: width! / 20.0 /*, top: height! / 60.0*/),
                                    child: Text(sectionsList[index].title!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                  const Spacer(),
                                  /*    Padding(
                                      padding: EdgeInsets.only(right: width!/20.0, top: height!/40.0),
                                      child: Text(StringsRes.showAll, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                    ),*/
                                ]),
                          sectionsList[index].productDetails!.isEmpty
                              ? Container()
                              : SizedBox(
                                  height: height! / 2.4,
                                  child: ListView.builder(
                                      //shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      scrollDirection: Axis.horizontal,
                                      physics: const AlwaysScrollableScrollPhysics(),
                                      itemCount: sectionsList[index].productDetails!.length,
                                      itemBuilder: (BuildContext buildContext, i) {
                                        double price = double.parse(sectionsList[index].productDetails![i].variants![0].specialPrice!);
                                        if (price == 0) {
                                          price = double.parse(sectionsList[index].productDetails![i].variants![0].price!);
                                        }

                                        double off = 0;
                                        if (sectionsList[index].productDetails![i].variants![0].specialPrice! != "0") {
                                          off = (double.parse(sectionsList[index].productDetails![i].variants![0].price!) -
                                                  double.parse(sectionsList[index].productDetails![i].variants![0].specialPrice!))
                                              .toDouble();
                                          off = off * 100 / double.parse(sectionsList[index].productDetails![i].variants![0].price!).toDouble();
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            if (sectionsList[index].productDetails![i].partnerDetails![0].isRestroOpen == "1") {
                                              bottomModelSheetShow(sectionsList[index].productDetails!, i);
                                            } else {
                                              restaurantClose(context);
                                            }
                                          },
                                          child: ProductContainer(
                                              productDetails: sectionsList[index].productDetails![i],
                                              height: height!,
                                              width: width,
                                              productDetailsList: sectionsList[index].productDetails!,
                                              price: price,
                                              off: off),
                                        );
                                      }),
                                ),
                        ],
                      );
              });
        });
  }

  Widget bestOffer() {
    return BlocConsumer<BestOfferCubit, BestOfferState>(
        bloc: context.read<BestOfferCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is BestOfferProgress || state is BestOfferInitial) {
            return SliderSimmer(width: width!, height: height!);
          }
          if (state is BestOfferFailure) {
            return Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final bestOfferList = (state as BestOfferSuccess).bestOfferList;
          return SizedBox(
              height: height! / 4.0,
              child: Column(
                children: [
                  SizedBox(
                    height: height! / 5.0,
                    child: CarouselSlider(
                        items: /*bestOfferData()*/ bestOfferList
                            .map((item) => GestureDetector(
                                  onTap: () {
                                    if (item.type == "default") {
                                    } else if (item.type == "categories") {
                                      Navigator.of(context)
                                          .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': item.data![0].id!, 'name': item.data![0].text!});
                                    } else if (item.type == "products" && item.data!.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (BuildContext context) => RestaurantDetailScreen(
                                            restaurantModel: item.data![0].partnerDetails![0],
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(/*left: width!/20.0, right: width!/20.0, */ top: height! / 30.0),
                                    child: ClipRRect(
                                        borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                                        child: /*Image.network(item.image!, width: width, height: height!/5.0, fit: BoxFit.cover,
                                      /*  errorBuilder: (BuildContext context, Object exception,
                                                      StackTrace? stackTrace) {
                                                    return Image.asset("assets/images/placeholder.png",
                                                        width: 1000.0, fit: BoxFit.cover);
                                              },
                                              loadingBuilder: (BuildContext context, Widget? child,
                                                      ImageChunkEvent? loadingProgress) {
                                                    if (loadingProgress == null) return child!;
                                                    return Image.asset("assets/images/placeholder.png",
                                                        width: 1000.0, fit: BoxFit.cover);
                                              },*/
                                    ),*/
                                            FadeInImage(
                                          placeholder: AssetImage(
                                            DesignConfig.setPngPath('placeholder_rectangel'),
                                          ),
                                          image: NetworkImage(
                                            item.image!,
                                          ),
                                          imageErrorBuilder: (context, error, stackTrace) {
                                            return Image.asset(
                                              DesignConfig.setPngPath('placeholder_rectangel'),
                                            );
                                          },
                                          width: width!,
                                          height: height! / 5.0,
                                          fit: BoxFit.cover,
                                        )),
                                  ),
                                ))
                            .toList(),
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          reverse: false,
                          autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                          aspectRatio: 2.4,
                          initialPage: 0,
                          onPageChanged: (index, reason) {
                            setState(() {
                              if (mounted) {
                                _currentPage = index;
                              }
                            });
                          },
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: bestOfferList
                        .map((item) => Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle, color: _currentPage == bestOfferList.indexOf(item) ? ColorsRes.red : ColorsRes.lightFont),
                            ))
                        .toList(),
                  ),
                ],
              ));
        });
  }

  Widget slider() {
    return BlocConsumer<SliderCubit, SliderState>(
        bloc: context.read<SliderCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is SliderProgress || state is SliderInitial) {
            return SliderSimmer(width: width!, height: height!);
          }
          if (state is SliderFailure) {
            return Center(
                child: Text(
              state.errorCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final sliderList = (state as SliderSuccess).sliderList;
          return SizedBox(
            height: height! / 5.0,
            child: CarouselSlider(
                items: sliderList
                    .map((item) => GestureDetector(
                          onTap: () {
                            if (item.type == "default") {
                            } else if (item.type == "categories") {
                              Navigator.of(context)
                                  .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': item.data![0].id!, 'name': item.data![0].text!});
                            } else if (item.type == "products") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) => RestaurantDetailScreen(
                                    restaurantModel: item.data![0].partnerDetails![0],
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(/*left: width!/20.0, right: width!/20.0, */ top: 0.0),
                            child: ClipRRect(
                              borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                              child: /*Image.network(item.image!, width: width, height: height!/5.0, fit: BoxFit.cover,
                              )*/
                                  FadeInImage(
                                placeholder: AssetImage(
                                  DesignConfig.setPngPath('placeholder_rectangel'),
                                ),
                                image: NetworkImage(
                                  item.image!,
                                ),
                                imageErrorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    DesignConfig.setPngPath('placeholder_rectangel'),
                                  );
                                },
                                width: width!,
                                height: height! / 6.5,
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  reverse: false,
                  autoPlayAnimationDuration: const Duration(milliseconds: 1000),
                  aspectRatio: 2.4,
                  initialPage: 0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                )),
          );
        });
  }

  Widget topBrand() {
    return BlocConsumer<TopRestaurantCubit, TopRestaurantState>(
        bloc: context.read<TopRestaurantCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TopRestaurantProgress || state is TopRestaurantInitial) {
            return TopBrandSimmer(width: width!, height: height!);
          }
          if (state is TopRestaurantFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final topRestaurantList = (state as TopRestaurantSuccess).topRestaurantList;
          final hasMore = state.hasMore;
          return SizedBox(
            height: height! / 5.0,
            child: ListView.builder(
              shrinkWrap: true,
              controller: topRestaurantController,
              physics: const BouncingScrollPhysics(),
              itemCount: topRestaurantList.length > 5 ? 5 : topRestaurantList.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext buildContext, index) {
                return hasMore && index == (topRestaurantList.length - 1)
                    ? const Center(
                        child: CircularProgressIndicator(
                        color: ColorsRes.red,
                      ))
                    : InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) => RestaurantDetailScreen(
                                restaurantModel: topRestaurantList[index],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration:
                              DesignConfig.boxDecorationContainerCardShadow(ColorsRes.offWhite, ColorsRes.shadowContainer, 15.0, 0, 10, 16, 0),
                          width: width! / 3.5,
                          padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                          margin: EdgeInsets.only(top: height! / 40.0, left: width! / 20.0, bottom: height! / 40.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              /*Expanded(flex: 3, child: Image.network(topRestaurantList[index].restaurantProfile!,
                    )),*/
                              Expanded(
                                flex: 3,
                                child: ClipRRect(
                                    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                    child: /*Image.network(topRestaurantList[index].restaurantProfile!, width: width!/5.0, height: height!/8.2, fit: BoxFit.cover)*/
                                        ColorFiltered(
                                      colorFilter: topRestaurantList[index].isRestroOpen == "1"
                                          ? const ColorFilter.mode(
                                              Colors.transparent,
                                              BlendMode.multiply,
                                            )
                                          : const ColorFilter.mode(
                                              Colors.grey,
                                              BlendMode.saturation,
                                            ),
                                      child: FadeInImage(
                                        placeholder: AssetImage(
                                          DesignConfig.setPngPath('placeholder_square'),
                                        ),
                                        image: NetworkImage(
                                          topRestaurantList[index].partnerProfile!,
                                        ),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            DesignConfig.setPngPath('placeholder_square'),
                                          );
                                        },
                                        width: width! / 5.0,
                                        height: height! / 8.2,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: height! / 85.0),
                                    child: Text(topRestaurantList[index].partnerName!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: ColorsRes.black, fontSize: 12, fontWeight: FontWeight.w500)),
                                  )),
                            ],
                          ),
                        ),
                      );
              },
            ),
          );
        });
  }

  Widget restaurantsNearby() {
    return BlocConsumer<RestaurantCubit, RestaurantState>(
        bloc: context.read<RestaurantCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is RestaurantProgress || state is RestaurantInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is RestaurantFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          restaurantList = (state as RestaurantSuccess).restaurantList;
          final hasMore = state.hasMore;
          return /*Container(height: height!/0.9, color: ColorsRes.white,
        child:*/
              ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  controller: restaurantController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: restaurantList.length > 5 ? 5 : restaurantList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (restaurantList.length - 1)
                        ? const Center(child: CircularProgressIndicator())
                        : RestaurantContainer(restaurant: restaurantList[index], height: height!, width: width!);
                  });
        });
  }

  Future<void> refreshList() async {
    context.read<RestaurantCubit>().fetchRestaurant(
        perPage,
        "0",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<AddressCubit>().gerCurrentAddress().latitude,
        context.read<AddressCubit>().gerCurrentAddress().longitude,
        context.read<AuthCubit>().getId(),
        "");
    context.read<TopRestaurantCubit>().fetchTopRestaurant(
        perPage,
        "1",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<AddressCubit>().gerCurrentAddress().latitude,
        context.read<AddressCubit>().gerCurrentAddress().longitude,
        context.read<AuthCubit>().getId(),
        "");
    context.read<SectionsCubit>().fetchSections(perPage, context.read<AuthCubit>().getId(), context.read<AddressCubit>().gerCurrentAddress().latitude,
        context.read<AddressCubit>().gerCurrentAddress().longitude, context.read<CityDeliverableCubit>().getCityId());
    context.read<SliderCubit>().fetchSlider();
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    context.read<CuisineCubit>().fetchCuisine(perPage, categoryKey);
    context.read<BestOfferCubit>().fetchBestOffer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollBottomBarController.removeListener(() {});
    searchController.dispose();
    restaurantController.dispose();
    topRestaurantController.dispose();
    cuisineController.dispose();
    _scrollBottomBarController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
        ),
        child: _connectionStatus == 'ConnectivityResult.none'
            ? const NoInternetScreen()
            : Scaffold(
                extendBody: true,
                backgroundColor: ColorsRes.white,
                bottomNavigationBar: _show
                    ? (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                        ? Container(
                            height: 0.0,
                          )
                        : FadeTransition(
                            opacity: Tween<double>(begin: 1.0, end: 0.0)
                                .animate(CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut)),
                            child: SlideTransition(
                              position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
                                  .animate(CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut)),
                              child: BlocConsumer<GetCartCubit, GetCartState>(
                                  bloc: context.read<GetCartCubit>(),
                                  listener: (context, state) {
                                    if (state is GetCartSuccess) {}
                                  },
                                  builder: (context, state) {
                                    if (state is GetCartProgress || state is GetCartInitial) {
                                      return BottomCartSimmer(show: _show, width: width!, height: height!);
                                    }
                                    if (state is GetCartFailure) {
                                      return const Text(
                                        /*state.errorMessage.toString()*/ "",
                                        textAlign: TextAlign.center,
                                      );
                                    }
                                    final cartList = (state as GetCartSuccess).cartModel;
                                    return cartList.data!.isEmpty
                                        ? Container()
                                        : Container(
                                            height: height! / 9.8,
                                            margin: EdgeInsets.only(bottom: _show == true ? height! / 16.0 : 0.0),
                                            width: width,
                                            padding: EdgeInsets.only(bottom: height! / 30.0, left: width! / 20.0, right: width! / 20.0),
                                            decoration: DesignConfig.boxDecorationContainerHalf(ColorsRes.backgroundDark),
                                            child: Row(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text("${cartList.totalQuantity} ${StringsRes.itemTag} | ",
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        style: const TextStyle(color: ColorsRes.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                                    Text(context.read<SystemConfigCubit>().getCurrency() + cartList.overallAmount.toString(),
                                                        textAlign: TextAlign.center,
                                                        maxLines: 2,
                                                        style: const TextStyle(color: ColorsRes.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                                  ],
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                    onTap: () {
                                                      UiUtils.clearAll();
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (BuildContext context) => const CartScreen(),
                                                        ),
                                                      );
                                                    },
                                                    child: Text(StringsRes.viewCart,
                                                        textAlign: TextAlign.center,
                                                        maxLines: 1,
                                                        style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))),
                                              ],
                                            ),
                                          );
                                  }),
                            ))
                    : Container(height: 0),
                body: SafeArea(
                  child: RefreshIndicator(
                      onRefresh: refreshList,
                      color: ColorsRes.red,
                      child: CustomScrollView(
                        controller: _scrollBottomBarController,
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Container(
                              margin: EdgeInsets.only(bottom: height! / 80.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(Routes.selectAddress, arguments: false);
                                          },
                                          child: Container(
                                              width: 32.0,
                                              height: 32.0,
                                              margin: EdgeInsets.only(
                                                  left: width! / 20.0, top: height! / 60.0, bottom: height! / 99.0, right: width! / 40.0),
                                              decoration:
                                                  DesignConfig.boxDecorationContainerCardShadow(ColorsRes.red, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                              child: SvgPicture.asset(DesignConfig.setSvgPath("other_address_white"), fit: BoxFit.scaleDown))),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(Routes.selectAddress, arguments: false);
                                        },
                                        child: deliveryLocation(),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  InkWell(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.notification);
                                      },
                                      child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          margin: EdgeInsets.only(right: width! / 20.0, top: height! / 60.0, bottom: height! / 99.0),
                                          width: 32,
                                          height: 32.0,
                                          decoration:
                                              DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                          child: Stack(
                                            children: [
                                              SvgPicture.asset(DesignConfig.setSvgPath("notification"), fit: BoxFit.scaleDown),
                                            ],
                                          ))),
                                ],
                              ),
                            ),
                          ),
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            shadowColor: Colors.transparent,
                            backgroundColor: ColorsRes.white,
                            systemOverlayStyle: SystemUiOverlayStyle.dark,
                            iconTheme: const IconThemeData(
                              color: ColorsRes.black,
                            ),
                            floating: false,
                            pinned: true,
                            title: searchBar(),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return BlocConsumer<CityDeliverableCubit, CityDeliverableState>(
                                    bloc: context.read<CityDeliverableCubit>(),
                                    listener: (context, state) {
                                      if (state is CityDeliverableSuccess) {
                                        context.read<RestaurantCubit>().fetchRestaurant(
                                            perPage,
                                            "0",
                                            context.read<CityDeliverableCubit>().getCityId(),
                                            context.read<AddressCubit>().gerCurrentAddress().latitude,
                                            context.read<AddressCubit>().gerCurrentAddress().longitude,
                                            context.read<AuthCubit>().getId(),
                                            "");
                                        context.read<TopRestaurantCubit>().fetchTopRestaurant(
                                            perPage,
                                            "1",
                                            context.read<CityDeliverableCubit>().getCityId(),
                                            context.read<AddressCubit>().gerCurrentAddress().latitude,
                                            context.read<AddressCubit>().gerCurrentAddress().longitude,
                                            context.read<AuthCubit>().getId(),
                                            "");
                                        context.read<SectionsCubit>().fetchSections(
                                            perPage,
                                            context.read<AuthCubit>().getId(),
                                            context.read<AddressCubit>().gerCurrentAddress().latitude,
                                            context.read<AddressCubit>().gerCurrentAddress().longitude,
                                            context.read<CityDeliverableCubit>().getCityId());
                                      }
                                    },
                                    builder: (context, state) {
                                      if (state is CityDeliverableProgress || state is CityDeliverableInitial) {
                                        return HomeSimmer(
                                          width: width,
                                          height: height,
                                        );
                                      }
                                      if (state is CityDeliverableFailure) {
                                        return Center(child: Text(state.errorCode));
                                      }
                                      return RefreshIndicator(onRefresh: refreshList, child: homeList());
                                    });
                              },
                              childCount: 1,
                            ),
                          ),
                        ],
                      )),
                ),
              ));
  }
}
