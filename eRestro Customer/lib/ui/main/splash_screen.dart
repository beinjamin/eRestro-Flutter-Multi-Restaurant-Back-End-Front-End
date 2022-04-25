import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/settings/settingsCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/string.dart';

import '../../utils/internetConnectivity.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  late double width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  initState() {
    CheckInternet.initConnectivity().then((value) => setState(() {
          _connectionStatus = value;
        }));
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    Future.delayed(Duration.zero, () {
      if (context.read<AuthCubit>().state is Authenticated) {
        context.read<SystemConfigCubit>().getSystemConfig(context.read<AuthCubit>().getId());
      } else {
        Future.delayed(const Duration(seconds: 2), () {
          navigateToNextScreen();
        });
      }
    });
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
    super.initState();
  }

  void navigateToNextScreen() async {
    //Reading from settingsCubit means we are just reading current value of settingsCubit
    //if settingsCubit will change in future it will not rebuild it's child
    final currentSettings = context.read<SettingsCubit>().state.settingsModel;
    final currentAuthState = context.read<AuthCubit>().state;

    if (currentSettings!.showIntroSlider) {
      Navigator.of(context).pushReplacementNamed(Routes.introSlider);
    } else {
      if (currentAuthState is Authenticated) {
        Navigator.of(context).pushReplacementNamed(Routes.home, arguments: false);
      } else {
        Navigator.of(context).pushReplacementNamed(Routes.login);
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
      ),
      child: _connectionStatus == 'ConnectivityResult.none'
          ? const NoInternetScreen()
          : BlocConsumer<SystemConfigCubit, SystemConfigState>(
              bloc: context.read<SystemConfigCubit>(),
              listener: (context, state) {
                if (state is SystemConfigFetchSuccess) {
                  //if animation is running then navigate to next screen
                  //after animation completed
                  navigateToNextScreen();
                }
                if (state is SystemConfigFetchFailure) {
                  print(state.errorCode);
                  //animationController.stop();
                }
              },
              builder: (context, state) {
                Widget child = const Center(
                  key: Key("splashAnimation"),
                  //child: _buildSplashAnimation(),
                );
                if (state is SystemConfigFetchFailure) {
                  child = const Center(
                    key: Key("errorContainer"),
                    child: CircularProgressIndicator(color: ColorsRes.red),
                  );
                }

                return Scaffold(
                    backgroundColor: ColorsRes.backgroundDark,
                    bottomNavigationBar: Container(
                      height: height / 9.0,
                      color: ColorsRes.backgroundDark,
                      alignment: Alignment.center,
                      child: Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(StringsRes.madeBy, style: const TextStyle(color: ColorsRes.grey, fontSize: 10.0, fontWeight: FontWeight.w800)),
                          SizedBox(height: height / 60.0),
                          SvgPicture.asset(DesignConfig.setSvgPath("made_by")),
                        ],
                      ) //Container(),
                          ),
                    ),
                    body: Container(
                      color: ColorsRes.backgroundDark,
                      alignment: Alignment.center,
                      child: Center(
                        child: SvgPicture.asset(DesignConfig.setSvgPath("logo_red")),
                      ),
                    ));
              }),
    );
  }
}
