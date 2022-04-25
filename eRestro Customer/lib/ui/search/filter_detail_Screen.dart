import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/address/cubit/addAddressCubit.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/cityDeliverableCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/favourite/cubit/favouriteRestaurantCubit.dart';
import 'package:erestro/features/home/search/cubit/filterCubit.dart';
import 'package:erestro/model/search_model.dart';
import 'package:erestro/ui/search/filter_screen.dart';
import 'package:erestro/ui/home/home_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/home/restaurants/restaurant_detail_screen.dart';
import 'package:erestro/ui/widgets/restaurantContainer.dart';
import 'package:erestro/ui/widgets/restaurantNearBySimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/internetConnectivity.dart';

class FilterDetailScreen extends StatefulWidget {
  final String? categoryId, statusFoodType, costStatus;
  const FilterDetailScreen({Key? key, this.categoryId, this.statusFoodType, this.costStatus}) : super(key: key);

  @override
  FilterDetailScreenState createState() => FilterDetailScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<FilterCubit>(
              create: (_) => FilterCubit(),
              child: FilterDetailScreen(
                  categoryId: arguments['categoryId'] as String,
                  statusFoodType: arguments['statusFoodType'] as String,
                  costStatus: arguments['costStatus'] as String),
            ));
  }
}

class FilterDetailScreenState extends State<FilterDetailScreen> {
  TextEditingController searchController = TextEditingController(text: "");
  double? width, height;
  ScrollController controller = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  RegExp regex = RegExp(r'([^\d]00)(?=[^\d]|$)');
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
      context.read<FilterCubit>().fetchFilter(
          perPage,
          widget.categoryId ?? "",
          widget.statusFoodType ?? "",
          widget.costStatus ?? "",
          context.read<AddressCubit>().gerCurrentAddress().latitude,
          context.read<AddressCubit>().gerCurrentAddress().longitude,
          context.read<AuthCubit>().getId(),
          context.read<CityDeliverableCubit>().getCityId());
    });
    super.initState();
  }

  scrollListener() {
    if (controller.position.maxScrollExtent == controller.offset) {
      if (context.read<FilterCubit>().hasMoreData()) {
        context.read<FilterCubit>().fetchMoreFilterData(
            perPage,
            widget.categoryId ?? "",
            widget.statusFoodType ?? "",
            widget.costStatus ?? "",
            context.read<AddressCubit>().gerCurrentAddress().latitude,
            context.read<AddressCubit>().gerCurrentAddress().longitude,
            context.read<AuthCubit>().getId(),
            context.read<CityDeliverableCubit>().getCityId());
      }
    }
  }

  Widget filterDetail() {
    return BlocConsumer<FilterCubit, FilterState>(
        bloc: context.read<FilterCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is FilterProgress || state is FilterInitial) {
            return RestaurantNearBySimmer(length: 5, width: width!, height: height!);
          }
          if (state is FilterFailure) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                SizedBox(height: height! / 20.0),
                Text(StringsRes.noSearchFoundTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 28 /*, fontWeight: FontWeight.w700*/)),
                const SizedBox(height: 5.0),
                Text(StringsRes.noSearchFoundSubTitle,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(color: ColorsRes.lightFont, fontSize: 14 /*, fontWeight: FontWeight.w500*/)),
              ]),
            );
          }
          final filterList = (state as FilterSuccess).filterList;
          final hasMore = state.hasMore;
          return SizedBox(
              height: height! / 1.2,
              /* color: ColorsRes.white,*/
              child: ListView.builder(
                  shrinkWrap: true,
                  controller: controller,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filterList.length,
                  itemBuilder: (BuildContext context, index) {
                    return hasMore && filterList.isEmpty && index == (filterList.length - 1)
                        ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                        : RestaurantContainer(restaurant: filterList[index].partnerDetails![0], height: height!, width: width!);
                  }));
        });
  }

  Widget searchData() {
    return Container(
        height: height! / 25.2,
        margin: EdgeInsets.only(top: height! / 40.0, bottom: height! / 40.0, left: width! / 20.0),
        child: ListView.builder(
            shrinkWrap: true, //padding: EdgeInsets.only(top: height!/40.0),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: searchList.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return Container(
                  padding: EdgeInsets.only(left: width! / 20.0, top: height! / 99.0, right: width! / 20.0, bottom: height! / 99.0),
                  margin: EdgeInsets.only(right: width! / 20.0),
                  decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(searchList[index].title!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 8.0),
                      SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 10, height: 10),
                    ],
                  ));
            }));
  }

  Widget searchBar() {
    return Container(
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 10.0),
      padding: EdgeInsets.only(left: width! / 99.0),
      margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0),
      child: TextField(
        controller: searchController,
        cursorColor: ColorsRes.lightFont,
        textAlignVertical: TextAlignVertical.center,
        enabled: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: InkWell(
              onTap: () {
                Navigator.of(context).pushNamed(Routes.search);
              },
              child: const Icon(Icons.search, color: ColorsRes.lightFont)),
          suffixIcon: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const FilterScreen(),
                  ),
                );
              },
              child: Container(
                  margin: const EdgeInsets.only(right: 4.0, top: 4.0, bottom: 4.0),
                  decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 12.0),
                  child: SvgPicture.asset(DesignConfig.setSvgPath("filter_button"), fit: BoxFit.scaleDown))),
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
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
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
                title: Text(StringsRes.filter,
                    textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                /*bottom: PreferredSize(
                  preferredSize: Size(width!, */ /*height!/5.0*/ /* height! / 50.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      searchBar(),
                      searchData(),
                      /*Padding(
                      padding: EdgeInsets.only(left: width!/20.0, right: width!/20.0),
                      child: Text(restaurantsNearbyList.length.toString() + " " + StringsRes.restaurantsNearby, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12)),
                    )*/
                    ],
                  ),
                ),*/
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  //margin: EdgeInsets.only(right: width!/40.0, left: width!/40.0),
                  child: filterDetail(),
                ),
              ),
            ),
    );
  }
}
