import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/cityDeliverableCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/home/restaurantsNearBy/cubit/topRestaurantCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/home/restaurants/restaurant_detail_screen.dart';
import 'package:erestro/ui/widgets/topBrandGridSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/internetConnectivity.dart';

class TopBrandScreen extends StatefulWidget {
  const TopBrandScreen({Key? key}) : super(key: key);

  @override
  TopBrandScreenState createState() => TopBrandScreenState();
}

class TopBrandScreenState extends State<TopBrandScreen> {
  double? width, height;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  ScrollController topRestaurantController = ScrollController();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((value) => setState(() {
      _connectionStatus = value;
    }));
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
          CheckInternet.updateConnectionStatus(result).then((value) => setState(() {
            _connectionStatus = value;
          }));
        });
    topRestaurantController.addListener(topRestaurantScrollListener);
    context.read<TopRestaurantCubit>().fetchTopRestaurant(perPage, "1", context.read<CityDeliverableCubit>().getCityId(), context.read<AddressCubit>().gerCurrentAddress().latitude, context.read<AddressCubit>().gerCurrentAddress().longitude, context.read<AuthCubit>().getId(), "");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  topRestaurantScrollListener() {
    if (topRestaurantController.position.maxScrollExtent == topRestaurantController.offset) {
      if (context.read<TopRestaurantCubit>().hasMoreData()) {
        context.read<TopRestaurantCubit>().fetchMoreTopRestaurantData(perPage, "1", context.read<CityDeliverableCubit>().getCityId(), context.read<AddressCubit>().gerCurrentAddress().latitude, context.read<AddressCubit>().gerCurrentAddress().longitude, context.read<AuthCubit>().getId(), "");
      }
    }
  }

  Widget topBrand() {
    return BlocConsumer<TopRestaurantCubit, TopRestaurantState>(
        bloc: context.read<TopRestaurantCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is TopRestaurantProgress ||
              state is TopRestaurantInitial) {
            return TopBrandGridSimmer(width: width!, height: height!, length: 9);
          }
          if (state is TopRestaurantFailure) {
            return Center(child: Text(state.errorMessageCode.toString(), textAlign: TextAlign.center,));
          }
          final topRestaurantList = (state as TopRestaurantSuccess)
              .topRestaurantList;
          final hasMore = state.hasMore;
          return SizedBox(height: height!/1.2,/* color: ColorsRes.white,*/
            child: GridView.count(
                physics: const BouncingScrollPhysics(),
                crossAxisCount: 3,childAspectRatio: 0.80,
        children: List.generate(topRestaurantList.length, (index) {
            return hasMore && index == (topRestaurantList.length - 1)
                ? const Center(
                child: CircularProgressIndicator(
                  color: ColorsRes.red,
                ))
                : InkWell(
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => RestaurantDetailScreen(
                      restaurantModel: topRestaurantList[index],
                      ),
                  ),
                );},
                  child: Container(alignment: Alignment.center, decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.offWhite, ColorsRes.shadowContainer, 15.0, 0, 10, 16, 0),
              padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
              margin: EdgeInsets.only(top: height!/40.0, right: width!/20.0),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /*Expanded(flex: 3, child: Image.network(topRestaurantList[index].partnerProfile!,
                    )),*/
                    Expanded(flex: 3, child: ClipRRect(borderRadius: const BorderRadius.all(Radius.circular(15.0)),child: /*Image.network(topRestaurantList[index].partnerProfile!, width: width!/5.0, height: height!/6.2, fit: BoxFit.cover)*/
                    ColorFiltered(
                      colorFilter: topRestaurantList[index].isRestroOpen == "1"
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
                              topRestaurantList[index].partnerProfile!,
                            ),
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                DesignConfig.setPngPath('placeholder_square'),
                              );
                            },
                            width: width! / 5.0,
                            height: height! / 8.2,
                            fit: BoxFit.cover,
                          ),
                        )),
                        ),
                    Expanded(flex: 1, child: Padding(
                      padding: EdgeInsets.only(top: height!/85.0),
                      child: Text(topRestaurantList[index].partnerName!, maxLines: 1, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.black, fontSize: 12, fontWeight: FontWeight.w500)),
                    )),
                  ],
              ),
            ),
                );
        })),
          );});
  }

  Future<void> refreshList() async{
    context.read<TopRestaurantCubit>().fetchTopRestaurant(perPage, "1", context.read<CityDeliverableCubit>().getCityId(), context.read<AddressCubit>().gerCurrentAddress().latitude, context.read<AddressCubit>().gerCurrentAddress().longitude, context.read<AuthCubit>().getId(), "");
  }


  @override
  void dispose() {
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
          ? const NoInternetScreen() : Scaffold(
        backgroundColor: ColorsRes.white,
        appBar: AppBar(leading: InkWell(
            onTap:(){
              Navigator.pop(context);
            },
            child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.topBrandsNearYou, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
        body: Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Container(margin: EdgeInsets.only(left: width!/20.0),
              child: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red, child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(),child: topBrand())),
            )
        ),
      ),
    );
  }
}
