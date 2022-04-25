import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/address/cubit/cityDeliverableCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/cart/cubits/getCartCubit.dart';
import 'package:erestro/features/cart/cubits/manageCartCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteProductsCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteRestaurantCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteProduct.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteRestaurant.dart';
import 'package:erestro/features/home/productAddOnsModel.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/restaurantCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/features/home/variantsModel.dart';
import 'package:erestro/features/product/cubit/productCubit.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/cart/cart_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/bottomCartSimmer.dart';
import 'package:erestro/ui/widgets/restaurantDetailSimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:vertical_scrollable_tabview/vertical_scrollable_tabview.dart';
import '../../../features/address/cubit/addressCubit.dart';
import '../../../utils/constants.dart';
import '../../../utils/internetConnectivity.dart';

class RestaurantDetailScreen extends StatefulWidget {
  RestaurantModel? restaurantModel;
  RestaurantDetailScreen({Key? key, this.restaurantModel}) : super(key: key);

  @override
  RestaurantDetailScreenState createState() => RestaurantDetailScreenState();
}

class RestaurantDetailScreenState extends State<RestaurantDetailScreen> with TickerProviderStateMixin {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  late var isVisible = false;
  double? expandHeight;
  TabController? tabController;
  int selectedIndex = 0;
  Map<String, List<ProductDetails>> datalist = {};
  ScrollController controllerProduct = ScrollController();
  String currcateid = "";
  late ProductDetails currproductlist;
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

    context.read<ProductCubit>().getProduct(
        partnerId: widget.restaurantModel!.partnerId!,
        latitude: context.read<AddressCubit>().gerCurrentAddress().latitude,
        longitude: context.read<AddressCubit>().gerCurrentAddress().longitude,
        userId: context.read<AuthCubit>().getId(),
        cityId: context.read<AddressCubit>().gerCurrentAddress().cityId);
    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());
    context.read<RestaurantCubit>().fetchRestaurant(
        perPage,
        "",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<AddressCubit>().gerCurrentAddress().latitude,
        context.read<AddressCubit>().gerCurrentAddress().longitude,
        context.read<AuthCubit>().getId(),
        "");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Future restaurantClose(BuildContext context, String? hours, String? minute) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          //shape: DesignConfig.setRoundedBorder(ColorsRes.white, 25.0, false),
          //title: Text('Not in stock'),
          content: Text(StringsRes.openingIn + " " + hours! + " " + StringsRes.hours + " and " + minute! + " " + StringsRes.minute,
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

  Future restaurantCloseSimple(BuildContext context) {
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

  Widget searchBar() {
    return Container(
        decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 10.0),
        padding: EdgeInsets.only(left: width! / 99.0),
        margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 40.0, bottom: height! / 20.0),
        child: TextField(
          controller: searchController,
          cursorColor: ColorsRes.lightFont,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: ColorsRes.lightFont),
            hintText: StringsRes.searchTitle,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
            ),
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

  @override
  void dispose() {
    searchController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  bottomModelSheetShow(List<ProductDetails> productList, int index) {
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
                                                              height: height! / 27,
                                                              width: width! / 14,
                                                              padding: const EdgeInsets.all(8.0),
                                                              decoration: DesignConfig.boxDecorationContainerRoundHalf(
                                                                  ColorsRes.lightFont, 15.0, 0.0, 0.0, 5.0),
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

  Future<void> refreshList() async {
    context.read<ProductCubit>().getProduct(
        partnerId: widget.restaurantModel!.partnerId!,
        latitude: context.read<AddressCubit>().gerCurrentAddress().latitude,
        longitude: context.read<AddressCubit>().gerCurrentAddress().longitude,
        userId: context.read<AuthCubit>().getId(),
        cityId: context.read<AddressCubit>().gerCurrentAddress().cityId);

    context.read<GetCartCubit>().getCartUser(userId: context.read<AuthCubit>().getId());

    context.read<RestaurantCubit>().fetchRestaurant(
        perPage,
        "",
        context.read<CityDeliverableCubit>().getCityId(),
        context.read<AddressCubit>().gerCurrentAddress().latitude,
        context.read<AddressCubit>().gerCurrentAddress().longitude,
        context.read<AuthCubit>().getId(),
        "");
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    expandHeight = height! / 2.5;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
      ),
      child: _connectionStatus == 'ConnectivityResult.none'
          ? const NoInternetScreen()
          : Scaffold(
              backgroundColor: ColorsRes.white,
              bottomNavigationBar: BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
                return (context.read<AuthCubit>().state is AuthInitial || context.read<AuthCubit>().state is Unauthenticated)
                    ? Container(
                        height: 0.0,
                      )
                    : BlocConsumer<GetCartCubit, GetCartState>(
                        bloc: context.read<GetCartCubit>(),
                        listener: (context, state) {},
                        builder: (context, state) {
                          if (state is GetCartProgress || state is GetCartInitial) {
                            return BottomCartSimmer(width: width!, height: height!);
                          }
                          if (state is GetCartFailure) {
                            return const Text(
                              /*state.errorMessage.toString()*/ "",
                              textAlign: TextAlign.center,
                            );
                          }
                          final cartList = (state as GetCartSuccess).cartModel;
                          return cartList.data!.isEmpty
                              ? Container()
                              : Container(
                                  margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 40.0),
                                  width: width,
                                  padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                                  child: Row(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text("${cartList.totalQuantity} ${StringsRes.itemTag} | ",
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: ColorsRes.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                          Text(context.read<SystemConfigCubit>().getCurrency() + cartList.overallAmount.toString(),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: ColorsRes.white, fontSize: 13, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () {
                                            UiUtils.clearAll();
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (BuildContext context) => const CartScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(StringsRes.viewCart,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))),
                                    ],
                                  ),
                                );
                        });
              }),
              body: RefreshIndicator(
                onRefresh: refreshList,
                color: ColorsRes.red,
                child: BlocConsumer<ProductCubit, ProductState>(
                    bloc: context.read<ProductCubit>(),
                    listener: (context, state) {
                      if (state is ProductSuccess) {
                        tabController = TabController(length: state.productModel.categories!.length, vsync: this);
                        tabController!.addListener(() {
                          setState(() {
                            selectedIndex = tabController!.index;
                          });
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is ProductProgress || state is ProductInitial) {
                        return RestaurantDetailSimmer(width: width!, height: height!);
                      }
                      if (state is ProductFailure) {
                        return Center(
                            child: Text(
                          state.errorMessage.toString(),
                          textAlign: TextAlign.center,
                        ));
                      }
                      final productList = (state as ProductSuccess).productModel;
                      datalist = {};
                      List<ProductDetails> maindata = productList.data!;
                      for (ProductDetails data in maindata) {
                        List<ProductDetails> list = [];
                        if (datalist.containsKey(data.categoryId)) {
                          list = datalist[data.categoryId]!;
                        }

                        list.add(data);
                        datalist[data.categoryId!] = list;
                      }

                      // final hasMore = state.hasMore;
                      return VerticalScrollableTabView(
                        tabController: tabController!,
                        listItemData: productList.categories!,
                        verticalScrollPosition: VerticalScrollPosition.begin,
                        eachItemChild: (object, index) {
                          currcateid = productList.categories![index].id!;
                          //List<ProductModel> data = datalist[currcateid]!;
                          //print("id: "+currcateid.toString());

                          List<ProductDetails> dataMainList = datalist[productList.categories![index].id]!;
                          //return itemTypeData(itemTypeList: /*object as*/ productList.data!,categoryList:productList.categories!,index:index ,datalist:[]);

                          return Container(
                              decoration:
                                  DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowContainer, 15.0, 0, 3, 16, 0),
                              // padding: EdgeInsets.only(left: width!/40.0, right: width!/40.0, bottom: height!/99.0),
                              //height: height!/4.7,
                              width: width!,
                              margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 50.0),
                              child: Theme(
                                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                                  child: ExpansionTile(
                                    childrenPadding: EdgeInsets.zero,
                                    iconColor: ColorsRes.lightFont,
                                    collapsedIconColor: ColorsRes.lightFont,
                                    tilePadding: EdgeInsets.only(left: width! / 25.0, right: width! / 35.0),
                                    initiallyExpanded: true,
                                    children: [
                                      ListView.builder(
                                          shrinkWrap: true,
                                          padding: EdgeInsets.zero,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: dataMainList.length,
                                          itemBuilder: (BuildContext context, i) {
                                            ProductDetails dataItem = dataMainList[i];
                                            double price = double.parse(dataItem.variants![0].specialPrice!);
                                            if (price == 0) {
                                              price = double.parse(dataItem.variants![0].price!);
                                            }
                                            double off = 0;
                                            if (dataItem.variants![0].specialPrice! != "0") {
                                              off = (double.parse(dataItem.variants![0].price!) - double.parse(dataItem.variants![0].specialPrice!))
                                                  .toDouble();
                                              off = off * 100 / double.parse(dataItem.variants![0].price!).toDouble();
                                            }
                                            return InkWell(
                                              onTap: () {
                                                if (dataItem.partnerDetails![0].isRestroOpen == "1") {
                                                  bottomModelSheetShow(dataMainList, i);
                                                } else {
                                                  restaurantCloseSimple(context);
                                                }
                                              },
                                              child: Container(
                                                  // padding: EdgeInsets.only(bottom: height!/99.0),
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
                                                          Expanded(
                                                            flex: 1,
                                                            child: ClipRRect(
                                                                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                                                child: /*Image.network(dataItem.image!, width: width!/5.0, height: height!/10.0, fit: BoxFit.cover)*/
                                                                    ColorFiltered(
                                                                  colorFilter: dataItem.partnerDetails![0].isRestroOpen == "1"
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
                                                                      dataItem.image!,
                                                                    ),
                                                                    imageErrorBuilder: (context, error, stackTrace) {
                                                                      return Image.asset(
                                                                        DesignConfig.setPngPath('placeholder_square'),
                                                                      );
                                                                    },
                                                                    width: width! / 5.0,
                                                                    height: height! / 10.0,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                )),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets.only(left: width! / 50.0, top: height! / 99.0, bottom: height! / 99.0),
                                                              child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  children: [
                                                                    Text(dataItem.name!,
                                                                        textAlign: TextAlign.left,
                                                                        style: const TextStyle(
                                                                            color: ColorsRes.backgroundDark,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.w500,
                                                                            overflow: TextOverflow.ellipsis),
                                                                        maxLines: 1),
                                                                    //const SizedBox(height: 5.0),
                                                                    //Text(itemTypeList.itemList![i].description!, textAlign: TextAlign.start, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10)),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.end,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                                                                                textAlign: TextAlign.center,
                                                                                style: const TextStyle(
                                                                                    color: ColorsRes.red, fontSize: 13, fontWeight: FontWeight.w700)),
                                                                            SizedBox(width: width! / 99.0),
                                                                            off.toStringAsFixed(2) == "0.00"
                                                                                ? const SizedBox()
                                                                                : Text(
                                                                                    context.read<SystemConfigCubit>().getCurrency() +
                                                                                        dataItem.variants![0].price! +
                                                                                        "",
                                                                                    style: const TextStyle(
                                                                                        decoration: TextDecoration.lineThrough,
                                                                                        letterSpacing: 0,
                                                                                        color: ColorsRes.lightFont,
                                                                                        fontSize: 12,
                                                                                        fontWeight: FontWeight.w600,
                                                                                        overflow: TextOverflow.ellipsis),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                          ],
                                                                        ),
                                                                        const Spacer(),
                                                                        Row(children: [
                                                                          (int.parse(dataItem.variants![0].cartCount!) != 1)
                                                                              ? Container()
                                                                              : InkWell(
                                                                                  onTap: () {
                                                                                    if (int.parse(dataItem.variants![0].cartCount!) != 1) {
                                                                                      setState(() {
                                                                                        /*dataItem.variants![0].cartCount =
                                                                                            (int.parse(dataItem.variants![0].cartCount!) - 1)
                                                                                                .toString();*/
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  child: const Icon(Icons.remove_circle, color: ColorsRes.lightFont)),
                                                                          SizedBox(width: width! / 50.0),
                                                                          (int.parse(dataItem.variants![0].cartCount!) != 1)
                                                                              ? Container()
                                                                              : Text(dataItem.variants![0].cartCount!,
                                                                                  textAlign: TextAlign.center,
                                                                                  style: const TextStyle(
                                                                                      color: ColorsRes.backgroundDark,
                                                                                      fontSize: 12,
                                                                                      fontWeight: FontWeight.w700)),
                                                                          SizedBox(width: width! / 50.0),
                                                                          Column(
                                                                            children: [
                                                                              dataItem.partnerDetails![0].isRestroOpen == "1"
                                                                                  ? InkWell(
                                                                                      onTap: () {
                                                                                        setState(() {
                                                                                          /*dataItem.variants![0].cartCount =
                                                                                              (int.parse(dataItem.variants![0].cartCount!) + 1)
                                                                                                  .toString();*/
                                                                                          bottomModelSheetShow(dataMainList, i);
                                                                                        });
                                                                                      },
                                                                                      child: const Icon(Icons.add_circle, color: ColorsRes.red))
                                                                                  : InkWell(
                                                                                      onTap: () {
                                                                                        if (dataItem.partnerDetails![0].partnerWorkingTime != null) {
                                                                                          DateTime now = DateTime.now();
                                                                                          var format = DateFormat("HH:mm");
                                                                                          var one = format.parse(
                                                                                              "${now.hour.toString()}:${now.minute.toString()}");
                                                                                          var two = format.parse(dataItem.partnerDetails![0]
                                                                                              .partnerWorkingTime![i].closingTime!);
                                                                                          var ans = two.difference(one);
                                                                                          var finalAns = format.parse(ans.toString());
                                                                                          //print('${ans.inHours} Hourse ${ans.inMinutes.round()} Minutes');
                                                                                          //print("Time:${two.difference(one)}"+ now.weekday.toString()); // prints 7:40
                                                                                          DateTime check = finalAns;
                                                                                          //print("Time2:${check.hour} Hourse ${check.minute}");
                                                                                          for (int i = 0;
                                                                                              i <
                                                                                                  dataItem
                                                                                                      .partnerDetails![0].partnerWorkingTime!.length;
                                                                                              i++) {
                                                                                            //print(dataItem.partnerDetails![0].partnerWorkingTime![i].day);
                                                                                            if (DateFormat('EEEE').format(now).toString() ==
                                                                                                dataItem
                                                                                                    .partnerDetails![0].partnerWorkingTime![i].day) {
                                                                                              restaurantClose(context, check.hour.toString(),
                                                                                                  check.minute.toString());
                                                                                            }
                                                                                          }
                                                                                        } else {
                                                                                          restaurantCloseSimple(context);
                                                                                        }
                                                                                      },
                                                                                      child: Icon(Icons.add_circle,
                                                                                          color: ColorsRes.black.withOpacity(0.50))),
                                                                            ],
                                                                          ),
                                                                        ]),
                                                                      ],
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: height! / 80.0),
                                                                      child: Row(
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                        children: [
                                                                          dataItem.indicator == "1"
                                                                              ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"),
                                                                                  width: 15, height: 15)
                                                                              : dataItem.indicator == "2"
                                                                                  ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"),
                                                                                      width: 15, height: 15)
                                                                                  : const SizedBox(),
                                                                          SizedBox(width: width! / 99.0),
                                                                          off.toStringAsFixed(2) == "0.00"
                                                                              ? const SizedBox()
                                                                              : Container(
                                                                                  /*margin: EdgeInsets.only(
                                                                      top: height! / 80.0,),*/
                                                                                  padding:
                                                                                      const EdgeInsets.only(top: 2, bottom: 2, left: 8.9, right: 8.9),
                                                                                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 5),
                                                                                  child: Text(
                                                                                      off.toStringAsFixed(2) +
                                                                                          StringsRes.percentSymbol +
                                                                                          " " +
                                                                                          StringsRes.off,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: const TextStyle(
                                                                                          color: ColorsRes.white,
                                                                                          fontSize: 13,
                                                                                          fontWeight: FontWeight.w700,
                                                                                          letterSpacing: 1.04))),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0),
                                                        child: Divider(color: ColorsRes.lightFont.withOpacity(0.50), height: 1.0),
                                                      ),
                                                    ],
                                                  )),
                                            );
                                          })
                                    ],
                                    title: Text(productList.categories![index].name!,
                                        textAlign: TextAlign.start,
                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                  )
                                  /*));
              }*/
                                  ));
                        },
                        slivers: [
                          SliverLayoutBuilder(builder: (context, constraints) {
                            return SliverAppBar(
                              shadowColor: Colors.transparent,
                              backgroundColor: ColorsRes.white,
                              systemOverlayStyle: SystemUiOverlayStyle.dark,
                              iconTheme: const IconThemeData(
                                color: ColorsRes.black,
                              ),
                              floating: false,
                              pinned: true,
                              //automaticallyImplyLeading: _isVisible,
                              leading: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Card(
                                    color: ColorsRes.red,
                                    margin: const EdgeInsets.only(left: 14, bottom: 11.0, top: 11.0),
                                    shape: DesignConfig.setRoundedBorder(ColorsRes.red, 50, false),
                                    child: const Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Icon(
                                        Icons.keyboard_arrow_left,
                                        color: ColorsRes.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              flexibleSpace: FlexibleSpaceBar(
                                centerTitle: false,
                                //titlePadding: const EdgeInsets.only(bottom: 50),
                                title: constraints.scrollOffset >= 350
                                    ? Text(widget.restaurantModel!.partnerName!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700))
                                    : const SizedBox(),
                                collapseMode: CollapseMode.pin,
                                background: Padding(
                                  padding: const EdgeInsets.only(top: 0),
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(25.0),
                                          bottomRight: Radius.circular(25.0),
                                        ),
                                        child: ShaderMask(
                                            shaderCallback: (Rect bounds) {
                                              return LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [ColorsRes.backgroundDark.withOpacity(0.25), ColorsRes.backgroundDark.withOpacity(0.25)],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.darken,
                                            child: ColorFiltered(
                                              colorFilter: maindata[0].partnerDetails![0].isRestroOpen == "1"
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
                                                  widget.restaurantModel!.partnerProfile!,
                                                ),
                                                imageErrorBuilder: (context, error, stackTrace) {
                                                  return Image.asset(
                                                    DesignConfig.setPngPath('placeholder_square'),
                                                  );
                                                },
                                                height: height! / 3.2,
                                                width: double.maxFinite,
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                      ),
                                      Container(
                                        height: height! / 5.9,
                                        width: width,
                                        margin: EdgeInsets.only(left: width! / 15.0, right: width! / 15.0, top: height! / 4.1),
                                        padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0, top: 10.0),
                                        decoration: DesignConfig.boxDecorationContainerCardShadow(
                                            ColorsRes.white, ColorsRes.shadowContainer, 25.0, 0, 10, 16, 0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(widget.restaurantModel!.partnerName!,
                                                          textAlign: TextAlign.center,
                                                          style: const TextStyle(
                                                              color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
                                                      SizedBox(width: width! / 50.0),
                                                      widget.restaurantModel!.partnerIndicator == "1"
                                                          ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                                          : widget.restaurantModel!.partnerIndicator == "2"
                                                              ? SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15)
                                                              : Row(
                                                                  children: [
                                                                    SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15),
                                                                    const SizedBox(width: 2.0),
                                                                    SvgPicture.asset(DesignConfig.setSvgPath("non_veg_icon"), width: 15, height: 15),
                                                                  ],
                                                                ),
                                                    ],
                                                  ),
                                                  const Spacer(),
                                                  BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
                                                    create: (context) => UpdateRestaurantFavoriteStatusCubit(),
                                                    child: Builder(builder: (context) {
                                                      return BlocBuilder<FavoriteRestaurantsCubit, FavoriteRestaurantsState>(
                                                          bloc: context.read<FavoriteRestaurantsCubit>(),
                                                          builder: (context, favoriteRestaurantState) {
                                                            if (favoriteRestaurantState is FavoriteRestaurantsFetchSuccess) {
                                                              //check if restaurant is favorite or not
                                                              bool isRestaurantFavorite = context
                                                                  .read<FavoriteRestaurantsCubit>()
                                                                  .isRestaurantFavorite(widget.restaurantModel!.partnerId!);
                                                              return BlocConsumer<UpdateRestaurantFavoriteStatusCubit,
                                                                  UpdateRestaurantFavoriteStatusState>(
                                                                bloc: context.read<UpdateRestaurantFavoriteStatusCubit>(),
                                                                listener: ((context, state) {
                                                                  //
                                                                  if (state is UpdateRestaurantFavoriteStatusSuccess) {
                                                                    //
                                                                    if (state.wasFavoriteRestaurantProcess) {
                                                                      context
                                                                          .read<FavoriteRestaurantsCubit>()
                                                                          .addFavoriteRestaurant(state.restaurant);
                                                                    } else {
                                                                      //
                                                                      context
                                                                          .read<FavoriteRestaurantsCubit>()
                                                                          .removeFavoriteRestaurant(state.restaurant);
                                                                    }
                                                                  }
                                                                }),
                                                                builder: (context, state) {
                                                                  if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                                    return Container(
                                                                        margin: const EdgeInsets.only(right: 10.0),
                                                                        height: 30.0,
                                                                        width: 30.0,
                                                                        padding: const EdgeInsets.all(8.0),
                                                                        decoration: DesignConfig.boxDecorationContainer(
                                                                            ColorsRes.lightFont.withOpacity(0.50), 15.0),
                                                                        child: const CircularProgressIndicator(
                                                                          color: ColorsRes.red,
                                                                        ));
                                                                  }
                                                                  return Container(
                                                                    alignment: Alignment.center,
                                                                    height: 30.0,
                                                                    width: 30.0,
                                                                    decoration: DesignConfig.boxDecorationContainer(
                                                                        ColorsRes.lightFont.withOpacity(0.50), 15.0),
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          //
                                                                          if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                                            return;
                                                                          }
                                                                          if (isRestaurantFavorite) {
                                                                            context.read<UpdateRestaurantFavoriteStatusCubit>().unFavoriteRestaurant(
                                                                                userId: context.read<AuthCubit>().getId(),
                                                                                type: partnersKey,
                                                                                restaurant: widget.restaurantModel!);
                                                                          } else {
                                                                            //
                                                                            context.read<UpdateRestaurantFavoriteStatusCubit>().favoriteRestaurant(
                                                                                userId: context.read<AuthCubit>().getId(),
                                                                                type: partnersKey,
                                                                                restaurant: widget.restaurantModel!);
                                                                          }
                                                                        },
                                                                        child: isRestaurantFavorite
                                                                            ? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                                            : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)),
                                                                  );
                                                                },
                                                              );
                                                            }
                                                            //if some how failed to fetch favorite restaurants or still fetching the restaurants
                                                            return const SizedBox();
                                                          });
                                                    }),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 3.0),
                                                child: Text(
                                                  widget.restaurantModel!.tags!.join(', ').toString(),
                                                  textAlign: TextAlign.start,
                                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(top: 5.0),
                                                child: RichText(
                                                  text: TextSpan(
                                                    text: widget.restaurantModel!.partnerAddress!,
                                                    style: const TextStyle(color: ColorsRes.lightFont, fontSize: 10),
                                                    children: <TextSpan>[
                                                      TextSpan(
                                                          text: " - " + widget.restaurantModel!.distance!.toString(),
                                                          style: const TextStyle(
                                                              color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w700)),
                                                    ],
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(top: height! / 69.0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                                                            fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                        const SizedBox(width: 5.0),
                                                        Text(double.parse(widget.restaurantModel!.partnerRating!).toStringAsFixed(1),
                                                            textAlign: TextAlign.center,
                                                            style: const TextStyle(
                                                                color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600)),
                                                      ],
                                                    ),
                                                    /*SizedBox(width: width!/60.0),
                                              Row(mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  SvgPicture.asset(DesignConfig.setSvgPath("money_icon"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                  const SizedBox(width: 3.0),
                                                  Text(widget.time!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis), maxLines: 2,),
                                                ],
                                              ),*/
                                                    SizedBox(width: width! / 10.0),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        SvgPicture.asset(DesignConfig.setSvgPath("delivery_time"),
                                                            fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                                        const SizedBox(width: 5.0),
                                                        Text(
                                                          widget.restaurantModel!.partnerCookTime!.replaceAll(regex, ''),
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
                                              ),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              expandedHeight: expandHeight,
                            );
                          }),
                          SliverPersistentHeader(
                            floating: false,
                            delegate: SliverAppBarDelegate(
                              TabBar(
                                indicatorWeight: 2.0,
                                onTap: (int val) {
                                  VerticalScrollableTabBarStatus.setIndex(val);
                                },
                                physics: const AlwaysScrollableScrollPhysics(),
                                isScrollable: true,
                                labelColor: ColorsRes.white,
                                unselectedLabelColor: ColorsRes.backgroundDark,
                                indicatorColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                controller: tabController,
                                indicator: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                tabs: productList.categories!
                                    .map((t) => Tab(
                                          text: t.name,
                                        ))
                                    .toList(),
                              ),
                            ),
                            pinned: true,
                          ),
                        ],
                      );
                    }),
              ),
            ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0, bottom: 8.0),
      color: ColorsRes.offWhite,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class Delegate extends SliverPersistentHeaderDelegate {
  Delegate({
    required this.child,
    this.minHeight = 56.0,
    this.maxHeight = 56.0,
  });

  final Widget child;
  final double minHeight;
  final double maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(Delegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}
