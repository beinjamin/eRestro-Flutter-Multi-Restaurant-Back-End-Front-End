import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/auth/cubits/signInCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/auth/verify_number_reset_password_screen.dart';
import 'package:erestro/ui/auth/verify_number_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart';

import '../../utils/internetConnectivity.dart';

class LoginScreen extends StatefulWidget {
  final String? from;
  const LoginScreen({
    Key? key,
    this.from,
  }) : super(key: key);

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "");
  TextEditingController passwordController = TextEditingController(text: "");
  String? countryCode = "+91";
  Location location = Location();
  bool obscure = true, status = false;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    getUserLocation();
    location.getLocation();
    getPermission();
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    passwordController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  static getUserLocation() async {
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
      /*Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      print("heading---${position.heading}");
      currLattitude = position.latitude.toString();
      currLongitude = position.longitude.toString();

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
          localeIdentifier: "en");
      // print(placemarks[0]);

      String? address =
          "${placemarks[0].name},${placemarks[0].thoroughfare},${placemarks[0].locality},${placemarks[0].postalCode},${placemarks[0].country}";

      print("curadd-$address");
      session!.setData(SessionManager.KEY_currentaddress, address);*/
    }
  }

  static getPermission() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == 'ConnectivityResult.none'
          ? const NoInternetScreen()
          : Scaffold(
              backgroundColor: ColorsRes.backgroundDark,
              key: scaffoldKey,
              appBar: AppBar(
                centerTitle: false,
                backgroundColor: ColorsRes.backgroundDark,
                shadowColor: Colors.transparent,
                automaticallyImplyLeading: false,
                title: Text(StringsRes.welcome, style: const TextStyle(fontSize: 28.0, color: ColorsRes.white, fontWeight: FontWeight.w500)),
                /*leading: Padding(padding: EdgeInsets.only(left: width/20.0), child: FloatingActionButton(backgroundColor: ColorsRes.white,onPressed: () {
              Navigator.pop(context);
              },
                child: const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.arrow_back_ios, color: ColorsRes.red),
                ))),*/
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(bottom: height / 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      StringsRes.donTHave,
                      style: const TextStyle(color: ColorsRes.white, fontSize: 12.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: width / 99.0),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const VerifyNumberScreen()));
                      },
                      child: Text(
                        StringsRes.signUp,
                        style: const TextStyle(
                            decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                        /*recognizer: TapGestureRecognizer()..onTap = () {
                                          Navigator.of(context).push(CupertinoPageRoute(
                                              builder: (context) => LogInScreen()));
                                        }*/
                      ),
                    ),
                  ],
                ),
              ),
              /* bottomNavigationBar: Container(height: height/10.5,
          child:
          Column(mainAxisAlignment: MainAxisAlignment.center,  crossAxisAlignment: CrossAxisAlignment.center, children:[
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(StringsRes.donTHave,
                  style: const TextStyle(color: ColorsRes.white, fontSize: 12.0), textAlign: TextAlign.center,),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(CupertinoPageRoute(
                        builder: (context) => const VerifyNumberScreen()));
                  },
                  child: Text(StringsRes.signUp,
                    style: const TextStyle(decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                    /*recognizer: TapGestureRecognizer()..onTap = () {
                                        Navigator.of(context).push(CupertinoPageRoute(
                                            builder: (context) => LogInScreen()));
                                      }*/),
                ),
              ],
            ),/*
            const SizedBox(height: 2.0),
            Text(StringsRes.byClickingYouAgreeToOur,
              style: const TextStyle(color: ColorsRes.white, fontSize: 12.0), textAlign: TextAlign.center,),
            const SizedBox(height: 2.0),
            Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(StringsRes.termAndCondition,
                style: const TextStyle(decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                *//*recognizer: TapGestureRecognizer()..onTap = () {
                                      Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) => LogInScreen()));
                                    }*//*),
              Text(" "+StringsRes.and+" ",
                style: const TextStyle(color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                *//*recognizer: TapGestureRecognizer()..onTap = () {
                                      Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) => LogInScreen()));
                                    }*//*),
              Text(StringsRes.privacyPolicy,
                style: const TextStyle(decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                *//*recognizer: TapGestureRecognizer()..onTap = () {
                                      Navigator.of(context).push(CupertinoPageRoute(
                                          builder: (context) => LogInScreen()));
                                    }*//*),
            ]),*/]),),*/
              body: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, left: 15, right: 15),
                child: SingleChildScrollView(
                    child: Column(
                  children: [
                    SizedBox(height: height / 12.0),
                    SvgPicture.asset(DesignConfig.setSvgPath("logo_white")),
                    Container(
                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0),
                        height: height / 16.0,
                        padding: EdgeInsets.only(left: width / 20.0),
                        margin: EdgeInsets.only(left: width / 35.0, right: width / 32.0, bottom: height / 60.0, top: height / 4.0),
                        child: TextFormField(
                          controller: phoneNumberController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            counterStyle: const TextStyle(color: ColorsRes.white, fontSize: 0),
                            border: InputBorder.none,
                            hintText: StringsRes.enterPhoneNumber,
                            labelStyle: const TextStyle(
                              color: ColorsRes.lightFont,
                              fontSize: 17.0,
                            ),
                            hintStyle: const TextStyle(
                              color: ColorsRes.black,
                              fontSize: 17.0,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            color: ColorsRes.black,
                            fontSize: 17.0,
                          ),
                        )),
                    Container(
                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.white, 10.0),
                        height: height / 16.0,
                        padding: EdgeInsets.only(left: width / 20.0),
                        margin: EdgeInsets.only(left: width / 35.0, right: width / 32.0, bottom: height / 60.0, top: height / 99.0),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            counterStyle: const TextStyle(color: ColorsRes.white, fontSize: 0),
                            border: InputBorder.none,
                            hintText: StringsRes.enterPassword,
                            labelStyle: const TextStyle(
                              color: ColorsRes.lightFont,
                              fontSize: 17.0,
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              child: Icon(
                                obscure ? Icons.visibility : Icons.visibility_off,
                                color: ColorsRes.black,
                              ),
                            ),
                            hintStyle: const TextStyle(
                              color: ColorsRes.black,
                              fontSize: 17.0,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                          keyboardType: TextInputType.text,
                          style: const TextStyle(
                            color: ColorsRes.black,
                            fontSize: 17.0,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        )),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => const VerifyNumberResetPasswordScreen()));
                      },
                      child: Padding(
                        padding: EdgeInsets.only(right: width / 20.0, top: height / 99.0, bottom: height / 99.0),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              StringsRes.forgotPassword,
                              style: const TextStyle(color: ColorsRes.white, fontSize: 12.0),
                              textAlign: TextAlign.center,
                            )),
                      ),
                    ),
                    BlocConsumer<SignInCubit, SignInState>(
                        bloc: context.read<SignInCubit>(),
                        listener: (context, state) async {
                          //Exceuting only if authProvider is email
                          if (state is SignInFailure) {
                            UiUtils.setSnackBar(StringsRes.login, state.errorMessage, context, false);
                            status = false;
                          } else if (state is SignInSuccess) {
                            context.read<AuthCubit>().updateDetails(authModel: state.authModel);
                            Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
                            status = false;
                          }
                        },
                        builder: (context, state) {
                          return status == false
                              ? TextButton(
                                  style: TextButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: () async {
                                    if (phoneNumberController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                      context.read<SignInCubit>().signInUser(mobile: phoneNumberController.text, password: passwordController.text);
                                      status = true;
                                    } else {
                                      if (phoneNumberController.text.isEmpty) {
                                        UiUtils.setSnackBar(StringsRes.phoneNumber, StringsRes.enterPhoneNumber, context, false);
                                        status = false;
                                      } else {
                                        UiUtils.setSnackBar(StringsRes.password, StringsRes.enterPassword, context, false);
                                        status = false;
                                      }
                                    }
                                  },
                                  child: Container(
                                    width: width,
                                    alignment: Alignment.center,
                                    decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                    margin: EdgeInsets.only(bottom: height / 20.0),
                                    padding: const EdgeInsets.all(12),
                                    child: Text(StringsRes.login, style: const TextStyle(fontSize: 18.0, color: ColorsRes.white)),
                                  ),
                                )
                              : const CircularProgressIndicator(color: ColorsRes.red);
                        }),
                  ],
                )),
              ),
            ),
    );
  }
}
