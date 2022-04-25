import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/features/rating/cubit/setRiderRatingCubit.dart';
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
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../utils/internetConnectivity.dart';

class RiderRatingScreen extends StatefulWidget {
  final String? id, riderId, riderName, riderRating, riderImage, riderMobile, riderNoOfRating;
  const RiderRatingScreen(
      {Key? key, this.id, this.riderId, this.riderName, this.riderRating, this.riderImage, this.riderMobile, this.riderNoOfRating})
      : super(key: key);

  @override
  _RiderRatingScreenState createState() => _RiderRatingScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    Map arguments = routeSettings.arguments as Map;
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<SetRiderRatingCubit>(
              create: (_) => SetRiderRatingCubit(RatingRepository()),
              child: RiderRatingScreen(
                  id: arguments['id'] as String,
                  riderId: arguments['riderId'] as String,
                  riderName: arguments['riderName'] as String,
                  riderRating: arguments['riderRating'] as String,
                  riderImage: arguments['riderImage'] as String,
                  riderMobile: arguments['riderMobile'] as String,
                  riderNoOfRating: arguments['riderNoOfRating'] as String),
            ));
  }
}

class _RiderRatingScreenState extends State<RiderRatingScreen> {
  double? width, height;
  String? statusTipDeliveryPartner = "10";
  double? rating = 5.0;
  TextEditingController commentController = TextEditingController(text: "");
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

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
    print("riderData:" +
        widget.id.toString() +
        "" +
        widget.riderId.toString() +
        "" +
        widget.riderImage.toString() +
        "" +
        widget.riderRating.toString() +
        "" +
        widget.riderNoOfRating.toString() +
        "" +
        widget.riderName.toString() +
        "" +
        widget.riderMobile.toString());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  @override
  void dispose() {
    commentController.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Widget comment() {
    return Container(
      padding: EdgeInsets.only(left: width! / 40.0, right: width! / 99.0),
      decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 10.0),
      margin: EdgeInsets.only(top: height! / 40.0),
      child: TextField(
        controller: commentController,
        cursorColor: ColorsRes.backgroundDark,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: StringsRes.writeComment,
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

  /*Widget tipDeliveryPartner(){
    return Container(margin: EdgeInsets.only(bottom: height!/99.0, top: height!/99.0, left: width!/99.0), child: Row(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
      Expanded(child: InkWell(
          onTap:(){
            setState(() {
              statusTipDeliveryPartner = "10";
            });
          },child: Container(margin: EdgeInsets.only(right: width!/20.0), width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(statusTipDeliveryPartner ==  "10" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child:
      Text(context.read<SystemConfigCubit>().getCurrency()+" 10", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: statusTipDeliveryPartner ==  "10" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
      ))),
      Expanded(child: InkWell(
          onTap:(){
            setState(() {
              statusTipDeliveryPartner = "20";
            });
          },child: Container(margin: EdgeInsets.only(right: width!/20.0),width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(statusTipDeliveryPartner ==  "20" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child:
      Text(context.read<SystemConfigCubit>().getCurrency()+" 20", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: statusTipDeliveryPartner ==  "20" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
      ))),
      Expanded(child: InkWell(
          onTap:(){
            setState(() {
              statusTipDeliveryPartner = "30";
            });
          },child: Container(margin: EdgeInsets.only(right: width!/20.0),width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(statusTipDeliveryPartner ==  "30" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child:
      Text(context.read<SystemConfigCubit>().getCurrency()+" 30", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: statusTipDeliveryPartner ==  "30" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
      ))),
      Expanded(child: InkWell(
          onTap:(){
            setState(() {
              statusTipDeliveryPartner = "40";
            });
          },child: Container(margin: EdgeInsets.only(right: width!/20.0),width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0), decoration: DesignConfig.boxDecorationContainer(statusTipDeliveryPartner ==  "40" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child:
      Text(context.read<SystemConfigCubit>().getCurrency()+" 40", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: statusTipDeliveryPartner ==  "40" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
      ))),
      Expanded(child: InkWell(
          onTap:(){
            setState(() {
              statusTipDeliveryPartner = "50";
            });
          },child: Container(margin: EdgeInsets.only(right: width!/20.0),width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0,right: width!/40.0,left: width!/40.0,), decoration: DesignConfig.boxDecorationContainer(statusTipDeliveryPartner ==  "50" ? ColorsRes.red : ColorsRes.textFieldBackground, 10.0), child:
      Text(context.read<SystemConfigCubit>().getCurrency()+" 50", textAlign: TextAlign.center, maxLines: 1, style: TextStyle(color: statusTipDeliveryPartner ==  "50" ? ColorsRes.white : ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
      ))),
    ]));
  }*/

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
                          child: SvgPicture.asset(DesignConfig.setSvgPath("cancel_icon"), width: 32, height: 32))),
                  backgroundColor: ColorsRes.white,
                  shadowColor: ColorsRes.white,
                  elevation: 0,
                  centerTitle: true,
                  title: Text(StringsRes.review,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                ),
                bottomNavigationBar: BlocConsumer<SetRiderRatingCubit, SetRiderRatingState>(
                    bloc: context.read<SetRiderRatingCubit>(),
                    listener: (context, state) {
                      if (state is SetRiderRatingSuccess) {
                        //UiUtils.setSnackBar(StringsRes.rating, StringsRes.updateSuccessFully, context, false);
                        Navigator.of(context).pushAndRemoveUntil(
                            CupertinoPageRoute(builder: (context) => const ThankYouForReviewScreen()), (Route<dynamic> route) => false);
                      } else if (state is SetRiderRatingFailure) {
                        UiUtils.setSnackBar(StringsRes.rating, state.errorCode, context, false);
                      }
                    },
                    builder: (context, state) {
                      if (state is SetRiderRatingFailure) {
                        UiUtils.setSnackBar(StringsRes.rating, state.errorCode, context, false);
                      }
                      return TextButton(
                          style: TextButton.styleFrom(
                            splashFactory: NoSplash.splashFactory,
                          ),
                          onPressed: () {
                            context
                                .read<SetRiderRatingCubit>()
                                .setRiderRating(context.read<AuthCubit>().getId(), widget.riderId, rating.toString(), commentController.text);
                          },
                          child: Container(
                              margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                              width: width,
                              padding: EdgeInsets.only(top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 100.0),
                              child: Text(StringsRes.submit,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                    }),
                body: Container(
                    margin: EdgeInsets.only(top: height! / 30.0),
                    decoration: DesignConfig.boxCurveShadow(),
                    width: width,
                    child: Container(
                      margin: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0, top: height! / 40.0),
                      child: SingleChildScrollView(
                        child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(StringsRes.helpingYourDeliverPartnerByRating,
                              textAlign: TextAlign.start,
                              maxLines: 1,
                              style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                          Padding(
                            padding: EdgeInsets.only(bottom: height! / 40.0, top: height! / 40.0),
                            child: Divider(
                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                              height: 0.0,
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: ClipRRect(
                                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                                      child: /*Image.network(widget.riderImage ?? "", width: width!/5.0, height: height!/8.2, fit: BoxFit.cover)*/
                                          FadeInImage(
                                        placeholder: AssetImage(
                                          DesignConfig.setPngPath('placeholder_square'),
                                        ),
                                        image: NetworkImage(
                                          widget.riderImage ?? "",
                                        ),
                                        imageErrorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            DesignConfig.setPngPath('placeholder_square'),
                                          );
                                        },
                                        width: width! / 5.0,
                                        height: height! / 8.2,
                                        fit: BoxFit.cover,
                                      ))),
                              Expanded(
                                  flex: 5,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: width! / 60.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(widget.riderName ?? "",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12, fontWeight: FontWeight.w500)),
                                        Text(widget.riderId ?? "",
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500)),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: ColorsRes.red, size: 15.0),
                                            Text(widget.riderRating ?? "" + " ( ${widget.riderNoOfRating ?? ""} Review )",
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 10, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                        SizedBox(width: width! / 50.0),
                                        // SvgPicture.asset(DesignConfig.setSvgPath(restaurantList[index].status=="1"?"veg_icon" : "non_veg_icon"), width: 15, height: 15),
                                      ],
                                    ),
                                  )),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: height! / 40.0, top: height! / 40.0),
                            child: Divider(
                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                              height: 0.0,
                            ),
                          ),
                          Center(
                              child: Text(StringsRes.howWasYourDeliveryPartner,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500))),
                          SizedBox(height: height! / 29.9),
                          Center(
                            child: RatingBar.builder(
                              glowColor: ColorsRes.white,
                              initialRating: rating!,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: ColorsRes.red,
                              ),
                              onRatingUpdate: (ratings) {
                                print(ratings);
                                rating = ratings;
                              },
                            ),
                          ),
                          SizedBox(height: height! / 29.9),
                          Center(
                              child: Text(StringsRes.helpUsImproveOurServicesAndYourExperienceByRatingThis,
                                  textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 12))),
                          /*Padding(
                          padding: EdgeInsets.only(bottom: height !/ 40.0, top: height !/40.0),
                          child: Divider(color: ColorsRes.textFieldBorder.withOpacity(0.50),
                            height: 0.0,),
                        ),*/
                          //Text(StringsRes.tipDeliveryPartner, textAlign: TextAlign.center, maxLines: 2, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 14, fontWeight: FontWeight.w500)),
                          //SizedBox(height: height!/75.0),
                          //tipDeliveryPartner(),
                          Padding(
                            padding: EdgeInsets.only(top: height! / 40.0),
                            child: Divider(
                              color: ColorsRes.textFieldBorder.withOpacity(0.50),
                              height: 0.0,
                            ),
                          ),
                          comment(),
                        ]),
                      ),
                    ))));
  }
}
