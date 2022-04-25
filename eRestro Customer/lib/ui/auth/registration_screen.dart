import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/auth/cubits/signUpCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_messaging/firebase_messaging.dart' as fcm;

import '../../utils/internetConnectivity.dart';

class RegistrationScreen extends StatefulWidget {
  final String? mobileNumber, countryCode;
  const RegistrationScreen({Key? key, this.mobileNumber, this.countryCode}) : super(key: key);

  @override
  RegistrationScreenState createState() => RegistrationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SignUpCubit>(
              create: (_) => SignUpCubit(AuthRepository()),
              child: RegistrationScreen(
                mobileNumber: arguments['mobileNumber'] as String,
                countryCode: arguments['countryCode'] as String,
              ),
            ));
  }
}

class RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameController = TextEditingController(text: "");
  TextEditingController emailController = TextEditingController(text: "");
  late TextEditingController phoneNumberController;
  /*late TextEditingController locationSearchController = TextEditingController(text: "");
  late TextEditingController enableLocationController = TextEditingController(text: "");*/
  TextEditingController passwordController = TextEditingController(text: "");
  TextEditingController friendsCodeController = TextEditingController(text: "");
  // String? countryCode = "+91";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  double? width, height;
  bool obscure = true;

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
    phoneNumberController = TextEditingController(text: widget.mobileNumber);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  static Future<String> getFCMToken() async {
    try {
      return await fcm.FirebaseMessaging.instance.getToken() ?? "";
    } catch (e) {
      return "";
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    //locationSearchController.dispose();
    //enableLocationController.dispose();
    passwordController.dispose();
    friendsCodeController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocProvider<SignUpCubit>(
        create: (_) => SignUpCubit(AuthRepository()),
        child: Builder(
          builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
            ),
            child: _connectionStatus == 'ConnectivityResult.none'
                ? const NoInternetScreen()
                : Scaffold(
                    backgroundColor: ColorsRes.white,
                    appBar: AppBar(
                      leading: InkWell(
                          onTap: () {
                            //Navigator.pop(context);
                            SystemNavigator.pop();
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: width! / 20.0),
                              child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32))),
                      backgroundColor: ColorsRes.white,
                      shadowColor: ColorsRes.white,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(StringsRes.signUp,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    bottomNavigationBar: BlocConsumer<SignUpCubit, SignUpState>(
                        bloc: context.read<SignUpCubit>(),
                        listener: (context, state) async {
                          //Exceuting only if authProvider is email
                          if (state is SignUpFailure) {
                            print(state.errorMessage);
                            UiUtils.setSnackBar(StringsRes.signUp, state.errorMessage, context, false);
                          }
                          if (state is SignUpSuccess) {
                            //bottomModelSheetShow();
                            context.read<AuthCubit>().statusUpdateAuth(state.authModel);
                            Navigator.of(context).pushReplacementNamed(Routes.changeAddress);
                          }
                        },
                        builder: (context, state) {
                          return TextButton(
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              onPressed: () {
                                //print("data");
                                context.read<SignUpCubit>().signUpUser(
                                    name: nameController.text.trim(),
                                    email: emailController.text.trim(),
                                    countryCode: widget.countryCode,
                                    mobile: phoneNumberController.text.trim(),
                                    password: passwordController.text.trim(),
                                    friendCode: friendsCodeController.text.trim());
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                  width: width,
                                  padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                  child: Text(StringsRes.signUp,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                        }),
                    body: Container(
                        margin: EdgeInsets.only(top: height! / 30.0),
                        decoration: DesignConfig.boxCurveShadow(),
                        width: width,
                        child: Container(
                          margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 20.0),
                          child: SingleChildScrollView(
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(StringsRes.fullName,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: TextField(
                                    controller: nameController,
                                    cursorColor: ColorsRes.lightFont,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: StringsRes.fullName,
                                      labelStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      contentPadding: const EdgeInsets.only(top: 10.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height! / 30.0),
                                child: const Divider(
                                  color: ColorsRes.textFieldBorder,
                                  height: 0.0,
                                ),
                              ),
                              Text(StringsRes.emailId,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: TextField(
                                    controller: emailController,
                                    cursorColor: ColorsRes.lightFont,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: StringsRes.enterEmail,
                                      labelStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      contentPadding: EdgeInsets.only(top: height! / 40.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height! / 30.0),
                                child: const Divider(
                                  color: ColorsRes.textFieldBorder,
                                  height: 0.0,
                                ),
                              ),
                              Text(StringsRes.phoneNumber,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: TextField(
                                    controller: phoneNumberController,
                                    cursorColor: ColorsRes.lightFont,
                                    enabled: false,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: StringsRes.enterPhoneNumber,
                                      labelStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      contentPadding: EdgeInsets.only(top: height! / 40.0),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height! / 30.0),
                                child: const Divider(
                                  color: ColorsRes.textFieldBorder,
                                  height: 0.0,
                                ),
                              ),
                              Text(StringsRes.password,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: TextField(
                                    obscureText: obscure,
                                    controller: passwordController,
                                    cursorColor: ColorsRes.lightFont,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: StringsRes.enterPassword,
                                      labelStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
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
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      contentPadding: EdgeInsets.only(top: height! / 40.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height! / 30.0),
                                child: const Divider(
                                  color: ColorsRes.textFieldBorder,
                                  height: 0.0,
                                ),
                              ),
                              /*Text(StringsRes.referralCode, textAlign: TextAlign.start, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                        Container(
                            padding: EdgeInsets.zero, margin: EdgeInsets.zero,
                            child: TextField(controller: referralCodeController,cursorColor: ColorsRes.lightFont,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: StringsRes.enterReferralCode,
                                labelStyle: const TextStyle(
                                  color: ColorsRes.lightFont,
                                  fontSize: 14.0,
                                ),
                                hintStyle: const TextStyle(
                                  color: ColorsRes.lightFont,
                                  fontSize: 14.0,
                                ),contentPadding: EdgeInsets.only(top: height/40.0),
                              ),keyboardType: TextInputType.text,
                              style: const TextStyle(
                                color: ColorsRes.lightFont,
                                fontSize: 14.0,
                              ),
                            )),
                        Padding(
                          padding: EdgeInsets.only(bottom: height/30.0),
                          child: const Divider(color: ColorsRes.textFieldBorder, height: 0.0,),
                        ),*/
                              Text(StringsRes.friendsCode,
                                  textAlign: TextAlign.start,
                                  maxLines: 2,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                              Container(
                                  padding: EdgeInsets.zero,
                                  margin: EdgeInsets.zero,
                                  child: TextField(
                                    controller: friendsCodeController,
                                    cursorColor: ColorsRes.lightFont,
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: StringsRes.enterFriendsCode,
                                      labelStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      hintStyle: const TextStyle(
                                        color: ColorsRes.lightFont,
                                        fontSize: 14.0,
                                      ),
                                      contentPadding: EdgeInsets.only(top: height! / 40.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height! / 30.0),
                                child: const Divider(
                                  color: ColorsRes.textFieldBorder,
                                  height: 0.0,
                                ),
                              ),
                            ]),
                          ),
                        )),
                  ),
          ),
        ));
  }
}
