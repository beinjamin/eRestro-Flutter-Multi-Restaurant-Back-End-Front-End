import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/helper/staggered_enter_animation.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/main/main_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/favourite/favourite_screen.dart';
import 'package:erestro/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';
import '../../utils/internetConnectivity.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  AccountScreenState createState() => AccountScreenState();
}

class AccountScreenState extends State<AccountScreen> with TickerProviderStateMixin{
  double? width, height;
  var size;
  late AnimationController _controller;
  late StaggeredAnimationEnterAnimation animation;
  final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height
  Location location = Location();

  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    location.getLocation();

    CheckInternet.initConnectivity().then((value) => setState(() {
      _connectionStatus = value;
    }));
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
        });

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    DesignConfig.myScroll(_scrollBottomBarController, context);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    animation = StaggeredAnimationEnterAnimation(_controller);
    _controller.forward();

    _playAnimation();
  }

  Future<void> _playAnimation() async {
    try {
      await _controller.forward().orCancel;
    } on TickerCanceled {}
  }

  circle(Size size, double animationValue) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(
        animationValue,
        animationValue,
        1.0,
      ),
      child:Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * .10),
        child: CircleAvatar(
          radius: 45,
          backgroundColor: ColorsRes.white,
          child: Container(alignment: Alignment.center,
            child: ClipOval(
                child:FadeInImage(
                  placeholder: AssetImage(
                    DesignConfig.setPngPath('placeholder_square'),
                  ),
                  image: NetworkImage(
                    context.read<AuthCubit>().getProfile(),
                  ),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      DesignConfig.setPngPath('placeholder_square'),
                    );
                  },
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                )),
          ),
        ),
      ),
    );
  }



  Widget profile(){
    return Container(/*margin: EdgeInsets.only(top: height!/4.4),*/ decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Container(margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, top: height!/40.0),
              child: SingleChildScrollView(
                child: Column(mainAxisAlignment:MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(StringsRes.profile, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return InkWell(
                          onTap:(){/*
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) => const ProfileScreen(),
                              ),
                            );*/
                            if(state is AuthInitial || state is Unauthenticated)
                            {
                              Navigator.of(context).pushReplacementNamed(Routes.login);
                              return ;
                            }
                            Navigator.of(context).pushNamed(Routes.profile, arguments: false);
                          },
                          child: Row(children:[
                            CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("profile_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                            Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(StringsRes.myProfile, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                              Text(StringsRes.myProfileSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                            ]),
                          ]),
                        );
                      }
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    InkWell(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const FavouriteScreen(),
                          ),
                        );
                      },
                      child: Row(children:[
                        CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("favourite_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(StringsRes.favourite, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(StringsRes.favouriteSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                          ]),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    InkWell(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const CartScreen(),
                          ),
                        );
                      },
                      child: Row(children:[
                        CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("cart_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(StringsRes.cart, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(StringsRes.cartSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                          ]),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    InkWell(
                      onTap:(){/*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const MyOrderScreen(),
                          ),
                        );*/

                        Navigator.of(context).pushNamed(Routes.order, arguments: false);
                      },
                      child: Row(children:[
                        CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("my_order_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(StringsRes.myOrder, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(StringsRes.myOrderSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                          ]),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    Text(StringsRes.address, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    InkWell(
                      onTap:(){
                        /*
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const DeliveryAddressScreen(),
                          ),
                        );*/
                        Navigator.of(context).pushNamed(Routes.deliveryAddress, arguments: false);
                      },
                      child: Row(children:[
                        CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("address_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(StringsRes.deliveryLocation, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(StringsRes.deliveryLocationSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                          ]),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    Text(StringsRes.settings, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    InkWell(
                      onTap:(){
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) => const SettingsScreen(),
                          ),
                        );
                      },
                      child: Row(children:[
                        CircleAvatar(radius: 18.0, backgroundColor: ColorsRes.backgroundDark, child: SvgPicture.asset(DesignConfig.setSvgPath("setting_icon"), width: 18.0, height: 18.0, color: ColorsRes.white)),SizedBox(width: width!/30.0),
                        Expanded(
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(StringsRes.settings, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                            Text(StringsRes.settingsSubTitle, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis), maxLines: 2,),
                          ]),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: height!/80.0, bottom: height!/80.0),
                      child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                    ),
                    SizedBox(height: height!/10.0),
                  ],
                ),
              ),
            )
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollBottomBarController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    size = MediaQuery.of(context).size;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == 'ConnectivityResult.none'
          ? const NoInternetScreen() : Scaffold(backgroundColor: ColorsRes.red,
        //backgroundColor: ColorsRes.white,
        /*appBar: AppBar(leading: InkWell(
            onTap:(){
              Navigator.pop(context);
            },
            child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: FloatingActionButton(backgroundColor: ColorsRes.white,onPressed: () {  },
            child: const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.arrow_back_ios, color: ColorsRes.red),
            )))), backgroundColor: ColorsRes.red, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title:
            Text(StringsRes.account, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)),
            ),*/
        bottomNavigationBar: Container(height: 0.0, color: ColorsRes.white),
        body: _connectionStatus == 'ConnectivityResult.none'
            ? const NoInternetScreen() : SafeArea(
          child: NestedScrollView(
            controller: _scrollBottomBarController,
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  shadowColor: Colors.transparent,
                  backgroundColor: ColorsRes.red,
                  systemOverlayStyle: SystemUiOverlayStyle.dark,
                  iconTheme: const IconThemeData(
                    color: ColorsRes.black,
                  ),
                  floating: false,
                  pinned: false,
                  centerTitle: true,
                  leading: Padding(padding: EdgeInsets.only(left: width!/20.0), child: FloatingActionButton(backgroundColor: ColorsRes.white,onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );  },
                          child: const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.arrow_back_ios, color: ColorsRes.red),
                          ))),title:
                Text(StringsRes.account, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(alignment: Alignment.topCenter,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: height!/8.0),
                            child: Align(alignment: Alignment.topRight,
                              child: SvgPicture.asset(DesignConfig.setSvgPath("profile_bg_img"),
                                //height: 80,
                                //width: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Padding(
                              padding: EdgeInsets.only(top: height!/8.0),
                              child: Align(alignment: Alignment.topRight,
                                  child: Container(color: ColorsRes.red.withOpacity(0.50), height: height!/4.0, width: width!/2.0,))),
                          Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: animation.controller,
                                builder: (BuildContext context, Widget? child) { return circle(size,
                                  animation.avatarSize.value,); },),
                              Padding(
                                padding: EdgeInsets.only(top: height!/50.0),
                                child: Text(context.read<AuthCubit>().getName(), textAlign: TextAlign.center, style: TextStyle(color: ColorsRes.white, fontSize: 20, fontWeight: FontWeight.w500)),
                              ),
                              SizedBox(height: height!/99.0),
                              Text(context.read<AuthCubit>().getEmail(), textAlign: TextAlign.center, style: TextStyle(color: ColorsRes.lightPink, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),]),
                  ),expandedHeight: height!/2.9,
                ),
              ];
            }, body: profile(),
          ),
        )/*profile()*/,
      ),
    );
  }
}
