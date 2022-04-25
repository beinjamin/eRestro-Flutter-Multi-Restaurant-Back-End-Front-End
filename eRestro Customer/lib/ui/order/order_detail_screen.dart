import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/home/addOnsDataModel.dart';
import 'package:erestro/features/order/cubit/orderCubit.dart';
import 'package:erestro/features/order/orderModel.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/orderDetailSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/internetConnectivity.dart';

class OrderDetailScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating;
  const OrderDetailScreen(
      {Key? key, this.id, this.riderId, this.riderName, this.riderRating, this.riderImage, this.riderMobile, this.riderNoOfRating})
      : super(key: key);

  @override
  OrderDetailScreenState createState() => OrderDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<OrderCubit>(
              create: (_) => OrderCubit(),
              child: OrderDetailScreen(
                  id: arguments['id'] as String,
                  riderId: arguments['riderId'] as String,
                  riderName: arguments['riderName'] as String,
                  riderRating: arguments['riderRating'] as String,
                  riderImage: arguments['riderImage'] as String,
                  riderMobile: arguments['riderMobile'] as String,
                  riderNoOfRating: arguments['riderNoOfRating'] as String),
            ));
  }
}

class OrderDetailScreenState extends State<OrderDetailScreen> {
  double? width, height;
  int selectedIndex = 0;
  Future<List<Directory>?>? _externalStorageDirectories;
  bool _isProgress = false;
  ScrollController orderController = ScrollController();
  String invoice = "";
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
    _externalStorageDirectories = getExternalStorageDirectories(type: StorageDirectory.downloads);
    Future.delayed(Duration.zero, () {
      context.read<OrderCubit>().fetchOrder(perPage, context.read<AuthCubit>().getId(), widget.id!);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  downloadInvoice() {
    return FutureBuilder<List<Directory>?>(
        future: _externalStorageDirectories,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              onPressed: () async {
                final status = await Permission.storage.request();
                // final per=await  Permission.manageExternalStorage.request();

                if (status == PermissionStatus.granted) {
                  if (mounted) {
                    setState(() {
                      _isProgress = true;
                    });
                  }
                  var targetPath;

                  if (Platform.isIOS) {
                    var target = await getApplicationDocumentsDirectory();
                    targetPath = target.path.toString();
                  } else {
                    if (snapshot.hasData) {
                      targetPath = snapshot.data!.map((Directory d) => d.path).join(', ');

                      print("dir path****$targetPath");
                    }
                  }

                  var targetFileName = "Invoice_${widget.id}";
                  var generatedPdfFile, filePath;
                  try {
                    generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                    filePath = generatedPdfFile.path;
                  } on Exception {
                    //  filePath = targetPath + "/" + targetFileName + ".html";
                    generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(invoice, targetPath, targetFileName);
                    filePath = generatedPdfFile.path;
                  }

                  if (mounted) {
                    setState(() {
                      _isProgress = false;
                    });
                  }
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      StringsRes.invoicePath + " " + targetFileName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.white),
                    ),
                    action: SnackBarAction(
                        label: StringsRes.view,
                        textColor: ColorsRes.white,
                        onPressed: () async {
                          final result = await OpenFile.open(filePath);
                        }),
                    backgroundColor: ColorsRes.green,
                    elevation: 1.0,
                  ));
                }
              },
              child: Container(
                  margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                  width: width,
                  padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                  child: Text(StringsRes.downloadBill,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
        });
  }

  Widget orderData() {
    return BlocConsumer<OrderCubit, OrderState>(
        bloc: context.read<OrderCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is OrderProgress || state is OrderInitial) {
            return OrderSimmer(width: width!, height: height!);
          }
          if (state is OrderFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final orderList = (state as OrderSuccess).orderList;
          invoice = orderList[0].invoiceHtml!;
          return Container(
              height: height! / 0.9,
              color: ColorsRes.white,
              child: ListView.builder(
                  shrinkWrap: true,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: orderList.length,
                  itemBuilder: (BuildContext context, index) {
                    return Container(
                        padding: EdgeInsets.only(left: width! / 60.0, right: width! / 60.0, bottom: height! / 99.0),
                        //height: height!/4.7,
                        width: width!,
                        margin: EdgeInsets.only(top: height! / 70.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 32.0,
                                    height: 32.0,
                                    margin: EdgeInsets.only(left: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0, right: width! / 40.0),
                                    decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                    child: SvgPicture.asset(DesignConfig.setSvgPath("other_address"), fit: BoxFit.scaleDown)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringsRes.deliveryFrom,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500)),
                                    SizedBox(
                                        width: width! / 1.6,
                                        child: Text(orderList[index].orderItems![0].partnerDetails![0].partnerAddress!,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              height: height! / 10.5,
                              width: 2.0,
                              margin: EdgeInsets.only(left: width! / 14.0),
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  itemCount: 14,
                                  itemBuilder: (BuildContext context, index) {
                                    return Container(
                                      margin: const EdgeInsets.only(top: 2.0),
                                      height: 5.0,
                                      width: 2.0,
                                      color: ColorsRes.backgroundDark,
                                    );
                                  }),
                            ),
                            Row(
                              children: [
                                Container(
                                    width: 32.0,
                                    height: 32.0,
                                    margin: EdgeInsets.only(left: width! / 40.0, top: height! / 99.0, bottom: height! / 99.0, right: width! / 40.0),
                                    decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowCard, 5, 0, 3, 6, 0),
                                    child: SvgPicture.asset(DesignConfig.setSvgPath("other_address"), fit: BoxFit.scaleDown)),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(StringsRes.deliveryLocation,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500)),
                                    SizedBox(
                                        width: width! / 1.6,
                                        child: Text(
                                          orderList[index].address!,
                                          textAlign: TextAlign.start,
                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: height! / 70.0, bottom: height! / 70.0),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(
                                children: [
                                  Text(StringsRes.orderId,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)),
                                  const Spacer(),
                                  Text(orderList[index].id!,
                                      textAlign: TextAlign.start,
                                      style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: height! / 70.0, bottom: height! / 70.0),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(right: width! / 99.0),
                                      alignment: Alignment.center,
                                      height: 40.0,
                                      width: 40,
                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                      child: const Icon(Icons.check, color: ColorsRes.white)),
                                  SizedBox(
                                    height: height! / 19.0,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(StringsRes.order + " " + orderList[index].activeStatus!,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                        Text(StringsRes.yourOrder + " " + orderList[index].activeStatus!,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                        Text(orderList[index].dateAdded!,
                                            textAlign: TextAlign.start,
                                            style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: height! / 70.0, bottom: height! / 70.0),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Text(StringsRes.billDetail,
                                  textAlign: TextAlign.start,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: height! / 70.0, bottom: height! / 70.0),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Column(
                              children: List.generate(orderList[index].orderItems!.length, (i) {
                                OrderItems data = orderList[index].orderItems![i];
                                return InkWell(
                                    onTap: () {},
                                    child: Container(
                                        padding: EdgeInsets.only(bottom: height! / 99.0),
                                        //height: height!/4.7,
                                        width: width!,
                                        margin:
                                            EdgeInsets.only(left: width! / 40.0, right: width! / 60.0, bottom: height! / 99.0, top: height! / 99.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(data.name! + " x " + data.quantity!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(
                                                      color: ColorsRes.backgroundDark,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      overflow: TextOverflow.ellipsis),
                                                  maxLines: 1),
                                              const SizedBox(height: 5.0),
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
                                                                color: ColorsRes.lightFont, fontSize: 12, overflow: TextOverflow.ellipsis),
                                                            maxLines: 1),
                                                      ],
                                                    )
                                                  : Container(),
                                              const SizedBox(height: 5.0),
                                              Text(context.read<SystemConfigCubit>().getCurrency() + " " + data.price!,
                                                  textAlign: TextAlign.center,
                                                  style: const TextStyle(color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                              orderList[index].orderItems![i].addOns!.isNotEmpty
                                                  ? Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Text(StringsRes.extraAddOn,
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                              color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
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
                                                                    color: ColorsRes.lightFontColor, fontSize: 14, fontWeight: FontWeight.w500)),
                                                            Text(context.read<SystemConfigCubit>().getCurrency() + " " + addOnData.price!,
                                                                textAlign: TextAlign.center,
                                                                style:
                                                                    const TextStyle(color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                          ]),
                                                    ));
                                              }))
                                            ])));
                              }),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 4.5,
                                bottom: 4.5,
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.otp,
                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10)),
                                const Spacer(),
                                Text(orderList[index].otp!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.chargesAndTaxes,
                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10)),
                                const Spacer(),
                                Text(StringsRes.percentSymbol + " " + orderList[index].totalTaxPercent!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.total,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(context.read<SystemConfigCubit>().getCurrency() + " " + orderList[index].total!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            orderList[index].promoCode == ""
                                ? Padding(
                                    padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: 4.5),
                                    child: Row(children: [
                                      Text(StringsRes.coupons + orderList[index].promoCode!,
                                          textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10)),
                                      const Spacer(),
                                      Text(" - " + context.read<SystemConfigCubit>().getCurrency() + " " + orderList[index].promoDiscount!,
                                          textAlign: TextAlign.right,
                                          style:
                                              const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                    ]),
                                  )
                                : Container(),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.deliveryTip,
                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10)),
                                const Spacer(),
                                Text(context.read<SystemConfigCubit>().getCurrency() + " " + orderList[index].deliveryTip!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                top: 4.5,
                                bottom: 4.5,
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.deliveryFee,
                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10)),
                                const Spacer(),
                                Text(context.read<SystemConfigCubit>().getCurrency() + " " + orderList[index].deliveryCharge!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.totalPay,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(context.read<SystemConfigCubit>().getCurrency() + " " + orderList[index].totalPayable!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: width! / 40.0,
                                right: width! / 40.0,
                              ),
                              child: Row(children: [
                                Text(StringsRes.payment,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                const Spacer(),
                                Text(orderList[index].paymentMethod!,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                              ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.5, bottom: 4.5),
                              child: Divider(
                                color: ColorsRes.lightFont.withOpacity(0.50),
                                height: 1.0,
                              ),
                            ),
                          ],
                        ));
                  }));
        });
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
                title: Text(StringsRes.orderDetails,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              bottomNavigationBar:
                  downloadInvoice(), //TextButton(style: TextButton.styleFrom(splashFactory: NoSplash.splashFactory,),onPressed:(){},child: Container(margin: EdgeInsets.only(left: width!/40.0, right: width!/40.0, bottom: height!/55.0), width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0), child: Text(StringsRes.downloadBill, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)))),

              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, top: height! / 40.0), child: orderData()),
              )),
    );
  }
}
