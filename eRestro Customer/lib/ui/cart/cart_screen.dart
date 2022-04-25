import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/deliveryChargeCubit.dart';
import 'package:erestro/features/address/cubit/updateAddressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/cart/cartModel.dart';
import 'package:erestro/features/cart/cartRepository.dart';
import 'package:erestro/features/cart/cubits/getCartCubit.dart';
import 'package:erestro/features/cart/cubits/manageCartCubit.dart';
import 'package:erestro/features/cart/cubits/removeFromCartCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteProductsCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteProduct.dart';
import 'package:erestro/features/home/addOnsDataModel.dart';
import 'package:erestro/features/home/productAddOnsModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/features/promoCode/promoCodesModel.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/dotted_border.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/model/delivery_tip_model.dart';
import 'package:erestro/ui/home/restaurants/restaurant_detail_screen.dart';
import 'package:erestro/ui/main/main_screen.dart';
import 'package:erestro/ui/offerCoupons/offer_coupons_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/addressSimmer.dart';
import 'package:erestro/ui/widgets/bottomCartSimmer.dart';
import 'package:erestro/ui/widgets/buttonSimmer.dart';
import 'package:erestro/ui/widgets/cartSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/shims/dart_ui_real.dart';
import 'package:flutter_svg/svg.dart';
import 'package:location/location.dart';

import '../../features/home/variantsModel.dart';
import '../../utils/internetConnectivity.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  CartScreenState createState() => CartScreenState();
}

double finalTotal = 0, subTotal = 0, deliveryCharge = 0, taxPercentage = 0, taxAmount = 0, deliveryTip = 0, latitude = 0, longitude = 0;
int? selectedAddress = 0;
String? selAddress, paymentMethod = '', selTime, selDate, promoCode = '';
bool? isTimeSlot, isPromoValid = false, isUseWallet = false, isPayLayShow = true;
int? selectedTime, selectedDate, selectedMethod;

double promoAmt = 0;
double remWalBal = 0, walletBalanceUsed = 0;
bool isAvailable = true;

String? razorpayId, paystackId, stripeId, stripeSecret, stripeMode = "test", stripeCurCode, stripePayId, paytmMerId, paytmMerKey;
bool payTesting = true;

class CartScreenState extends State<CartScreen> {
  double? width, height;
  TextEditingController addNoteController = TextEditingController(text: "");
  int? selectedIndex, addressIndex;
  final ScrollController _scrollBottomBarController = ScrollController(); // set controller on scrolling
  bool isScrollingDown = false;
  double bottomBarHeight = 75; // set bottom bar height
  Location location = Location();
  String activeStatus = "pending";
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  CartModel? cartModel;
  String addressId = "";
  String isRestaurantOpen = "";
  //String promoCode = '';
  //double promoAmt = 0;
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
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    location.getLocation();
    DesignConfig.myScroll(_scrollBottomBarController, context);
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future restaurantClose(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //shape: DesignConfig.setRoundedBorder(ColorsRes.white, 25.0, false),
          //title: Text('Not in stock'),
          content: Text(StringsRes.restaurantClose,
              textAlign: TextAlign.start,
              maxLines: 2,
              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),
              child: Text(StringsRes.ok, style: const TextStyle(color: ColorsRes.red, fontSize: 12, fontWeight: FontWeight.w500)),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop(true);
              },
            )
          ],
        );
      },
    );
  }

  Widget cart() {
    return Container(
      margin: EdgeInsets.only(top: height! / 30.0),
      decoration: DesignConfig.boxCurveShadow(),
      width: width,
      child: Container(
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
      ),
    );
  }

  Widget addNote() {
    return Container(
        decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 10.0),
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(
          left: width! / 40.0,
          right: width! / 40.0,
        ),
        padding: EdgeInsets.only(left: width! / 20.0, bottom: height! / 99.0),
        child: TextField(
          controller: addNoteController,
          cursorColor: ColorsRes.lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.addNotesForFoodPartner,
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
            ),
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
          ),
        ));
  }

  Widget offerCoupons(List<PromoCodesModel> promoCodeList) {
    return SizedBox(
        height: height! / 10.0,
        child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: promoCodeList.length,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                onTap: () {
                  if (promoCodeList[index].status == "1") {
                    //coupons(context, promoCodeList[index].promoCode!, promoCodeList[index].maxDiscountAmt!);
                  }
                },
                child: promoCode != promoCodeList[index].promoCode!
                    ? Container(
                        margin: EdgeInsets.only(left: width! / 40.0, bottom: height! / 99.0, top: height! / 99.0),
                        padding: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0),
                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(promoCodeList[index].discount! + StringsRes.percentSymbol + " " + StringsRes.off + " ",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                            Text(StringsRes.upTo + " ",
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                            Text(context.read<SystemConfigCubit>().getCurrency() + promoCodeList[index].maxDiscountAmt!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: ColorsRes.white, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
                        margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 99.0, top: height! / 99.0),
                        child: DottedBorder(
                            dashPattern: const [8, 4],
                            strokeWidth: 1,
                            strokeCap: StrokeCap.round,
                            borderType: BorderType.RRect,
                            radius: const Radius.circular(10.0),
                            padding: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text(promoCodeList[index].discount! + StringsRes.percentSymbol + " " + StringsRes.off + " ",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                Text(StringsRes.upTo + " ",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                                Text(context.read<SystemConfigCubit>().getCurrency() + promoCodeList[index].maxDiscountAmt!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
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
            }));
  }

  Widget deliveryTips() {
    return Container(
        height: height! / 15.4,
        width: width!,
        margin: EdgeInsets.only(left: width! / 40.0, bottom: height! / 50.0),
        child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: deliveryTipList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    if (deliveryTipList[index].like == "0") {
                      setState(() {
                        deliveryTipList[index].like = "1";
                        selectedIndex = null;
                        deliveryTip = 0;
                      });
                    } else {
                      setState(() {
                        deliveryTipList[index].like = "0";
                        selectedIndex = index;
                        deliveryTip = double.parse(deliveryTipList[index].price!);
                      });
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: width! / 7.0,
                    padding: EdgeInsets.only(
                      top: height! / 55.0,
                      bottom: height! / 55.0,
                      right: width! / 99.0,
                      left: width! / 99.0,
                    ),
                    margin: EdgeInsets.only(right: width! / 25.0),
                    decoration: DesignConfig.boxDecorationContainer(selectedIndex == index ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text(context.read<SystemConfigCubit>().getCurrency() + deliveryTipList[index].price!,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: selectedIndex == index ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ));
            }));
  }

  bottomModelSheetShowEdit(List<ProductDetails> productList, int index) {
    ProductDetails productDetailsModel = productList[index];
    Map<String, int> qtyData = {};
    int _currentIndex = 0, qty = 0;
    List<bool> _isChecked = List<bool>.filled(productDetailsModel.productAddOns!.length, false);
    String? productVariantId = productDetailsModel.variants![0].id;

    List<String> addOnIds = [];
    List<String> addOnQty = [];
    List<double> addOnPrice = [];
    List<String> productAddOnIds = [];
    for (int i = 0; i < productDetailsModel.variants![_currentIndex].addOnsData!.length; i++) {
      productAddOnIds.add(productDetailsModel.variants![_currentIndex].addOnsData![i].id!);
    }
    if (productDetailsModel.variants![_currentIndex].cartCount != "0") {
      qty = int.parse(productDetailsModel.variants![_currentIndex].cartCount!);
    } else {
      qty = int.parse(productDetailsModel.minimumOrderQuantity!);
    }
    qtyData[productVariantId!] = qty;

    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
            double priceCurrent = double.parse(productDetailsModel.variants![_currentIndex].specialPrice!);
            if (priceCurrent == 0) {
              priceCurrent = double.parse(productDetailsModel.variants![_currentIndex].price!);
            }

            double offCurrent = 0;
            if (productDetailsModel.variants![_currentIndex].specialPrice! != "0") {
              offCurrent = (double.parse(productDetailsModel.variants![_currentIndex].price!) -
                      double.parse(productDetailsModel.variants![_currentIndex].specialPrice!))
                  .toDouble();
              offCurrent = offCurrent * 100 / double.parse(productDetailsModel.variants![_currentIndex].price!).toDouble();
            }
            productVariantId = productDetailsModel.variants![_currentIndex].id;
            return BlocProvider<UpdateProductFavoriteStatusCubit>(
              create: (context) => UpdateProductFavoriteStatusCubit(),
              child: Builder(builder: (context) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                        width: width!,
                        height: (MediaQuery.of(context).size.height / 1.14),
                        padding: EdgeInsets.only(top: height! / 15.0),
                        child: Container(
                          decoration: DesignConfig.boxDecorationContainerRoundHalf(ColorsRes.white, 25, 0, 25, 0),
                          child: Container(
                            padding: const EdgeInsets.only(left: /*width!/25.*/ 0, right: /* width!/25.*/ 0, top: /*height!/25.*/ 0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
                                                child: /*Image.network(productDetailsModel.image!, width: width!/5.0, height: height!/10.2, fit: BoxFit.cover)*/
                                                    ColorFiltered(
                                                  colorFilter: productDetailsModel.partnerDetails![0].isRestroOpen == "1"
                                                      ? const ColorFilter.mode(
                                                          Colors.transparent,
                                                          BlendMode.multiply,
                                                        )
                                                      : const ColorFilter.mode(
                                                          Colors.grey,
                                                          BlendMode.saturation,
                                                        ),
                                                  child: FadeInImage(
                                                    placeholder: AssetImage(
                                                      DesignConfig.setPngPath('placeholder_square'),
                                                    ),
                                                    image: NetworkImage(
                                                      productDetailsModel.image!,
                                                    ),
                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                      return Image.asset(
                                                        DesignConfig.setPngPath('placeholder_square'),
                                                      );
                                                    },
                                                    width: width!,
                                                    height: height! / 5.0,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )),
                                            BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
                                                bloc: context.read<FavoriteProductsCubit>(),
                                                builder: (context, favoriteProductState) {
                                                  if (favoriteProductState is FavoriteProductsFetchSuccess) {
                                                    //check if restaurant is favorite or not
                                                    bool isProductFavorite =
                                                        context.read<FavoriteProductsCubit>().isProductFavorite(productDetailsModel.id!);
                                                    return BlocConsumer<UpdateProductFavoriteStatusCubit, UpdateProductFavoriteStatusState>(
                                                      bloc: context.read<UpdateProductFavoriteStatusCubit>(),
                                                      listener: ((context, state) {
                                                        //
                                                        if (state is UpdateProductFavoriteStatusSuccess) {
                                                          //
                                                          if (state.wasFavoriteProductProcess) {
                                                            context.read<FavoriteProductsCubit>().addFavoriteProduct(state.product);
                                                          } else {
                                                            //
                                                            context.read<FavoriteProductsCubit>().removeFavoriteProduct(state.product);
                                                          }
                                                        }
                                                      }),
                                                      builder: (context, state) {
                                                        if (state is UpdateProductFavoriteStatusInProgress) {
                                                          return Container(
                                                              margin: const EdgeInsets.only(right: 10.0),
                                                              height: 15,
                                                              width: 15,
                                                              child: const CircularProgressIndicator(color: ColorsRes.red));
                                                        }
                                                        return InkWell(
                                                            onTap: () {
                                                              //
                                                              if (state is UpdateProductFavoriteStatusInProgress) {
                                                                return;
                                                              }
                                                              if (isProductFavorite) {
                                                                context.read<UpdateProductFavoriteStatusCubit>().unFavoriteProduct(
                                                                    userId: context.read<AuthCubit>().getId(),
                                                                    type: productsKey,
                                                                    product: productDetailsModel);
                                                              } else {
                                                                //
                                                                context.read<UpdateProductFavoriteStatusCubit>().favoriteProduct(
                                                                    userId: context.read<AuthCubit>().getId(),
                                                                    type: productsKey,
                                                                    product: productDetailsModel);
                                                              }
                                                            },
                                                            child: Container(
                                                                height: height! / 27,
                                                                width: width! / 14,
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.only(left: 5.0),
                                                                decoration: DesignConfig.boxDecorationContainerRoundHalf(
                                                                    ColorsRes.lightFont, 15.0, 0.0, 0.0, 5.0),
                                                                child: isProductFavorite
                                                                    ? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                                    : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)));
                                                      },
                                                    );
                                                  }
                                                  //if some how failed to fetch favorite products or still fetching the products
                                                  return const SizedBox();
                                                }),
                                          ],
                                        ),
                                        SizedBox(height: height! / 99.0),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: Text(productDetailsModel.name!,
                                                            textAlign: TextAlign.left,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark, fontSize: 18, fontWeight: FontWeight.w500))),
                                                    SizedBox(width: width! / 50.0),
                                                    productDetailsModel.indicator == "1"
                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                        : productDetailsModel.indicator == "2"
                                                            ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                            : const SizedBox(),
                                                  ],
                                                ),
                                                const SizedBox(height: 2.5),
                                                Text(productDetailsModel.shortDescription!,
                                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                                                const SizedBox(height: 5),
                                                Text(context.read<SystemConfigCubit>().getCurrency() + priceCurrent.toString(),
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(color: ColorsRes.red, fontSize: 14, fontWeight: FontWeight.w700)),
                                                const SizedBox(height: 2.5),
                                                offCurrent.toStringAsFixed(2) == "0.00"
                                                    ? const SizedBox()
                                                    : Row(children: [
                                                        Text(
                                                          context.read<SystemConfigCubit>().getCurrency() +
                                                              productDetailsModel.variants![_currentIndex].price!,
                                                          style: const TextStyle(
                                                              decoration: TextDecoration.lineThrough,
                                                              letterSpacing: 0,
                                                              color: ColorsRes.lightFont,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w600,
                                                              overflow: TextOverflow.ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                        Text(
                                                          "  " + offCurrent.toStringAsFixed(2) + StringsRes.percentSymbol + " " + StringsRes.off,
                                                          style: const TextStyle(
                                                              color: ColorsRes.red,
                                                              fontSize: 12,
                                                              fontWeight: FontWeight.w700,
                                                              overflow: TextOverflow.ellipsis),
                                                          maxLines: 1,
                                                        ),
                                                      ]),
                                                const SizedBox(height: 2.0),
                                              ]),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            bottom: height! / 40.0,
                                            top: height! / 40.0,
                                            left: width! / 25.0,
                                            right: width! / 25.0,
                                          ),
                                          child: Divider(
                                            color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                            height: 0.0,
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(StringsRes.quantity,
                                                  textAlign: TextAlign.left,
                                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                              Row(children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 8.0),
                                                  child: InkWell(
                                                      onTap: qty > 1
                                                          ? () {
                                                              setState(() {
                                                                if (qty <= int.parse(productDetailsModel.minimumOrderQuantity!)) {
                                                                  qty = int.parse(productDetailsModel.quantityStepSize!);
                                                                } else {
                                                                  qty = qty - int.parse(productDetailsModel.quantityStepSize!);
                                                                }
                                                                qtyData[productVariantId!] = qty;
                                                              });
                                                            }
                                                          : null,
                                                      child: const Icon(Icons.remove_circle, color: ColorsRes.lightFont)),
                                                ),
                                                SizedBox(width: width! / 50.0),
                                                Text(qtyData[productVariantId!].toString(),
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w700)),
                                                //Text(qty.toString(), textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w700)),
                                                SizedBox(width: width! / 50.0),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (qty >= int.parse(productDetailsModel.totalAllowedQuantity!)) {
                                                            qty = int.parse(productDetailsModel.totalAllowedQuantity!);
                                                          } else {
                                                            qty = (qty + int.parse(productDetailsModel.quantityStepSize!));
                                                          }
                                                          qtyData[productVariantId!] = qty;
                                                          //productDetailsModel.variants![0].cartCount = (int.parse(productDetailsModel.variants![0].cartCount!) + 1).toString();
                                                        });
                                                      },
                                                      child: const Icon(Icons.add_circle, color: ColorsRes.red)),
                                                ),
                                              ]),
                                            ],
                                          ),
                                        ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  bottom: height! / 40.0,
                                                  top: height! / 40.0,
                                                  left: width! / 25.0,
                                                  right: width! / 25.0,
                                                ),
                                                child: Divider(
                                                  color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                                  height: 0.0,
                                                ),
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Row(
                                                  children: [
                                                    Text(StringsRes.size,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                                    //Text(StringsRes.chose, textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                  //bottom: height! / 40.0,
                                                  top: height! / 60.0,
                                                  left: width! / 25.0,
                                                  right: width! / 25.0,
                                                ),
                                                /*child: Divider(
                                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                              height: 0.0,
                                            ),*/
                                              ),
                                        productDetailsModel.attributes!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: List.generate(productDetailsModel.variants!.length, (index) {
                                                      VariantsModel data = productDetailsModel.variants![index];
                                                      double price = double.parse(data.specialPrice!);
                                                      if (price == 0) {
                                                        price = double.parse(data.price!);
                                                      }

                                                      double off = 0;
                                                      if (data.specialPrice! != "0") {
                                                        off = (double.parse(data.price!) - double.parse(data.specialPrice!)).toDouble();
                                                        off = off * 100 / double.parse(data.price!).toDouble();
                                                      }
                                                      return InkWell(
                                                          onTap: () {},
                                                          child: RadioListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            dense: true,
                                                            visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                            activeColor: ColorsRes.red,
                                                            controlAffinity: ListTileControlAffinity.trailing,
                                                            value: index,
                                                            groupValue: _currentIndex,
                                                            title: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Text(data.variantValues!,
                                                                    textAlign: TextAlign.center,
                                                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                                                const Spacer(),
                                                                Row(
                                                                  children: [
                                                                    Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                                                                        textAlign: TextAlign.center,
                                                                        style: const TextStyle(
                                                                          color: ColorsRes.red,
                                                                          fontSize: 13,
                                                                        )),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                            onChanged: (int? value) {
                                                              _currentIndex = value!;
                                                              productVariantId = productDetailsModel.variants![value].id!;

                                                              if (qtyData.containsKey(productVariantId)) {
                                                                qty = qtyData[productVariantId] ?? 1;
                                                              } else {
                                                                int newQty = 0;
                                                                if (productDetailsModel.variants![value].cartCount != "0") {
                                                                  newQty = int.parse(productDetailsModel.variants![value].cartCount!);
                                                                } else {
                                                                  newQty = int.parse(productDetailsModel.minimumOrderQuantity!);
                                                                }
                                                                qtyData[productVariantId!] = newQty;
                                                                qty = newQty;
                                                              }
                                                              setState(() {});
                                                            },
                                                          ));
                                                    })),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: height! / 40.0, top: height! / 40.0, left: width! / 25.0, right: width! / 25.0),
                                                child: Divider(
                                                  color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                                  height: 0.0,
                                                ),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                                child: Row(
                                                  children: [
                                                    Text(StringsRes.extraAddOn,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w700)),
                                                    //Text(StringsRes.chose2, textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.red, fontSize: 10, fontWeight: FontWeight.w500)),
                                                  ],
                                                ),
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Padding(
                                                padding: EdgeInsets.only(
                                                    /*bottom: height! / 40.0,*/ top: height! / 60.0, left: width! / 25.0, right: width! / 25.0),
                                                /*child: Divider(
                                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                                              height: 0.0,
                                            ),*/
                                              ),
                                        productDetailsModel.productAddOns!.isEmpty
                                            ? Container()
                                            : Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(productDetailsModel.productAddOns!.length, (index) {
                                                  ProductAddOnsModel data = productDetailsModel.productAddOns![index];
                                                  if (productAddOnIds.contains(data.id)) {
                                                    _isChecked[index] = true;
                                                    if (!addOnIds.contains(data.id!)) {
                                                      addOnIds.add(data.id!);
                                                      addOnQty.add("1");
                                                      addOnPrice.add(double.parse(data.price!));
                                                    }
                                                  } else {
                                                    _isChecked[index] = false;
                                                  }
                                                  return InkWell(
                                                      onTap: () {},
                                                      child: Container(
                                                          margin: EdgeInsets.only(
                                                            left: width! / 25.0,
                                                            right: width! / 25.0,
                                                            //bottom: height! / 99.0,
                                                            //top: height! / 99.0,
                                                          ), //padding: EdgeInsets.only(left: width!/25.0, right: width!/25.0),
                                                          //decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                                          child: CheckboxListTile(
                                                              contentPadding: EdgeInsets.zero,
                                                              dense: true,
                                                              visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                                                              activeColor: ColorsRes.red,
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  SizedBox(
                                                                      width: width! / 2.0,
                                                                      child: Text(
                                                                        data.title!,
                                                                        textAlign: TextAlign.start,
                                                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12),
                                                                        maxLines: 2,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      )),
                                                                  const Spacer(),
                                                                  Text(context.read<SystemConfigCubit>().getCurrency() + data.price!,
                                                                      textAlign: TextAlign.center,
                                                                      style: const TextStyle(
                                                                        color: ColorsRes.red,
                                                                        fontSize: 13,
                                                                      )),
                                                                ],
                                                              ),
                                                              value: _isChecked[index],
                                                              onChanged: (val) {
                                                                setState(
                                                                  () {
                                                                    _isChecked[index] = val!;
                                                                    if (_isChecked[index] == false) {
                                                                      addOnIds.removeAt(index);
                                                                      productAddOnIds.remove(data.id);
                                                                      addOnQty.removeAt(index);
                                                                      addOnPrice.removeAt(index);
                                                                    } else {
                                                                      productAddOnIds.add(data.id!);
                                                                      if (!addOnIds.contains(data.id!)) {
                                                                        addOnIds.add(data.id!);
                                                                        addOnQty.add("1");
                                                                        addOnPrice.add(double.parse(data.price!));
                                                                      }
                                                                    }
                                                                  },
                                                                );
                                                              })));
                                                }),
                                              )
                                      ],
                                    ),
                                  ),
                                ),
                                BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                                  return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                                      ? Container(
                                          height: 0.0,
                                        )
                                      : Container(
                                          alignment: Alignment.bottomCenter,
                                          padding: EdgeInsets.only(left: width! / 25.0, right: width! / 25.0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                            Expanded(
                                              child: BlocConsumer<GetCartCubit, GetCartState>(
                                                  bloc: context.read<GetCartCubit>(),
                                                  listener: (context, state) {},
                                                  builder: (context, state) {
                                                    if (state is GetCartProgress || state is GetCartInitial) {
                                                      return BottomCartSimmer(show: false, width: width!, height: height!);
                                                    }
                                                    if (state is GetCartFailure) {
                                                      return const Text(/*state.errorMessage.toString()*/ "", textAlign: TextAlign.center);
                                                    }
                                                    final cartList = (state as GetCartSuccess).cartModel;
                                                    var sum = 0.0;
                                                    for (var i = 0; i < addOnPrice.length; i++) {
                                                      sum += addOnPrice[i];
                                                    }
                                                    double overAllTotal = ((priceCurrent * qtyData[productVariantId!]!) + sum);
                                                    return Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Text("${qtyData[productVariantId!].toString()} ${StringsRes.itemTag}" + " | ",
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                                        Text(context.read<SystemConfigCubit>().getCurrency() + overAllTotal.toStringAsFixed(2),
                                                            textAlign: TextAlign.center,
                                                            maxLines: 1,
                                                            style: const TextStyle(color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                      ],
                                                    );
                                                  }),
                                            ),
                                            Expanded(
                                                child: productDetailsModel.variants![_currentIndex].availability == "1" ||
                                                        productDetailsModel.variants![_currentIndex].availability == ""
                                                    ? BlocConsumer<ManageCartCubit, ManageCartState>(
                                                        bloc: context.read<ManageCartCubit>(),
                                                        listener: (context, state) {
                                                          if (state is ManageCartSuccess) {
                                                            final currentCartModel = context.read<GetCartCubit>().getCartModel();
                                                            context.read<GetCartCubit>().updateCartList(currentCartModel.updateCart(
                                                                state.data,
                                                                state.totalQuantity,
                                                                state.subTotal,
                                                                state.taxPercentage,
                                                                state.taxAmount,
                                                                state.overallAmount));
                                                            Navigator.pop(context);
                                                            UiUtils.setSnackBar(StringsRes.addToCart, StringsRes.updateSuccessFully, context, false);
                                                            // Navigator.pop(context);
                                                          } else if (state is ManageCartFailure) {
                                                            Navigator.pop(context);
                                                            //showMessage = state.errorMessage.toString();
                                                            UiUtils.setSnackBar(StringsRes.addToCart, state.errorMessage, context, false);
                                                          }
                                                        },
                                                        builder: (context, state) {
                                                          return TextButton(
                                                              style: TextButton.styleFrom(
                                                                splashFactory: NoSplash.splashFactory,
                                                              ),
                                                              onPressed: () {
                                                                if (qty == 0) {
                                                                  Navigator.pop(context);
                                                                  UiUtils.setSnackBar(
                                                                      StringsRes.quantity, StringsRes.quantityMessage, context, false);
                                                                } else {
                                                                  context.read<ManageCartCubit>().manageCartUser(
                                                                      userId: context.read<AuthCubit>().getId(),
                                                                      productVariantId: productVariantId,
                                                                      isSavedForLater: "0",
                                                                      qty: qtyData[productVariantId!].toString(),
                                                                      addOnId: addOnIds.isNotEmpty ? addOnIds.join(",").toString() : "",
                                                                      addOnQty: addOnQty.isNotEmpty ? addOnQty.join(",").toString() : "");
                                                                }
                                                              },
                                                              child: Container(
                                                                  width: width,
                                                                  padding: EdgeInsets.only(
                                                                      top: height! / 55.0,
                                                                      bottom: height! / 55.0,
                                                                      left: width! / 20.0,
                                                                      right: width! / 20.0),
                                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                                                  child: Text(StringsRes.addToCart,
                                                                      textAlign: TextAlign.center,
                                                                      maxLines: 1,
                                                                      style: const TextStyle(
                                                                          color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                                        })
                                                    : Container())
                                          ]),
                                          // showMessage==""?Container():Text(showMessage, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.darkFontColor, fontSize: 16, fontWeight: FontWeight.w500))
                                        );
                                }),
                              ],
                            ),
                          ),
                        )),
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
                  ],
                );
              }),
            );
          });
        });
  }

  bottomModelSheetShow() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: DesignConfig.setRoundedBorderCard(20.0, 0.0, 20.0, 0.0),
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (BuildContext context, void Function(void Function()) setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      height: (MediaQuery.of(context).size.height) / 1.14,
                      padding: EdgeInsets.only(top: height! / 15.0),
                      child: Container(
                        decoration: DesignConfig.boxDecorationContainerRoundHalf(ColorsRes.white, 25, 0, 25, 0),
                        child: Container(
                          padding: EdgeInsets.only(left: width! / 15.0, right: width! / 15.0, top: height! / 25.0),
                          child: Column(
                            children: [
                              Expanded(
                                child: BlocProvider<UpdateAddressCubit>(
                                  create: (_) => UpdateAddressCubit(AddressRepository()),
                                  child: Builder(builder: (context) {
                                    return BlocConsumer<AddressCubit, AddressState>(
                                        bloc: context.read<AddressCubit>(),
                                        listener: (context, state) {},
                                        builder: (context, state) {
                                          if (state is AddressProgress || state is AddressInitial) {
                                            return AddressSimmer(width: width!, height: height!);
                                          }
                                          if (state is AddressFailure) {
                                            return Center(
                                                child: Text(
                                              state.errorCode.toString(),
                                              textAlign: TextAlign.center,
                                            ));
                                          }
                                          final addressList = (state as AddressSuccess).addressList;
                                          return ListView.builder(
                                              shrinkWrap: true,
                                              padding: EdgeInsets.zero,
                                              physics: const AlwaysScrollableScrollPhysics(),
                                              itemCount: addressList.length,
                                              scrollDirection: Axis.vertical,
                                              itemBuilder: (BuildContext context, index) {
                                                return BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                                                    bloc: context.read<UpdateAddressCubit>(),
                                                    listener: (context, state) {
                                                      if (state is UpdateAddressSuccess) {
                                                        if (state.addressModel.id! == addressList[index].id!) {
                                                          context.read<AddressCubit>().updateAddress(state.addressModel);
                                                          //context.read<GetCartCubit>().setCartAddress(state.addressModel);
                                                          addressId = state.addressModel.id!;
                                                        }
                                                        //context.read<DeliveryChargeCubit>().fetchDeliveryCharge(context.read<AuthCubit>().getId(), state.addressModel.id!);
                                                        //Navigator.pop(context);
                                                        //print(" User id ${context.read<DeliveryChargeCubit>().getDeliveryCharge()} id is ${state.addressModel.id!}");

                                                        //print("address:${context.read<DeliveryChargeCubit>().fetchDeliveryCharge(context.read<AuthCubit>().getId(), state.addressModel.id!)}");
                                                      } else if (state is UpdateAddressFailure) {
                                                        print(state.errorCode.toString());
                                                      }
                                                    },
                                                    builder: (context, state) {
                                                      return GestureDetector(
                                                        onTap: () {
                                                          //print("${addressList[index].id}${addressList[index].userId}${addressList[index].mobile}${addressList[index].address}${addressList[index].city}${addressList[index].latitude}${addressList[index].longitude}${addressList[index].area}${addressList[index].type}${addressList[index].name}${addressList[index].countryCode}${addressList[index].alternateMobile}${addressList[index].landmark}${addressList[index].pincode}${addressList[index].state}${addressList[index].country}");
                                                          context.read<UpdateAddressCubit>().fetchUpdateAddress(
                                                              addressList[index].id,
                                                              addressList[index].userId,
                                                              addressList[index].mobile,
                                                              addressList[index].address,
                                                              addressList[index].city,
                                                              addressList[index].latitude,
                                                              addressList[index].longitude,
                                                              addressList[index].area,
                                                              addressList[index].type,
                                                              addressList[index].name,
                                                              addressList[index].countryCode,
                                                              addressList[index].alternateMobile,
                                                              addressList[index].landmark,
                                                              addressList[index].pincode,
                                                              addressList[index].state,
                                                              addressList[index].country,
                                                              "1");
                                                        },
                                                        child: Container(
                                                          decoration: addressList[index].isDefault == "1"
                                                              ? DesignConfig.boxDecorationContainerBorder(ColorsRes.red, ColorsRes.redLight, 15)
                                                              : DesignConfig.boxDecorationContainerBorder(ColorsRes.white, ColorsRes.white, 15),
                                                          margin: EdgeInsets.only(bottom: height! / 99.0),
                                                          padding: EdgeInsets.symmetric(vertical: height! / 40.0, horizontal: height! / 40.0),
                                                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                                                            Row(
                                                              children: [
                                                                addressList[index].type == StringsRes.home
                                                                    ? SvgPicture.asset(
                                                                        DesignConfig.setSvgPath("home_address"),
                                                                      )
                                                                    : addressList[index].type == StringsRes.office
                                                                        ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                                                        : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
                                                                SizedBox(width: height! / 99.0),
                                                                Text(
                                                                  addressList[index].type == StringsRes.home
                                                                      ? StringsRes.home
                                                                      : addressList[index].type == StringsRes.office
                                                                          ? StringsRes.office
                                                                          : StringsRes.other,
                                                                  style: const TextStyle(
                                                                      fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                                                )
                                                              ],
                                                            ),
                                                            SizedBox(width: height! / 99.0),
                                                            Row(
                                                              children: [
                                                                SizedBox(width: width! / 11.0),
                                                                Expanded(
                                                                  child: Text(
                                                                    addressList[index].address! +
                                                                        "," +
                                                                        addressList[index].city.toString() +
                                                                        "," +
                                                                        addressList[index].state! +
                                                                        "," +
                                                                        addressList[index].pincode!,
                                                                    style: const TextStyle(
                                                                      fontSize: 14,
                                                                      color: ColorsRes.backgroundDark,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ]),
                                                        ),
                                                      );
                                                    });
                                              });
                                        });
                                  }),
                                ),
                              ),
                              TextButton(
                                  style: TextButton.styleFrom(
                                    splashFactory: NoSplash.splashFactory,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pushNamed(Routes.addAddress, arguments: {'from': ''});
                                  },
                                  child: Container(
                                      margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                      width: width,
                                      padding:
                                          EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                      child: Text(StringsRes.addAddress,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)))),
                            ],
                          ),
                        ),
                      )),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32)),
                ],
              ),
            );
          });
        });
  }

  Widget cartData() {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
          ? cart()
          : BlocConsumer<GetCartCubit, GetCartState>(
              bloc: context.read<GetCartCubit>(),
              listener: (context, state) {},
              builder: (context, state) {
                if (state is GetCartProgress || state is GetCartInitial) {
                  return CartSimmer(width: width!, height: height!);
                }
                if (state is GetCartFailure) {
                  //return Center(child: Text(state.errorMessage.toString(), textAlign: TextAlign.center,));
                  return cart();
                }
                final cartList = (state as GetCartSuccess).cartModel;
                taxPercentage = double.parse(cartList.taxPercentage!);
                taxAmount = double.parse(cartList.taxAmount!);
                subTotal = double.parse(cartList.subTotal!);
                cartModel = cartList;
                isRestaurantOpen = cartList.data![0].productDetails![0].partnerDetails![0].isRestroOpen!;

                return /*Container(height: height!/0.9, color: ColorsRes.white,
            child:*/
                    cartList.totalQuantity == ""
                        ? cart()
                        : Container(
                            margin: EdgeInsets.only(top: height! / 30.0),
                            height: height! / 0.9,
                            decoration: DesignConfig.boxCurveShadow(),
                            width: width,
                            child: Container(
                                padding: EdgeInsets.only(
                                  left: width! / 40.0,
                                  right: width! / 40.0,
                                ),
                                //height: height!/4.7,
                                width: width!,
                                margin: EdgeInsets.only(top: height! / 70.0),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: /*Row(
                                              children: [*/
                                            Text(cartList.data![0].productDetails![0].partnerDetails![0].partnerName!.toString(),
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 18, fontWeight: FontWeight.w500)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 80.0,
                                          bottom: height! / 50.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
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
                                          Text(
                                            StringsRes.deliveryLocation,
                                            style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              bottomModelSheetShow();
                                              //Navigator.of(context).pushNamed(Routes.selectAddress, arguments: false);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(3.0),
                                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                                              child: Text(
                                                StringsRes.change,
                                                style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                                              ),
                                            ),
                                          ),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 80.0,
                                          bottom: height! / 50.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Divider(
                                          color: ColorsRes.lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                      BlocProvider<UpdateAddressCubit>(
                                        create: (_) => UpdateAddressCubit(AddressRepository()),
                                        child: Builder(builder: (context) {
                                          return BlocConsumer<AddressCubit, AddressState>(
                                              bloc: context.read<AddressCubit>(),
                                              listener: (context, state) {},
                                              builder: (context, state) {
                                                if (state is AddressProgress || state is AddressInitial) {
                                                  return AddressSimmer(width: width!, height: height!);
                                                }
                                                if (state is AddressFailure) {
                                                  return Center(
                                                      child: Text(
                                                    state.errorCode.toString(),
                                                    textAlign: TextAlign.center,
                                                  ));
                                                }
                                                final addressList = (state as AddressSuccess).addressList;
                                                return ListView.builder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    physics: const NeverScrollableScrollPhysics(),
                                                    itemCount: addressList.length,
                                                    itemBuilder: (BuildContext context, i) {
                                                      if (addressList[i].isDefault == "1") {
                                                        addressIndex = i;
                                                        selAddress = addressList[addressIndex!].id;
                                                        latitude = double.parse(addressList[addressIndex!].latitude!);
                                                        longitude = double.parse(addressList[addressIndex!].longitude!);
                                                      }
                                                      return addressList[i].isDefault == "0"
                                                          ? Container()
                                                          : Container(
                                                              margin: const EdgeInsets.only(top: 5),
                                                              padding:
                                                                  EdgeInsets.only(bottom: height! / 99.0, left: width! / 40.0, right: width! / 40.0),
                                                              child: Column(children: [
                                                                Row(children: [
                                                                  addressList[i].type == StringsRes.home
                                                                      ? SvgPicture.asset(
                                                                          DesignConfig.setSvgPath("home_address"),
                                                                        )
                                                                      : addressList[i].type == StringsRes.office
                                                                          ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                                                                          : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
                                                                  SizedBox(width: height! / 99.0),
                                                                  Text(
                                                                    addressList[i].type == StringsRes.home
                                                                        ? StringsRes.home
                                                                        : addressList[i].type == StringsRes.office
                                                                            ? StringsRes.office
                                                                            : StringsRes.other,
                                                                    style: const TextStyle(
                                                                        fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                                                                  ),
                                                                ]),
                                                                SizedBox(width: height! / 99.0),
                                                                Row(
                                                                  children: [
                                                                    SizedBox(width: width! / 11.0),
                                                                    Expanded(
                                                                      child: Text(
                                                                        addressList[i].address! +
                                                                            "," +
                                                                            addressList[i].area! +
                                                                            "," +
                                                                            addressList[i].city.toString() +
                                                                            "," +
                                                                            addressList[i].state! +
                                                                            "," +
                                                                            addressList[i].pincode!,
                                                                        style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark),
                                                                        maxLines: 2,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )
                                                              ]),
                                                            );
                                                    });
                                              });
                                        }),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 80.0,
                                          bottom: height! / 50.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Divider(
                                          color: ColorsRes.lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: cartList.data!.length,
                                          itemBuilder: (BuildContext context, i) {
                                            int qty = int.parse(cartList.data![i].qty!);
                                            double price = double.parse(cartList.data![i].specialPrice!);
                                            if (price == 0) {
                                              price = double.parse(cartList.data![i].price!);
                                            }

                                            double off = 0;
                                            if (cartList.data![i].specialPrice! != "0") {
                                              off =
                                                  (double.parse(cartList.data![i].price!) - double.parse(cartList.data![i].specialPrice!)).toDouble();
                                              off = off * 100 / double.parse(cartList.data![i].price!).toDouble();
                                            }
                                            return BlocProvider<RemoveFromCartCubit>(
                                              create: (_) => RemoveFromCartCubit(CartRepository()),
                                              child: Builder(builder: (context) {
                                                return Container(
                                                    padding: EdgeInsets.only(bottom: height! / 99.0),
                                                    //height: height!/4.7,
                                                    width: width!,
                                                    margin: EdgeInsets.only(
                                                      left: width! / 60.0,
                                                      right: width! / 60.0,
                                                    ),
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            cartList.data![i].image!.isEmpty
                                                                ? Expanded(
                                                                    flex: 1,
                                                                    child: ClipRRect(
                                                                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                                        child: SizedBox(
                                                                          width: width! / 5.0,
                                                                          height: height! / 10.0,
                                                                        )))
                                                                : Expanded(
                                                                    flex: 1,
                                                                    child: ClipRRect(
                                                                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                                        child: ColorFiltered(
                                                                          colorFilter:
                                                                              cartList.data![i].productDetails![0].partnerDetails![0].isRestroOpen ==
                                                                                      "1"
                                                                                  ? const ColorFilter.mode(
                                                                                      Colors.transparent,
                                                                                      BlendMode.multiply,
                                                                                    )
                                                                                  : const ColorFilter.mode(
                                                                                      Colors.grey,
                                                                                      BlendMode.saturation,
                                                                                    ),
                                                                          child: FadeInImage(
                                                                            placeholder: AssetImage(
                                                                              DesignConfig.setPngPath('placeholder_square'),
                                                                            ),
                                                                            image: NetworkImage(
                                                                              cartList.data![i].image!,
                                                                            ),
                                                                            imageErrorBuilder: (context, error, stackTrace) {
                                                                              return Image.asset(
                                                                                DesignConfig.setPngPath('placeholder_square'),
                                                                              );
                                                                            },
                                                                            width: width! / 5.0,
                                                                            height: height! / 9.0,
                                                                            fit: BoxFit.cover,
                                                                          ),
                                                                        )),
                                                                  ),
                                                            Expanded(
                                                              flex: 3,
                                                              child: Padding(
                                                                padding: EdgeInsets.only(
                                                                    left: width! / 50.0,
                                                                    //top: height! / 99.0,
                                                                    bottom: height! / 99.0),
                                                                child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Text(
                                                                              cartList.data![i].name!,
                                                                              textAlign: TextAlign.left,
                                                                              style: const TextStyle(
                                                                                  color: ColorsRes.backgroundDark,
                                                                                  fontSize: 14,
                                                                                  fontWeight: FontWeight.w500,
                                                                                  overflow: TextOverflow.ellipsis),
                                                                              maxLines: 1,
                                                                            ),
                                                                          ),
                                                                          BlocConsumer<RemoveFromCartCubit, RemoveFromCartState>(
                                                                              bloc: context.read<RemoveFromCartCubit>(),
                                                                              listener: (context, state) {
                                                                                if (state is RemoveFromCartSuccess) {
                                                                                  UiUtils.setSnackBar(StringsRes.delete,
                                                                                      StringsRes.deleteSuccessFully, context, false);
                                                                                  cartList.data!.removeAt(i);
                                                                                  context
                                                                                      .read<GetCartCubit>()
                                                                                      .getCartUser(userId: context.read<AuthCubit>().getId());
                                                                                  // Navigator.pop(context);
                                                                                } else if (state is RemoveFromCartFailure) {
                                                                                  //showMessage = state.errorMessage.toString();
                                                                                  UiUtils.setSnackBar(
                                                                                      StringsRes.cart, state.errorMessage, context, false);
                                                                                }
                                                                              },
                                                                              builder: (context, state) {
                                                                                return InkWell(
                                                                                  onTap: () {
                                                                                    setState(() {
                                                                                      context.read<RemoveFromCartCubit>().removeFromCart(
                                                                                          userId: context.read<AuthCubit>().getId(),
                                                                                          productVariantId: cartList.data![i].productVariantId);
                                                                                      promoCode = "";
                                                                                      promoAmt = 0;
                                                                                      finalTotal = cartList.overallAmount! + deliveryCharge;
                                                                                      //cartList.data!.removeWhere((element) => element.productVariantId == cartList.data![i].productVariantId);
                                                                                    });
                                                                                  },
                                                                                  child: const Icon(Icons.close, color: ColorsRes.lightFont),
                                                                                );
                                                                              }),
                                                                        ],
                                                                      ),
                                                                      const SizedBox(height: 5.0),
                                                                      Column(
                                                                          children: List.generate(cartList.data![i].productDetails!.length, (j) {
                                                                        ProductDetails productDetail = cartList.data![i].productDetails![j];
                                                                        return Container(
                                                                            //padding: EdgeInsets.only(bottom: height! / 99.0), width: width!,
                                                                            margin: EdgeInsets.only(/*top: height! / 60.0, */ right: width! / 60.0),
                                                                            child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Column(
                                                                                      children: List.generate(
                                                                                          cartList.data![i].productDetails![j].variants!.length, (l) {
                                                                                    VariantsModel variantData =
                                                                                        cartList.data![i].productDetails![j].variants![l];
                                                                                    return (cartList.data![i].productVariantId ==
                                                                                            cartList.data![i].productDetails![j].variants![l].id!)
                                                                                        ? Container(
                                                                                            //padding: EdgeInsets.only(bottom: height! / 99.0), width: width!,
                                                                                            margin: EdgeInsets.only(
                                                                                                /*top: height! / 60.0, */ right: width! / 60.0),
                                                                                            child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      variantData.attrName != ""
                                                                                                          ? Text(
                                                                                                              variantData.attrName!.toString() +
                                                                                                                  " : ",
                                                                                                              textAlign: TextAlign.left,
                                                                                                              style: const TextStyle(
                                                                                                                  color: ColorsRes.lightFont,
                                                                                                                  fontSize: 12,
                                                                                                                  fontWeight: FontWeight.w500))
                                                                                                          : Container(),
                                                                                                      variantData.variantValues != ""
                                                                                                          ? Text(variantData.variantValues! + " ",
                                                                                                              textAlign: TextAlign.left,
                                                                                                              style: const TextStyle(
                                                                                                                color: ColorsRes.lightFont,
                                                                                                                fontSize: 12,
                                                                                                              ))
                                                                                                          : Container(),
                                                                                                      cartList.data![i].productDetails![j]
                                                                                                              .variants![l].addOnsData!.isNotEmpty
                                                                                                          ? Wrap(
                                                                                                              crossAxisAlignment:
                                                                                                                  WrapCrossAlignment.start,
                                                                                                              children: List.generate(
                                                                                                                  cartList
                                                                                                                              .data![i]
                                                                                                                              .productDetails![j]
                                                                                                                              .variants![l]
                                                                                                                              .addOnsData!
                                                                                                                              .length >=
                                                                                                                          10
                                                                                                                      ? 10
                                                                                                                      : cartList
                                                                                                                          .data![i]
                                                                                                                          .productDetails![j]
                                                                                                                          .variants![l]
                                                                                                                          .addOnsData!
                                                                                                                          .length, (m) {
                                                                                                                AddOnsDataModel addOnData =
                                                                                                                    variantData.addOnsData![m];
                                                                                                                return GestureDetector(
                                                                                                                  onTap: () {},
                                                                                                                  child: Text(addOnData.title! + ", ",
                                                                                                                      textAlign: TextAlign.center,
                                                                                                                      style: const TextStyle(
                                                                                                                          color: ColorsRes
                                                                                                                              .lightFontColor,
                                                                                                                          fontSize: 12)),
                                                                                                                );
                                                                                                              }))
                                                                                                          : Container(),
                                                                                                    ],
                                                                                                  ),
                                                                                                  const SizedBox(height: 5.0),
                                                                                                  Row(children: [
                                                                                                    Text(
                                                                                                        context
                                                                                                                .read<SystemConfigCubit>()
                                                                                                                .getCurrency() +
                                                                                                            price.toString(),
                                                                                                        textAlign: TextAlign.center,
                                                                                                        style: const TextStyle(
                                                                                                            color: ColorsRes.red,
                                                                                                            fontSize: 13,
                                                                                                            fontWeight: FontWeight.w700)),
                                                                                                    SizedBox(width: width! / 99.0),
                                                                                                    off.toStringAsFixed(2) == "0.00" ||
                                                                                                            off.toStringAsFixed(2) == "0.0"
                                                                                                        ? const SizedBox()
                                                                                                        : Text(
                                                                                                            context
                                                                                                                    .read<SystemConfigCubit>()
                                                                                                                    .getCurrency() +
                                                                                                                cartList.data![i].price!,
                                                                                                            style: const TextStyle(
                                                                                                                decoration:
                                                                                                                    TextDecoration.lineThrough,
                                                                                                                letterSpacing: 0,
                                                                                                                color: ColorsRes.lightFont,
                                                                                                                fontSize: 12,
                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                overflow: TextOverflow.ellipsis),
                                                                                                            maxLines: 1,
                                                                                                          ),
                                                                                                    off.toStringAsFixed(2) == "0.00"
                                                                                                        ? const SizedBox()
                                                                                                        : const Text(
                                                                                                            "  |  ",
                                                                                                            style: TextStyle(
                                                                                                                color: ColorsRes.backgroundDark,
                                                                                                                fontSize: 12,
                                                                                                                fontWeight: FontWeight.w700,
                                                                                                                overflow: TextOverflow.ellipsis),
                                                                                                            maxLines: 1,
                                                                                                          ),
                                                                                                    off.toStringAsFixed(2) == "0.00"
                                                                                                        ? const SizedBox()
                                                                                                        : Text(
                                                                                                            off.toStringAsFixed(2) +
                                                                                                                StringsRes.percentSymbol +
                                                                                                                " " +
                                                                                                                StringsRes.off,
                                                                                                            style: const TextStyle(
                                                                                                                color: ColorsRes.red,
                                                                                                                fontSize: 12,
                                                                                                                fontWeight: FontWeight.w700,
                                                                                                                overflow: TextOverflow.ellipsis),
                                                                                                            maxLines: 1,
                                                                                                          ),
                                                                                                  ]),
                                                                                                  const SizedBox(height: 5.0),
                                                                                                  InkWell(
                                                                                                    onTap: () {
                                                                                                      setState(() {
                                                                                                        bottomModelSheetShowEdit(
                                                                                                            cartList.data![i].productDetails!, j);
                                                                                                      });
                                                                                                    },
                                                                                                    child: Container(
                                                                                                      width: width! / 8.0,
                                                                                                      padding: const EdgeInsets.all(3.0),
                                                                                                      decoration: DesignConfig.boxDecorationContainer(
                                                                                                          ColorsRes.textFieldBackground, 4.0),
                                                                                                      child: Row(
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            StringsRes.edit,
                                                                                                            style: const TextStyle(
                                                                                                                fontSize: 12, color: ColorsRes.red),
                                                                                                          ),
                                                                                                          const Icon(Icons.keyboard_arrow_down,
                                                                                                              color: ColorsRes.red, size: 10.0),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  //const SizedBox(height: 2.0),
                                                                                                  //SizedBox(height: height! / 60),
                                                                                                ]))
                                                                                        : Container();
                                                                                  })),
                                                                                ]));
                                                                      })),
                                                                    ]),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(
                                                            top: height! / 99.0,
                                                            bottom: height! / 99.0,
                                                            left: width! / 40.0,
                                                            right: width! / 40.0,
                                                          ),
                                                          child: const Divider(color: ColorsRes.lightFont, height: 1.0),
                                                        ),
                                                      ],
                                                    ));
                                              }),
                                            );
                                          } /*)*/),
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (BuildContext context) => const OfferCouponsScreen(),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              setState(() {
                                                promoCode = value['code'];
                                                finalTotal = value['finalAmount'] + deliveryCharge;
                                                promoAmt = value['amount'];
                                              });
                                            }
                                          });
                                        },
                                        child: Padding(
                                          padding:
                                              EdgeInsets.only(top: height! / 70.0, bottom: height! / 70.0, left: width! / 40.0, right: width! / 40.0),
                                          child: Row(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.end, children: [
                                            Text(StringsRes.addCoupon,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.all(3.0),
                                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                                              child: Text(
                                                StringsRes.viewAll,
                                                style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                                              ),
                                            ),
                                          ]),
                                        ),
                                      ),
                                      promoCode != ""
                                          ? Padding(
                                              padding: EdgeInsets.only(top: height! / 70.0, left: width! / 40.0, bottom: 5.0),
                                              child: Row(
                                                children: [
                                                  Text(StringsRes.usedCoupon,
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(
                                                          color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                                  const Spacer(),
                                                  promoAmt == 0
                                                      ? const SizedBox()
                                                      : InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              promoCode = "";
                                                              promoAmt = 0;
                                                              finalTotal = cartList.overallAmount! + deliveryCharge;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets.all(3.0),
                                                            decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                                                            child: Text(
                                                              StringsRes.removeCoupon,
                                                              style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      promoCode != ""
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                left: width! / 40.0,
                                                right: width! / 40.0,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(StringsRes.coupon + promoCode.toString(),
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                                  const Spacer(),
                                                  Text(context.read<SystemConfigCubit>().getCurrency() + promoAmt.toString(),
                                                      textAlign: TextAlign.start,
                                                      style: const TextStyle(color: ColorsRes.green, fontSize: 12, fontWeight: FontWeight.w700)),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 70.0,
                                          bottom: height! / 70.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
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
                                            Text(StringsRes.addMoreFoodInCart,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                            const Spacer(),
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext context) => RestaurantDetailScreen(
                                                      restaurantModel: cartList.data![0].productDetails![0].partnerDetails![0],
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: const Icon(Icons.add_circle, color: ColorsRes.red),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 70.0,
                                          bottom: height! / 70.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
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
                                            Text(StringsRes.tipDeliveryPartner,
                                                textAlign: TextAlign.start,
                                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                            const Spacer(),
                                            deliveryTip == 0
                                                ? const SizedBox()
                                                : InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        selectedIndex = null;
                                                        deliveryTip = 0;
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets.all(3.0),
                                                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                                                      child: Text(
                                                        StringsRes.removeTip,
                                                        style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                                                      ),
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 70.0,
                                          bottom: height! / 70.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Divider(
                                          color: ColorsRes.lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                      deliveryTips(),
                                      addNote(),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: height! / 70.0,
                                          bottom: height! / 70.0,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
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
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.5,
                                          bottom: 4.5,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Row(children: [
                                          Text(StringsRes.chargesAndTaxes,
                                              textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                          const Spacer(),
                                          Text(cartList.taxPercentage! + StringsRes.percentSymbol,
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: ColorsRes.red,
                                                fontSize: 12, /* fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                              )),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.5,
                                          bottom: 4.5,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
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
                                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                          const Spacer(),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + subTotal.toString(),
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                  color: ColorsRes.backgroundDark,
                                                  fontSize: 15,
                                                  //fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.8)),
                                        ]),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          top: 4.5,
                                          bottom: 4.5,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Divider(
                                          color: ColorsRes.lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                      promoAmt != 0
                                          ? Padding(
                                              padding: EdgeInsets.only(
                                                bottom: 4.5,
                                                left: width! / 40.0,
                                                right: width! / 40.0,
                                              ),
                                              child: Row(children: [
                                                Text(StringsRes.coupon + promoCode.toString(),
                                                    textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                                const Spacer(),
                                                Text(" - " + context.read<SystemConfigCubit>().getCurrency() + promoAmt.toString(),
                                                    textAlign: TextAlign.end,
                                                    style: const TextStyle(
                                                      color: ColorsRes.green,
                                                      fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                                    )),
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
                                              textAlign: TextAlign.left, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                          const Spacer(),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + deliveryTip.toString(),
                                              textAlign: TextAlign.end,
                                              style: const TextStyle(
                                                color: ColorsRes.red,
                                                fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                              )),
                                        ]),
                                      ),
                                      BlocConsumer<DeliveryChargeCubit, DeliveryChargeState>(
                                          bloc: context.read<DeliveryChargeCubit>(),
                                          listener: (context, state) {
                                            if (state is DeliveryChargeFailure) {
                                              UiUtils.setSnackBar(StringsRes.address, state.errorCode, context, false);
                                            }
                                            if (state is DeliveryChargeSuccess) {
                                              deliveryCharge = double.parse(state.delivaryCharge.toString());
                                              finalTotal = subTotal + deliveryCharge;
                                            }
                                          },
                                          builder: (context, state) {
                                            //double deliveryCharge = 0;
                                            return Padding(
                                                padding: EdgeInsets.only(
                                                  top: 4.5,
                                                  bottom: 4.5,
                                                  left: width! / 40.0,
                                                  right: width! / 40.0,
                                                ),
                                                child: Column(children: [
                                                  Row(
                                                    children: [
                                                      Text(StringsRes.deliveryFee,
                                                          textAlign: TextAlign.left,
                                                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12)),
                                                      const Spacer(),
                                                      Text(context.read<SystemConfigCubit>().getCurrency() + deliveryCharge.toString(),
                                                          textAlign: TextAlign.end,
                                                          style: const TextStyle(
                                                            color: ColorsRes.red,
                                                            fontSize: 12, /*fontWeight: FontWeight.w700, letterSpacing: 0.8*/
                                                          )),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      top: 4.5,
                                                      bottom: 4.5,
                                                    ),
                                                    child: Divider(
                                                      color: ColorsRes.lightFont.withOpacity(0.50),
                                                      height: 1.0,
                                                    ),
                                                  ),
                                                  Row(children: [
                                                    Text(StringsRes.totalPay,
                                                        textAlign: TextAlign.left,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark, fontSize: 15, fontWeight: FontWeight.w700)),
                                                    const Spacer(),
                                                    Text(context.read<SystemConfigCubit>().getCurrency() + (finalTotal + deliveryTip).toString(),
                                                        textAlign: TextAlign.end,
                                                        style: const TextStyle(
                                                            color: ColorsRes.backgroundDark,
                                                            fontSize: 15,
                                                            fontWeight: FontWeight.w700,
                                                            letterSpacing: 0.8)),
                                                  ]),
                                                ]));
                                          }),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          bottom: 4.5,
                                          left: width! / 40.0,
                                          right: width! / 40.0,
                                        ),
                                        child: Divider(
                                          color: ColorsRes.lightFont.withOpacity(0.50),
                                          height: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            /*}
                  )*/
                            );
              });
    });
  }

  Future<void> refreshList() async {
    UiUtils.clearAll();
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
  }

  Future<bool> navigator() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const MainScreen(),
      ),
    );
    return Future.value(true);
  }

  @override
  void dispose() {
    addNoteController.dispose();
    _scrollBottomBarController.dispose();
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
          : WillPopScope(
              onWillPop: navigator,
              child: Scaffold(
                  backgroundColor: ColorsRes.white,
                  /* appBar: AppBar(leading: InkWell(
                onTap:(){
                  Navigator.pop(context);
                },
                child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.myCart, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),*/
                  bottomNavigationBar: BlocProvider<UpdateAddressCubit>(
                    create: (_) => UpdateAddressCubit(AddressRepository()),
                    child: Builder(builder: (context) {
                      return BlocConsumer<AddressCubit, AddressState>(
                          bloc: context.read<AddressCubit>(),
                          listener: (context, state) {},
                          builder: (context, state) {
                            if (state is AddressProgress || state is AddressInitial) {
                              return CartSimmer(width: width!, height: height!);
                            }
                            if (state is AddressFailure) {
                              return Center(
                                  child: Text(
                                state.errorCode.toString(),
                                textAlign: TextAlign.center,
                              ));
                            }
                            final addressList = (state as AddressSuccess).addressList;
                            return BlocConsumer<GetCartCubit, GetCartState>(
                                bloc: context.read<GetCartCubit>(),
                                listener: (context, state) {
                                  if (state is GetCartSuccess) {
                                    for (int i = 0; i < addressList.length; i++) {
                                      if (addressList[i].isDefault == "1") {
                                        context
                                            .read<DeliveryChargeCubit>()
                                            .fetchDeliveryCharge(context.read<AuthCubit>().getId(), addressList[i].id!);
                                      }
                                    }
                                  }
                                },
                                builder: (context, state) {
                                  if (state is GetCartSuccess) {
                                    return BlocBuilder<DeliveryChargeCubit, DeliveryChargeState>(
                                        bloc: context.read<DeliveryChargeCubit>(),
                                        builder: (context, state) {
                                          if (state is DeliveryChargeProgress) {
                                            return ButtonSimmer(width: width!, height: height!);
                                          }
                                          return TextButton(
                                              style: TextButton.styleFrom(
                                                splashFactory: NoSplash.splashFactory,
                                              ),
                                              onPressed: () {
                                                if (isRestaurantOpen == "1") {
                                                  Navigator.of(context).pushNamed(Routes.payment, arguments: {
                                                    'cartModel': context.read<GetCartCubit>().getCartModel() /*cartModel*/,
                                                    'addNote': addNoteController.text
                                                  });
                                                } else {
                                                  restaurantClose(context);
                                                }
                                              },
                                              child: Container(
                                                  margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                                  width: width,
                                                  padding: EdgeInsets.only(
                                                      top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                                  child: Text(StringsRes.confirmOrder,
                                                      textAlign: TextAlign.center,
                                                      maxLines: 1,
                                                      style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                        });
                                  }
                                  return TextButton(
                                      style: TextButton.styleFrom(
                                        splashFactory: NoSplash.splashFactory,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushAndRemoveUntil(
                                            CupertinoPageRoute(builder: (context) => const MainScreen()), (Route<dynamic> route) => false);
                                      },
                                      child: Container(
                                          margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                          width: width,
                                          padding:
                                              EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                          decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                          child: Text(StringsRes.browseMenu,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                });
                          });
                    }),
                  ),
                  body: SafeArea(
                    child: NestedScrollView(
                      controller: _scrollBottomBarController,
                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                        return <Widget>[
                          SliverAppBar(
                            shadowColor: Colors.transparent,
                            backgroundColor: ColorsRes.white,
                            systemOverlayStyle: SystemUiOverlayStyle.dark,
                            iconTheme: const IconThemeData(
                              color: ColorsRes.black,
                            ),
                            floating: false,
                            pinned: false,
                            centerTitle: true,
                            leading: InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const MainScreen(),
                                    ),
                                  );
                                },
                                child: Padding(
                                    padding: EdgeInsets.only(left: width! / 20.0),
                                    child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                            title: Text(StringsRes.myCart,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ];
                      },
                      body: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red, child: cartData()),
                    ),
                  )),
            ),
    );
  }
}
