import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({Key? key}) : super(key: key);

  @override
  NoInternetScreenState createState() => NoInternetScreenState();
}

class NoInternetScreenState extends State<NoInternetScreen> {
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
        body: Container(margin: EdgeInsets.only(left: width/10.0, right: width/10.0, top: height/5.0), width: width,
              child: Column(
                  children: [
                    SvgPicture.asset(DesignConfig.setSvgPath("connection_lost")),
                    SizedBox(height: height/20.0),
                    Text(StringsRes.whoops, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.red, fontSize: 26, fontWeight: FontWeight.w700), maxLines: 2,),
                    const SizedBox(height: 5.0),
                    Text(StringsRes.noInternetSubTitle, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                    InkWell(
                      onTap:(){
                        setState(() {
                          _isLoading = true;
                        });
                        Future.delayed(const Duration(seconds: 3), () {
                          CheckInternet.initConnectivity();
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
                        child: Container(margin: EdgeInsets.only(top: height/10.0), padding: EdgeInsets.only(top: height/70.0, bottom: 10.0, left: width/20.0, right: width/20.0), decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.red, ColorsRes.white, 0.0), child: Text(StringsRes.tryAgain, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.red, fontSize: 12, fontWeight: FontWeight.w500)))),
                  ]
              ),
            )
      ),
    );
  }
}
