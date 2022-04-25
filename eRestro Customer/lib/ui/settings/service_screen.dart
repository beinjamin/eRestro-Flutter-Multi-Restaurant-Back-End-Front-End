import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/systemConfig/cubits/appSettingsCubit.dart';
import 'package:erestro/features/systemConfig/systemConfigRepository.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:html/dom.dart' as dom;

import '../../utils/internetConnectivity.dart';
import 'no_internet_screen.dart';

class ServiceScreen extends StatefulWidget {
  final String? title;
  const ServiceScreen({Key? key, required this.title}) : super(key: key);

  @override
  ServiceScreenState createState() => ServiceScreenState();
  static Route<ServiceScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AppSettingsCubit>(
              create: (_) => AppSettingsCubit(
                SystemConfigRepository(),
              ),
              child: ServiceScreen(title: routeSettings.arguments as String),
            ));
  }
}

class ServiceScreenState extends State<ServiceScreen> {
  late WebViewController webViewController;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String getType() {
    if (widget.title == aboutUsKey) {
      return "about_us";
    }
    if (widget.title == privacyPolicyKey) {
      return "privacy_policy";
    }
    if (widget.title == termsAndConditionsKey) {
      return "terms_conditions";
    }
    if (widget.title == contactUsKey) {
      return "contact_us";
    }

    print(widget.title);
    return "";
  }

  @override
  void initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    getAppSetting();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  void getAppSetting() {
    Future.delayed(Duration.zero, () {
      context.read<AppSettingsCubit>().getAppSetting(getType());
    });
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
              appBar: AppBar(
                leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                        padding: EdgeInsets.only(left: width / 20.0),
                        child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                backgroundColor: ColorsRes.white,
                shadowColor: ColorsRes.white,
                elevation: 0,
                centerTitle: true,
                title: Text(widget.title!,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                  margin: EdgeInsets.only(top: height / 30.0),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                      margin: EdgeInsets.only(left: width / 20.0, right: width / 20.0, top: height / 20.0),
                      child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
                        bloc: context.read<AppSettingsCubit>(),
                        builder: (context, state) {
                          if (state is AppSettingsFetchInProgress || state is AppSettingsIntial) {
                            return const Center(
                              child: CircularProgressIndicator(color: ColorsRes.red),
                            );
                          }
                          if (state is AppSettingsFetchFailure) {
                            Container(
                              alignment: Alignment.center,
                              child: Center(
                                  child: Text(
                                state.errorCode.toString(),
                                textAlign: TextAlign.center,
                              )),
                            );
                          }
                          return SingleChildScrollView(
                            child: Html(
                              data: (state as AppSettingsFetchSuccess).settingsData,
                              onLinkTap: (String? url, RenderContext context, Map<String, String> attributes, dom.Element? element) async {
                                if (await canLaunch(url!)) {
                                  await launch(
                                    url,
                                    forceSafariVC: false,
                                    forceWebView: false,
                                  );
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                            ),
                          );
                        },
                      )))),
    );
  }
}
