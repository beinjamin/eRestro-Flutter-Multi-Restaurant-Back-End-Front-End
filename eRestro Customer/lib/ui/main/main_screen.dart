import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/bottomNavigationBar/navicationBarCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/ui/payment/payment_screen.dart';
import 'package:erestro/ui/settings/account_screen.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/favourite/favourite_screen.dart';
import 'package:erestro/ui/home/home_screen.dart';
import 'package:erestro/ui/settings/maintenance_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/bottomNavigationBar/navigation_bar_provider.dart';
import '../../utils/internetConnectivity.dart';

class MainScreen extends StatefulWidget {
  final int? id;
  const MainScreen({Key? key, this.id}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int? selectedIndex = 0;
  String text = StringsRes.home;
  late List<Widget> fragments;
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  late AnimationController navigationContainerAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    Future.delayed(Duration.zero, () {
      context.read<NavigationBarCubit>().setAnimationController(navigationContainerAnimationController);
    });
    isAppMaintenance();
    fragments = [
      HomeScreen(animationController: navigationContainerAnimationController),
      const FavouriteScreen(),
      const CartScreen(),
      const AccountScreen(),
    ];
    widget.id != null ? selectedIndex = widget.id : selectedIndex = 0;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void updateTabSelection(int index, String buttonText) {
    setState(() {
      selectedIndex = index;
      text = buttonText;
    });
  }

  void isAppMaintenance() {
    if (context.read<SystemConfigCubit>().isAppMaintenance() == "1") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => const MaintenanceScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : WillPopScope(
            onWillPop: () {
              if (selectedIndex != 0) {
                setState(() {
                  selectedIndex = 0;
                });
                return Future.value(false);
              }
              return Future.value(true);
            },
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarIconBrightness: Platform.isIOS ? Brightness.light : Brightness.dark,
              ),
              child: Platform.isIOS
                  ? SafeArea(
                      child: Scaffold(
                      resizeToAvoidBottomInset: false,
                      extendBody: true,
                      backgroundColor: Colors.transparent,
                      body: IndexedStack(
                        index: selectedIndex!,
                        children: fragments,
                      ),
                      //body: fragments[selectedIndex!],
                      bottomNavigationBar: FadeTransition(
                        opacity: Tween<double>(begin: 1.0, end: 0.0)
                            .animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
                        child: SlideTransition(
                          position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
                              .animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
                          child: BottomAppBar(
                            notchMargin: 0,
                            color: Colors.transparent,
                            child: Container(
                              decoration: DesignConfig.boxCurveBottomBarShadow(),
                              height: MediaQuery.of(context).size.height / 10.0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                                child: BottomNavigationBar(
                                  backgroundColor: Colors.white,
                                  showSelectedLabels: false,
                                  showUnselectedLabels: false,
                                  unselectedItemColor: ColorsRes.blueColor,
                                  elevation: 0.0,
                                  //backgroundColor: Colors.white,
                                  items: <BottomNavigationBarItem>[
                                    BottomNavigationBarItem(
                                      backgroundColor: Colors.transparent,
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("home_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(
                                                    DesignConfig.setSvgPath(
                                                      "home_icon",
                                                    ),
                                                    height: 13.6,
                                                    width: 13.5,
                                                    color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.home,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("favourite_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("favourite_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.favourite,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.cart,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("profile_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("profile_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.account,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  type: BottomNavigationBarType.shifting,
                                  currentIndex: selectedIndex!,
                                  selectedItemColor: ColorsRes.white,
                                  onTap: (index) {
                                    setState(() {
                                      selectedIndex = index;
                                      if (selectedIndex == 2) {
                                        UiUtils.clearAll();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ))
                  : Scaffold(
                      resizeToAvoidBottomInset: false,
                      extendBody: true,
                      backgroundColor: Colors.transparent,
                      body: IndexedStack(
                        index: selectedIndex!,
                        children: fragments,
                      ),
                      //body: fragments[selectedIndex!],
                      bottomNavigationBar: FadeTransition(
                        opacity: Tween<double>(begin: 1.0, end: 0.0)
                            .animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
                        child: SlideTransition(
                          position: Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0))
                              .animate(CurvedAnimation(parent: navigationContainerAnimationController, curve: Curves.easeInOut)),
                          child: BottomAppBar(
                            notchMargin: 0,
                            color: Colors.transparent,
                            child: Container(
                              decoration: DesignConfig.boxCurveBottomBarShadow(),
                              height: MediaQuery.of(context).size.height / 10.0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                                child: BottomNavigationBar(
                                  backgroundColor: Colors.white,
                                  showSelectedLabels: false,
                                  showUnselectedLabels: false,
                                  unselectedItemColor: ColorsRes.blueColor,
                                  elevation: 0.0,
                                  //backgroundColor: Colors.white,
                                  items: <BottomNavigationBarItem>[
                                    BottomNavigationBarItem(
                                      backgroundColor: Colors.transparent,
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("home_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(
                                                    DesignConfig.setSvgPath(
                                                      "home_icon",
                                                    ),
                                                    height: 13.6,
                                                    width: 13.5,
                                                    color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.home,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("favourite_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("favourite_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.favourite,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.cart,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                    BottomNavigationBarItem(
                                      icon: SvgPicture.asset(DesignConfig.setSvgPath("profile_icon"),
                                          height: 13.6, width: 13.5, color: ColorsRes.lightFont),
                                      label: "",
                                      activeIcon: Container(
                                        height: height! / 30.0,
                                        width: width! / 4.2,
                                        alignment: Alignment.center,
                                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 12.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                                flex: 6,
                                                child: SvgPicture.asset(DesignConfig.setSvgPath("profile_icon"),
                                                    height: 13.6, width: 13.5, color: ColorsRes.white)),
                                            Expanded(
                                                flex: 9,
                                                child: Text(StringsRes.account,
                                                    style: const TextStyle(
                                                      color: ColorsRes.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 10,
                                                    )))
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  type: BottomNavigationBarType.shifting,
                                  currentIndex: selectedIndex!,
                                  selectedItemColor: ColorsRes.white,
                                  onTap: (index) {
                                    setState(() {
                                      selectedIndex = index;
                                      print(selectedIndex);
                                      if (selectedIndex == 2) {
                                        UiUtils.clearAll();
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ));
  }
}
