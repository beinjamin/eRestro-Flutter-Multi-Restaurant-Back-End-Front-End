import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/app/routes.dart';
import 'package:erestro/features/address/addressRepository.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/address/cubit/updateAddressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/widgets/addressSimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:erestro/helper/color.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/internetConnectivity.dart';

class SelectDeliveryLocationScreen extends StatefulWidget {
  final String? from;
  const SelectDeliveryLocationScreen({Key? key, this.from}) : super(key: key);

  @override
  SelectDeliveryLocationScreenState createState() => SelectDeliveryLocationScreenState();
  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => MultiBlocProvider(
          providers: [
            // BlocProvider<AddressCubit>(create: (context) => AddressCubit(AddressRepository(),)),
            BlocProvider<UpdateAddressCubit>(create: (_) => UpdateAddressCubit(AddressRepository())),
          ],
          child: const SelectDeliveryLocationScreen(
          )),
    );
  }
}

class SelectDeliveryLocationScreenState extends State<SelectDeliveryLocationScreen> {
  double? width, height;
  String? address = StringsRes.home;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
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
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  Widget addressData(){
    return BlocConsumer<AddressCubit, AddressState>(
        bloc: context.read<AddressCubit>(),
        listener: (context, state) {
          if(state is AddressSuccess) {
            // context.read<AddressCubit>().addAddress();
          }
        },
        builder: (context, state) {
          if (state is AddressProgress ||
              state is AddressInitial) {
            return AddressSimmer(width: width!, height: height!);
          }
          if (state is AddressFailure) {
            return Center(child: Text(state.errorCode.toString(), textAlign: TextAlign.center,));
          }
          final addressList = (state as AddressSuccess)
              .addressList;
          return ListView.builder(shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: addressList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, index) {
                return BlocProvider<UpdateAddressCubit>(create: (_) => UpdateAddressCubit(AddressRepository()),
                  child: Builder(
                      builder: (context) {
                        return BlocConsumer<UpdateAddressCubit, UpdateAddressState>(
                            bloc: context.read<UpdateAddressCubit>(),
                            listener: (context, state) {
                              //print(state.toString());
                              if(state is UpdateAddressSuccess) {
                                context.read<AddressCubit>().updateAddress(state.addressModel);

                                Navigator.pop(context);
                                // Navigator.pop(context);
                              }
                              else if(state is UpdateAddressFailure){
                                print(state.errorCode.toString());
                              }
                            },
                            builder: (context, state) {
                              return GestureDetector(
                                onTap: () {
                                  context.read<UpdateAddressCubit>()
                                      .fetchUpdateAddress(
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
                                  decoration: addressList[index]
                                      .isDefault == "1"
                                      ? DesignConfig
                                      .boxDecorationContainerBorder(
                                      ColorsRes.red,
                                      ColorsRes.redLight, 15)
                                      : DesignConfig
                                      .boxDecorationContainerBorder(
                                      ColorsRes.white,
                                      ColorsRes.white, 15),
                                  margin: EdgeInsets.only(
                                      bottom: height! / 99.0),
                                  padding: EdgeInsets.symmetric(
                                      vertical: height! / 40.0,
                                      horizontal: height! / 40.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            addressList[index].type ==
                                                StringsRes.home
                                                ? SvgPicture.asset(
                                              DesignConfig.setSvgPath(
                                                  "home_address"),)
                                                :
                                            addressList[index].type ==
                                                StringsRes.office
                                                ? SvgPicture.asset(
                                                DesignConfig
                                                    .setSvgPath(
                                                    "work_address"))
                                                :
                                            SvgPicture.asset(
                                                DesignConfig
                                                    .setSvgPath(
                                                    "other_address")),
                                            SizedBox(width: height! /
                                                99.0),
                                            Text(addressList[index]
                                                .type ==
                                                StringsRes.home
                                                ? StringsRes.home
                                                : addressList[index]
                                                .type ==
                                                StringsRes.office
                                                ? StringsRes.office
                                                : StringsRes.other,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorsRes
                                                      .backgroundDark,
                                                  fontWeight: FontWeight
                                                      .w500),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                            width: height! / 99.0),
                                        Row(
                                          children: [
                                            SizedBox(
                                                width: width! / 11.0),
                                            Expanded(
                                              child: Text(
                                                addressList[index]
                                                    .address! + "," +addressList[index]
                                                    .area! + "," +
                                                    addressList[index]
                                                        .city.toString() + "," +
                                                    addressList[index]
                                                        .state! +
                                                    "," +
                                                    addressList[index]
                                                        .pincode!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorsRes
                                                      .backgroundDark,),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ]
                                  ),
                                ),
                              );
                            });
                      }
                  ),
                );
              }
          );
        });
  }

  Future<void> refreshList() async{
    context.read<AddressCubit>().fetchAddress(context.read<AuthCubit>().getId());
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
              child: Padding(padding: EdgeInsets.only(left: width!/20.0), child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))), backgroundColor: ColorsRes.white, shadowColor: ColorsRes.white,elevation: 0, centerTitle: true, title: Text(StringsRes.selectDeliveryLocation, textAlign: TextAlign.center, style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),),
          bottomNavigationBar: TextButton(
              style: TextButton.styleFrom(
                splashFactory: NoSplash.splashFactory,
              ),onPressed:(){
                if(widget.from!=null) {
                      Navigator.of(context).pushNamed(Routes.addAddress, arguments: {'from': widget.from!});
                }else{
                Navigator.of(context).pushNamed(Routes.addAddress, arguments: {'from': ""});
              }
                },child: Container(margin: EdgeInsets.only(left: width!/40.0, right: width!/40.0, bottom: height!/55.0), width: width, padding: EdgeInsets.only(top: height!/55.0, bottom: height!/55.0, left: width!/20.0, right: width!/20.0), decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0), child: Text(StringsRes.addAddress, textAlign: TextAlign.center, maxLines: 1, style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500)))),

          body:  Container(margin: EdgeInsets.only(top: height!/30.0), decoration: DesignConfig.boxCurveShadow(), width: width,
            child: Container(margin: EdgeInsets.only(left: width!/20.0, right: width!/20.0, top: height!/40.0),
              child: RefreshIndicator(onRefresh: refreshList, color: ColorsRes.red,child: addressData())
            ),
          )
      ),
    );
  }
}
