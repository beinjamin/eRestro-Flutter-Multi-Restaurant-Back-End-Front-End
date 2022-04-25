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

class ThankYouForOrderScreen extends StatefulWidget {
  const ThankYouForOrderScreen({Key? key}) : super(key: key);

  @override
  ThankYouForOrderScreenState createState() => ThankYouForOrderScreenState();
}

class ThankYouForOrderScreenState extends State<ThankYouForOrderScreen> {
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
    Timer(const Duration(seconds: 2), () {
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
              body: Container(
                margin: EdgeInsets.only(left: width / 20.0, right: width / 20.0, top: height / 5.0),
                width: width,
                child: Column(children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("order_placed")),
                  SizedBox(height: height / 20.0),
                  Text(StringsRes.thankYou,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 26, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                  const SizedBox(height: 5.0),
                  Text(StringsRes.forYourOrder,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.39)),
                  SizedBox(height: height / 55.0),
                  Text(StringsRes.forYourOrderSubTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, letterSpacing: -0.21)),
                ]),
              )),
    );
  }
}
