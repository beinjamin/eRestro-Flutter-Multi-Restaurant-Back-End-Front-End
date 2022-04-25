import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteProductsCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteProduct.dart';
import 'package:erestro/features/home/sections/sectionsModel.dart';
import 'package:erestro/features/systemConfig/cubits/systemConfigCubit.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/apiBodyParameterLabels.dart';

class ProductContainer extends StatelessWidget {
  final ProductDetails productDetails;
  final List<ProductDetails>? productDetailsList;
  final double? width, height, price, off;
  const ProductContainer({Key? key, required this.productDetails, this.width, this.height, this.price, this.off, this.productDetailsList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateProductFavoriteStatusCubit>(
      create: (context) => UpdateProductFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return Container(
          alignment: Alignment.topLeft,
          margin: EdgeInsets.only(left: width! / 20.0, top: height! / 80.0),
          child: Stack(
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(25.0)),
                  child: /*Image.network(sectionsList[index].productDetails![i]
                                                  .image!, width: width! / 2.32,
                                              height: height! / 5.0,
                                              fit: BoxFit.cover)*/
                      ColorFiltered(
                    colorFilter: productDetails.partnerDetails![0].isRestroOpen == "1"
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
                        productDetails.image!,
                      ),
                      imageErrorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          DesignConfig.setPngPath('placeholder_square'),
                        );
                      },
                      width: productDetailsList!.length != 1 ? width! / 2.32 : width! / 1.1,
                      height: height! / 5.0,
                      fit: BoxFit.cover,
                    ),
                  )),
              BlocBuilder<FavoriteProductsCubit, FavoriteProductsState>(
                  bloc: context.read<FavoriteProductsCubit>(),
                  builder: (context, favoriteProductState) {
                    if (favoriteProductState is FavoriteProductsFetchSuccess) {
                      //check if restaurant is favorite or not
                      bool isProductFavorite = context.read<FavoriteProductsCubit>().isProductFavorite(productDetails.id!);
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
                                  context
                                      .read<UpdateProductFavoriteStatusCubit>()
                                      .unFavoriteProduct(userId: context.read<AuthCubit>().getId(), type: productsKey, product: productDetails);
                                } else {
                                  //
                                  context
                                      .read<UpdateProductFavoriteStatusCubit>()
                                      .favoriteProduct(userId: context.read<AuthCubit>().getId(), type: productsKey, product: productDetails);
                                }
                              },
                              child: Container(
                                  height: height! / 27,
                                  width: width! / 14,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.only(left: 5.0),
                                  decoration: DesignConfig.boxDecorationContainerRoundHalf(ColorsRes.lightFont, 25.0, 0.0, 0.0, 5.0),
                                  child: isProductFavorite
                                      ? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                      : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)));
                        },
                      );
                    }
                    //if some how failed to fetch favorite products or still fetching the products
                    return const SizedBox();
                  }),
              off!.toStringAsFixed(2) == "0.00"
                  ? const SizedBox()
                  : Positioned(
                      right: 0.0,
                      child: Container(
                        height: height! / 24.0,
                        width: width! / 8.9,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.only(left: width! / 90.0, top: height! / 99.0),
                        decoration: DesignConfig.boxDecorationContainerRoundHalf(ColorsRes.red, 0.0, 5.0, 20.0, 0.0),
                        child: RichText(
                          softWrap: true,
                          text: TextSpan(
                            text: off!.toStringAsFixed(2) + StringsRes.percentSymbol + "\n",
                            style: const TextStyle(color: ColorsRes.white, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 0.72),
                            children: <TextSpan>[
                              TextSpan(text: StringsRes.off, style: const TextStyle(color: ColorsRes.white, fontSize: 11, letterSpacing: 0.88)),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
              Container(
                  padding: EdgeInsets.only(left: width! / 40.0, top: height! / 60.0, right: width! / 40.0),
                  height: height! / 4.3,
                  width: productDetailsList!.length != 1 ? width! / 2.5 : width! / 1.15,
                  margin: EdgeInsets.only(top: height! / 7.5, left: width! / 60.0, right: width! / 60.0),
                  decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowContainer, 25.0, 0.0, 10.0, 16.0, 0.0),
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(productDetails.name!,
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        style: const TextStyle(
                            color: ColorsRes.backgroundDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.72,
                            overflow: TextOverflow.ellipsis)),
                    Padding(
                      padding: EdgeInsets.only(top: height! / 99.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(productDetails.partnerDetails![0].partnerName!,
                                textAlign: TextAlign.start,
                                maxLines: 1,
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis, color: ColorsRes.backgroundDark, fontSize: 11, fontWeight: FontWeight.normal)),
                          ),
                          SizedBox(width: width! / 50.0),
                          productDetails.indicator == "1"
                              ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                              : productDetails.indicator == "2"
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
                    ),
                    Container(
                        margin: EdgeInsets.only(top: height! / 80.0, bottom: height! / 80.0),
                        padding: const EdgeInsets.only(top: 2, bottom: 2, left: 8.9, right: 8.9),
                        decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 5),
                        child: Text(context.read<SystemConfigCubit>().getCurrency() + price.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: ColorsRes.white, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 1.04))),
                    off!.toStringAsFixed(2) == "0.00"
                        ? const SizedBox()
                        : Row(children: [
                            Text(
                              context.read<SystemConfigCubit>().getCurrency() + productDetails.variants![0].price!,
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
                              "  " + off!.toStringAsFixed(2) + StringsRes.percentSymbol + " " + StringsRes.off,
                              style:
                                  const TextStyle(color: ColorsRes.red, fontSize: 12, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                              maxLines: 1,
                            ),
                          ]),
                    const SizedBox(height: 2.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                        const SizedBox(width: 5.0),
                        Text(double.parse(productDetails.rating!).toStringAsFixed(1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600)),
                        SizedBox(width: width! / 60.0),
                        SvgPicture.asset(DesignConfig.setSvgPath("delivery_time"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                        const SizedBox(width: 5.0),
                        Text(
                          productDetails.partnerDetails![0].partnerCookTime!.toString().replaceAll(regex, ''),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                          maxLines: 1,
                        ),
                      ],
                    ),
                    off!.toStringAsFixed(2) == "0.00" ? const Text("") : const SizedBox(),
                    Container(
                      margin: EdgeInsets.only(top: height! / 80.0),
                      padding: const EdgeInsets.all(2.0),
                      decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 39.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Text(
                            StringsRes.addToCart,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: ColorsRes.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                overflow: TextOverflow.ellipsis,
                                letterSpacing: 1.04),
                            maxLines: 2,
                          )),
                          Container(
                              height: 26.1,
                              width: 26.1,
                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 39.0),
                              child: const Icon(Icons.add, color: ColorsRes.white)),
                        ],
                      ),
                    ),
                  ])),
            ],
          ),
        );
      }),
    );
  }
}
