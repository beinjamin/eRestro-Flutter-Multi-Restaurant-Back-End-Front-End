import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/internetConnectivity.dart';

class ThankYouForReviewScreen extends StatefulWidget {
  const ThankYouForReviewScreen({Key? key}) : super(key: key);

  @override
  ThankYouForReviewScreenState createState() => ThankYouForReviewScreenState();
}

class ThankYouForReviewScreenState extends State<ThankYouForReviewScreen> {
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
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
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
          ? const NoInternetScreen()
          : Scaffold(
              backgroundColor: ColorsRes.white,
              /*bottomNavigationBar: TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),onPressed:(){
            Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                    builder: (context) => const MainScreen(
                    )),
                    (Route<dynamic> route) => false);},child: Container(margin: EdgeInsets.only(left: width/40.0, right: width/40.0), width: width, padding: EdgeInsets.only(top: height/55.0, bottom: height/55.0, left: width/20.0, right: width/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0), child: Text(StringsRes.backToHome, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)))),*/
              body: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.only(left: width / 20.0, right: width / 20.0),
                width: width,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("review_msg")),
                  SizedBox(height: height / 20.0),
                  Text(StringsRes.thankYou,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                  const SizedBox(height: 5.0),
                  Text(StringsRes.forYourReview,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                ]),
              )),
    );
  }
}
