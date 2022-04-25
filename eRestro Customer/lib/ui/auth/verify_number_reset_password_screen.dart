import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/verifyUserCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/auth/otp_verify_rest_password_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import '../../utils/internetConnectivity.dart';

class VerifyNumberResetPasswordScreen extends StatefulWidget {
  final String? from;
  const VerifyNumberResetPasswordScreen({
    Key? key,
    this.from,
  }) : super(key: key);

  @override
  VerifyNumberResetPasswordScreenState createState() => VerifyNumberResetPasswordScreenState();
}

class VerifyNumberResetPasswordScreenState extends State<VerifyNumberResetPasswordScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "");
  String? countryCode = "+91";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool? status = false;

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
    scaffoldKey = GlobalKey<ScaffoldState>();
  }

  @override
  void dispose() {
    phoneNumberController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return BlocProvider<VerifyUserCubit>(
        create: (_) => VerifyUserCubit(AuthRepository()),
        child: Builder(
          builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
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
                    ),
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
                              child: IntlPhoneField(
                                controller: phoneNumberController,
                                dropDownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: ColorsRes.black),
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
                                iconPosition: IconPosition.trailing,
                                initialCountryCode: 'IN',
                                style: const TextStyle(
                                  color: ColorsRes.black,
                                  fontSize: 17.0,
                                ),
                                onChanged: (phone) {
                                  setState(() {
                                    print(phone.completeNumber);
                                    countryCode = phone.countryCode;
                                  });
                                },
                              )),
                          BlocConsumer<VerifyUserCubit, VerifyUserState>(
                              bloc: context.read<VerifyUserCubit>(),
                              listener: (context, state) async {
                                if (state is VerifyUserFailure) {
                                  /*UiUtils.setSnackbar(
                                  StringsRes.mobileNo,
                                    state.errorMessage, context, false);*/
                                  if (state.errorMessage == "Mobile is already registered.Please login again !") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) => OtpVerifyResetPasswordScreen(
                                          mobileNumber: phoneNumberController.text,
                                          countryCode: countryCode,
                                        ),
                                      ),
                                    );
                                  }
                                }
                                if (state is VerifyUserSuccess) {
                                  UiUtils.setSnackBar(StringsRes.mobileNo, StringsRes.numberNotRegister, context, false);
                                  status = false;
                                }
                              },
                              builder: (context, state) {
                                return status == false
                                    ? TextButton(
                                        style: TextButton.styleFrom(
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () {
                                          if (phoneNumberController.text.isNotEmpty) {
                                            context.read<VerifyUserCubit>().verifyUser(mobile: phoneNumberController.text);
                                            status = true;
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: Text(StringsRes.enterPhoneNumber),
                                            ));
                                          }
                                        },
                                        child: Container(
                                          width: width,
                                          alignment: Alignment.center,
                                          decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                          margin: EdgeInsets.only(bottom: height / 20.0),
                                          padding: const EdgeInsets.all(12),
                                          child: Text(StringsRes.submit, style: const TextStyle(fontSize: 18.0, color: ColorsRes.white)),
                                        ),
                                      )
                                    : const CircularProgressIndicator(color: ColorsRes.red);
                              }),
                          SizedBox(
                            height: height / 10.0,
                          ),
                          SizedBox(
                            height: height / 30.0,
                          ),
                        ],
                      )),
                    ),
                  ),
          ),
        ));
  }
}
