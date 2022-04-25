import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';
import '../../utils/internetConnectivity.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({Key? key}) : super(key: key);

  @override
  ReferAndEarnScreenState createState() => ReferAndEarnScreenState();
}

class ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == 'ConnectivityResult.none'
          ? const NoInternetScreen() : Scaffold(
          backgroundColor: ColorsRes.white,
          appBar: AppBar(leading: InkWell(
          onTap:(){
          Navigator.pop(context);
          },
          child: Padding(padding: EdgeInsets.only(left: width/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.referralAndEarnCode, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
          bottomNavigationBar: TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),onPressed:(){
            var str =
                "${appName}\nRefer Code:${context.read<SystemConfigCubit>().getReferCode()}\n${StringsRes.appFind}$androidLink$packageName\n\n${StringsRes.ios}\n$iosLink$iosPackage";
            Share.share(str);
          },child: Container(margin: EdgeInsets.only(left: width/40.0, right: width/40.0), width: width, padding: EdgeInsets.only(top: height/55.0, bottom: height/55.0, left: width/20.0, right: width/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0), child: Text(StringsRes.shareApp, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))))
          ,
          body: Container(margin: EdgeInsets.only(top: height/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Container(margin: EdgeInsets.only(left: width/20.0, right: width/20.0, top: height/99.0), width: width,
              child: SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(DesignConfig.setSvgPath("refer_and_earn"), fit: BoxFit.scaleDown,),
                      //SizedBox(height: height/20.0),
                      Text(StringsRes.referralAndEarnCode, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                      const SizedBox(height: 5.0),
                      Text(StringsRes.referralAndEarnCodeSubTitle, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 17, fontWeight: FontWeight.w500, letterSpacing: -0.39)),
                      SizedBox(height: height/55.0),
                      Text(StringsRes.yourCode, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, letterSpacing: -0.21)),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                            decoration: const BoxDecoration(
                                color: ColorsRes.red,
                                borderRadius:
                                BorderRadius.all(Radius.circular(4.0))),
                            child: Text(StringsRes.tapToCopy,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.button!.copyWith(
                                  color: ColorsRes.white,
                                ))),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: context.read<SystemConfigCubit>().getReferCode()));
                          UiUtils.setSnackBar(StringsRes.referralCode, "Refercode Copied to clipboard", context, false);
                        },
                      ),
                      ]
                ),
              ),
            ),
          )
      ),
    );
  }
}
