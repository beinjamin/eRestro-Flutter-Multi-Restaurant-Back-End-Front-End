import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/transaction/cubit/transactionCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/myOrderSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

import '../../utils/internetConnectivity.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  TransactionScreenState createState() => TransactionScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<TransactionCubit>(
          create: (_) => TransactionCubit(),
          child: const TransactionScreen(),
        ));
  }
}

class TransactionScreenState extends State<TransactionScreen> {
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('dd-MM-yyyy');
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
      context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), transactionKey);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<TransactionCubit>().hasMoreData()) {
        context.read<TransactionCubit>().fetchMoreTransactionData(perPage, context.read<AuthCubit>().getId(), transactionKey);
      }
    }
  }

  Widget transaction() {
    return  BlocConsumer<TransactionCubit, TransactionState>(
        bloc: context.read<TransactionCubit>(),
        listener: (context, state) {
        },
        builder: (context, state) {
          if (state is TransactionProgress ||
              state is TransactionInitial) {
            return MyOrderSimmer(length: 5, width: width, height: height
            );
          }
          if (state is TransactionFailure) {
            return Center(child: Text(state.errorMessageCode.toString(), textAlign: TextAlign.center,));
          }
          final transactionList = (state as TransactionSuccess)
              .transactionList;
          final hasMore = state.hasMore;
          return Container(height: height!/1.2, color: ColorsRes.white,
              child: ListView.builder(shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: transactionList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && index == (transactionList.length - 1)
                        ? const Center(
                        child: CircularProgressIndicator(
                        ))
                        : GestureDetector(
                      onTap:(){
                      },
                      child: Container(
                        padding: EdgeInsets.only(left: width!/40.0, top: height!/99.0, right: width!/40.0,),
                        //height: height!/4.7,
                        width:width!,
                        margin: EdgeInsets.only(top: height!/52.0, left: width!/40.0, right: width!/40.0),
                        decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
                        child: Padding(
                          padding: EdgeInsets.only(left: width!/60.0),
                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children:[
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringsRes.amount+" : ", textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                    SizedBox(width: width!/99.0),
                                    Text(transactionList[index].amount!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                  ],
                                ),
                                const Spacer(),
                                Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringsRes.date+" :", textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                    SizedBox(width: width!/99.0),
                                    Text(formatter.format(DateTime.parse(transactionList[index].dateCreated!)), textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                  ],
                                ),
                                SizedBox(height: height!/99.0),
                              ],
                            ),
                            SizedBox(height: height!/99.0),
                            Row(
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringsRes.orderId+" : ", textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                    SizedBox(width: width!/99.0),
                                    Text(transactionList[index].orderId!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                  ],
                                ),
                                Expanded(flex: 1,
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Container(alignment: Alignment.center,
                                      padding: const EdgeInsets
                                          .only(
                                          top: 4.5, bottom: 4.5),
                                      width: 55,
                                      decoration: DesignConfig
                                          .boxDecorationContainer(
                                          transactionList[index].status ==
                                              StringsRes.success
                                              ? ColorsRes.green
                                              : ColorsRes.red,
                                          4.0),
                                      child: Text(
                                        transactionList[index].status!,
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: ColorsRes
                                                .white),
                                      ),
                                    ),),
                                ),
                              ],
                            ),
                            SizedBox(height: height!/99.0),
                            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringsRes.type+" : ", textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(width: width!/99.0),
                                Text(transactionList[index].type!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: height!/99.0),Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringsRes.transactionId+" :", textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(width: width!/99.0),
                                Text(transactionList[index].txnId!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: height!/99.0),
                            Row(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(StringsRes.message+" :", textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(width: width!/99.0),
                                SizedBox(width: width!/1.7, child: Text(transactionList[index].message!, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis,)),
                              ],
                            ),
                            SizedBox(height: height!/99.0),
                          ]),
                        ),
                      ),
                    );
                  }
              ));});
  }


  @override
  void dispose() {
    controller.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  Future<void> refreshList() async{
    context.read<TransactionCubit>().fetchTransaction(perPage, context.read<AuthCubit>().getId(), transactionKey);
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
            child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.transaction, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
        body: Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
          child: Container(color: ColorsRes.white, margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, top: height!/60.0),
              child: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red, child: SingleChildScrollView(physics: AlwaysScrollableScrollPhysics(),child: transaction()))
          ),
        ),
      ),
    );
  }
}
