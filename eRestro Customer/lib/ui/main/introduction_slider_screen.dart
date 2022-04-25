  import 'dart:async';

  import 'package:connectivity_plus/connectivity_plus.dart';
  import 'package:erestro/app/routes.dart';
  import 'package:erestro/features/settings/settingsCubit.dart';
  import 'package:erestro/helper/Slideanimation.dart';
  import 'package:erestro/helper/color.dart';
  import 'package:erestro/helper/design.dart';
  import 'package:erestro/helper/string.dart';
  import 'package:erestro/model/introduction_slider_model.dart';
  import 'package:erestro/ui/settings/no_internet_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter/services.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:flutter_svg/svg.dart';

  import '../../utils/internetConnectivity.dart';


  class IntroductionSliderScreen extends StatefulWidget {
    const IntroductionSliderScreen({Key? key}) : super(key: key);

    @override
    IntroductionSliderScreenState createState() => IntroductionSliderScreenState();
  }

  class IntroductionSliderScreenState extends State<IntroductionSliderScreen> with SingleTickerProviderStateMixin{
    final PageController _pageController = PageController(initialPage: 0);
    int currentIndex = 0;
    double? height, width;
    AnimationController? _animationController;
    String _connectionStatus = 'unKnown';
    final Connectivity _connectivity = Connectivity();
    late StreamSubscription<ConnectivityResult> _connectivitySubscription;

    @override
    void initState() {
      CheckInternet.initConnectivity().then((value) => setState(() {
        _connectionStatus = value;
      }));
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
            CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
              _connectionStatus = value;
            }));
          });
      _animationController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 1000));
      super.initState();
    }

    @override
    void dispose() {
      _animationController!.dispose();
      _pageController.dispose();
      _connectivitySubscription.cancel();
      super.dispose();
    }

    _onPageChanged(int index) {
      setState(() {
        currentIndex = index;
        _animationController!.repeat();
      });
    }


    List<T?> map<T>(List list, Function handler) {
      List<T?> result = [];
      for (var i = 0; i < list.length; i++) {
        result.add(handler(i, list[i]));
      }

      return result;
    }

    Widget _slider() {
      return PageView.builder(
        itemCount: introductionSliderList.length,
        scrollDirection: Axis.horizontal,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (BuildContext context, int index) {

          return Container(color: ColorsRes.white, alignment: Alignment.center,
            child: Stack(alignment: Alignment.center,
              children: [

                Padding(
                  padding: EdgeInsets.only(top: height!/6.8),
                  child: Column(
                    children: [
                      SvgPicture.asset(DesignConfig.setSvgPath(
                          introductionSliderList[index].image!
                      )),
                      SlideAnimation(
                        position: currentIndex+1,
                        itemCount: 8,
                        slideDirection: SlideDirection.fromRight,
                        animationController:
                        _animationController,
                        child: Padding(
                          padding: EdgeInsets.only(top: height!/10.0),
                          child: Text(introductionSliderList[currentIndex].title!,
                              style: const TextStyle(fontSize: 35, color: ColorsRes.backgroundDark), textAlign: TextAlign.center,),
                        ),
                      ),
                      SlideAnimation(
                        position: currentIndex+2,
                        itemCount: 8,
                        slideDirection: SlideDirection.fromRight,
                        animationController:
                        _animationController,
                        child: Padding(
                          padding: EdgeInsets.only(top: height!/40.0),
                          child: Text(introductionSliderList[currentIndex].subTitle!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18, color: ColorsRes.subTitle),),
                          ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    List<Widget> _buildIndicator() {
      List<Widget> indicators = [];
      for (int i = 0; i < 3; i++) {
        if (currentIndex == i) {
          indicators.add(_indicator(true));
        } else {
          indicators.add(_indicator(false));
        }
      }

      return indicators;
    }

    Widget _indicator(bool isActive) {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 6,
          width: isActive ? 15 : 10,
          margin: const EdgeInsets.only(right: 5),
          decoration: isActive?DesignConfig.boxDecorationContainer(ColorsRes.red, 3):DesignConfig.boxDecorationContainerBorder(ColorsRes.red, ColorsRes.textFieldBackground,  3));
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
            ? const NoInternetScreen() : Scaffold(bottomNavigationBar: currentIndex==2? SlideAnimation(
          position: currentIndex+3,
          itemCount: 8,
          slideDirection: SlideDirection.fromBottom,
          animationController:
          _animationController,
          child: Container(color: ColorsRes.white, height: height!/12,margin: EdgeInsets.only(bottom: height!/50.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                    ),onPressed:(){
                    context.read<SettingsCubit>().changeShowIntroSlider();
                    Navigator.of(context).pushReplacementNamed(Routes.login);
                  },
                    child: Container(width: width, alignment: Alignment.center, decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                      padding: const EdgeInsets.all(12),
                      child: Text(StringsRes.getStarted,
                          style: const TextStyle(fontSize: 18.0, color: ColorsRes.white)),
                    ),
                  ),
                 ),
        ):const SizedBox(width: 0, height: 0),
            body: SizedBox(
              width: width,
              height: height,
              child: Stack(
                children: <Widget>[
                  _slider(),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: height!/30,
                        top: height!/1.2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _buildIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

