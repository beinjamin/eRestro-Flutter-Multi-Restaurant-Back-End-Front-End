import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/home/cuisine/cubit/cuisineCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/categoryVerticallySimmer.dart';
import 'package:erestro/utils/apiBodyParameterLabels.dart';
import 'package:erestro/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import '../../utils/internetConnectivity.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  FilterScreenState createState() => FilterScreenState();
}

class FilterScreenState extends State<FilterScreen> {
  double? width, height;
  ScrollController cuisineController = ScrollController();
  bool enableList = false;
  int? _selectedIndex;
  String? statusFoodType = "1";
  String? statusRating = "1";
  String? costStatus = "ASC";
  TextEditingController emailController = TextEditingController(text: "");
  TextEditingController subjectController = TextEditingController(text: "");
  TextEditingController messageController = TextEditingController(text: "");
  List<String> ratingList = ["1", "2", "3", "4", "5"];
  List<String> costList = [StringsRes.lowToHigh, StringsRes.highToLow];
  int deliveryTimeIndex = 0;
  late int selectedIndex = 0;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? categoryId;

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
    cuisineController.addListener(cuisineScrollListener);
    Future.delayed(Duration.zero, () {
      context.read<CuisineCubit>().fetchCuisine(perPage, categoryKey);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.initState();
  }

  cuisineScrollListener() {
    if (cuisineController.position.maxScrollExtent == cuisineController.offset) {
      if (context.read<CuisineCubit>().hasMoreData()) {
        context.read<CuisineCubit>().fetchMoreCuisineData(perPage, categoryKey);
      }
    }
  }

  onChanged(int position) {
    setState(() {
      _selectedIndex = position;
      enableList = !enableList;
    });
  }

  onTap() {
    setState(() {
      enableList = !enableList;
    });
  }

  Widget selectType() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return Center(child: CuisineVerticallySimmer(length: 9, width: width!, height: height!));
          }
          if (state is CuisineFailure) {}
          final cuisineList = (state as CuisineSuccess).cuisineList;
          final hasMore = state.hasMore;
          return Container(
            decoration: DesignConfig.boxDecorationContainerCardShadow(ColorsRes.white, ColorsRes.shadow, 10.0, 0.0, 0.0, 10.0, 0.0),
            margin: EdgeInsets.only(top: height! / 99.0),
            child: ListView.builder(
                controller: cuisineController,
                padding: EdgeInsets.only(top: height! / 99.9, bottom: height! / 99.0),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                physics: const BouncingScrollPhysics(),
                itemCount: cuisineList.length,
                itemBuilder: (context, position) {
                  return hasMore && position == (cuisineList.length - 1)
                      ? const Center(child: CircularProgressIndicator(color: ColorsRes.red))
                      : InkWell(
                          onTap: () {
                            onChanged(position);
                            categoryId = cuisineList[position].id!;
                          },
                          child: Container(
                              padding: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, top: height! / 99.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cuisineList[position].name!,
                                    style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: height! / 99.0),
                                    child: Divider(
                                      color: ColorsRes.lightFont.withOpacity(0.50),
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              )),
                        );
                }),
          );
        });
  }

  Widget selectTypeDropdown() {
    return BlocConsumer<CuisineCubit, CuisineState>(
        bloc: context.read<CuisineCubit>(),
        listener: (context, state) {},
        builder: (context, state) {
          if (state is CuisineProgress || state is CuisineInitial) {
            return Center(child: CuisineVerticallySimmer(length: 9, width: width!, height: height!));
          }
          if (state is CuisineFailure) {}
          final cuisineList = (state as CuisineSuccess).cuisineList;
          final hasMore = state.hasMore;
          return InkWell(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.only(bottom: height! / 50.0),
              decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
              padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0, top: height! / 99.0, bottom: height! / 99.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                      child: Text(
                    _selectedIndex != null ? cuisineList[_selectedIndex!].text! : StringsRes.selectCuisine,
                    style: const TextStyle(fontSize: 12.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                  )),
                  Icon(enableList ? Icons.expand_less : Icons.expand_more, size: 24.0, color: ColorsRes.backgroundDark),
                ],
              ),
            ),
          );
        });
  }

  Widget foodType() {
    return Container(
        margin: EdgeInsets.only(bottom: height! / 50.0),
        decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
        child: Row(children: [
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "1";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(
                        left: width! / 70.0,
                        right: width! / 99.0,
                        bottom: height! / 99.0,
                        top: height! / 99.0,
                      ),
                      width: width,
                      padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 99.0, right: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "1" ? ColorsRes.red : ColorsRes.white, 15.0),
                      child: Text(StringsRes.vegetarian,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "1" ? ColorsRes.white : ColorsRes.backgroundDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              flex: 3,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "2";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(bottom: height! / 99.0, top: height! / 99.0, left: width! / 70.0, right: width! / 70.0),
                      width: width,
                      padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 99.0, right: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "2" ? ColorsRes.red : ColorsRes.white, 15.0),
                      child: Text(StringsRes.nonVegetarian,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "2" ? ColorsRes.white : ColorsRes.backgroundDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
          Expanded(
              flex: 2,
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusFoodType = "3";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(bottom: height! / 99.0, top: height! / 99.0, left: width! / 70.0, right: width! / 70.0),
                      width: width,
                      padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 99.0, right: width! / 99.0),
                      decoration: DesignConfig.boxDecorationContainer(statusFoodType == "3" ? ColorsRes.red : ColorsRes.white, 15.0),
                      child: Text(StringsRes.both,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                              color: statusFoodType == "3" ? ColorsRes.white : ColorsRes.backgroundDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w500))))),
        ]));
  }

  Widget rating() {
    return Container(
        margin: EdgeInsets.only(bottom: height! / 99.0, top: height! / 99.0),
        child: Row(children: [
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "1";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: width! / 40.0),
                      width: width,
                      padding: EdgeInsets.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        right: width! / 40.0,
                        left: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "1" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, color: statusRating == "1" ? ColorsRes.white : ColorsRes.red),
                          SizedBox(width: width! / 99.0),
                          Text("1",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "1" ? ColorsRes.white : ColorsRes.backgroundDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "2";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: width! / 40.0),
                      width: width,
                      padding: EdgeInsets.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        right: width! / 40.0,
                        left: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "2" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, color: statusRating == "2" ? ColorsRes.white : ColorsRes.red),
                          SizedBox(width: width! / 99.0),
                          Text("2",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "2" ? ColorsRes.white : ColorsRes.backgroundDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "3";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: width! / 40.0),
                      width: width,
                      padding: EdgeInsets.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        right: width! / 40.0,
                        left: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "3" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, color: statusRating == "3" ? ColorsRes.white : ColorsRes.red),
                          SizedBox(width: width! / 99.0),
                          Text("3",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "3" ? ColorsRes.white : ColorsRes.backgroundDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "4";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: width! / 40.0),
                      width: width,
                      padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, right: width! / 40.0, left: width! / 40.0),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "4" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, color: statusRating == "4" ? ColorsRes.white : ColorsRes.red),
                          SizedBox(width: width! / 99.0),
                          Text("4",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "4" ? ColorsRes.white : ColorsRes.backgroundDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
          Expanded(
              child: InkWell(
                  onTap: () {
                    setState(() {
                      statusRating = "5";
                    });
                  },
                  child: Container(
                      margin: EdgeInsets.only(right: width! / 40.0),
                      width: width,
                      padding: EdgeInsets.only(
                        top: height! / 55.0,
                        bottom: height! / 55.0,
                        right: width! / 40.0,
                        left: width! / 40.0,
                      ),
                      decoration: DesignConfig.boxDecorationContainer(statusRating == "5" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(DesignConfig.setSvgPath("restaurant_rating"),
                              width: 12.1, height: 11.5, color: statusRating == "5" ? ColorsRes.white : ColorsRes.red),
                          SizedBox(width: width! / 99.0),
                          Text("5",
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                  color: statusRating == "5" ? ColorsRes.white : ColorsRes.backgroundDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      )))),
        ]));
  }

  Widget cost() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.5),
      itemCount: costList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int index) {
        return RadioListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: ColorsRes.red,
          controlAffinity: ListTileControlAffinity.leading,
          value: index,
          groupValue: deliveryTimeIndex,
          dense: true,
          visualDensity: VisualDensity.compact,
          title: Text(
            costList[index],
            style: const TextStyle(
              color: ColorsRes.black,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          onChanged: (int? val) {
            setState(() {
              if (val == 0) {
                deliveryTimeIndex = val!; /*gender="Male";*/
                costStatus = "ASC";
              } else if (val == 1) {
                deliveryTimeIndex = val!; /*gender="Female";*/
                costStatus = "DESC";
              }
              deliveryTimeIndex = val!;
            });
          },
        );
      },
    );
  }

  /*Widget deliveryTime() {
    return Container(height: height!/15.0, margin: EdgeInsets.only(top: height!/60.0, bottom: height!/40.0,),
        child: ListView.builder(shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: deliveryTimeList.length,scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, index) {
              return InkWell(onTap:(){
                  setState(() {
                    selectedIndex = index;
                    if(deliveryTimeList[index].like == "1") {
                      deliveryTimeList[index].like = "2";
                    } else{
                      deliveryTimeList[index].like = "1";
                    }
                  });
                  },child: Container(alignment: Alignment.center, margin: EdgeInsets.only(right: width!/30.0), width: width!/4.0, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(selectedIndex == index ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child: Text(deliveryTimeList[index].time!, textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: selectedIndex == index ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                    ));
            }
        ));
  }*/

  @override
  void dispose() {
    cuisineController.dispose();
    emailController.dispose();
    subjectController.dispose();
    messageController.dispose();
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
              ),
              bottomNavigationBar: Row(
                children: [
                  Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                              width: width,
                              padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                              child: Text(StringsRes.clear,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500))))),
                  Expanded(
                      child: TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            Navigator.of(context).pushNamed(Routes.filter,
                                arguments: {'categoryId': categoryId ?? "", 'statusFoodType': statusFoodType ?? "", 'costStatus': costStatus ?? ""});
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                              width: width,
                              padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                              child: Text(StringsRes.letsSearch,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))))),
                ],
              ),
              body: Container(
                margin: EdgeInsets.only(top: height! / 30.0),
                decoration: DesignConfig.boxCurveShadow(),
                width: width,
                child: Container(
                  margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 60.0),
                  child: SingleChildScrollView(
                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(StringsRes.selectRestaurantWith,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 50.0, bottom: height! / 50.0),
                        child: const Divider(
                          color: ColorsRes.lightFont,
                          height: 1.0,
                        ),
                      ),
                      foodType(),
                      Text(StringsRes.selectCuisine,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 50.0, bottom: height! / 50.0),
                        child: const Divider(
                          color: ColorsRes.lightFont,
                          height: 1.0,
                        ),
                      ),
                      selectTypeDropdown(),
                      enableList ? selectType() : Container(),
                      /*Text(StringsRes.rating,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height!/50.0, bottom: height!/99.0),
                        child: const Divider(color: ColorsRes.lightFont, height: 1.0,),
                      ),
                      rating(),*/
                      Text(StringsRes.cost, style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height! / 50.0, bottom: height! / 99.0),
                        child: const Divider(
                          color: ColorsRes.lightFont,
                          height: 1.0,
                        ),
                      ),
                      cost(),
                      /*Text(StringsRes.deliveryTime,
                          style: const TextStyle(fontSize: 14.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                      Padding(
                        padding: EdgeInsets.only(top: height!/50.0),
                        child: const Divider(color: ColorsRes.lightFont, height: 1.0,),
                      ),
                      deliveryTime(),*/
                    ]),
                  ),
                ),
              )),
    );
  }
}
