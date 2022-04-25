import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/promoCode/cubit/promoCodeCubit.dart';
import 'package:erestro/features/promoCode/cubit/validatePromoCodeCubit.dart';
import 'package:erestro/features/promoCode/promoCodeRepository.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/dotted_border.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/promoCodeSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../../utils/internetConnectivity.dart';

class OfferCouponsScreen extends StatefulWidget {
  const OfferCouponsScreen({Key? key}) : super(key: key);

  @override
  OfferCouponsScreenState createState() => OfferCouponsScreenState();
}

class OfferCouponsScreenState extends State<OfferCouponsScreen> {
  double? width, height;
  ScrollController promoCodeController = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? promoCodeData = "", finalTotalData = "";
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
    promoCodeController.addListener(promoCodeScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<PromoCodeCubit>().fetchPromoCode(perPage);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  promoCodeScrollListener() {
    if (promoCodeController.position.maxScrollExtent == promoCodeController.offset) {
      if (context.read<PromoCodeCubit>().hasMoreData()) {
        context.read<PromoCodeCubit>().fetchMorePromoCodeData(perPage);
      }
    }
  }

  Widget offerCoupons() {
    return BlocConsumer<PromoCodeCubit, PromoCodeState>(
        bloc: context.read<PromoCodeCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is PromoCodeProgress || state is PromoCodeInitial) {
            return PromoCodeSimmer(length: 8, width: width!, height: height!);
          }
          if (state is PromoCodeFailure) {
            return Center(
                child: Text(
              state.errorMessageCode.toString(),
              textAlign: TextAlign.center,
            ));
          }
          final promoCodeList = (state as PromoCodeSuccess).promoCodeList;
          final hasMore = state.hasMore;
          return SizedBox(
            height: height! / 1.3,
            child: GridView.count(
                shrinkWrap: true,
                controller: promoCodeController,
                physics: const BouncingScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 2.1,
                children: List.generate(promoCodeList.length, (index) {
                  return hasMore && index == (promoCodeList.length - 1)
                      ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                      : BlocProvider<ValidatePromoCodeCubit>(
                          create: (context) => ValidatePromoCodeCubit(PromoCodeRepository()),
                          child: Builder(builder: (context) {
                            return BlocConsumer<ValidatePromoCodeCubit, ValidatePromoCodeState>(
                                bloc: context.read<ValidatePromoCodeCubit>(),
                                listener: (context, state) {
                                  if (state is ValidatePromoCodeFetchFailure) {
                                    UiUtils.setSnackBar(StringsRes.promoCode, state.errorCode, context, false);
                                  }
                                  if (state is ValidatePromoCodeFetchSuccess) {
                                    //print("success:"+state.promoCodeValidateModel!.promoCode!);
                                    promoCode = state.promoCodeValidateModel!.promoCode!.toString();
                                    promoAmt = double.parse(state.promoCodeValidateModel!.finalDiscount!);

                                    coupons(context, promoCode!, promoAmt, double.parse(state.promoCodeValidateModel!.finalTotal!));
                                  }
                                },
                                builder: (context, state) {
                                  return InkWell(
                                    onTap: () {
                                      promoCodeData = promoCodeList[index].promoCode!;
                                      finalTotalData = subTotal.toString();
                                      context
                                          .read<ValidatePromoCodeCubit>()
                                          .getValidatePromoCode(promoCodeData, context.read<AuthCubit>().getId(), finalTotalData);
                                    },
                                    child: promoCode == promoCodeList[index].promoCode!
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                left: width! / 40.0, right: width! / 40.0, bottom: height! / 80.0, top: height! / 80.0),
                                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                            child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                    Text(promoCodeList[index].discount! + StringsRes.percentSymbol + " " + StringsRes.off + " ",
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                            color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                                    Text(StringsRes.upTo + " ",
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                            color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                                    Text(context.read<SystemConfigCubit>().getCurrency() + promoCodeList[index].maxDiscountAmt!,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                            color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                                  ]),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 2.9),
                                                    child: Text(StringsRes.coupon + " " + promoCodeList[index].promoCode!,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          color: ColorsRes.white,
                                                          fontSize: 10,
                                                        )),
                                                  )
                                                ]),
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(
                                                left: width! / 40.0, right: width! / 40.0, bottom: height! / 80.0, top: height! / 80.0),
                                            child: DottedBorder(
                                                dashPattern: const [8, 4],
                                                strokeWidth: 1,
                                                strokeCap: StrokeCap.round,
                                                borderType: BorderType.RRect,
                                                radius: const Radius.circular(10.0),
                                                child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                        Text(promoCodeList[index].discount! + StringsRes.percentSymbol + " " + StringsRes.off + " ",
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark,
                                                                fontSize: 10,
                                                                fontWeight: FontWeight.w700,
                                                                letterSpacing: 0.8)),
                                                        Text(StringsRes.upTo + " ",
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                                        Text(context.read<SystemConfigCubit>().getCurrency() + promoCodeList[index].maxDiscountAmt!,
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                                      ]),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 2.9),
                                                        child: Text(StringsRes.coupon + " " + promoCodeList[index].promoCode!,
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                              color: ColorsRes.borderColor,
                                                              fontSize: 10,
                                                            )),
                                                      )
                                                    ])),
                                          ),
                                  );
                                });
                          }),
                        );
                })),
          );
        });
  }

  void coupons(BuildContext context, String code, double price, double finalAmount) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: DesignConfig.setRounded(25.0),
            //title: Text('Not in stock'),
            content: SizedBox(
              height: height! / 2.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(DesignConfig.setSvgPath("coupon_applied")),
                  Text(" ' ${StringsRes.use} " + code + " ' " + StringsRes.applie,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 18, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5.0),
                  Text(StringsRes.youSaved + " ",
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 5.0),
                  Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: const TextStyle(color: ColorsRes.red, fontSize: 28, fontWeight: FontWeight.w500)),
                ],
              ),
            ));
      },
    );
    await Future.delayed(
      const Duration(seconds: 1),
    );
    Navigator.of(context).pop();

    Navigator.of(context).pop({"code": code, "amount": price, "finalAmount": finalAmount});
  }

  @override
  void dispose() {
    promoCodeController.dispose();
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
                title: Text(StringsRes.offerCoupons,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              body: Container(
                  margin: EdgeInsets.only(top: height! / 30.0),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 40.0, left: width! / 40.0),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: width! / 20.0, top: height! / 40.0),
                            child: Text(StringsRes.availableCoupons,
                                textAlign: TextAlign.start,
                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: height! / 99.0, left: width! / 20.0, right: width! / 20.0),
                            child: Divider(
                              color: ColorsRes.lightFont.withOpacity(0.50),
                              height: 1.0,
                            ),
                          ),
                          offerCoupons(),
                        ],
                      ),
                    ),
                  )),
            ),
    );
  }
}
