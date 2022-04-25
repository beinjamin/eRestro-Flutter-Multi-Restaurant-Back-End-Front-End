import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/cart/cartRepository.dart';
import 'package:erestro/features/cart/cubits/manageCartCubit.dart';
import 'package:erestro/features/home/addOnsDataModel.dart';
import 'package:erestro/features/order/cubit/orderCubit.dart';
import 'package:erestro/features/order/cubit/orderDetailCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/myOrderSimmer.dart';
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

import '../../features/order/orderModel.dart';
import '../../utils/internetConnectivity.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({Key? key}) : super(key: key);

  @override
  MyOrderScreenState createState() => MyOrderScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: const MyOrderScreen(),
            ));
  }
}

class MyOrderScreenState extends State<MyOrderScreen> {
  double? width, height;
  ScrollController orderController = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');

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
    orderController.addListener(orderScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), "");
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  orderScrollListener() {
    if (orderController.position.maxScrollExtent == orderController.offset) {
      if (context.read<OrderCubit>().hasMoreData()) {
        context.read<OrderCubit>().fetchMoreOrderData(perPage, context.read<AuthCubit>().getId(), "");
      }
    }
  }

  Future cancel(BuildContext context, String? status, String? orderId) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: DesignConfig.setRoundedBorder(ColorsRes.white, 25.0, false),
          //title: Text('Not in stock'),
          content: SizedBox(
            height: height! / 2.0,
            child: Column(
              children: [
                SvgPicture.asset(DesignConfig.setSvgPath("order_cancel")),
                Text(StringsRes.heyWait,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 5.0),
                Padding(
                  padding: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0),
                  child: Text(StringsRes.cancelDialogSubTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                SizedBox(height: height! / 40.0),
                BlocConsumer<OrderDetailCubit, OrderDetailState>(
                    bloc: context.read<OrderDetailCubit>(),
                    listener: (context, state) {},
                    builder: (context, state) {
                      if (state is OrderDetailFailure) {
                        return Center(
                            child: SizedBox(
                          width: width! / 2,
                          child: Text(state.errorMessage.toString(),
                              textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(overflow: TextOverflow.ellipsis)),
                        ));
                      }
                      if (state is OrderDetailSuccess) {
                        //UiUtils.setSnackBar(StringsRes.order, StringsRes.cancelOrder, context, false);
                        Navigator.of(context, rootNavigator: true).pop(true);
                      }
                      return Row(
                        children: [
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true).pop(true);
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(top: height! / 99.0, right: width! / 99.0),
                                      width: width!,
                                      padding: EdgeInsets.only(
                                        top: height! / 65.0,
                                        bottom: height! / 65.0,
                                      ),
                                      decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.backgroundDark, ColorsRes.white, 100.0),
                                      child: Text(StringsRes.no,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500))))),
                          Expanded(
                              flex: 1,
                              child: InkWell(
                                  onTap: () {
                                    context.read<OrderDetailCubit>().getOrderDetail(status: status, orderId: orderId);
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(top: height! / 99.0),
                                      width: width!,
                                      padding: EdgeInsets.only(top: height! / 65.0, bottom: height! / 65.0),
                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 100.0),
                                      child: Text(StringsRes.cancelOrder,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)))))
                        ],
                      );
                    })
              ],
            ),
          ),
        );
      },
    );
  }

  Future paymentFailed(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: DesignConfig.setRounded(25.0),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: height! / 2.0,
              child: Column(
                children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("payment_failed")),
                  Text(StringsRes.paymentFailed,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5.0),
                  Text(StringsRes.paymentFailedSubTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                  SizedBox(height: height! / 40.0),
                  InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).pop(true);
                      },
                      child: Container(
                          margin: EdgeInsets.only(top: height! / 99.0, right: width! / 99.0),
                          width: width!,
                          padding: EdgeInsets.only(
                            top: height! / 65.0,
                            bottom: height! / 65.0,
                          ),
                          decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                          child: Text(StringsRes.tryAgain,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))))
                ],
              ),
            ));
      },
    );
  }

  Widget order() {
    return /*Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
      child: */
        Container(
      margin: EdgeInsets.only(left: width! / 7.0, right: width! / 7.0, top: height! / 10.0),
      child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
          SvgPicture.asset(DesignConfig.setSvgPath("empty_cart")),
          SizedBox(height: height! / 20.0),
          Text(StringsRes.noOrderYet,
              textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
          const SizedBox(height: 5.0),
          Text(StringsRes.noOrderYetSubTitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
        ]),
      ),
    );
    /*);*/
  }

  Widget myOrder() {
    return BlocConsumer<OrderCubit, OrderState>(
        bloc: context.read<OrderCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is OrderProgress || state is OrderInitial) {
            return MyOrderSimmer(length: 5, width: width!, height: height!);
          }
          if (state is OrderFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
            //return order();
          }
          final orderList = (state as OrderSuccess).orderList;
          //print("Length:"+orderList.length.toString());
          final hasMore = state.hasMore;
          return orderList.isEmpty
              ? order()
              : Container(
                  height: height! / 1.3,
                  color: ColorsRes.white,
                  child: ListView.builder(
                      shrinkWrap: true,
                      controller: orderController,
                      physics: const BouncingScrollPhysics(),
                      itemCount: orderList.length,
                      itemBuilder: (BuildContext context, index) {
                        var status = "";
                        if (orderList[index].activeStatus == deliveredKey) {
                          status = StringsRes.delivered;
                        } else if (orderList[index].activeStatus == pendingKey) {
                          status = StringsRes.pendingLb;
                        } else if (orderList[index].activeStatus == waitingKey) {
                          status = StringsRes.pendingLb;
                        } else if (orderList[index].activeStatus == receivedKey) {
                          status = StringsRes.pendingLb;
                        } else if (orderList[index].activeStatus == outForDeliveryKey) {
                          status = StringsRes.outForDeliveryLb;
                        } else if (orderList[index].activeStatus == confirmedKey) {
                          status = StringsRes.confirmedLb;
                        } else if (orderList[index].activeStatus == cancelledKey) {
                          status = StringsRes.cancel;
                        } else if (orderList[index].activeStatus == preparingKey) {
                          status = StringsRes.preparingLb;
                        } else {
                          status = "";
                        }
                        return hasMore && index == (orderList.length - 1)
                            ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                            : BlocProvider(
                                create: (context) => ManageCartCubit(CartRepository()),
                                child: Builder(builder: (context) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
                                        'id': orderList[index].id!,
                                        'riderId': orderList[index].riderId!,
                                        'riderName': orderList[index].riderName!,
                                        'riderRating': orderList[index].riderRating!,
                                        'riderImage': orderList[index].riderImage!,
                                        'riderMobile': orderList[index].riderMobile!,
                                        'riderNoOfRating': orderList[index].riderNoOfRatings!
                                      });
                                    },
                                    child: Container(
                                        padding:
                                            EdgeInsets.only(left: width! / 40.0, top: height! / 99.0, right: width! / 40.0, bottom: height! / 99.0),
                                        //height: height!/4.7,
                                        width: width!,
                                        margin: EdgeInsets.only(
                                          top: height! / 70.0,
                                          left: width! / 20.0,
                                          right: width! / 20.0,
                                        ),
                                        decoration: DesignConfig.boxDecorationContainerCardShadow(
                                            ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                        child: Image.network(orderList[index].orderItems![0].partnerDetails![0].partnerProfile!,
                                                            width: width! / 5.0, height: height! / 10.0, fit: BoxFit.cover))),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: EdgeInsets.only(left: width! / 60.0),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets.only(bottom: height! / 99.0),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Expanded(
                                                                  child: Text(
                                                                    orderList[index].orderItems![0].partnerDetails![0].partnerName!,
                                                                    textAlign: TextAlign.start,
                                                                    maxLines: 1,
                                                                    style: const TextStyle(
                                                                        color: ColorsRes.backgroundDark,
                                                                        fontSize: 14,
                                                                        overflow: TextOverflow.ellipsis,
                                                                        fontWeight: FontWeight.w500),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                SizedBox(width: width! / 50.0),
                                                                orderList[index].orderItems![0].partnerDetails![0].partnerIndicator == "1"
                                                                    ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                                    : orderList[index].orderItems![0].partnerDetails![0].partnerIndicator == "2"
                                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                            width: 15, height: 15)
                                                                        : Row(
                                                                            children: [
                                                                              SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                                                                                  width: 15, height: 15),
                                                                              const SizedBox(width: 2.0),
                                                                              SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                                  width: 15, height: 15),
                                                                            ],
                                                                          ),
                                                              ],
                                                            ),
                                                            /*Expanded(flex: 4,
                                                                child: Align(
                                                                  alignment: Alignment.topRight,
                                                                  child: Container(alignment: Alignment.center,
                                                                    padding: const EdgeInsets
                                                                        .only(
                                                                        top: 4.5, bottom: 4.5),
                                                                    width: 55,
                                                                    decoration: DesignConfig
                                                                        .boxDecorationContainer(
                                                                        orderList[index].activeStatus ==
                                                                            deliveredKey
                                                                            ? ColorsRes.green
                                                                            :orderList[index].activeStatus ==
                                                                            cancelledKey
                                                                            ? ColorsRes.red
                                                                            : ColorsRes.blueColor,
                                                                        4.0),
                                                                    child: Text(
                                                                      status,
                                                                      style: const TextStyle(
                                                                          fontSize: 12,
                                                                          color: ColorsRes
                                                                              .white),
                                                                    ),
                                                                  ),),
                                                              ),*/
                                                          ),
                                                          /* Text(orderList[index].orderItems![0].partnerDetails![0].tags!.join(', ').toString(),
                                                            textAlign: TextAlign.start,
                                                            style: const TextStyle(
                                                              color: ColorsRes.lightFont,
                                                              fontSize: 10,
                                                              fontWeight: FontWeight
                                                                  .normal,)),*/
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                                                                      fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                                  const SizedBox(width: 5.0),
                                                                  Text(
                                                                      double.parse(orderList[index].orderItems![0].partnerDetails![0].partnerRating!)
                                                                          .toStringAsFixed(1),
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.backgroundDark,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.w600)),
                                                                ],
                                                              ),
                                                              SizedBox(width: width! / 60.0),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  SvgPicture.asset(DesignConfig.setSvgPath("delivery_time"),
                                                                      fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                                  const SizedBox(width: 5.0),
                                                                  Text(
                                                                    orderList[index]
                                                                        .orderItems![0]
                                                                        .partnerDetails![0]
                                                                        .partnerCookTime!
                                                                        .toString()
                                                                        .replaceAll(regex, ''),
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(
                                                                        color: ColorsRes.backgroundDark,
                                                                        fontSize: 12,
                                                                        fontWeight: FontWeight.w600,
                                                                        overflow: TextOverflow.ellipsis),
                                                                    maxLines: 2,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: height! / 99.0),
                                                          FittedBox(
                                                            fit: BoxFit.fitWidth,
                                                            child: Container(
                                                              alignment: Alignment.topLeft,
                                                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5, left: 4.5, right: 4.5),
                                                              //width: width!/3.0,
                                                              decoration: DesignConfig.boxDecorationContainer(
                                                                  orderList[index].activeStatus == deliveredKey
                                                                      ? ColorsRes.green
                                                                      : orderList[index].activeStatus == cancelledKey
                                                                          ? ColorsRes.red
                                                                          : ColorsRes.blueColor,
                                                                  4.0),
                                                              child: Text(
                                                                status,
                                                                style: const TextStyle(fontSize: 12, color: ColorsRes.white),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            /* Container(
                                          height: height! / 7.3, color: ColorsRes.white,
                                          child: ListView.builder(shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: orderList[index].orderItems!
                                                  .length,
                                              itemBuilder: (BuildContext context, index) {
                                                return Container(
                                                    padding: EdgeInsets.only(
                                                        bottom: height! / 99.0),
                                                    //height: height!/4.7,
                                                    width: width!,
                                                    margin: EdgeInsets.only(
                                                        top: height! / 60.0,
                                                        left: width! / 60.0,
                                                        right: width! / 60.0),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        crossAxisAlignment: CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Text(orderList[index]
                                                              .orderItems![index].name! +
                                                              " x " + orderList[index]
                                                              .orderItems![index]
                                                              .quantity!,
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                  color: ColorsRes
                                                                      .backgroundDark,
                                                                  fontSize: 14,
                                                                  fontWeight: FontWeight
                                                                      .w500)),
                                                          Text(context.read<SystemConfigCubit>().getCurrency() +
                                                              " " + orderList[index]
                                                              .orderItems![index].price!,
                                                              textAlign: TextAlign.center,
                                                              style: const TextStyle(
                                                                  color: ColorsRes.red,
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight
                                                                      .w700)),
                                                        ]
                                                    ));
                                              }
                                          )),*/
                                            Column(
                                                children: List.generate(orderList[index].orderItems!.length, (i) {
                                              OrderItems data = orderList[index].orderItems![i];
                                              return InkWell(
                                                  onTap: () {
                                                    /*if(offerCouponsList[index].status=="1") {
                                                                coupons(context, offerCouponsList[index].couponsCode!, offerCouponsList[index].price!);
                                                              }*/
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.only(bottom: height! / 99.0),
                                                    //height: height!/4.7,
                                                    width: width!,
                                                    margin: EdgeInsets.only(top: height! / 60.0, left: width! / 60.0, right: width! / 60.0),
                                                    child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  data.name! + " x " + data.quantity!,
                                                                  textAlign: TextAlign.left,
                                                                  style: const TextStyle(
                                                                      color: ColorsRes.backgroundDark,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w500,
                                                                      overflow: TextOverflow.ellipsis),
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                              //const Spacer(),
                                                              orderList[index].activeStatus == deliveredKey
                                                                  ? InkWell(
                                                                      onTap: () {
                                                                        Navigator.of(context).pushNamed(Routes.productRating,
                                                                            arguments: {'productId': data.productId!});
                                                                      },
                                                                      child: Align(
                                                                        alignment: Alignment.topRight,
                                                                        child: Container(
                                                                          alignment: Alignment.center,
                                                                          padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                                                                          width: 55,
                                                                          decoration:
                                                                              DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 4.0),
                                                                          child: Text(
                                                                            StringsRes.rate,
                                                                            style: const TextStyle(fontSize: 12, color: ColorsRes.white),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                          orderList[index].orderItems![i].attrName != ""
                                                              ? Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(orderList[index].orderItems![i].attrName! + " : ",
                                                                        textAlign: TextAlign.left,
                                                                        style: const TextStyle(
                                                                            color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.w500)),
                                                                    Text(orderList[index].orderItems![i].variantValues!,
                                                                        textAlign: TextAlign.left,
                                                                        style: const TextStyle(
                                                                          color: ColorsRes.lightFont,
                                                                          fontSize: 12,
                                                                        )),
                                                                  ],
                                                                )
                                                              : Container(),
                                                          const SizedBox(height: 5.0),
                                                          Text(context.read<SystemConfigCubit>().getCurrency() + " " + data.price!,
                                                              textAlign: TextAlign.center,
                                                              style:
                                                                  const TextStyle(color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                          orderList[index].orderItems![i].addOns!.isNotEmpty
                                                              ? Padding(
                                                                  padding: const EdgeInsets.only(top: 8.0),
                                                                  child: Text(StringsRes.extraAddOn,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.backgroundDark,
                                                                          fontSize: 16,
                                                                          fontWeight: FontWeight.w500)),
                                                                )
                                                              : Container(),
                                                          Column(
                                                              children: List.generate(orderList[index].orderItems![i].addOns!.length, (j) {
                                                            AddOnsDataModel addOnData = orderList[index].orderItems![i].addOns![j];
                                                            return InkWell(
                                                                onTap: () {
                                                                  /*if(offerCouponsList[index].status=="1") {
                                                            coupons(context, offerCouponsList[index].couponsCode!, offerCouponsList[index].price!);
                                                          }*/
                                                                },
                                                                child: Container(
                                                                  padding: EdgeInsets.only(bottom: height! / 99.0),
                                                                  //height: height!/4.7,
                                                                  width: width!,
                                                                  margin: EdgeInsets.only(top: height! / 60.0, right: width! / 60.0),
                                                                  child: Column(
                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Text(addOnData.title! + " x " + addOnData.qty!,
                                                                            textAlign: TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: ColorsRes.lightFontColor,
                                                                                fontSize: 13,
                                                                                fontWeight: FontWeight.w500)),
                                                                        Text(context.read<SystemConfigCubit>().getCurrency() + " " + addOnData.price!,
                                                                            textAlign: TextAlign.center,
                                                                            style: const TextStyle(
                                                                                color: ColorsRes.red, fontSize: 14, fontWeight: FontWeight.w700)),
                                                                      ]),
                                                                ));
                                                          }))
                                                        ]),
                                                  ));
                                            })),
                                            Padding(
                                              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                                              child: Divider(
                                                color: ColorsRes.lightFont.withOpacity(0.50),
                                                height: 1.0,
                                              ),
                                            ),
                                            Row(children: [
                                              Text(StringsRes.totalPay,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                              const Spacer(),
                                              Text(context.read<SystemConfigCubit>().getCurrency() + orderList[index].finalTotal!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: ColorsRes.backgroundDark,
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.96)),
                                            ]),
                                            Padding(
                                              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                                              child: Divider(
                                                color: ColorsRes.lightFont.withOpacity(0.50),
                                                height: 1.0,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                        onTap: () {
                                                          if (mounted) {
                                                            //if (orderList[index].activeStatus == pendingKey) {
                                                            if (orderList[index].activeStatus == deliveredKey) {
                                                              Navigator.of(context).pushNamed(Routes.orderDeliverd, arguments: {
                                                                'id': orderList[index].id!,
                                                                'riderId': orderList[index].riderId!,
                                                                'riderName': orderList[index].riderName!,
                                                                'riderRating': orderList[index].riderRating!,
                                                                'riderImage': orderList[index].riderImage!,
                                                                'riderMobile': orderList[index].riderMobile!,
                                                                'riderNoOfRating': orderList[index].riderNoOfRatings!
                                                              });
                                                            } else if (orderList[index].orderItems![0].isCancelable == "1") {
                                                              cancel(context, StringsRes.cancelled, orderList[index].id!);
                                                            } else {
                                                              UiUtils.setSnackBar(StringsRes.order, StringsRes.orderCantCancel, context, false);
                                                            }
                                                            //}
                                                          }
                                                        },
                                                        child: Container(
                                                            margin: EdgeInsets.only(top: height! / 99.0, right: width! / 30.0),
                                                            width: width!,
                                                            padding: EdgeInsets.only(
                                                              top: height! / 65.0,
                                                              bottom: height! / 65.0,
                                                            ),
                                                            decoration: DesignConfig.boxDecorationContainerBorder(
                                                                ColorsRes.backgroundDark, ColorsRes.white, 100.0),
                                                            child: Text(
                                                                orderList[index].activeStatus == deliveredKey
                                                                    ? StringsRes.riderRate
                                                                    : StringsRes.cancel,
                                                                textAlign: TextAlign.center,
                                                                maxLines: 1,
                                                                style: const TextStyle(
                                                                    color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500))))),
                                                Expanded(
                                                    flex: 1,
                                                    child: BlocConsumer<ManageCartCubit, ManageCartState>(
                                                        bloc: context.read<ManageCartCubit>(),
                                                        listener: (context, state) {
                                                          if (state is ManageCartSuccess) {
                                                            UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false);
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) => const CartScreen(),
                                                              ),
                                                            );
                                                          } else if (state is ManageCartFailure) {
                                                            Navigator.pop(context);
                                                            //showMessage = state.errorMessage.toString();
                                                            UiUtils.setSnackBar(StringsRes.addToCart, state.errorMessage, context, false);
                                                          }
                                                        },
                                                        builder: (context, state) {
                                                          return InkWell(
                                                              onTap: () {
                                                                if (orderList[index].activeStatus == outForDeliveryKey) {
                                                                  //print(orderList[index].activeStatus);
                                                                  Navigator.of(context).pushNamed(Routes.orderTracking, arguments: {
                                                                    'id': orderList[index].id!,
                                                                    'riderId': orderList[index].riderId!,
                                                                    'riderName': orderList[index].riderName!,
                                                                    'riderRating': orderList[index].riderRating!,
                                                                    'riderImage': orderList[index].riderImage!,
                                                                    'riderMobile': orderList[index].riderMobile!,
                                                                    'riderNoOfRating': orderList[index].riderNoOfRatings!,
                                                                    'latitude': double.parse(orderList[index].latitude!),
                                                                    'longitude': double.parse(orderList[index].longitude!),
                                                                    'latitudeRes':
                                                                        double.parse(orderList[index].orderItems![0].partnerDetails![0].latitude!),
                                                                    'longitudeRes':
                                                                        double.parse(orderList[index].orderItems![0].partnerDetails![0].longitude!),
                                                                    'orderAddress': orderList[index].address,
                                                                    'partnerAddress':
                                                                        orderList[index].orderItems![0].partnerDetails![0].partnerAddress!
                                                                  });
                                                                } else {
                                                                  //if (orderList[index].activeStatus == deliveredKey) {
                                                                  List<String> addOnId = [];
                                                                  List<String> addOnQty = [];
                                                                  for (int i = 0; i < orderList[index].orderItems!.length; i++) {
                                                                    addOnId.clear();
                                                                    addOnQty.clear();
                                                                    for (int j = 0; j < orderList[index].orderItems![i].addOns!.length; j++) {
                                                                      addOnId.add(orderList[index].orderItems![i].addOns![j].id!);
                                                                      addOnQty.add(orderList[index].orderItems![i].addOns![j].qty!);
                                                                    }
                                                                    context.read<ManageCartCubit>().manageCartUser(
                                                                        userId: context.read<AuthCubit>().getId(),
                                                                        productVariantId: orderList[index].orderItems![i].productVariantId!,
                                                                        isSavedForLater: "0",
                                                                        qty: orderList[index].orderItems![i].quantity!,
                                                                        addOnId: addOnId.join(","),
                                                                        addOnQty: addOnQty.join(","));
                                                                  }
                                                                }
                                                                //}
                                                              },
                                                              child: Container(
                                                                  margin: EdgeInsets.only(top: height! / 99.0),
                                                                  width: width!,
                                                                  padding: EdgeInsets.only(top: height! / 65.0, bottom: height! / 65.0),
                                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                                                  child: Text(
                                                                      orderList[index].activeStatus == outForDeliveryKey
                                                                          ? StringsRes.trackOrder
                                                                          : StringsRes.reOrder,
                                                                      textAlign: TextAlign.center,
                                                                      maxLines: 1,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                                        }))
                                              ],
                                            )
                                          ],
                                        )),
                                  );
                                }),
                              );
                      }),
                );
        });
  }

  Future<void> refreshList() async {
    context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), "");
  }

  @override
  void dispose() {
    orderController.dispose();
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
                title: Text(StringsRes.myOrder,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(top: height! / 60.0),
                  height: height!,
                  child: RefreshIndicator(
                    onRefresh: refreshList,
                    color: ColorsRes.red,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: EdgeInsets.only(left: width! / 20.0, top: height! / 99.0),
                          child: Text(StringsRes.orderHistory,
                              style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 70.0),
                          child: Divider(
                            color: ColorsRes.lightFont.withOpacity(0.50),
                            height: 1.0,
                          ),
                        ),
                        myOrder(),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
