import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/rating/cubit/setProductRatingCubit.dart';
import 'package:erestro/features/rating/ratingRepository.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/rating/thank_you_for_review_screen.dart';
import 'package:erestro/utils/uiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/internetConnectivity.dart';

class ProductRatingScreen extends StatefulWidget {
  final String? productId;
  const ProductRatingScreen({Key? key, this.productId}) : super(key: key);

  @override
  _ProductRatingScreenState createState() => _ProductRatingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SetProductRatingCubit>(
              create: (_) => SetProductRatingCubit(RatingRepository()),
              child: ProductRatingScreen(productId: arguments['productId'] as String),
            ));
  }
}

class _ProductRatingScreenState extends State<ProductRatingScreen> {
  double? width, height;
  String? statusRating = "1";
  String? statusRatingImage = "poor";
  String? statusRatingTitle = StringsRes.veryPoor;
  TextEditingController commentController = TextEditingController(text: "");
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  List<File> reviewPhotos = [];

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Widget getImageField() {
    return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
      return Container(
        padding: const EdgeInsetsDirectional.only(start: 20.0, end: 20.0, top: 5),
        height: 100,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(color: ColorsRes.backgroundDark, borderRadius: BorderRadius.circular(50.0)),
                    child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          color: ColorsRes.white,
                          size: 25.0,
                        ),
                        onPressed: () {
                          _reviewImgFromGallery(setModalState);
                        }),
                  ),
                  Text(
                    StringsRes.addPhotos,
                    style: const TextStyle(color: ColorsRes.white, fontSize: 11),
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
              shrinkWrap: true,
              itemCount: reviewPhotos.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, i) {
                return InkWell(
                  child: Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Image.file(
                        reviewPhotos[i],
                        width: 100,
                        height: 100,
                      ),
                      Container(
                          color: ColorsRes.black,
                          child: const Icon(
                            Icons.clear,
                            size: 15,
                          ))
                    ],
                  ),
                  onTap: () {
                    if (mounted) {
                      setModalState(() {
                        reviewPhotos.removeAt(i);
                      });
                    }
                  },
                );
              },
            )),
          ],
        ),
      );
    });
  }

  void _reviewImgFromGallery(StateSetter setModalState) async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      allowMultiple: true,
    );
    if (result != null) {
      reviewPhotos = result.paths.map((path) => File(path!)).toList();
      if (mounted) setModalState(() {});
    } else {
      // User canceled the picker
    }
  }

  Widget rating() {
    return Container(
        margin: EdgeInsets.only(bottom: height! / 99.0, top: height! / 99.0, left: width! / 20.0),
        child: Row(children: [
          Expanded(
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      statusRating = "1";
                      statusRatingTitle = StringsRes.veryPoor;
                      statusRatingImage = "very_poor";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 20.0),
                    width: width,
                    padding: EdgeInsets.only(
                      top: height! / 55.0,
                      bottom: height! / 55.0,
                      right: width! / 40.0,
                      left: width! / 40.0,
                    ),
                    decoration: DesignConfig.boxDecorationContainer(statusRating == "1" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text("1 +",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: statusRating == "1" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ))),
          Expanded(
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      statusRating = "2";
                      statusRatingTitle = StringsRes.poor;
                      statusRatingImage = "poor";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 20.0),
                    width: width,
                    padding: EdgeInsets.only(
                      top: height! / 55.0,
                      bottom: height! / 55.0,
                      right: width! / 40.0,
                      left: width! / 40.0,
                    ),
                    decoration: DesignConfig.boxDecorationContainer(statusRating == "2" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text("2 +",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: statusRating == "2" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ))),
          Expanded(
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      statusRating = "3";
                      statusRatingTitle = StringsRes.average;
                      statusRatingImage = "average";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 20.0),
                    width: width,
                    padding: EdgeInsets.only(
                      top: height! / 55.0,
                      bottom: height! / 55.0,
                      right: width! / 40.0,
                      left: width! / 40.0,
                    ),
                    decoration: DesignConfig.boxDecorationContainer(statusRating == "3" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text("3 +",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: statusRating == "3" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ))),
          Expanded(
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      statusRating = "4";
                      statusRatingTitle = StringsRes.good;
                      statusRatingImage = "good";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 20.0),
                    width: width,
                    padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, right: width! / 40.0, left: width! / 40.0),
                    decoration: DesignConfig.boxDecorationContainer(statusRating == "4" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text("4 +",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: statusRating == "4" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ))),
          Expanded(
              child: InkWell(
                  splashFactory: NoSplash.splashFactory,
                  onTap: () {
                    setState(() {
                      statusRating = "5";
                      statusRatingTitle = StringsRes.excellent;
                      statusRatingImage = "excellent";
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: width! / 20.0),
                    width: width,
                    padding: EdgeInsets.only(
                      top: height! / 55.0,
                      bottom: height! / 55.0,
                      right: width! / 40.0,
                      left: width! / 40.0,
                    ),
                    decoration: DesignConfig.boxDecorationContainer(statusRating == "5" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0),
                    child: Text("5 +",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        style: TextStyle(
                            color: statusRating == "5" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                  ))),
        ]));
  }

  Widget comment() {
    return Container(
      padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
      margin: EdgeInsets.only(top: height! / 40.0, left: width! / 20.0, right: width! / 20.0),
      child: TextField(
        controller: commentController,
        cursorColor: ColorsRes.backgroundDark,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: StringsRes.doYouHaveAnyComments,
          labelStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: const TextStyle(
            color: ColorsRes.backgroundDark,
            fontSize: 12.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        keyboardType: TextInputType.text,
        style: const TextStyle(
          color: ColorsRes.backgroundDark,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : Scaffold(
            backgroundColor: ColorsRes.backgroundDark,
            appBar: AppBar(
                backgroundColor: ColorsRes.backgroundDark,
                shadowColor: Colors.transparent,
                leading: Padding(
                    padding: EdgeInsets.only(left: width! / 20.0),
                    child: FloatingActionButton(
                        backgroundColor: ColorsRes.white,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.arrow_back_ios, color: ColorsRes.red),
                        )))),
            bottomNavigationBar: BlocConsumer<SetProductRatingCubit, SetProductRatingState>(
                bloc: context.read<SetProductRatingCubit>(),
                listener: (context, state) {
                  if (state is SetProductRatingSuccess) {
                    //UiUtils.setSnackBar(StringsRes.rating, StringsRes.updateSuccessFully, context, false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const ThankYouForReviewScreen(),
                      ),
                    );
                  } else if (state is SetProductRatingFailure) {
                    print(state.errorCode.toString());
                  }
                },
                builder: (context, state) {
                  return TextButton(
                      style: TextButton.styleFrom(
                        splashFactory: NoSplash.splashFactory,
                      ),
                      onPressed: () {
                        context
                            .read<SetProductRatingCubit>()
                            .setProductRating(context.read<AuthCubit>().getId(), widget.productId, statusRating, commentController.text);
                        /*
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => const AddAddressScreen(),
                ),
              );*/
                        // Navigator.of(context).pushNamed(Routes.addAddress, arguments: false);
                      },
                      child: Container(
                          margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                          width: width,
                          padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                          decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 100.0),
                          child: Text(StringsRes.done,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                }),
            body: Container(
                alignment: Alignment.topCenter,
                child: SingleChildScrollView(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Text(StringsRes.howWasYour,
                        textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.white, fontSize: 34, fontWeight: FontWeight.w700)),
                    Text(StringsRes.food,
                        textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.red, fontSize: 34, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 9.0),
                    Text(StringsRes.kindlyRateYourExperience,
                        textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 16)),
                    const SizedBox(height: 30.9),
                    Image.asset(DesignConfig.setPngPath(statusRatingImage!)),
                    const SizedBox(height: 30.1),
                    Text(statusRatingTitle!, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.lightFont, fontSize: 16)),
                    const SizedBox(height: 30.9),
                    rating(),
                    comment(),
                    //getImageField(),
                  ]),
                )));
  }
}
