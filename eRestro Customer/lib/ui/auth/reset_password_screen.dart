import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/resetPasswordCubit.dart';
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

class ResetPasswordScreen extends StatefulWidget {
  final String? mobileNumber, countryCode;
  const ResetPasswordScreen({Key? key, this.mobileNumber, this.countryCode}) : super(key: key);

  @override
  ResetPasswordScreenState createState() => ResetPasswordScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<ResetPasswordCubit>(
              create: (_) => ResetPasswordCubit(AuthRepository()),
              child: ResetPasswordScreen(
                mobileNumber: arguments['mobileNumber'] as String,
                countryCode: arguments['countryCode'] as String,
              ),
            ));
  }
}

class ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool obscure = true;
  late TextEditingController phoneNumberController;
  TextEditingController passwordController = TextEditingController(text: "");
  // String? countryCode = "+91";
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
    phoneNumberController.dispose();
    passwordController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return BlocProvider<ResetPasswordCubit>(
        create: (_) => ResetPasswordCubit(AuthRepository()),
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
                              padding: EdgeInsets.only(left: width / 20.0),
                              child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32))),
                      backgroundColor: ColorsRes.white,
                      shadowColor: ColorsRes.white,
                      elevation: 0,
                      centerTitle: true,
                      title: Text(StringsRes.resetPassword,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                    ),
                    bottomNavigationBar: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
                        bloc: context.read<ResetPasswordCubit>(),
                        listener: (context, state) async {
                          //Exceuting only if authProvider is email

                          if (state is ResetPasswordFailure) {
                            UiUtils.setSnackBar(StringsRes.resetPassword, state.errorMessage, context, false);
                          }
                          if (state is ResetPasswordSuccess) {
                            UiUtils.setSnackBar(StringsRes.resetPassword, StringsRes.passwordChangeSuccessFully, context, false);
                            Navigator.of(context).pushReplacementNamed(Routes.login);
                          }
                        },
                        builder: (context, state) {
                          return TextButton(
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              onPressed: () {
                                if (phoneNumberController.text.isNotEmpty && passwordController.text.isNotEmpty) {
                                  context
                                      .read<ResetPasswordCubit>()
                                      .resetPassword(mobile: phoneNumberController.text.trim(), password: passwordController.text.trim());
                                } else {
                                  if (phoneNumberController.text.isEmpty) {
                                    UiUtils.setSnackBar(StringsRes.phoneNumber, StringsRes.phoneNumber, context, false);
                                  } else {
                                    UiUtils.setSnackBar(StringsRes.password, StringsRes.enterPassword, context, false);
                                  }
                                }
                              },
                              child: Container(
                                  margin: EdgeInsets.only(left: width / 40.0, right: width / 40.0, bottom: height / 55.0),
                                  width: width,
                                  padding: EdgeInsets.only(top: height / 55.0, bottom: height / 55.0, left: width / 20.0, right: width / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                  child: Text(StringsRes.resetPassword,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                        }),
                    body: Container(
                        margin: EdgeInsets.only(top: height / 30.0),
                        decoration: DesignConfig.boxCurveShadow(),
                        width: width,
                        child: Container(
                          margin: EdgeInsets.only(left: width / 20.0, right: width / 20.0 /*, top: height / 20.0*/),
                          child: SingleChildScrollView(
                            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                                      contentPadding: EdgeInsets.only(top: height / 40.0),
                                    ),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height / 30.0),
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
                                      contentPadding: EdgeInsets.only(top: height / 40.0),
                                    ),
                                    keyboardType: TextInputType.text,
                                    style: const TextStyle(
                                      color: ColorsRes.lightFont,
                                      fontSize: 14.0,
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(bottom: height / 30.0),
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
