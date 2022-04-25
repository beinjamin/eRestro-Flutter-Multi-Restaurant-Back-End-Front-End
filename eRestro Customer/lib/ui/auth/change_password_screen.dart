import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/authRepository.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/auth/cubits/changePasswordCubit.dart';
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
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(providers: [
        // BlocProvider<AddressCubit>(create: (context) => AddressCubit(AddressRepository(),)),
        BlocProvider<ChangePasswordCubit>(create: (_) => ChangePasswordCubit(AuthRepository())),
      ], child: const ChangePasswordScreen()),
    );
  }
}

class ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController oldPasswordController = TextEditingController(text: "");
  TextEditingController newPasswordController = TextEditingController(text: "");
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool obscureNew = true, obscureOld = true;

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
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
              backgroundColor: ColorsRes.white,
              appBar: AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsets.only(left: width! / 20.0),
                        child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32))),
                backgroundColor: ColorsRes.white,
                shadowColor: ColorsRes.white,
                elevation: 0,
                centerTitle: true,
                title: Text(StringsRes.changePassword,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
                  bloc: context.read<ChangePasswordCubit>(),
                  listener: (context, state) {
                    if (state is ChangePasswordSuccess) {
                      UiUtils.setSnackBar(StringsRes.changePassword, StringsRes.passwordChangeSuccessFully, context, false);
                      Navigator.of(context).pushReplacementNamed(Routes.login);
                      // Navigator.pop(context);
                    } else if (state is ChangePasswordFailure) {
                      UiUtils.setSnackBar(StringsRes.changePassword, state.errorMessage, context, false);
                    }
                  },
                  builder: (context, state) {
                    return TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: () {
                          if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                            context.read<ChangePasswordCubit>().changePassword(
                                userId: context.read<AuthCubit>().getId(),
                                oldPassword: oldPasswordController.text,
                                newPassword: newPasswordController.text);
                          } else {
                            if (oldPasswordController.text.isEmpty) {
                              UiUtils.setSnackBar(StringsRes.password, StringsRes.enterOldPassword, context, false);
                            } else {
                              UiUtils.setSnackBar(StringsRes.password, StringsRes.enterNewPassword, context, false);
                            }
                          }
                        },
                        child: Container(
                            margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                            width: width,
                            padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                            child: Text(StringsRes.changePassword,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                  }),
              body: Container(
                  margin: EdgeInsets.only(top: height! / 30.0),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                    margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0 /*, top: height! / 20.0*/),
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(height: height! / 15.0),
                      Text(StringsRes.oldPassword,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                      Container(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          child: TextField(
                            controller: oldPasswordController,
                            cursorColor: ColorsRes.lightFont,
                            obscureText: obscureOld,
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
                                    obscureOld = !obscureOld;
                                  });
                                },
                                child: Icon(
                                  obscureOld ? Icons.visibility : Icons.visibility_off,
                                  color: ColorsRes.black,
                                ),
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
                        padding: EdgeInsets.only(bottom: height! / 99.0),
                        child: const Divider(
                          color: ColorsRes.textFieldBorder,
                          height: 0.0,
                        ),
                      ),
                      Text(StringsRes.newPassword,
                          textAlign: TextAlign.start,
                          maxLines: 2,
                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                      Container(
                          padding: EdgeInsets.zero,
                          margin: EdgeInsets.zero,
                          child: TextField(
                            controller: newPasswordController,
                            cursorColor: ColorsRes.lightFont,
                            obscureText: obscureNew,
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
                                    obscureNew = !obscureNew;
                                  });
                                },
                                child: Icon(
                                  obscureNew ? Icons.visibility : Icons.visibility_off,
                                  color: ColorsRes.black,
                                ),
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
                      const Divider(
                        color: ColorsRes.textFieldBorder,
                        height: 0.0,
                      ),
                    ]),
                  )),
            ),
    );
  }
}
