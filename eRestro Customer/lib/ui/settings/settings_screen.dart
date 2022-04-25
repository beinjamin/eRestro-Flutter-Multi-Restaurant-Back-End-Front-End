import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/settings/settingsCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/ui/auth/login_screen.dart';
import 'package:erestro/ui/settings/refer_and_earn_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:launch_review/launch_review.dart';
import 'package:share_plus/share_plus.dart';

import '../../utils/internetConnectivity.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool notificationSwitch = true, appNotificationSwitch = false, tLogin = true, fLogin = false, gLogin = true;
  double? width, height;
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

  Widget line() {
    return Container(
      padding: const EdgeInsets.only(
        top: 10,
      ),
      child: Divider(
        height: 1,
        color: ColorsRes.lightFont.withOpacity(0.10),
      ),
    );
  }

  Widget notification() {
    return titleName(DesignConfig.setSvgPath("notification"), StringsRes.notification);
  }

  Widget notificationData() {
    return switchTile(StringsRes.notification, notificationSwitch);
  }

  Widget appNotificationData() {
    return switchTile(StringsRes.appNotification, appNotificationSwitch);
  }

  Widget linkedAccount() {
    return titleName(DesignConfig.setSvgPath("set_link_icon"), StringsRes.linkedAccount);
  }

  Widget twitterLogin() {
    return switchTile(StringsRes.twitterLogin, tLogin);
  }

  Widget fbLogin() {
    return switchTile(StringsRes.facebookLogin, fLogin);
  }

  Widget googleLogin() {
    return switchTile(StringsRes.googleLogin, gLogin);
  }

  Widget more() {
    return titleName(DesignConfig.setSvgPath("set_more_icon"), StringsRes.more);
  }

  Widget changePasswordData() {
    return arrowTile(
        name: StringsRes.changePassword,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.changePassword, arguments: aboutUsKey);
        });
  }

  Widget aboutUsData() {
    return arrowTile(
        name: StringsRes.aboutUs,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: aboutUsKey);
        });
  }

  Widget contactUsData() {
    return arrowTile(
        name: StringsRes.contactUs,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: contactUsKey);
        });
  }

  Widget helpAndSupport() {
    return arrowTile(
        name: StringsRes.helpAndSupport,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.addTicket);
        });
  }

  Widget termAndCondition() {
    return arrowTile(
        name: StringsRes.termAndCondition,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: termsAndConditionsKey);
        });
  }

  Widget privacyPolicyData() {
    return arrowTile(
        name: StringsRes.privacyPolicy,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.appSettings, arguments: privacyPolicyKey);
        });
  }

  Widget transactionData() {
    return arrowTile(
        name: StringsRes.transaction,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.transaction);
        });
  }

  Widget walletData() {
    return arrowTile(
        name: StringsRes.wallet,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.wallet);
        });
  }

  Widget faqs() {
    return arrowTile(
        name: StringsRes.faqs,
        onPressed: () {
          Navigator.of(context).pushNamed(Routes.faqs);
        });
  }

  Widget referAndEarn() {
    return arrowTile(
        name: StringsRes.referralAndEarnCode,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const ReferAndEarnScreen(),
            ),
          );
        });
  }

  Widget rateUs() {
    return arrowTile(
        name: StringsRes.rateUs,
        onPressed: () {
          LaunchReview.launch(
            androidAppId: packageName,
            iOSAppId: "585027354",
          );
        });
  }

  Widget share() {
    return arrowTile(
        name: StringsRes.share,
        onPressed: () {
          try {
            if (Platform.isAndroid) {
              Share.share(appName + " \nhttps://play.google.com/store/apps/details?id=" + packageName + "\n");
            } else {
              Share.share(appName + "\nhttps://apps.apple.com/585027354");
            }
          } catch (e) {
            UiUtils.setSnackBar(StringsRes.share, e.toString(), context, false);
          }
        });
  }

  Widget switchTile(String name, bool switchData) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
      title: Text(
        name,
        style: const TextStyle(fontSize: 14, color: ColorsRes.lightFont, fontWeight: FontWeight.w600),
      ),
      trailing: Container(
        //padding: const EdgeInsets.only(left: 45),
        child: Transform.scale(
          alignment: Alignment.centerRight,
          scale: 0.7,
          child: CupertinoSwitch(
            activeColor: ColorsRes.backgroundDark,
            value: context.read<SettingsCubit>().getSettings().notification,
            onChanged: (value) {
              setState(() {
                context.read<SettingsCubit>().changeNotification(value);
              });
            },
          ),
        ),
      ),
    );
  }

  Widget titleName(String image, String name) {
    return Container(
      padding: EdgeInsets.only(top: height! / 90.0),
      child: Row(
        children: [
          SvgPicture.asset(image),
          const SizedBox(
            width: 5,
          ),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }

  Widget arrowTile({String? name, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
          title: Text(
            name!,
            style: const TextStyle(fontSize: 14, color: ColorsRes.textFieldBorder, fontWeight: FontWeight.w600),
          ),
          trailing: IconButton(
              onPressed: onPressed,
              padding: EdgeInsets.only(left: height! / 40.0),
              icon: const Icon(Icons.arrow_forward_ios, size: 15, color: ColorsRes.textFieldBorder))),
    );
  }

  @override
  void dispose() {
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
                        child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                backgroundColor: ColorsRes.white,
                shadowColor: ColorsRes.white,
                elevation: 0,
                centerTitle: true,
                title: Text(StringsRes.settings,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar: Container(
                height: height! / 8.0,
                child: Column(
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                          splashFactory: NoSplash.splashFactory,
                        ),
                        onPressed: () {
                          //  Navigator.of(context).pop();
                          context.read<AuthCubit>().signOut();
                          Navigator.of(context)
                              .pushAndRemoveUntil(CupertinoPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
                        },
                        child: Container(
                            margin: EdgeInsets.only(left: width! / 4.0, right: width! / 4.0, bottom: height! / 99.0),
                            width: width,
                            padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0, left: width! / 20.0, right: width! / 20.0),
                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.power_settings_new, color: ColorsRes.white),
                                SizedBox(width: width! / 60.0),
                                Text(StringsRes.logout,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)),
                              ],
                            ))),
                    Platform.isIOS
                        ? Text(StringsRes.appVersion + " " + context.read<SystemConfigCubit>().getCurrentVersionIos(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: const TextStyle(color: ColorsRes.darkGrey, fontSize: 10, fontWeight: FontWeight.w500))
                        : Text(StringsRes.appVersion + context.read<SystemConfigCubit>().getCurrentVersionAndroid(),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: const TextStyle(color: ColorsRes.darkGrey, fontSize: 10, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 50.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        transactionData(),
                        walletData(),
                        changePasswordData(),
                        aboutUsData(),
                        contactUsData(),
                        helpAndSupport(),
                        termAndCondition(),
                        privacyPolicyData(),
                        faqs(),
                        rateUs(),
                        share(),
                        referAndEarn(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
