import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/verifyUserCubit.dart';
import 'package:erestro/ui/auth/login_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/auth/otp_verify_screen.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import '../../utils/internetConnectivity.dart';

class VerifyNumberScreen extends StatefulWidget {
  final String? from;
  const VerifyNumberScreen({
    Key? key,
    this.from,
  }) : super(key: key);

  @override
  VerifyNumberScreenState createState() => VerifyNumberScreenState();
}

class VerifyNumberScreenState extends State<VerifyNumberScreen> {
  GlobalKey<ScaffoldState>? scaffoldKey;
  late double width, height;
  TextEditingController phoneNumberController = TextEditingController(text: "");
  String? countryCode = "+91";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool status = false, iAccept = false;

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
                    bottomNavigationBar: Container(
                      height: height / 9.0,
                      padding: EdgeInsets.only(bottom: height / 50.0),
                      child: Column(children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Theme(
                              data: Theme.of(context).copyWith(
                                unselectedWidgetColor: Colors.white,
                              ),
                              child: Checkbox(
                                  value: iAccept,
                                  activeColor: ColorsRes.red,
                                  onChanged: (val) {
                                    setState(() {
                                      iAccept = val!;
                                    });
                                  },
                                  checkColor: ColorsRes.white,
                                  visualDensity: const VisualDensity(horizontal: 0, vertical: -4)),
                            ),
                            Text(
                              StringsRes.byClickingYouAgreeToOur,
                              style: const TextStyle(color: ColorsRes.white, fontSize: 12.0),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                        //const SizedBox(height: 2.0),
                        Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
                            },
                            child: Text(
                              StringsRes.termAndCondition,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            " " + StringsRes.and + " ",
                            style: const TextStyle(color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
                            },
                            child: Text(
                              StringsRes.privacyPolicy,
                              style: const TextStyle(
                                  decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 2.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              StringsRes.alreadyHave,
                              style: const TextStyle(color: ColorsRes.white, fontSize: 12.0),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(width: width / 99.0),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => const LoginScreen()));
                              },
                              child: Text(
                                StringsRes.signIn,
                                style: const TextStyle(
                                    decoration: TextDecoration.underline, color: ColorsRes.white, fontSize: 12.0, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ]),
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
                                textInputAction: TextInputAction.done,
                                dropDownIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: ColorsRes.black),
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
                                  UiUtils.setSnackBar(StringsRes.mobileNo, state.errorMessage, context, false);
                                  status = false;
                                }
                                if (state is VerifyUserSuccess) {
                                  status = false;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => OtpVerifyScreen(
                                        mobileNumber: phoneNumberController.text,
                                        countryCode: countryCode,
                                      ),
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return status == false
                                    ? TextButton(
                                        style: TextButton.styleFrom(
                                          splashFactory: NoSplash.splashFactory,
                                        ),
                                        onPressed: () {
                                          if (iAccept == true) {
                                            if (phoneNumberController.text.isNotEmpty) {
                                              context.read<VerifyUserCubit>().verifyUser(mobile: phoneNumberController.text);
                                              status = true;
                                            } else {
                                              UiUtils.setSnackBar(StringsRes.mobileNo, StringsRes.enterPhoneNumber, context, false);
                                            }
                                          } else {
                                            UiUtils.setSnackBar(StringsRes.acceptTermCondition, StringsRes.pleaseAcceptTermCondition, context, false);
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
                        ],
                      )),
                    ),
                  ),
          ),
        ));
  }
}
