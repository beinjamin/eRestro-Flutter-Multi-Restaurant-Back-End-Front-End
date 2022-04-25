import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteRestaurantCubit.dart';
import 'package:erestro/features/favourite/cubit/updateFavouriteRestaurant.dart';
import 'package:erestro/features/home/restaurantsNearBy/restaurantModel.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/ui/home/restaurants/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/apiBodyParameterLabels.dart';

class RestaurantContainer extends StatelessWidget {
  final RestaurantModel restaurant;
  final double? width, height;
  const RestaurantContainer({Key? key, required this.restaurant, this.width, this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
    return BlocProvider<UpdateRestaurantFavoriteStatusCubit>(
      create: (context) => UpdateRestaurantFavoriteStatusCubit(),
      child: Builder(builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => RestaurantDetailScreen(
                  restaurantModel: restaurant,
                ),
              ),
            );
          },
          child: Container(
              padding: EdgeInsets.only(left: width! / 40.0, top: height! / 99.0, right: width! / 40.0, bottom: height! / 99.0),
              //height: height!/4.7,
              width: width!,
              margin: EdgeInsets.only(top: height! / 52.0, left: width! / 24.0, right: width! / 24.0),
              decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadowBottomBar, 15.0, 0.0, 0.0, 10.0, 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                        child: /*Image.network(restaurantList[index].restaurantProfile!, width: width!/5.0, height: height!/8.2, fit: BoxFit.cover)*/
                            ColorFiltered(
                          colorFilter: restaurant.isRestroOpen == "1"
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
                              restaurant.partnerProfile!,
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
                    flex: 6,
                    child: Padding(
                      padding: EdgeInsets.only(left: width! / 60.0),
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(restaurant.partnerName!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                                SizedBox(width: width! / 50.0),
                                restaurant.partnerIndicator == "1"
                                    ? SvgPicture.asset(DesignConfig.setSvgPath("veg_icon"), width: 15, height: 15)
                                    : restaurant.partnerIndicator == "2"
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
                            BlocBuilder<FavoriteRestaurantsCubit, FavoriteRestaurantsState>(
                                bloc: context.read<FavoriteRestaurantsCubit>(),
                                builder: (context, favoriteRestaurantState) {
                                  if (favoriteRestaurantState is FavoriteRestaurantsFetchSuccess) {
                                    //check if restaurant is favorite or not
                                    bool isRestaurantFavorite = context.read<FavoriteRestaurantsCubit>().isRestaurantFavorite(restaurant.partnerId!);
                                    return BlocConsumer<UpdateRestaurantFavoriteStatusCubit, UpdateRestaurantFavoriteStatusState>(
                                      bloc: context.read<UpdateRestaurantFavoriteStatusCubit>(),
                                      listener: ((context, state) {
                                        //
                                        if (state is UpdateRestaurantFavoriteStatusSuccess) {
                                          //
                                          if (state.wasFavoriteRestaurantProcess) {
                                            context.read<FavoriteRestaurantsCubit>().addFavoriteRestaurant(state.restaurant);
                                          } else {
                                            //
                                            context.read<FavoriteRestaurantsCubit>().removeFavoriteRestaurant(state.restaurant);
                                          }
                                        }
                                      }),
                                      builder: (context, state) {
                                        if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                          return Container(
                                              margin: const EdgeInsets.only(right: 10.0),
                                              height: 15,
                                              width: 15,
                                              child: const CircularProgressIndicator(color: ColorsRes.red));
                                        }
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: InkWell(
                                              onTap: () {
                                                //
                                                if (state is UpdateRestaurantFavoriteStatusInProgress) {
                                                  return;
                                                }
                                                if (isRestaurantFavorite) {
                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().unFavoriteRestaurant(
                                                      userId: context.read<AuthCubit>().getId(), type: partnersKey, restaurant: restaurant);
                                                } else {
                                                  //
                                                  context.read<UpdateRestaurantFavoriteStatusCubit>().favoriteRestaurant(
                                                      userId: context.read<AuthCubit>().getId(), type: partnersKey, restaurant: restaurant);
                                                }
                                              },
                                              child: isRestaurantFavorite
                                                  ? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                  : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)
                                              /*? const Icon(Icons.favorite, size: 18, color: ColorsRes.red)
                                                  : const Icon(Icons.favorite_border, size: 18, color: ColorsRes.red)*/
                                              ),
                                        );
                                      },
                                    );
                                  }
                                  //if some how failed to fetch favorite restaurants or still fetching the restaurants
                                  return const SizedBox();
                                })
                          ],
                        ),
                        //SizedBox(height: height! / 99.0),
                        Text(restaurant.tags!.join(', '),
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                                color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.normal, overflow: TextOverflow.ellipsis),
                            maxLines: 1),
                        SizedBox(height: height! / 99.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                const SizedBox(width: 5.0),
                                Text(double.parse(restaurant.partnerRating!).toStringAsFixed(1),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            SizedBox(width: width! / 60.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SvgPicture.asset(DesignConfig.setSvgPath("delivery_time"), fit: BoxFit.scaleDown, width: 7.0, height: 12.3),
                                const SizedBox(width: 5.0),
                                Text(
                                  restaurant.partnerCookTime!.toString().replaceAll(regex, ''),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w600, overflow: TextOverflow.ellipsis),
                                  maxLines: 2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),
                ],
              )),
        );
      }),
    );
  }
}
