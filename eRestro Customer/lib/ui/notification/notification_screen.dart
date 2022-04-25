import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/notificatiion/cubit/notificationCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/notificationSimmer.dart';
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

import '../../utils/internetConnectivity.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  NotificationScreenState createState() => NotificationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<NotificationCubit>(
          create: (_) => NotificationCubit(),
          child: const NotificationScreen(),
        ));
  }
}

class NotificationScreenState extends State<NotificationScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
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
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<NotificationCubit>().fetchNotification(perPage);
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<NotificationCubit>().hasMoreData()) {
        context.read<NotificationCubit>().fetchMoreNotificationData(perPage);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Widget notification(){
    return Container(margin: EdgeInsets.only(left: width!/10.0, right: width!/10.0, top: height!/10.0),
      child: Column(
          children: [
            SvgPicture.asset(DesignConfig.setSvgPath("no_notification")),
            SizedBox(height: height!/20.0),
            Text(StringsRes.noDataFound, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28/*, fontWeight: FontWeight.w500*/), maxLines: 2,),
            const SizedBox(height: 5.0),
            Text(StringsRes.noNotificationFoundSubTitle, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14/*, fontWeight: FontWeight.w500*/)),
          ]
      ),
    );
  }

  Widget notificationData(){
    return BlocConsumer<NotificationCubit, NotificationState>(
        bloc: context.read<NotificationCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is NotificationProgress ||
              state is NotificationInitial) {
            return NotificationSimmer(width: width, height: height);
          }
          if (state is NotificationFailure) {
            return Center(child: Text(state.errorMessageCode.toString(), textAlign: TextAlign.center));
          }
          final notificationList = (state as NotificationSuccess)
              .notificationList;
          final hasMore = state.hasMore;
          return notificationList.isEmpty? notification() : SizedBox(height: height!/1.18,//height! / 1.28,
            child: ListView.builder(
              controller: controller,
              itemCount: notificationList.length,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return hasMore && index == (notificationList.length - 1)
                    ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                    : GestureDetector(
                      onTap:(){
                        if(notificationList[index].type=="categories") {
                          Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {
                            'categoryId': notificationList[index].typeId!,
                            'name': StringsRes.deliciousCuisine
                          });
                        }
                        else{
                          UiUtils.setSnackBar(StringsRes.notification, StringsRes.normalNotification, context, false);
                        }
                      },
                      child: Container(margin: EdgeInsets.only(
                      left: width! / 20.0,
                      right: width! / 20.0,
                      top: height! / 50.0),
                      decoration: DesignConfig.boxDecorationContainer(
                          ColorsRes.backgroundDark, 15.0),
                      width: width,
                      child: Padding(
                        padding: EdgeInsets.only(top: width! / 32.0,
                            bottom: width! / 32.0,
                            left: width! / 32.0,
                            right: width! / 32.0),
                        child: Row(
                          children: [
                            Container(height: 39.0,
                                width: 39.0,
                                decoration: DesignConfig
                                    .boxDecorationContainer(
                                    ColorsRes.white, 10.0),
                                child: notificationList[index].image!.isNotEmpty
                                    ? CachedNetworkImage(
                                  imageUrl: notificationList[index].image!, fit: BoxFit.cover,
                                )
                                    : SvgPicture.asset(
                                  DesignConfig.setSvgPath(
                                      "notification_thumb"), width: 10.0,
                                  height: 10.0,),
                                margin: EdgeInsets.only(
                                    right: width! / 32.0)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(notificationList[index].title!,
                                    textAlign: TextAlign.start,
                                    style: const TextStyle(
                                        color: ColorsRes.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500),
                                    maxLines: 2,),
                                  //const SizedBox(height: 7),
                                  Text(notificationList[index].message!,
                                      textAlign: TextAlign.start,
                                      maxLines: 2,
                                      style: const TextStyle(
                                          color: ColorsRes.white,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                    );
              },
            ),
          );
        });
  }

  Future<void> refreshList() async{
    context.read<NotificationCubit>().fetchNotification(perPage);
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
            child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.notification, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
        body: Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*Padding(
                  padding: EdgeInsets.only(top: height!/30.0, left: width!/20.0),
                  child: Text(StringsRes.clearAll, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500), maxLines: 2,),
                ),*/
                RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red,child: notificationData())
              ],
            )
        ),
      ),
    );
  }
}
