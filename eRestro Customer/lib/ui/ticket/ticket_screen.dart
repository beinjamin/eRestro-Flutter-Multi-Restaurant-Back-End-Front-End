import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/helpAndSupport/cubit/ticketCubit.dart';
import 'package:erestro/ui/ticket/chat_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/addressSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class TicketScreen extends StatefulWidget {
  const TicketScreen({Key? key}) : super(key: key);

  @override
  TicketScreenState createState() => TicketScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<TicketCubit>(
              create: (_) => TicketCubit(),
              child: const TicketScreen(),
            ));
  }
}

class TicketScreenState extends State<TicketScreen> {
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
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
    });
    controller.addListener(scrollListener);
    Future.delayed(Duration.zero, () {
      context.read<TicketCubit>().fetchTicket(perPage);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TicketCubit>().hasMoreData()) {
        context.read<TicketCubit>().fetchMoreTicketData(perPage);
      }
    }
  }

  Widget ticket() {
    return BlocConsumer<TicketCubit, TicketState>(
        bloc: context.read<TicketCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TicketProgress || state is TicketInitial) {
            return AddressSimmer(width: width, height: height);
          }
          if (state is TicketFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final ticketList = (state as TicketSuccess).ticketList;
          final hasMore = state.hasMore;
          return Container(
              height: height! / 1.2,
              color: ColorsRes.white,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: ticketList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (ticketList.length - 1)
                        ? const Center(child: CircularProgressIndicator())
                        : GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                top: height! / 99.0,
                                right: width! / 40.0,
                              ),
                              //height: height!/4.7,
                              width: width!,
                              margin: EdgeInsets.only(top: height! / 52.0, left: width! / 40.0, right: width! / 40.0),
                              decoration: DesignConfig.boxDecorationContainerCardShadow(
                                  ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
                              child: Padding(
                                padding: EdgeInsets.only(left: width! / 60.0),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(StringsRes.type + " : ",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      Text(ticketList[index].ticketType!,
                                          textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(StringsRes.subject + " :",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      Text(ticketList[index].subject!,
                                          textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(StringsRes.message + " :",
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      Expanded(
                                          child: Text(ticketList[index].description!,
                                              textAlign: TextAlign.start,
                                              style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, overflow: TextOverflow.ellipsis),
                                              maxLines: 2)),
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(StringsRes.date + " :",
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                      SizedBox(width: width! / 99.0),
                                      Text(ticketList[index].dateCreated!,
                                          textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(Routes.editTicket, arguments: {
                                              'id': int.parse(ticketList[index].id!),
                                              'typeId': int.parse(ticketList[index].ticketTypeId!),
                                              'email': ticketList[index].email!,
                                              'subject': ticketList[index].subject!,
                                              'message': ticketList[index].description!,
                                              'status': ticketList[index].status!
                                            });
                                          },
                                          child: Container(
                                              margin: EdgeInsets.only(top: height! / 99.0),
                                              width: width! / 5.0,
                                              padding: EdgeInsets.only(
                                                top: height! / 99.0,
                                                bottom: height! / 99.0,
                                              ),
                                              decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.backgroundDark, ColorsRes.white, 0.0),
                                              child: Text(StringsRes.edit,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style:
                                                      const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)))),
                                      GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatScreen(id: ticketList[index].id!, status: ticketList[index].status!)),
                                            );
                                          },
                                          child: Container(
                                              margin: EdgeInsets.only(top: height! / 99.0, left: width! / 40.0),
                                              width: width! / 5.0,
                                              padding: EdgeInsets.only(
                                                top: height! / 99.0,
                                                bottom: height! / 99.0,
                                              ),
                                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 0.0),
                                              child: Text(StringsRes.chat,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(color: ColorsRes.white, fontSize: 14, fontWeight: FontWeight.w500))))
                                    ],
                                  ),
                                  SizedBox(height: height! / 99.0),
                                ]),
                              ),
                            ),
                          );
                  }));
        });
  }

  Future<void> refreshList() async {
    context.read<TicketCubit>().fetchTicket(perPage);
  }

  @override
  void dispose() {
    controller.dispose();
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
                title: Text(StringsRes.helpAndSupport,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                    color: ColorsRes.white,
                    margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                    child: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red, child: ticket())),
              ),
            ),
    );
  }
}
