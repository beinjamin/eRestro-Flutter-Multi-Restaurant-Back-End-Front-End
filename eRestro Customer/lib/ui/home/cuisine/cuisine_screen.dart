import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/home/cuisine/cubit/cuisineCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/cuicineSimmer.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../utils/internetConnectivity.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({Key? key}) : super(key: key);

  @override
  CuisineScreenState createState() => CuisineScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<CuisineCubit>(
              create: (_) => CuisineCubit(),
              child: const CuisineScreen(),
            ));
  }
}

class CuisineScreenState extends State<CuisineScreen> {
  double? width, height;
  ScrollController cuisineController = ScrollController();
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
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
    cuisineController.addListener(cuisineScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<CuisineCubit>().fetchCuisine(perPage, "");
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  cuisineScrollListener() {
    if (cuisineController.position.maxScrollExtent == cuisineController.offset) {
      if (context.read<CuisineCubit>().hasMoreData()) {
        context.read<CuisineCubit>().fetchMoreCuisineData(perPage, "");
      }
    }
  }

  Widget topCuisine() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return Center(child: CuisineSimmer(length: 6, width: width!, height: height!));
          }
          if (state is CuisineFailure) {
            return Center(child: Text(state.errorMessageCode));
          }
          final cuisineList = (state as CuisineSuccess).cuisineList;
          final hasMore = state.hasMore;
          return SizedBox(
            height: height! / 1.2,
            /* color: ColorsRes.white,*/
            child: GridView.count(
              controller: cuisineController,
              physics: const BouncingScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 0.80,
              children: List.generate(cuisineList.length, (index) {
                return hasMore && index == (cuisineList.length - 1)
                    ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                    : GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(Routes.cuisineDetail, arguments: {'categoryId': cuisineList[index].id!, 'name': cuisineList[index].text!});
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: height! / 88.0),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: width! / 3.0,
                                height: height! / 8.88,
                                decoration: DesignConfig.boxDecorationContainer(ColorsRes.offWhite, 15.0),
                                padding: const EdgeInsets.only(top: 14.0, bottom: 14.0),
                                margin: EdgeInsets.only(top: height! / 20.0, right: width! / 20.0),
                                child: Padding(
                                  padding: EdgeInsets.only(top: height! / 30.0),
                                  child: Text(cuisineList[index].name!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                          color: ColorsRes.backgroundDark,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          overflow: TextOverflow.ellipsis),
                                      maxLines: 2),
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.only(right: width! / 20.0),
                                  alignment: Alignment.topCenter,
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: ColorsRes.white,
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: ClipOval(
                                          child: FadeInImage(
                                        placeholder: AssetImage(
                                          DesignConfig.setPngPath('placeholder_square'),
                                        ),
                                        image: NetworkImage(
                                          cuisineList[index].image!,
                                        ),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            DesignConfig.setPngPath('placeholder_square'),
                                          );
                                        },
                                        width: 55.0,
                                        height: 55.0,
                                        fit: BoxFit.cover,
                                      )),
                                    ),
                                  ))
                            ],
                          ),
                        ),
                      );
              }),
            ),
          );
        });
  }

  Future<void> refreshList() async {
    context.read<CuisineCubit>().fetchCuisine(perPage, "");
  }

  @override
  void dispose() {
    cuisineController.dispose();
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
                title: Column(
                  children: [
                    Text(StringsRes.deliciousCuisine,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w700)),
                    Text(StringsRes.discoverAndGetBestFood,
                        textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 12, fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              body: Container(
                  margin: EdgeInsets.only(top: height! / 30.0),
                  decoration: DesignConfig.boxCurveShadow(),
                  width: width,
                  child: Container(
                    margin: EdgeInsets.only(left: width! / 20.0),
                    child: RefreshIndicator(
                        onRefresh: refreshList,
                        color: ColorsRes.red,
                        child: SingleChildScrollView(physics: const AlwaysScrollableScrollPhysics(), child: topCuisine())),
                  )),
            ),
    );
  }
}
