import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:erestro/features/address/cubit/addAddressCubit.dart';
import 'package:erestro/features/address/cubit/addressCubit.dart';
import 'package:erestro/features/auth/cubits/authCubit.dart';
import 'package:erestro/helper/design.dart';
import 'package:erestro/helper/string.dart';
import 'package:erestro/ui/main/main_screen.dart';
import 'package:erestro/ui/settings/no_internet_screen.dart';
import 'package:erestro/ui/address/select_delivery_location_screen.dart';
import 'package:erestro/utils/internetConnectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:erestro/helper/color.dart';

import '../../features/address/addressRepository.dart';

String? latitude = "", longitude = "";

class ChangeLocationScreen extends StatefulWidget {
  final double? latitude, longitude;
  final String? from;

  const ChangeLocationScreen({Key? key, this.latitude, this.longitude, this.from}) : super(key: key);

  @override
  _ChangeLocationScreenState createState() => _ChangeLocationScreenState();
  static Route<ChangeLocationScreen> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
        builder: (_) => BlocProvider<AddAddressCubit>(
              create: (_) => AddAddressCubit(
                AddressRepository(),
              ),
              child: const ChangeLocationScreen(),
            ));
  }
}

class _ChangeLocationScreenState extends State<ChangeLocationScreen> {
  LatLng? latlong = null;
  late CameraPosition _cameraPosition;
  GoogleMapController? _controller;
  TextEditingController locationController = TextEditingController();
  TextEditingController areaRoadApartmentNameController = TextEditingController(text: "");
  TextEditingController cityController = TextEditingController(text: "");
  Set<Marker> _markers = Set();
  double? width, height;
  String? locationStatus = StringsRes.office;
  late Position position;
  String _connectionStatus = 'unKnown';
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  String? states, country, pincode, latitude, longitude, address, city, addressData = "", area;

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
    _cameraPosition = const CameraPosition(target: LatLng(0, 0), zoom: 10.0);
    //getCurrentLocation();
    getUserLocation();
  }

  Widget cityField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: cityController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterCity,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget areaRoadApartmentNameField() {
    return Container(
        padding: EdgeInsets.only(left: width! / 20.0),
        child: TextField(
          controller: areaRoadApartmentNameController,
          cursorColor: ColorsRes.lightFont,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: StringsRes.enterAreaRoadApartmentName,
            labelStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: const TextStyle(
              color: ColorsRes.lightFont,
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.text,
          style: const TextStyle(
            color: ColorsRes.lightFont,
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget locationChange() {
    return Container(
      decoration: DesignConfig.boxDecorationContainerBorder(ColorsRes.white, ColorsRes.white, 15),
      margin: const EdgeInsets.only(bottom: 10.0),
      padding: EdgeInsets.only(left: width! / 20.0, right: width! / 20.0),
      child: Column(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                locationStatus == StringsRes.home
                    ? SvgPicture.asset(
                        DesignConfig.setSvgPath("home_address"),
                      )
                    : locationStatus == StringsRes.office
                        ? SvgPicture.asset(DesignConfig.setSvgPath("work_address"))
                        : SvgPicture.asset(DesignConfig.setSvgPath("other_address")),
                SizedBox(width: height! / 99.0),
                Text(
                  StringsRes.work,
                  style: const TextStyle(fontSize: 14, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) => const SelectDeliveryLocationScreen(from: "login"),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(3.0),
                decoration: DesignConfig.boxDecorationContainer(ColorsRes.textFieldBackground, 4.0),
                child: Text(
                  StringsRes.change,
                  style: const TextStyle(fontSize: 12, color: ColorsRes.red),
                ),
              ),
            ),
          ],
        ),
        SizedBox(width: height! / 99.0),
        Row(
          children: [
            SizedBox(width: width! / 11.0),
            Expanded(
              child: Text(
                addressData!,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorsRes.backgroundDark,
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }

  Widget tagLocation() {
    return Row(children: [
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.home;
            });
          },
          child: Container(
              margin: EdgeInsets.only(left: width! / 15.0, right: width! / 99.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(
                top: height! / 99.0,
                bottom: height! / 99.0,
              ),
              decoration: locationStatus == StringsRes.home
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.home,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.home ? ColorsRes.white : ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)))),
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.office;
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: width! / 99.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0),
              decoration: locationStatus == StringsRes.office
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.work,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.work ? ColorsRes.white : ColorsRes.lightFont, fontSize: 14, fontWeight: FontWeight.w500)))),
      TextButton(
          style: TextButton.styleFrom(
            splashFactory: NoSplash.splashFactory,
          ),
          onPressed: () {
            setState(() {
              locationStatus = StringsRes.other;
            });
          },
          child: Container(
              margin: EdgeInsets.only(right: width! / 40.0, top: height! / 99.0),
              width: width! / 5.0,
              padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 99.0),
              decoration: locationStatus == StringsRes.other
                  ? DesignConfig.boxDecorationContainer(ColorsRes.backgroundDark, 5.0)
                  : DesignConfig.boxDecorationContainerBorder(ColorsRes.lightFont, ColorsRes.white, 5.0),
              child: Text(StringsRes.other,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                      color: locationStatus == StringsRes.other ? ColorsRes.white : ColorsRes.lightFont,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)))),
    ]);
  }

  getUserLocation() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();

      getUserLocation();
    } else if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        await Geolocator.openLocationSettings();

        getUserLocation();
      } else {
        getUserLocation();
      }
    } else {
      position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      print("heading---${position.heading}");

      List<Placemark> placemark = await placemarkFromCoordinates(position.latitude, position.longitude, localeIdentifier: "en");
      // print(placemarks[0]);

      if (mounted) {
        setState(() {
          //latlong = new LatLng(widget.latitude!, widget.longitude!);
          latlong = LatLng(position.latitude, position.longitude);

          _cameraPosition = CameraPosition(target: latlong!, zoom: 15.0, bearing: 0);
          if (_controller != null) {
            _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
          }

          var address1;

          address1 = placemark[0].name;
          address1 = address1 + ", " + placemark[0].subLocality;
          address1 = address1 + ", " + placemark[0].locality;
          address1 = address1 + ", " + placemark[0].administrativeArea;
          address1 = address1 + ", " + placemark[0].country;
          address1 = address1 + ", " + placemark[0].postalCode;

          states = placemark[0].administrativeArea;
          country = placemark[0].country;
          pincode = placemark[0].postalCode;
          latitude = position.latitude.toString();
          longitude = position.longitude.toString();
          address = placemark[0].name;
          city = placemark[0].locality;
          area = placemark[0].subLocality;

          addressData = address1;

          locationController.text = address1;
          _markers.add(Marker(
            markerId: const MarkerId("Marker"),
            //position: LatLng(widget.latitude!, widget.longitude!),
            position: LatLng(position.latitude, position.longitude),
          ));
        });
      }
    }
  }

  @override
  void dispose() {
    _controller!.dispose();
    locationController.dispose();
    areaRoadApartmentNameController.dispose();
    cityController.dispose();
    _connectivitySubscription.cancel();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return _connectionStatus == 'ConnectivityResult.none'
        ? const NoInternetScreen()
        : Scaffold(
            body: Stack(
            children: [
              Column(
                children: <Widget>[
                  Expanded(
                    child: Stack(children: [
                      (latlong != null)
                          ? GoogleMap(
                              initialCameraPosition: _cameraPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller = (controller);
                                _controller!.animateCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                              },
                              markers: this.myMarker(),
                              onTap: (latLng) {
                                if (mounted) {
                                  setState(() {
                                    latlong = latLng;
                                  });
                                }
                              })
                          : Container(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          decoration: DesignConfig.boxCurveShadow(),
                          width: width,
                          child: Container(
                            margin: EdgeInsets.only(top: height! / 30.0),
                            child: SingleChildScrollView(
                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Padding(
                                  padding: EdgeInsets.only(left: width! / 20.0),
                                  child: Text(StringsRes.selectDeliveryLocation,
                                      style: const TextStyle(fontSize: 16.0, color: ColorsRes.backgroundDark, fontWeight: FontWeight.w500)),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: height! / 60.0, bottom: height! / 40.0),
                                  child: Divider(
                                    color: ColorsRes.lightFont,
                                    height: 1.0,
                                    endIndent: width! / 20.0,
                                    indent: width! / 20.0,
                                  ),
                                ),
                                locationChange(),
                                Padding(
                                  padding: EdgeInsets.only(top: height! / 99.0, bottom: height! / 40.0),
                                  child: Divider(
                                    color: ColorsRes.lightFont,
                                    height: 1.0,
                                    endIndent: width! / 20.0,
                                    indent: width! / 20.0,
                                  ),
                                ),
                                areaRoadApartmentNameController.text.isEmpty
                                    ? Padding(
                                        padding: EdgeInsets.only(left: width! / 20.0),
                                        child: Text(StringsRes.areaRoadApartmentName,
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                                      )
                                    : Container(),
                                areaRoadApartmentNameController.text.isEmpty ? areaRoadApartmentNameField() : Container(),
                                Padding(
                                  padding: EdgeInsets.only(bottom: height! / 40.0),
                                  child: Divider(
                                    color: ColorsRes.lightFont,
                                    height: 1.0,
                                    endIndent: width! / 20.0,
                                    indent: width! / 20.0,
                                  ),
                                ),
                                city == ""
                                    ? Padding(
                                        padding: EdgeInsets.only(left: width! / 20.0, top: height! / 60.0),
                                        child: Text(StringsRes.city,
                                            textAlign: TextAlign.start,
                                            maxLines: 2,
                                            style: const TextStyle(color: ColorsRes.backgroundDark, fontSize: 16, fontWeight: FontWeight.w500)),
                                      )
                                    : Container(),
                                city == "" ? cityField() : Container(),
                                Padding(
                                  padding: EdgeInsets.only(bottom: height! / 40.0),
                                  child: Divider(
                                    color: ColorsRes.lightFont,
                                    height: 1.0,
                                    endIndent: width! / 20.0,
                                    indent: width! / 20.0,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: width! / 20.0),
                                  child: Text(StringsRes.tagThisLocationForLater,
                                      style: const TextStyle(fontSize: 14.0, color: ColorsRes.lightFont, fontWeight: FontWeight.w500)),
                                ),
                                tagLocation(),
                                /*TextField(
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2!
                                            .copyWith(color: ColorsRes.backgroundDark),
                                        cursorColor: ColorsRes.backgroundDark,
                                        controller: locationController,
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          icon: Container(
                                            margin: EdgeInsetsDirectional.only(start: width!/20.0, top: 0),
                                            width: 10,
                                            height: 10,
                                            child: const Icon(
                                              Icons.location_on,
                                              color: ColorsRes.red,
                                            ),
                                          ),
                                          hintText: StringsRes.pickup,
                                          border: InputBorder.none,
                                          contentPadding:
                                          const EdgeInsetsDirectional.only(start: 15.0, top: 12.0),
                                        ),
                                      ),*/
                                BlocConsumer<AddAddressCubit, AddAddressState>(
                                    bloc: context.read<AddAddressCubit>(),
                                    listener: (context, state) {
                                      if (state is AddAddressSuccess) {
                                        context.read<AddressCubit>().addAddress(state.addressModel);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) => const MainScreen(),
                                          ),
                                        );
                                      }
                                      if (state is AddAddressFailure) {
                                        print("Error:" + state.errorCode);
                                        //context.read<AddressCubit>().addAddress(state.addressModel);
                                        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) => const MainScreen(),),);
                                      }
                                    },
                                    builder: (context, state) {
                                      return TextButton(
                                          style: TextButton.styleFrom(
                                            splashFactory: NoSplash.splashFactory,
                                          ),
                                          onPressed: () {
                                            context.read<AddAddressCubit>().fetchAddAddress(
                                                  context.read<AuthCubit>().getId(),
                                                  context.read<AuthCubit>().getMobile(),
                                                  address ?? "",
                                                  city == "" ? cityController.text : city,
                                                  latitude ?? "",
                                                  longitude ?? "",
                                                  area ?? "",
                                                  locationStatus,
                                                  context.read<AuthCubit>().getName(),
                                                  context.read<AuthCubit>().getCountryCode(),
                                                  "",
                                                  "",
                                                  pincode ?? "",
                                                  states ?? "",
                                                  country ?? "",
                                                  "1",
                                                );
                                          },
                                          child: Container(
                                              margin: EdgeInsets.only(left: width! / 40.0, right: width! / 40.0, bottom: height! / 55.0),
                                              width: width,
                                              padding: EdgeInsets.only(
                                                  top: height! / 55.0, bottom: height! / 55.0, left: width! / 20.0, right: width! / 20.0),
                                              decoration: DesignConfig.boxDecorationContainer(ColorsRes.red, 10.0),
                                              child: Text(StringsRes.confirmLocation,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  style: const TextStyle(color: ColorsRes.white, fontSize: 16, fontWeight: FontWeight.w500))));
                                    }),
                                /*ElevatedButton(
                  child: Text(StringsRes.updateLocation,
                    style: Theme.of(context)
                          .textTheme
                          .subtitle2!
                          .copyWith(color: ColorsRes.white),
                  ),
                  onPressed: () {
                    //
                    /*if (widget.from == getTranslated(context, 'ADDADDRESS')) {
                      latitude = latlong!.latitude.toString();
                      longitude = latlong!.longitude.toString();
                    }*/

                    /*else if(widget.from==getTranslated(context, 'EDIT_PROFILE_LBL')){
                      lat=latlong!.latitude.toString();
                      long=latlong!.longitude.toString();
                    }*/

                    Navigator.pop(context);
                  },
                ),*/
                              ]),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                              padding: EdgeInsets.only(left: width! / 20.0, top: height! / 20.0),
                              child: SvgPicture.asset(DesignConfig.setSvgPath("back_icon"), width: 32, height: 32))),
                    ]),
                  ),
                ],
              ),
            ],
          ));
  }

  Set<Marker> myMarker() {
    if (_markers != null) {
      _markers.clear();
    }

    _markers.add(Marker(
      markerId: MarkerId(Random().nextInt(10000).toString()),
      position: LatLng(latlong!.latitude, latlong!.longitude),
    ));

    getLocation();

    return _markers;
  }

  Future<void> getLocation() async {
    List<Placemark> placemark = await placemarkFromCoordinates(latlong!.latitude, latlong!.longitude);

    var address1;

    address1 = placemark[0].name;

    address1 = address1 + ", " + placemark[0].subLocality;
    address1 = address1 + ", " + placemark[0].locality;
    address1 = address1 + ", " + placemark[0].administrativeArea;
    address1 = address1 + ", " + placemark[0].country;
    address1 = address1 + ", " + placemark[0].postalCode;
    locationController.text = address1;
    states = placemark[0].administrativeArea;
    country = placemark[0].country;
    pincode = placemark[0].postalCode;
    latitude = position.latitude.toString();
    longitude = position.longitude.toString();
    address = placemark[0].name;
    city = placemark[0].locality;
    area = placemark[0].subLocality;
    addressData = address1;
    locationController.text = address1;

    addressData = address1;
    if (mounted) setState(() {});
  }
}
