import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/resetPasswordCubit.dart';
import 'package:erestro/features/auth/cubits/signUpCubit.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_autofill/otp_autofill.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:sms_autofill/sms_autofill.dart';

import '../../utils/internetConnectivity.dart';

class OtpVerifyResetPasswordScreen extends StatefulWidget {
  final String? countryCode, mobileNumber;
  const OtpVerifyResetPasswordScreen({Key? key, this.countryCode, this.mobileNumber}) : super(key: key);

  @override
  _OtpVerifyResetPasswordScreenState createState() => _OtpVerifyResetPasswordScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<ResetPasswordCubit>(
              create: (_) => ResetPasswordCubit(AuthRepository()),
              child: OtpVerifyResetPasswordScreen(
                mobileNumber: arguments['mobileNumber'] as String,
                countryCode: arguments['countryCode'] as String,
              ),
            ));
  }
}

class _OtpVerifyResetPasswordScreenState extends State<OtpVerifyResetPasswordScreen> with SingleTickerProviderStateMixin {
  double? width, height;
//  late TextEditingController pinEditController1 = TextEditingController(text: "");
  /*late TextEditingController locationSearchController = TextEditingController(text: "");
  late TextEditingController enableLocationController = TextEditingController(text: "");*/
  final _formKey = GlobalKey<FormState>();
  String mobile = "", _verificationId = "", otp = "", signature = "";
  bool _isClickable = false, isCodeSent = false, isloading = false, isErrorOtp = false;
  //late OTPTextEditController controller;
  late TextEditingController controller = TextEditingController();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  late AnimationController buttonController;
  late Timer _timer;
  int _start = 60;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  int otpTimeOutSeconds = 60;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _isClickable = true;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  bool otpMobile(String value) {
    if (value.trim().isEmpty) {
      setState(() {
        isErrorOtp = true;
      });
      return false;
    }
    return false;
  }

//to get time to display in text widget
  String getTime() {
    String secondsAsString = _start < 10 ? "0$_start" : _start.toString();
    return secondsAsString;
  }

  static Future<bool> checkNet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      check = true;
    }
    return check;
  }

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
    getSignature();
    signInWithPhoneNumber();
    startTimer();
    Future.delayed(const Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
  }

  @override
  void dispose() {
    _timer.cancel();
    buttonController.dispose();
    controller.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> getSignature() async {
    SmsAutoFill().getAppSignature.then((sign) {
      setState(() {
        signature = sign;
      });
    });
    await SmsAutoFill().listenForCode;
  }

  Future<void> checkNetworkOtpResend() async {
    bool checkInternet = await checkNet();
    if (checkInternet) {
      if (_isClickable) {
        signInWithPhoneNumber();
      } else {
        UiUtils.setSnackBar("", StringsRes.resendSnackBar, context, false);
      }
    } else {
      setState(() {
        checkInternet = false;
      });
      Future.delayed(const Duration(seconds: 60)).then((_) async {
        bool checkInternet = await checkNet();
        if (checkInternet) {
          if (_isClickable) {
            signInWithPhoneNumber();
          } else {
            UiUtils.setSnackBar("", StringsRes.resendSnackBar, context, false);
          }
        } else {
          await buttonController.reverse();
          UiUtils.setSnackBar("", StringsRes.noInterNetSnackBar, context, false);
        }
      });
    }
  }

  void signInWithPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      timeout: Duration(seconds: otpTimeOutSeconds),
      phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
      verificationCompleted: (PhoneAuthCredential credential) {
        print("Phone number verified");
      },
      verificationFailed: (FirebaseAuthException e) {
        //if otp code does not verify
        print("Firebase Auth error------------");
        print(e.message);
        print("---------------------");
        UiUtils.setSnackBar("", e.toString(), context, false);

        setState(() {
          isloading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        print("Code sent successfully");
        setState(() {
          //codeSent = true;
          _verificationId = verificationId;
          isloading = false;
        });

        /*Future.delayed(Duration(milliseconds: 75)).then((value) {
          resendOtpTimerContainerKey.currentState?.setResendOtpTimer();
        });*/
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  void _onFormSubmitted() async {
    String code = otp.trim();
    if (code.length == 6) {
      setState(() {
        isloading = true;
      });
      AuthCredential _authCredential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: code);
      _firebaseAuth.signInWithCredential(_authCredential).then((UserCredential value) async {
        //Navigator.of(context).pushNamed(Routes.resetPassword, arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode});
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.resetPassword, (Route<dynamic> route) => false,
            arguments: {'mobileNumber': widget.mobileNumber, 'countryCode': widget.countryCode});
        isloading = false;
        if (value.user != null) {
          await buttonController.reverse();
        } else {
          await buttonController.reverse();
        }
      }).catchError((error) async {
        if (mounted) {
          UiUtils.setSnackBar("", error.toString(), context, false);
          await buttonController.reverse();
        }
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : BlocProvider<SignUpCubit>(
            create: (_) => SignUpCubit(AuthRepository()),
            child: Builder(
              builder: (context) => Scaffold(
                backgroundColor: ColorsRes.white,
                appBar: AppBar(
                  backgroundColor: ColorsRes.white,
                  shadowColor: Colors.transparent,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(Icons.arrow_back_ios, color: ColorsRes.backgroundDark)),
                      SizedBox(width: width! / 99.0),
                      Text(StringsRes.otpVerification, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28)),
                    ],
                  ),
                  centerTitle: false,
                  leadingWidth: 5.0,
                ),
                body: Container(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                        SizedBox(height: height! / 15.0),
                        Text(
                          StringsRes.otpVerificationSubTitle,
                          style: const TextStyle(fontSize: 18.0, color: ColorsRes.backgroundDark),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height! / 50.0),
                        Text(
                          widget.countryCode! + " - " + widget.mobileNumber!,
                          style: const TextStyle(fontSize: 20.0, color: ColorsRes.backgroundDark),
                          textAlign: TextAlign.center,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0, bottom: 10.0, right: width! / 15.0, top: height! / 15.0),
                          child: PinInputTextField(
                            pinLength: 6,
                            //decoration: _pinDecoration,
                            controller: controller,
                            textInputAction: TextInputAction.done,
                            //enabled: _enable,
                            keyboardType: TextInputType.phone,
                            textCapitalization: TextCapitalization.characters,
                            onSubmit: (pin) {
                              debugPrint('submit pin:$pin');
                              otp = pin;
                            },
                            onChanged: (pin) {
                              debugPrint('onChanged execute. pin:$pin' + pin.length.toString());
                              isErrorOtp = controller.text.isEmpty;
                              otp = pin;
                              isloading = false;
                            },
                            decoration: BoxLooseDecoration(
                                strokeColorBuilder: PinListenColorBuilder(ColorsRes.backgroundDark, ColorsRes.lightFont),
                                textStyle: const TextStyle(color: ColorsRes.black, fontSize: 28, fontWeight: FontWeight.w600),
                                gapSpace: 8.0,
                                bgColorBuilder: PinListenColorBuilder(ColorsRes.textFieldBackground, ColorsRes.textFieldBackground)),
                            enableInteractiveSelection: false,
                            cursor: Cursor(
                              width: 2,
                              color: ColorsRes.backgroundDark,
                              radius: const Radius.circular(8),
                              //enabled: _cursorEnable,
                            ),
                          ),
                        ),
                        isloading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: ColorsRes.red,
                                  value: 10.0,
                                ),
                              )
                            : TextButton(
                                style: TextButton.styleFrom(
                                  splashFactory: NoSplash.splashFactory,
                                ),
                                onPressed: () {
                                  if (controller.text.isEmpty) {
                                    otpMobile(controller.text);
                                  } else {
                                    _onFormSubmitted();
                                  }
                                  //bottomModelSheetShow();
                                },
                                child: Container(
                                  width: width,
                                  alignment: Alignment.center,
                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                  margin: EdgeInsets.only(bottom: height! / 20.0, left: width! / 20.0, right: width! / 20.0, top: height! / 20.0),
                                  padding: const EdgeInsets.all(12),
                                  child: Text(StringsRes.enterOtp, style: const TextStyle(fontSize: 18.0, color: ColorsRes.white)),
                                ),
                              ),
                        Text(
                          StringsRes.didNotGetCodeYet,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: height! / 99.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _isClickable == false
                                ? Text(
                                    StringsRes.resetCodeIn + " 00:" + getTime() + " ",
                                    style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  )
                                : Container(),
                            _isClickable == true
                                ? InkWell(
                                    onTap: () async {
                                      setState(() {
                                        isloading = false;
                                      });
                                      await buttonController.reverse();
                                      checkNetworkOtpResend();
                                    },
                                    child: Text(
                                      StringsRes.resendOtp,
                                      style: const TextStyle(fontSize: 14.0, color: ColorsRes.red, fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      ]),
                    )),
              ),
            ));
  }
}
