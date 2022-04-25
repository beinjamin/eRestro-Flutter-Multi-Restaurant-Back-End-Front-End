import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  MaintenanceScreenState createState() => MaintenanceScreenState();
}

class MaintenanceScreenState extends State<MaintenanceScreen> {
  bool? _isLoading = false;
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
                margin: EdgeInsets.only(left: width / 20.0, right: width / 20.0 /*, top: height/5.0*/),
                width: width,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  Text(
                    StringsRes.maintenance,
                    style: const TextStyle(color: ColorsRes.red, fontSize: 30, fontWeight: FontWeight.w700),
                    maxLines: 2,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width / 20.0, right: width / 20.0, top: 8.0, bottom: height / 14.0),
                    child: Text(StringsRes.maintenanceSubTitle,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                  SvgPicture.asset(DesignConfig.setSvgPath("maintainance")),
                  Padding(
                    padding: EdgeInsets.only(left: width / 10.0, right: width / 10.0, top: height / 14.0),
                    child: Text(StringsRes.weAreStillWorkingOnThis,
                        textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.black, fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: width / 10.0, right: width / 10.0, top: 11.0),
                    child: Text(StringsRes.thankYouForYourUnderstanding,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                  ),
                ]),
              )),
    );
  }
}
