import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/faq/cubit/faqsCubit.dart';
import 'package:erestro/features/faq/faqsRepository.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class FaqsScreen extends StatefulWidget {
  const FaqsScreen({Key? key}) : super(key: key);

  @override
  FaqsScreenState createState() => FaqsScreenState();
  static Route<FaqsScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FaqsCubit>(
          create: (_) => FaqsCubit(
            FaqsRepository(),
          ),
          child: const FaqsScreen(),
        ));
  }
}

class FaqsScreenState extends State<FaqsScreen> {
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
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
        });
    context.read<FaqsCubit>().fetchFaqs();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Widget faqs() {
    return BlocConsumer<FaqsCubit, FaqsState>(
        bloc: context.read<FaqsCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FaqsProgress ||
              state is FaqsInitial) {
            return const Center(child: CircularProgressIndicator(
            ));
          }
          if (state is FaqsFailure) {
            /*return ErrorContainer(
                      showBackButton: false,
                      errorMessageColor: Theme
                          .of(context)
                          .primaryColor,
                      showErrorImage: true,
                      errorMessage: AppLocalization.of(context)!
                          .getTranslatedValues(convertErrorCodeToLanguageKey(
                          state.errorMessageCode)),
                      onTapRetry: () {
                        context.read<FaqsCubit>().fetchFaqs(
                            "20");
                      },
                    );*/
          }
          final faqsList = (state as FaqsSuccess)
              .faqsList;
      return Container(
        child: ListView.builder(padding: EdgeInsets.zero,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            itemCount: faqsList.length,
            itemBuilder: (context, index) {
              return Container(margin: EdgeInsets.only(top: height!/99.0),decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
                  child: Theme(
                    data: ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(childrenPadding: EdgeInsets.zero, iconColor: ColorsRes.lightFont, collapsedIconColor: ColorsRes.lightFont,expandedAlignment: Alignment.topLeft,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: width!/24.0, bottom: height!/40.0),
                        child: Text(
                        faqsList[index].answer!, textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 12,
                          color: ColorsRes.backgroundDark,
                          fontWeight: FontWeight.w500,
                        )),
                      ),
                    ],
                    title: Text(faqsList[index].question!,textAlign: TextAlign.start,
                      style: const TextStyle(
                      fontSize: 12,
                      color: ColorsRes.backgroundDark,
                      ),
                    ),),
                  ),
                );
            }),
      );}
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
          ? const NoInternetScreen() : Scaffold(
          backgroundColor: ColorsRes.white,
          appBar: AppBar(leading: InkWell(
              onTap:(){
                Navigator.pop(context);
              },
              child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.faqs, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
          body:  Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Container(margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, top: height!/50.0),
              child: SingleChildScrollView(
                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(StringsRes.questions,
                          style: const TextStyle(fontSize: 16.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5.0),
                      Text(StringsRes.frequentlyAsked,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.lightFont, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height!/99.0, bottom: height!/99.0),
                        child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0,),
                      ),
                      faqs(),
                    ]
                ),
              ),
            ),
          )
      ),
    );
  }
}
